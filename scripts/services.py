# This script is used to detect all services in the repository

import argparse
import os, yaml
from typing_extensions import List
import subprocess, requests
from typing import Optional

class Service:
    def __init__(self, path: str):
        self.path = path
        with open(os.path.join(self.path, "Buildfile.yaml"), 'r') as f:
            self.data = yaml.safe_load(f)
            self.data["path"] = self.path

    def __repr__(self):
        return str(self.data)

    def __eq__(self, other):
        if not isinstance(other, Service):
            return False
        return self.path == other.path

    def __hash__(self):
        return hash(self.path)

GITHUB_API = "https://api.github.com"

def run_git(*args: str, cwd: Optional[str] = None) -> str:
    try:
        out = subprocess.check_output(["git", *args], cwd=cwd, stderr=subprocess.STDOUT)
        return out.decode().strip()
    except subprocess.CalledProcessError as e:
        msg = e.output.decode().strip()
        raise RuntimeError(f"git {' '.join(args)} failed: {msg}") from e


def detect_services():
    services = []
    for root, dirs, files in os.walk('.'):
        for file in files:
            if file == "Buildfile.yaml":
                services.append(Service(root))
    return services

def is_sub_path(path1 : str, path2 : str) -> bool:
    if path1.startswith("./"):
        path1 = path1[2:]
    return os.path.commonpath([path1, path2]) == path1

def changed_service(path : str, changes : List[str]) -> bool:
    for change in changes:
        if is_sub_path(path, change):
            return True
    return False

def get_services_by_kind(services : List[Service], type : str) -> List[Service]:
    return [service for service in services if service.data.get("kind") == type]

def get_triggers(config):
    return config.get("files", [])

def get_services_by_selector(selector, services) -> List[Service]:
    if selector.get("all"):
        return services
    ret = []
    for attribute_name, attribute_value in selector.get("attributes", {}).items():
        for service in services:
            if service.data.get(attribute_name) == attribute_value:
                ret.append(service)
    return ret

def get_changed_services(changes : List[str], config) -> List[Service]:
    services = detect_services()
    additional_services = []
    for c in config.get("additional_services", []):
        changed_files = get_triggers(c.get("trigger", {}))
        if any(c in changes for c in changed_files):
            additional_services.extend(get_services_by_selector(c.get("selector", {}), services))
    changed_services = [service for service in services if changed_service(service.path, changes)]

    # Use dict.fromkeys() to preserve order while removing duplicates
    all_services = changed_services + additional_services
    return list(dict.fromkeys(all_services))

def compare_services(cmp : str, config):
    changes = run_git("diff", "--name-only", cmp)
    return get_changed_services(changes.split("\n"), config)

def current_commit() -> str:
    return run_git("rev-parse", "HEAD")

def pick_first_success_run(runs: list) -> Optional[dict]:
    for r in runs:
        # We want completed + conclusion success
        if (r.get("status") == "completed") and (r.get("conclusion") == "success"):
            return r
    return None

def list_runs(owner: str, repo: str, branch: str, token: str,
              workflow_id: Optional[int] = None,
              workflow_ref: Optional[str] = None,
              per_page: int = 50) -> list:
    headers = {
        "Authorization": f"Bearer {token}",
        "Accept": "application/vnd.github+json",
    }

    # If a specific workflow is given (file name or ID), use the workflow-runs endpoint for that workflow.
    if workflow_id is not None or workflow_ref is not None:
        workflow_part = str(workflow_id) if workflow_id is not None else workflow_ref
        url = f"{GITHUB_API}/repos/{owner}/{repo}/actions/workflows/{workflow_part}/runs"
        params = {"branch": branch, "status": "completed", "per_page": per_page}
    else:
        # Otherwise query all workflow runs for the repo
        url = f"{GITHUB_API}/repos/{owner}/{repo}/actions/runs"
        params = {"branch": branch, "status": "completed", "per_page": per_page}

    resp = requests.get(url, headers=headers, params=params, timeout=30)
    if resp.status_code != 200:
        raise RuntimeError(f"GitHub API error {resp.status_code}: {resp.text}")

    data = resp.json()
    runs = data.get("workflow_runs", [])
    return runs

def get_last_green_commit(owner: str, repo: str, branch: str, token: str,
                          workflow: Optional[str] = None,
                          workflow_id: Optional[int] = None) -> str:
    runs = list_runs(owner, repo, branch, token, workflow_id=workflow_id, workflow_ref=workflow)
    run = pick_first_success_run(runs)
    if not run:
        return current_commit()
    return run.get("head_sha")


def main():
    parser = argparse.ArgumentParser(description='Detect services in the repository')
    parser.add_argument('--all', action='store_true', help='Find all services')
    parser.add_argument("--cmp", type=str, help="Compare with a git commit")
    parser.add_argument("--config", type=str, help="Configuration file", default="services.yaml")
    parser.add_argument("--last-green", action="store_true", help="Return changed services since the last green build")
    parser.add_argument("--branch", type=str, help="Branch to find last green commit")
    parser.add_argument("--repo", type=str, help="Github repository name")
    parser.add_argument("--owner", type=str, help="Github repository owner")
    parser.add_argument("--workflow", type=str, help="Github workflow name")
    args = parser.parse_args()

    if args.all:
        print(detect_services())
    if args.cmp:
        with open(args.config, "r") as f:
            config = yaml.safe_load(f)
            print(compare_services(args.cmp, config))
    if args.last_green:
        if args.branch is None or args.repo is None or args.owner is None:
            raise ValueError("Branch, repo and owner must be specified")
        token = os.environ.get("GITHUB_TOKEN")
        if token is None:
            raise ValueError("GITHUB_TOKEN environment variable is not set")
        last_green_commit = get_last_green_commit(args.owner, args.repo, args.branch, token, args.workflow)
        print(last_green_commit)

if __name__ == '__main__':
    main()
