# This script is used to detect all services in the repository

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
                        "path": os.path.join(root, file)
                    }
                    services.append(service)
    return services

def main():
    services = detect_services()
    print(services)

if __name__ == '__main__':
    main()
