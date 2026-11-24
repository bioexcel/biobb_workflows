#!/usr/bin/env python3
"""Update the bio.tools entries of the BioBB workflows at a release.

Per entry of biotools.manifest.yml it downloads the CURRENT record from bio.tools, changes
only three things and sends the whole record back (bio.tools' update is a full PUT; its
docs do not say whether missing fields are erased, so nothing is ever left out):

  version   adds the release label (--replace-versions: keeps only that label)
  link      the WorkflowHub entries of the workflow (from workflowhub.manifest.yml), one
            "Software catalogue" link per flavour, replacing previous workflowhub.eu links;
            plus the workflow folder on GitHub ("Repository") if missing
  download  the workflow folder ("Source code") and the GHCR Docker image ("Container
            file") if missing

Other links are kept as they are; --check-links reports the ones that no longer answer
(e.g. renamed repositories) so a person can fix them on bio.tools.

Default is a DRY RUN: prints "current -> new" per entry and, with a token, asks bio.tools
to validate the change (PUT /api/tool/<id>/validate/) without saving it. --apply saves:
it first writes a backup of every record to --backup, then PUTs /api/tool/<id>/.

Side effects seen on the first real run (2026-11-24, 15 entries): bio.tools fills the
publications' metadata itself after a save (good), may reorder unordered lists (EDAM
operations, operating systems), and resets its internal `confidence_flag` (a curation hint
from its automatic imports, not shown on the entry page), which the API does not accept
back. Nothing else changes (each record was compared with its backup).

Env: BIOTOOLS_TOKEN (a bio.tools login key; see .claude/skills/biobb-release). Without it
only the diff is shown. Needs PyYAML.

Usage: python3 .github/biotools/biotools_update.py --version 2026.2 [--only wf,...]
         [--apply] [--replace-versions] [--check-links] [--backup DIR]
"""
import argparse
import copy
import json
import os
import sys
import urllib.error
import urllib.request

try:
    import yaml
except ImportError:
    sys.exit("PyYAML missing: pip install pyyaml")

API = "https://bio.tools/api/tool"
GH = "https://github.com/bioexcel/biobb_workflows"
WFH = "https://workflowhub.eu/workflows/"
READ_ONLY = {"biotoolsCURIE", "owner", "additionDate", "lastUpdate", "validated", "homepage_status",
             "elixir_badge", "confidence_flag", "editPermission"}
FLAVOURS = ["jupyter", "python", "docker", "cwl", "airflow", "nextflow", "galaxy"]
LABEL = {"jupyter": "Jupyter Notebook", "python": "Python", "docker": "Docker", "cwl": "CWL",
         "airflow": "Apache Airflow", "nextflow": "Nextflow", "galaxy": "Galaxy"}
UA = "biobb-workflows biotools_update.py"


def call(method, url, token=None, data=None):
    headers = {"Accept": "application/json", "User-Agent": UA}
    if token:
        headers["Authorization"] = f"Token {token}"
    body = None
    if data is not None:
        body = json.dumps(data).encode()
        headers["Content-Type"] = "application/json"
    req = urllib.request.Request(url, data=body, method=method, headers=headers)
    try:
        with urllib.request.urlopen(req, timeout=120) as r:
            raw = r.read().decode()
            return r.status, (json.loads(raw) if raw.strip() else {})
    except urllib.error.HTTPError as e:
        return e.code, e.read().decode(errors="replace")[:1500]
    except Exception as e:  # network
        return 0, str(e)


def link_state(url):
    """None if the link works, else 'gone (HTTP 404)' or 'unreachable (<reason>)'."""
    for method in ("HEAD", "GET"):
        req = urllib.request.Request(url, method=method, headers={"User-Agent": UA})
        try:
            with urllib.request.urlopen(req, timeout=60) as r:
                return None if r.status < 400 else f"gone (HTTP {r.status})"
        except urllib.error.HTTPError as e:
            if e.code in (405, 403) and method == "HEAD":
                continue
            return f"gone (HTTP {e.code})" if e.code in (404, 410) else f"answers HTTP {e.code}"
        except Exception as e:
            reason = str(getattr(e, "reason", e))[:80]
            return f"unreachable ({reason})"
    return "answers HTTP 403"


def under(path, prefix):
    prefix = prefix.rstrip("/")
    return path == prefix or path.startswith(prefix + "/")


def workflowhub_links(entry, wfh):
    include = entry.get("workflowhub") or [entry["wf"]]
    exclude = entry.get("workflowhub_exclude") or []
    out = []
    for e in wfh.get("workflows") or []:
        if e.get("skip") or not e.get("id") or not e.get("path"):
            continue
        if any(under(e["path"], p) for p in include) and not any(under(e["path"], p) for p in exclude):
            out.append((FLAVOURS.index(e["flavour"]) if e["flavour"] in FLAVOURS else 99, e["flavour"], e["id"]))
    return [{"url": f"{WFH}{i}", "type": ["Software catalogue"], "note": f"WorkflowHub: {LABEL.get(f, f)} flavour"}
            for _, f, i in sorted(out)]


def clean(value):
    """bio.tools returns records with empty lists and nulls ("otherID": [], "note": null)
    but its validator rejects them on the way back: drop every empty value (it carries no
    information), recursively."""
    if isinstance(value, dict):
        out = {k: clean(v) for k, v in value.items()}
        return {k: v for k, v in out.items() if v not in (None, "", [], {})}
    if isinstance(value, list):
        out = [clean(v) for v in value]
        return [v for v in out if v not in (None, "", [], {})]
    return value


def desired(record, entry, args, wfh):
    new = copy.deepcopy(record)
    vers = list(new.get("version") or [])
    if args.replace_versions:
        vers = [args.version]
    elif args.version not in vers:
        vers.append(args.version)
    new["version"] = vers

    repo_url = f"{GH}/tree/main/{entry['wf']}"
    links = [l for l in new.get("link") or [] if not str(l.get("url", "")).startswith(WFH)]
    if not any(str(l.get("url", "")).rstrip("/") == repo_url for l in links):
        links.append({"url": repo_url, "type": ["Repository"], "note": "Source code in GitHub (all flavours)"})
    new["link"] = links + workflowhub_links(entry, wfh)

    dl = list(new.get("download") or [])

    def ensure(url, typ, note):
        if not any(str(d.get("url", "")).rstrip("/") == url for d in dl):
            dl.append({"url": url, "type": typ, "note": note})

    ensure(repo_url, "Source code", "Workflow folder (all flavours) in GitHub")
    if os.path.isdir(os.path.join(args.repo, entry["wf"], "docker")):
        ensure(f"{GH}/pkgs/container/{entry['wf']}", "Container file", "Docker image (GHCR)")
    new["download"] = dl
    return new


def diff(old, new):
    lines = []
    if old.get("version") != new.get("version"):
        lines.append(f"    version: {old.get('version')} -> {new.get('version')}")
    for key in ("link", "download"):
        o = {str(x.get("url")) for x in old.get(key) or []}
        n = {str(x.get("url")) for x in new.get(key) or []}
        lines += [f"    {key} - {u}" for u in sorted(o - n)]
        lines += [f"    {key} + {u}" for u in sorted(n - o)]
    return lines


def main():
    ap = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    ap.add_argument("--version", required=True)
    ap.add_argument("--manifest", default="biotools.manifest.yml")
    ap.add_argument("--wfh-manifest", default="workflowhub.manifest.yml")
    ap.add_argument("--repo", default=".")
    ap.add_argument("--only", help="comma-separated workflow folders or biotoolsIDs")
    ap.add_argument("--apply", action="store_true")
    ap.add_argument("--replace-versions", action="store_true")
    ap.add_argument("--check-links", action="store_true")
    ap.add_argument("--backup", default="_biotools_backup")
    args = ap.parse_args()

    token = os.environ.get("BIOTOOLS_TOKEN")
    if args.apply and not token:
        sys.exit("--apply needs BIOTOOLS_TOKEN")
    entries = [e for e in yaml.safe_load(open(args.manifest))["entries"] if not e.get("skip")]
    if args.only:
        want = {s.strip() for s in args.only.split(",") if s.strip()}
        entries = [e for e in entries if e["wf"] in want or e["biotoolsID"] in want]
    wfh = yaml.safe_load(open(args.wfh_manifest))
    if args.apply:
        os.makedirs(args.backup, exist_ok=True)

    results = []
    for e in entries:
        tid = e["biotoolsID"]
        status, record = call("GET", f"{API}/{tid}/?format=json")
        if status != 200:
            results.append((tid, "FAILED", f"cannot read the entry (HTTP {status})"))
            continue
        new = desired(record, e, args, wfh)
        changes = diff(record, new)
        print(f"== {tid} ({e['wf']})  owner {record.get('owner')}")
        print("\n".join(changes) if changes else "    nothing to change")
        if args.check_links:
            urls = [record.get("homepage")] + [x.get("url") for k in ("link", "download", "documentation")
                                               for x in record.get(k) or []]
            for u in sorted({u for u in urls if u and not u.startswith(WFH)}):
                state = link_state(u)
                if state:
                    print(f"::warning::{tid}: link {state} (check it, fix by hand on bio.tools): {u}")
        if not changes:
            results.append((tid, "unchanged", ""))
            continue
        if not token:
            results.append((tid, "dry run", f"{len(changes)} change(s); no token, not validated"))
            continue
        payload = clean({k: v for k, v in new.items() if k not in READ_ONLY})
        status, body = call("PUT", f"{API}/{tid}/validate/", token, payload)
        if status == 403 and "Request Blocked" in str(body):
            # the SDU firewall in front of bio.tools, not bio.tools: it blocks every PUT to
            # this entry's URL (seen for an ID containing "_from_", 2026-11-24)
            results.append((tid, "BLOCKED", "the SDU firewall in front of bio.tools blocks changes to "
                            "this entry's address (false alarm); edit it on the website or ask "
                            "registry-support@elixir-dk.org"))
            continue
        if status in (401, 403):
            print(f"::warning::{tid}: bio.tools refused (HTTP {status}): {str(body)[:600]}")
            results.append((tid, "NO PERMISSION", f"the job's account cannot edit it; the owner "
                            f"({record.get('owner')}) must add it as an editor"))
            continue
        if status not in (200, 201):
            print(f"::error::{tid}: bio.tools validation HTTP {status}: {str(body)[:1500]}")
            results.append((tid, "FAILED", f"validation HTTP {status}: {str(body)[:400]}"))
            continue
        if not args.apply:
            results.append((tid, "valid", f"{len(changes)} change(s), not saved (dry run)"))
            continue
        with open(os.path.join(args.backup, f"{tid}.json"), "w") as fh:
            json.dump(record, fh, indent=2)
        status, body = call("PUT", f"{API}/{tid}/", token, payload)
        results.append((tid, "saved" if status in (200, 201) else "FAILED",
                        f"{len(changes)} change(s)" if status in (200, 201) else f"HTTP {status}: {str(body)[:400]}"))

    summary = [f"## bio.tools ({'APPLY' if args.apply else 'dry run'}, version `{args.version}`)", "",
               "| entry | result | detail |", "| --- | --- | --- |"]
    summary += [f"| [{t}](https://bio.tools/{t}) | {r} | {d.replace('|', '/')} |" for t, r, d in results]
    print("\n".join(summary))
    if os.environ.get("GITHUB_STEP_SUMMARY"):
        with open(os.environ["GITHUB_STEP_SUMMARY"], "a") as fh:
            fh.write("\n".join(summary) + "\n")
    return 1 if any(r == "FAILED" for _, r, _ in results) else 0


if __name__ == "__main__":
    sys.exit(main())
