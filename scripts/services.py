# This script is used to detect all services in the repository

import argparse
import os, yaml

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

def main():
    parser = argparse.ArgumentParser(description='Detect services in the repository')
    parser.add_argument('--all', action='store_true', help='Find all services')
    args = parser.parse_args()

    if args.all:
        print(detect_services())

if __name__ == '__main__':
    main()
