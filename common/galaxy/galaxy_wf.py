#!/usr/bin/env python3
"""Check and update the Galaxy flavour (<wf>/galaxy/*.ga) against the BioBB Galaxy server.

The .ga workflows run on https://biobb.usegalaxy.es (INB), where the biobb tools are
installed as local tools (ids such as biobb_io_pdb_ext, no ToolShed repository). The
server keeps ONE version of each tool, the latest, so a workflow is runnable only if
every tool it uses exists there; a step whose tool_version is older than the server's
makes Galaxy warn and upgrade the step on import.

Subcommands (no account needed; anonymous read-only API calls):
  check  [WF ...]   every tool of every step exists on the server; lists version
                    differences in both directions:
                      "server newer"  the .ga can be updated (`update`)
                      "server behind" the SERVER needs the newer tool (ask its admins);
                                      never fixed by downgrading the .ga
                    Exit 1 if a tool is missing (the workflow cannot run), 0 otherwise.
                    --strict: also exit 1 when the server is behind.
  update [WF ...]   raise each step's tool_version (and the version inside a ToolShed
                    tool_id/content_id) to the server's version when the server's is
                    NEWER; never downgrades. Writes the .ga back with
                    the same layout (4-space JSON). Galaxy's own upgrade of the step's
                    parameters happens when the workflow is imported on the server; the
                    run test (tests/galaxy/run_test.sh with GALAXY_API_KEY) checks that.

  run WF [--timeout MIN]
                    needs env GALAXY_API_KEY (an account on the server): imports the .ga,
                    runs it in a new history (the BioBB workflows fetch their own inputs,
                    no upload needed), waits until every job finishes, then deletes the
                    workflow and purges the history. Exit 1 if any job fails or on timeout.
                    Steps whose newer server tool has parameters the .ga lacks are
                    reported (warning) and run with the tools' defaults
                    (allow_tool_state_corrections).

  --server URL     default https://biobb.usegalaxy.es   (env GALAXY_URL overrides)

Stdlib only.
"""
import argparse
import glob
import json
import os
import sys
import urllib.error
import urllib.parse
import urllib.request

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
UA = {"User-Agent": "biobb-workflows-galaxy-check"}
_cache = {}


def tool_info(server, tool_id):
    """{'version': ..., 'versions': [...]} or None if the server does not have it."""
    if tool_id in _cache:
        return _cache[tool_id]
    url = f"{server}/api/tools/{urllib.parse.quote(tool_id, safe='')}"
    try:
        with urllib.request.urlopen(urllib.request.Request(url, headers=UA), timeout=60) as r:
            d = json.loads(r.read().decode())
            info = {"version": d.get("version"), "versions": d.get("versions") or [d.get("version")]}
    except urllib.error.HTTPError as e:
        if e.code in (400, 404):
            info = None
        else:
            raise
    _cache[tool_id] = info
    return info


def base_id(tool_id):
    """ToolShed ids end with /<version>; the server lists them without it."""
    if "/repos/" in tool_id:
        return tool_id.rsplit("/", 1)[0]
    return tool_id


def ga_files(wfs):
    wfs = wfs or sorted(d for d in os.listdir(ROOT) if d.startswith("biobb_wf_"))
    out = []
    for wf in wfs:
        out += sorted(glob.glob(os.path.join(ROOT, wf, "galaxy", "*.ga")))
    return out


def tool_steps(ga):
    return [s for s in ga["steps"].values() if s.get("type") == "tool"]


def vtuple(v):
    import re
    return tuple(int(x) for x in re.findall(r"\d+", str(v or "0")))


def lookup(server, step):
    tid = step["tool_id"]
    info = tool_info(server, tid)
    if info is None and "/repos/" in tid:
        info = tool_info(server, base_id(tid))
    return info


def cmd_check(args):
    missing_total, drift_total = 0, 0
    for f in ga_files(args.wf):
        ga = json.load(open(f))
        missing, newer, behind = [], {}, {}
        for s in tool_steps(ga):
            info = lookup(args.server, s)
            if info is None:
                missing.append(s["tool_id"])
            elif s.get("tool_version") not in info["versions"]:
                pair = (s.get("tool_version"), info["version"])
                (newer if vtuple(pair[1]) > vtuple(pair[0]) else behind)[s["tool_id"]] = pair
        rel = os.path.relpath(f, ROOT)
        status = "MISSING TOOLS" if missing else ("server behind" if behind else ("can update" if newer else "ok"))
        print(f"{status:14} {rel}: {len(tool_steps(ga))} tool steps, {len(set(missing))} missing, "
              f"{len(newer)} server newer, {len(behind)} server behind")
        for t in sorted(set(missing)):
            print(f"::error::{rel}: tool {t} is not installed on {args.server}")
        for t, (a, b) in sorted(newer.items()):
            print(f"    server newer   {t}: workflow {a} -> server {b}")
        for t, (a, b) in sorted(behind.items()):
            print(f"    server behind  {t}: workflow {a}, server only has {b}")
        missing_total += len(set(missing))
        drift_total += len(behind)
    print(f"\n{missing_total} missing tool(s), {drift_total} step(s) where the server is behind")
    return 1 if missing_total or (args.strict and drift_total) else 0


def cmd_update(args):
    changed_files = 0
    for f in ga_files(args.wf):
        text = open(f).read()
        ga = json.loads(text)
        n = 0
        for s in tool_steps(ga):
            info = lookup(args.server, s)
            if info is None:
                print(f"::warning::{os.path.relpath(f, ROOT)}: {s['tool_id']} not on the server, left as is")
                continue
            new = info["version"]
            if s.get("tool_version") == new or vtuple(new) < vtuple(s.get("tool_version")):
                continue
            s["tool_version"] = new
            if "/repos/" in s["tool_id"]:
                s["tool_id"] = base_id(s["tool_id"]) + "/" + new
                if s.get("content_id"):
                    s["content_id"] = s["tool_id"]
            n += 1
        if n:
            changed_files += 1
            if not args.dry_run:
                with open(f, "w") as fh:
                    fh.write(json.dumps(ga, indent=4, ensure_ascii=False) + ("\n" if text.endswith("\n") else ""))
        print(f"{os.path.relpath(f, ROOT)}: {n} step(s) {'would be ' if args.dry_run else ''}updated")
    print(f"\n{changed_files} file(s) {'would change' if args.dry_run else 'changed'}")
    return 0


def api(server, method, path, payload=None, quiet=False):
    key = os.environ["GALAXY_API_KEY"]
    data = json.dumps(payload).encode() if payload is not None else None
    req = urllib.request.Request(f"{server}/api/{path}", data=data, method=method,
                                 headers={**UA, "x-api-key": key, "Content-Type": "application/json"})
    try:
        with urllib.request.urlopen(req, timeout=120) as r:
            body = r.read().decode()
            return json.loads(body) if body.strip() else {}
    except urllib.error.HTTPError as e:
        # Galaxy explains a refusal in the body (e.g. which tool versions are missing)
        detail = e.read().decode(errors="replace")[:4000]
        e.detail = detail
        if not quiet:
            print(f"::error::{method} /api/{path}: HTTP {e.code}: {detail}")
        raise


def cmd_run(args):
    import time
    if not os.environ.get("GALAXY_API_KEY"):
        print("GALAXY_API_KEY is not set: run test skipped")
        return 0
    files = ga_files([args.wf])
    if not files:
        print(f"no .ga in {args.wf}/galaxy")
        return 1
    failed = 0
    for f in files:
        ga = json.load(open(f))
        name = f"CI test {os.path.basename(f)} {time.strftime('%Y-%m-%d %H:%M')}"
        ga["name"] = name
        wf = api(args.server, "POST", "workflows", {"workflow": ga, "publish": False})
        hist = None
        try:
            payload = {"history": f"hist_name={name}", "inputs": {}}
            try:
                inv = api(args.server, "POST", f"workflows/{wf['id']}/invocations", payload, quiet=True)
            except urllib.error.HTTPError as e:
                # The server's tools are newer than the .ga's tool_version and some steps
                # lack a parameter the new version added. Galaxy refuses such a workflow
                # unless asked to fill the gaps with the tools' defaults (what saving it
                # in the Galaxy editor does). Report the gaps, then run with defaults.
                if e.code != 400 or "upgrade messages" not in getattr(e, "detail", ""):
                    print(f"::error::POST invocations: HTTP {e.code}: {getattr(e, 'detail', '')}")
                    raise
                try:
                    gaps = json.loads(e.detail).get("err_data", {})
                except ValueError:
                    gaps = e.detail
                print(f"::warning::{os.path.relpath(f, ROOT)}: steps with parameters missing for the "
                      f"server's tool version, run with the tools' defaults: {json.dumps(gaps)}")
                payload["allow_tool_state_corrections"] = True
                inv = api(args.server, "POST", f"workflows/{wf['id']}/invocations", payload)
            hist = inv.get("history_id")
            print(f"{os.path.relpath(f, ROOT)}: invocation {inv['id']} started")
            deadline = time.time() + args.timeout * 60
            while True:
                summary = api(args.server, "GET", f"invocations/{inv['id']}/jobs_summary")
                states = summary.get("states", {})
                state = api(args.server, "GET", f"invocations/{inv['id']}").get("state")
                busy = sum(n for st, n in states.items() if st in ("new", "queued", "running", "waiting", "upload"))
                bad = sum(n for st, n in states.items() if st in ("error", "failed", "deleted"))
                print(f"  invocation {state}, jobs {states}")
                if state in ("failed", "cancelled") or bad:
                    print(f"::error::{os.path.relpath(f, ROOT)}: workflow run failed ({state}, {states})")
                    failed += 1
                    break
                if state == "scheduled" and not busy:
                    print("  all jobs finished OK")
                    break
                if time.time() > deadline:
                    print(f"::error::{os.path.relpath(f, ROOT)}: timeout after {args.timeout} min")
                    failed += 1
                    break
                time.sleep(60)
        finally:
            try:
                api(args.server, "DELETE", f"workflows/{wf['id']}")
                if hist:
                    api(args.server, "DELETE", f"histories/{hist}", {"purge": True})
            except Exception as e:
                print(f"::warning::cleanup failed: {e}")
    return 1 if failed else 0


def main():
    ap = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    ap.add_argument("--server", default=os.environ.get("GALAXY_URL", "https://biobb.usegalaxy.es"))
    sub = ap.add_subparsers(dest="cmd", required=True)
    s = sub.add_parser("check")
    s.add_argument("wf", nargs="*")
    s.add_argument("--strict", action="store_true")
    s = sub.add_parser("run")
    s.add_argument("wf")
    s.add_argument("--timeout", type=int, default=600, help="minutes")
    s = sub.add_parser("update")
    s.add_argument("wf", nargs="*")
    s.add_argument("--dry-run", action="store_true")
    args = ap.parse_args()
    args.server = args.server.rstrip("/")
    return {"check": cmd_check, "update": cmd_update, "run": cmd_run}[args.cmd](args)


if __name__ == "__main__":
    sys.exit(main())
