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

### Manual Trigger with User Input
1. Go to the **Actions** tab in your repository
2. Select the workflow you want to run (e.g., "Simple User Message Input")
3. Click **"Run workflow"** button
4. Fill in the input fields that appear:
   - **Message**: Enter your custom message text
   - **Environment**: Select from dropdown (if available)
   - **Enable notifications**: Check/uncheck boolean options
   - **Version**: Enter optional version number
5. Click **"Run workflow"** to start execution

### Setting Up User Input in Workflows
To allow users to set variables through the GitHub UI, use `workflow_dispatch` with `inputs`:

```yaml
on:
  workflow_dispatch:
    inputs:
      message:
        description: 'Enter your custom message'
        required: true
        default: 'Hello from GitHub Actions!'
        type: string
      environment:
        description: 'Target environment'
        type: choice
        options:
          - dev
          - staging
          - production
      enable_feature:
        description: 'Enable special feature'
        type: boolean
        default: false
```

### Input Types Available
- **`string`**: Text input field
- **`choice`**: Dropdown with predefined options
- **`boolean`**: Checkbox (true/false)
- **`environment`**: Environment selector

### Accessing User Input in Jobs
```yaml
steps:
  - run: echo "User message: ${{ github.event.inputs.message }}"
  - run: echo "Selected environment: ${{ github.event.inputs.environment }}"
  - run: echo "Feature enabled: ${{ github.event.inputs.enable_feature }}"
```

### Automatic Triggers
The workflows will also run on:
- Push to main/master branches
- Pull requests to main/master branches

## Best Practices

1. **Use Descriptive Output Names**: Make output names clear and descriptive
2. **Handle Default Values**: Always provide fallbacks for optional inputs
3. **Add Helpful Descriptions**: Write clear descriptions for UI inputs
4. **Set Appropriate Defaults**: Provide sensible default values for inputs
5. **Use Required Wisely**: Only mark inputs as required when truly necessary
6. **Validate Input**: Add basic validation for string inputs when needed
7. **Escape Special Characters**: Be careful with strings containing special characters
8. **Use Quotes**: When in doubt, quote your variables to handle spaces
9. **Document Outputs**: Clearly document what each output contains

## Troubleshooting

### Common Issues

1. **Output Not Available**: Ensure the job defining the output completes successfully
2. **Empty Output**: Check that the step setting the output actually runs
3. **Special Characters**: Use proper escaping for strings with special characters
4. **Job Dependencies**: Make sure `needs:` is properly configured

### Debugging Tips

- Add `echo` statements to verify output values and user inputs
- Use the Actions logs to trace output generation
- Test with simple static strings before using dynamic values
- Check the "Re-run jobs" option to test different input values
- Use `github.event.inputs.input_name || 'default'` pattern for safety

## Advanced Use Cases

- **Multi-environment Deployments**: Pass environment-specific configuration
- **Version Management**: Generate and propagate version numbers
- **Build Artifacts**: Pass build information between jobs
- **Notification Messages**: Create formatted messages for external systems
- **Configuration Management**: Generate configuration based on inputs

These examples provide a solid foundation for implementing string output and input patterns in your GitHub Actions workflows.