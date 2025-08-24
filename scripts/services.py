# This script is used to detect all services in the repository

import argparse
import os, yaml
from typing_extensions import List
import subprocess
from typing import Optional

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
                with open(os.path.join(root, file), 'r') as f:
                    data = yaml.safe_load(f)
                    service = {
                        "name": data.get("name", ""),
                        "path": root
                    }
                    services.append(service)
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

def compare_services(cmp : str):
    services = detect_services()
    changes = run_git("diff", "--name-only", cmp)
    changed_services = [service for service in services if changed_service(service["path"], changes.split("\n"))]
    print(changed_services)

def main():
    parser = argparse.ArgumentParser(description='Detect services in the repository')
    parser.add_argument('--all', action='store_true', help='Find all services')
    parser.add_argument("--cmp", type=str, help="Compare with a git commit")
    args = parser.parse_args()

    if args.all:
        print(detect_services())
    if args.cmp:
        compare_services(args.cmp)

if __name__ == '__main__':
    main()
