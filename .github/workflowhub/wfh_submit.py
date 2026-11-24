#!/usr/bin/env python3
"""Submit the crates staged by wfh_stage.py to WorkflowHub, one by one.

Does what workflowhub-eu/submission-action@v0 does (zip each staged folder, POST it
to <instance>/workflows/submit with the team id), with three differences needed for a
release of ~120 entries:
  - one failing entry does not stop the others (the action exits at the first error);
  - every result is reported: entry, version, link, or the server's error;
  - entries without an id (new on WorkflowHub) print the id they got, to be written
    into workflowhub.manifest.yml (otherwise the next release creates them again).

Env: WORKFLOWHUB_API_TOKEN (required). Usage:
  python3 wfh_submit.py [--stage _wfh_stage] [--instance URL] [--team ID]
--instance / --team override the values stored in <stage>/index.json (from the
manifest); the sandbox (dev.workflowhub.eu) has its own team ids.
Writes <stage>/results.json and, in GitHub Actions, a table in the job summary.
Exit 1 if any submission failed. Stdlib only.
"""
import argparse
import io
import json
import os
import sys
import urllib.error
import urllib.request
import uuid
import zipfile


def zip_dir(path):
    buf = io.BytesIO()
    with zipfile.ZipFile(buf, "w", zipfile.ZIP_DEFLATED) as z:
        for root, _, files in os.walk(path):
            for f in sorted(files):
                full = os.path.join(root, f)
                z.write(full, os.path.relpath(full, path))
    return buf.getvalue()


def multipart(fields, file_field, filename, data):
    boundary = uuid.uuid4().hex
    out = io.BytesIO()
    for k, v in fields:
        out.write(f"--{boundary}\r\nContent-Disposition: form-data; name=\"{k}\"\r\n\r\n{v}\r\n".encode())
    out.write(f"--{boundary}\r\nContent-Disposition: form-data; name=\"{file_field}\"; "
              f"filename=\"{filename}\"\r\nContent-Type: application/zip\r\n\r\n".encode())
    out.write(data)
    out.write(f"\r\n--{boundary}--\r\n".encode())
    return out.getvalue(), f"multipart/form-data; boundary={boundary}"


def submit(instance, team, token, entry, stage_root):
    data = zip_dir(os.path.join(stage_root, os.path.basename(entry["dir"])))
    body, ctype = multipart([("workflow[project_ids][]", str(team))], "ro_crate", "crate.zip", data)
    req = urllib.request.Request(f"{instance}/workflows/submit", data=body, method="POST", headers={
        "Authorization": f"Token {token}", "Content-Type": ctype, "Accept": "application/json",
        "User-Agent": "biobb-workflows wfh_submit.py"})
    try:
        with urllib.request.urlopen(req, timeout=300) as r:
            resp = json.loads(r.read().decode() or "{}")
        d = resp.get("data") or {}
        link = d.get("links", {}).get("self", "")
        return {"ok": True, "id": d.get("id"), "url": f"{instance}{link}" if link.startswith("/") else link,
                "version": (d.get("attributes") or {}).get("latest_version")}
    except urllib.error.HTTPError as e:
        return {"ok": False, "error": f"HTTP {e.code}: {e.read().decode(errors='replace')[:800]}"}
    except Exception as e:  # network, timeout
        return {"ok": False, "error": str(e)[:800]}


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--stage", default="_wfh_stage")
    ap.add_argument("--instance")
    ap.add_argument("--team")
    a = ap.parse_args()
    token = os.environ.get("WORKFLOWHUB_API_TOKEN")
    if not token:
        sys.exit("WORKFLOWHUB_API_TOKEN is not set")
    idx = json.load(open(os.path.join(a.stage, "index.json")))
    instance = (a.instance or idx.get("instance") or "https://workflowhub.eu").rstrip("/")
    team = a.team or idx.get("team_id")
    if not team:
        sys.exit("no team id (manifest team_id or --team)")
    print(f"Submitting {len(idx['entries'])} crate(s), version {idx['version']}, to {instance} team {team}")

    same_instance = instance == (idx.get("instance") or "https://workflowhub.eu").rstrip("/")
    results = []
    for e in idx["entries"]:
        r = submit(instance, team, token, e, a.stage)
        r.update({"key": e["key"], "manifest_id": e.get("id"), "name": e["name"], "flavour": e["flavour"]})
        results.append(r)
        if r["ok"]:
            new = "  NEW ENTRY: put this id in the manifest" if not e.get("id") and same_instance else ""
            # the ids in the manifest are production ids; another instance numbers its own
            if same_instance and e.get("id") and r.get("id") and str(r["id"]) != str(e["id"]):
                new = f"  WARNING: landed on entry {r['id']}, manifest says {e['id']} (source link mismatch?)"
            print(f"ok      {e['key']:>40}  -> {r.get('url')} (version {r.get('version')}){new}")
        else:
            print(f"::error::WorkflowHub {e['key']} ({e['name']}): {r['error']}")

    json.dump({"instance": instance, "version": idx["version"], "results": results},
              open(os.path.join(a.stage, "results.json"), "w"), indent=2)
    failed = [r for r in results if not r["ok"]]
    new = [r for r in results if r["ok"] and not r["manifest_id"]] if same_instance else []
    summary = [f"## WorkflowHub: {len(results) - len(failed)}/{len(results)} submitted "
               f"(version `{idx['version']}`, {instance})", "",
               "| entry | flavour | result |", "| --- | --- | --- |"]
    for r in results:
        res = f"[{r.get('id')} v{r.get('version')}]({r.get('url')})" if r["ok"] else "FAILED: " + r["error"][:200].replace("|", "/")
        summary.append(f"| {r['name']} | {r['flavour']} | {res} |")
    if new:
        summary += ["", "**New entries: write these ids into `workflowhub.manifest.yml`:**", ""]
        summary += [f"- `{r['key']}` → `id: {r['id']}`" for r in new]
    if failed:
        summary += ["", "Re-run only the failed ones with the `ids`/`tutorials` inputs: "
                    + ", ".join(str(r["manifest_id"] or r["key"]) for r in failed)]
    if os.environ.get("GITHUB_STEP_SUMMARY"):
        with open(os.environ["GITHUB_STEP_SUMMARY"], "a") as fh:
            fh.write("\n".join(summary) + "\n")
    print("\n".join(summary[:1]))
    return 1 if failed else 0


if __name__ == "__main__":
    sys.exit(main())
