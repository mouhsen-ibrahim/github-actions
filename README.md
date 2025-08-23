# GitHub Actions String Output and Input Examples

This repository contains several GitHub Actions workflows that demonstrate how to output strings from one job and use them as input variables in other jobs. This is a common pattern for passing data between jobs in GitHub Actions workflows.

## Workflows Overview

### 1. Simple String Output and Input (`simple-string-example.yml`)

The most basic example showing how to:
- Generate a string output from one job
- Use that string as input in another job

**Key Features:**
- Manual trigger with custom input
- Date/time formatting
- Basic string manipulation

**Usage:**
```yaml
outputs:
  my_string: ${{ steps.set-output.outputs.message }}
```

### 2. Comprehensive String Example (`string-output-input.yml`)

A more advanced example demonstrating:
- Multiple string outputs
- Conditional job execution based on string content
- Matrix jobs using string outputs
- File creation with string content
- Artifact upload

**Key Features:**
- Multiple output types (generated, processed, timestamp)
- String length calculations
- Conditional logic with `contains()`
- Matrix strategy with string transformations
- Artifact generation

### 3. Reusable String Workflow (`reusable-string-workflow.yml`)

A reusable workflow that can be called from other workflows:
- Accepts input parameters
- Processes strings with configurable options
- Returns multiple outputs

**Key Features:**
- `workflow_call` trigger
- Configurable inputs (text, prefix, timestamp option)
- Multiple outputs for flexibility

### 4. Caller Workflow (`call-reusable-example.yml`)

Demonstrates how to call the reusable workflow:
- Single workflow call
- Matrix strategy calling reusable workflow multiple times
- Processing outputs from reusable workflows

## How String Outputs Work

### Setting Outputs

In GitHub Actions, you set outputs using the `GITHUB_OUTPUT` environment file:

```bash
echo "output_name=value" >> $GITHUB_OUTPUT
```

### Defining Job Outputs

Jobs must declare their outputs to make them available to other jobs:

```yaml
jobs:
  job1:
    outputs:
      my_output: ${{ steps.step_id.outputs.output_name }}
    steps:
      - id: step_id
        run: echo "output_name=Hello World" >> $GITHUB_OUTPUT
```

### Using Outputs in Other Jobs

Other jobs can access outputs using the `needs` context:

```yaml
jobs:
  job2:
    needs: job1
    steps:
      - run: echo "Received: ${{ needs.job1.outputs.my_output }}"
```

## Common Patterns

### 1. Dynamic String Generation
```yaml
run: |
  DYNAMIC_VALUE="Build-$(date +%Y%m%d-%H%M%S)"
  echo "build_id=${DYNAMIC_VALUE}" >> $GITHUB_OUTPUT
```

### 2. Processing User Input
```yaml
run: |
  INPUT="${{ github.event.inputs.user_input || 'default_value' }}"
  PROCESSED="Processed: ${INPUT}"
  echo "result=${PROCESSED}" >> $GITHUB_OUTPUT
```

### 3. Conditional Logic
```yaml
if: contains(needs.previous_job.outputs.string_output, 'keyword')
```

### 4. String Manipulation
```bash
# Uppercase
echo "upper=${STRING^^}" >> $GITHUB_OUTPUT

# Lowercase  
echo "lower=${STRING,,}" >> $GITHUB_OUTPUT

# Length
echo "length=${#STRING}" >> $GITHUB_OUTPUT

# Substring
echo "first_10=${STRING:0:10}" >> $GITHUB_OUTPUT
```

## Running the Workflows

### Manual Trigger
1. Go to Actions tab in your repository
2. Select the workflow you want to run
3. Click "Run workflow"
4. Provide input parameters if required

### Automatic Triggers
The workflows will also run on:
- Push to main/master branches
- Pull requests to main/master branches

## Best Practices

1. **Use Descriptive Output Names**: Make output names clear and descriptive
2. **Handle Default Values**: Always provide fallbacks for optional inputs
3. **Validate Input**: Add basic validation for string inputs when needed
4. **Escape Special Characters**: Be careful with strings containing special characters
5. **Use Quotes**: When in doubt, quote your variables to handle spaces
6. **Document Outputs**: Clearly document what each output contains

## Troubleshooting

### Common Issues

1. **Output Not Available**: Ensure the job defining the output completes successfully
2. **Empty Output**: Check that the step setting the output actually runs
3. **Special Characters**: Use proper escaping for strings with special characters
4. **Job Dependencies**: Make sure `needs:` is properly configured

### Debugging Tips

- Add `echo` statements to verify output values
- Use the Actions logs to trace output generation
- Test with simple static strings before using dynamic values

## Advanced Use Cases

- **Multi-environment Deployments**: Pass environment-specific configuration
- **Version Management**: Generate and propagate version numbers
- **Build Artifacts**: Pass build information between jobs
- **Notification Messages**: Create formatted messages for external systems
- **Configuration Management**: Generate configuration based on inputs

These examples provide a solid foundation for implementing string output and input patterns in your GitHub Actions workflows.