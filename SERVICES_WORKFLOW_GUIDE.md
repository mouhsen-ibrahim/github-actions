# GitHub Actions Services Workflow Guide

This guide explains the structure and concepts of the `services.yml` workflow, designed to help you understand GitHub Actions fundamentals through a practical example.

## Workflow Overview

The services workflow demonstrates key GitHub Actions concepts by building and deploying multiple services dynamically based on a configurable list.

## File Structure Breakdown

### 1. Workflow Metadata

```yaml
name: Services Workflow

env:
  DEFAULT_SERVICES: '[{"path": "services/serviceA", "name": "serviceA"}, {"path": "services/serviceB", "name": "serviceB"}]'
```

**Concepts Explained:**
- `name`: Human-readable name shown in GitHub Actions UI
- `env`: Workflow-level environment variables accessible in all jobs
- **Use Case**: Define constants that multiple jobs need to access

### 2. Trigger Events

```yaml
on:
  workflow_dispatch:
    inputs:
      services:
        description: "JSON array of services with path and name keys"
        required: true
        default: '[{"path": "services/serviceA", "name": "serviceA"}, {"path": "services/serviceB", "name": "serviceB"}]'
        type: string
  push:
    branches:
      - main
```

**Concepts Explained:**
- `on`: Defines when the workflow runs
- `workflow_dispatch`: Manual trigger with user inputs
- `inputs`: User-provided parameters for manual runs
- `push`: Automatic trigger on code changes
- **Use Case**: Support both manual testing and automatic deployment

### 3. Job Dependencies and Outputs

```yaml
jobs:
  setup:
    runs-on: ubuntu-latest
    outputs:
      services: ${{ steps.set-services.outputs.services }}
    steps:
      - name: Set services list
        id: set-services
        run: |
          if [ "${{ github.event_name }}" = "workflow_dispatch" ]; then
            echo "services=${{ github.event.inputs.services }}" >> $GITHUB_OUTPUT
          else
            echo "services=${{ env.DEFAULT_SERVICES }}" >> $GITHUB_OUTPUT
          fi
```

**Concepts Explained:**
- `jobs`: Contains all workflow jobs
- `runs-on`: Specifies runner environment (ubuntu-latest, windows-latest, etc.)
- `outputs`: Makes step outputs available to other jobs
- `steps`: Individual tasks within a job
- `id`: Unique identifier for referencing step outputs
- `$GITHUB_OUTPUT`: Standard way to set outputs in GitHub Actions
- **Use Case**: Dynamic configuration based on trigger type

### 4. Matrix Strategy

```yaml
  build:
    needs: setup
    runs-on: ubuntu-latest
    strategy:
      matrix:
        service: ${{ fromJson(needs.setup.outputs.services) }}
```

**Concepts Explained:**
- `needs`: Creates dependency on other jobs
- `strategy.matrix`: Runs job multiple times with different parameters
- `fromJson()`: Converts JSON string to object/array
- `needs.job_name.outputs.output_name`: Access outputs from dependent jobs
- **Use Case**: Process multiple services in parallel

### 5. Conditional Job Execution

```yaml
  deploy:
    needs: [setup, build]
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
```

**Concepts Explained:**
- `needs: [job1, job2]`: Depend on multiple jobs
- `if`: Conditional execution based on GitHub contexts
- `github.ref`: Current branch reference
- **Use Case**: Deploy only from main branch

### 6. Step Structure and Context Usage

```yaml
steps:
  - name: Checkout code
    uses: actions/checkout@v4

  - name: Build service
    run: |
      echo "Building service: ${{ matrix.service.name }}"
      echo "Service path: ${{ matrix.service.path }}"
      cd "${{ matrix.service.path }}"
      if [ -f "Makefile" ]; then
        make build
      else
        echo "No Makefile found in ${{ matrix.service.path }}"
      fi
```

**Concepts Explained:**
- `uses`: Use pre-built actions from GitHub Marketplace
- `run`: Execute shell commands
- `${{ matrix.service.name }}`: Access matrix variables
- Multi-line commands with `|`
- **Use Case**: Standard checkout and custom build logic

## Key GitHub Actions Concepts Demonstrated

### 1. **Contexts**
- `github.*`: Information about the workflow run, repository, etc.
- `needs.*`: Outputs from dependent jobs
- `matrix.*`: Current matrix iteration values

### 2. **Expressions**
- `${{ expression }}`: Evaluate GitHub Actions expressions
- `fromJson()`: Function to parse JSON strings
- Conditional logic with `&&` and `||`

### 3. **Job Orchestration**
- **Sequential**: Jobs run after dependencies complete
- **Parallel**: Jobs without dependencies run simultaneously
- **Conditional**: Jobs run based on conditions

### 4. **Data Flow**
```
Trigger Event → Setup Job (determines services) → Matrix Jobs (process each service) → Deploy Jobs (conditional)
```

## Workflow Execution Flow

### Manual Trigger Path:
1. User provides custom services JSON
2. Setup job reads from `github.event.inputs.services`
3. Matrix jobs process each service from input
4. Deploy jobs run if on main branch

### Push Trigger Path:
1. Code pushed to main branch
2. Setup job uses `DEFAULT_SERVICES` env variable
3. Matrix jobs process default services
4. Deploy jobs run automatically

## Best Practices Demonstrated

### 1. **Separation of Concerns**
- Setup job handles configuration logic
- Build/deploy jobs focus on their specific tasks

### 2. **Dynamic Configuration**
- Matrix strategy adapts to different service lists
- Conditional logic handles different trigger types

### 3. **Error Handling**
- Check for file existence before operations
- Provide meaningful error messages

### 4. **Environment Variables**
- Use workflow-level env for constants
- Avoid hardcoding values in multiple places

### 5. **Conditional Execution**
- Deploy only from main branch
- Handle missing files gracefully

## Common Patterns You Can Apply

### 1. **Multi-Environment Deployment**
```yaml
strategy:
  matrix:
    environment: [dev, staging, prod]
    service: ${{ fromJson(needs.setup.outputs.services) }}
```

### 2. **Version Matrix**
```yaml
strategy:
  matrix:
    node-version: [16, 18, 20]
    service: ${{ fromJson(needs.setup.outputs.services) }}
```

### 3. **Platform Matrix**
```yaml
strategy:
  matrix:
    os: [ubuntu-latest, windows-latest, macos-latest]
    service: ${{ fromJson(needs.setup.outputs.services) }}
```

## Troubleshooting Tips

### 1. **Debug Outputs**
Add debug steps to understand data flow:
```yaml
- name: Debug services
  run: echo "Services: ${{ needs.setup.outputs.services }}"
```

### 2. **Validate JSON**
Ensure JSON strings are properly formatted:
```yaml
- name: Validate JSON
  run: echo '${{ needs.setup.outputs.services }}' | jq .
```

### 3. **Check Contexts**
Use GitHub's built-in context information:
```yaml
- name: Dump contexts
  run: |
    echo "Event name: ${{ github.event_name }}"
    echo "Ref: ${{ github.ref }}"
```

## Extensions and Customizations

### 1. **Add More Service Properties**
```json
[
  {
    "path": "services/api",
    "name": "API Service",
    "dockerfile": "Dockerfile.api",
    "port": 3000
  }
]
```

### 2. **Add Environment-Specific Logic**
```yaml
- name: Deploy to environment
  run: |
    if [ "${{ github.ref }}" = "refs/heads/main" ]; then
      make deploy-prod
    else
      make deploy-staging
    fi
```

### 3. **Add Artifact Handling**
```yaml
- name: Upload build artifacts
  uses: actions/upload-artifact@v3
  with:
    name: ${{ matrix.service.name }}-build
    path: ${{ matrix.service.path }}/dist/
```

This workflow structure provides a solid foundation for understanding GitHub Actions while solving real-world CI/CD challenges. The patterns demonstrated here can be adapted for various use cases beyond service deployment.
