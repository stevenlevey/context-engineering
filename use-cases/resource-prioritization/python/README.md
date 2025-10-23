# Context Generator: Engineering Your Prompts as Code

The simple concept for **context engineering**: take your prompt template, merge it with data from any source system, and send the output to any LLM to process. You can automate this process and deploy it anywhere—as a CLI tool, in a Docker container, as a 4am workflow, or embedded inline in any process.

**Why it matters**: Stop manually copying and pasting context. Template your prompt once, extract data from source systems, and systematically generate context. Version control it like code.

## The Core Concept

```
Your Prompt Template  +  Data from Source System  =  Generated Prompt  -> Any LLM
       (fixed)              (changes daily)            (ready to use)
```

That's it. This tool is an example of how you can handle the `+` (merge operation) in a more systematic way.

### Example Deployment Patterns

**1. Command Line** (Manual, on-demand)

```
Data File → Context Generator → Output → Copy to Clipboard → Paste into Claude/ChatGPT
```

```bash
cat data/sample_data.json | uv run python src/context_generator.py -t prompt/prompt_template.md | pbcopy
```

**2. Scheduled Workflow** (Daily/automated)

```
Cron (4am) → Fetch Fresh Data → Context Generator → Send to Slack/Email
```

**3. Docker Container** (Deployable anywhere)

```
CI/CD Trigger → Docker Container (Context Generator) → Store Output / Trigger Action
```

**4. Embedded in Pipeline** (Inline with other processes)

```
Log File → Parse → Context Generator → Create Issue / Trigger Workflow
```

All four patterns use the same core operation: **Template + Data → Generated Prompt**. The deployment method depends on your workflow needs.

## Why This Approach

- **Simple**: One concept, many deployment options
- **Flexible**: Works with any source system, any AI tool
- **Version Controlled**: Your templates are text files in Git
- **Testable**: Same template always produces predictable structure
- **Scalable**: From manual CLI use to automated production pipelines

## The Simplicity

You need exactly three things:

1. **A template file** (your prompt with variables)
2. **Data** (from any source system)
3. **A way to merge them** (This tool as an example, or your own code)

Then deploy the output wherever you need it.

## How to Get Started

### 1. Install

```bash
cd use-cases/resource-prioritization/python
uv sync
```

### 2. Create Your Template

Replace hard-coded data in your prompt with `{{variable}}` and loops with `{% for item in items %}`. See `prompt/prompt_template.md` for a full example.

### 3. Get Your Data

Export from any source (JIRA, GitHub, database, API, etc.) as JSON or YAML.

### 4. Generate

```bash
uv run python src/context_generator.py -t your_template.md -d your_data.json
```

### 5. Deploy

Pipe to your AI tool (Claude, ChatGPT, Gemini) or automate it in your workflow.

## Project Structure

```
use-cases/resource-prioritization/python/
├── README.md              # This file
├── pyproject.toml         # UV project configuration
├── uv.lock                # UV lock file
├── .gitignore            # Git ignore rules
│
├── src/                   # Core application
│   └── context_generator.py
│
├── prompt/                # Prompt templates
│   └── prompt_template.md     # Sample Jinja2 template
│
├── data/                  # Sample data files
│   ├── sample_data.json       # Sample JSON data
│   └── data.yaml              # Sample YAML data
│
├── scripts/               # Demo and test scripts
│   └── demo.sh                # Comprehensive demo script
│
└── output/                # Generated outputs (gitignored)
    └── .gitkeep
```

## Prerequisites

- **Python 3.8 or higher**
- **[uv](https://docs.astral.sh/uv/)** - Fast Python package installer and resolver

### Installing UV

If you don't have uv installed:

```bash
curl -LsSf https://astral.sh/uv/install.sh | sh
```

## Quick Start

### 1. Install Dependencies

```bash
# Navigate to the project directory
cd use-cases/resource-prioritization/python

# Install dependencies using uv (creates isolated environment)
uv sync
```

### 2. Run the Demo

```bash
# Run comprehensive demo script with tests and examples
./scripts/demo.sh
```

### 3. Basic Usage

```bash
# Generate and view output
uv run python src/context_generator.py -t prompt/prompt_template.md -d data/sample_data.json

# Save to file
uv run python src/context_generator.py -t prompt/prompt_template.md -d data/sample_data.json -o output/result.md

# Validate without generating
uv run python src/context_generator.py -t prompt/prompt_template.md -d data/sample_data.json --validate-only
```

## Usage Examples

### Basic Operations

```bash
# Output to stdout (default)
uv run python src/context_generator.py -t prompt/prompt_template.md -d data/sample_data.json

# Save to file
uv run python src/context_generator.py -t prompt/prompt_template.md -d data/sample_data.json -o output/result.md

# Use YAML data instead of JSON
uv run python src/context_generator.py -t prompt/prompt_template.md -d data/data.yaml

# Pipe JSON from stdin
cat data/sample_data.json | uv run python src/context_generator.py -t prompt/prompt_template.md

# Use partial data (undefined variables become empty/null)
echo '{"company_name": "TechCorp", "current_quarter": "Q3 2025"}' | uv run python src/context_generator.py -t prompt/prompt_template.md

# Strict mode: error on undefined variables
uv run python src/context_generator.py -t prompt/prompt_template.md -d data/data.yaml --strict
```

### Integrating with AI Systems

The tool is AI-agnostic and works with any system via Unix pipes:

```bash
# Copy to clipboard (macOS)
uv run python src/context_generator.py -t prompt/prompt_template.md -d data/sample_data.json | pbcopy

# Copy to clipboard (Linux)
uv run python src/context_generator.py -t prompt/prompt_template.md -d data/sample_data.json | xclip -selection clipboard

# Pipe to Gemini CLI
uv run python src/context_generator.py -t prompt/prompt_template.md -d data/sample_data.json | gemini -p "What should I prioritize?"

# Pipe to any AI CLI tool
uv run python src/context_generator.py -t prompt/prompt_template.md -d data/sample_data.json | your-ai-tool
```

### Real-World Workflows

```bash
# Engineering manager weekly analysis
uv run python src/context_generator.py \
  -t templates/weekly_review.md \
  -d data/sprint_data.json \
  | gemini -p "What should I prioritize this week?"

# Product decision making
uv run python src/context_generator.py \
  -t templates/product_context.md \
  -d data/user_metrics.json \
  -o output/product_prompt.md
# Then paste into Claude or ChatGPT

# Risk assessment
cat data/project_status.json \
  | uv run python src/context_generator.py -t templates/risk_analysis.md \
  | pbcopy
# Then paste into any AI system
```

## Command Line Options

| Option            | Description                                                         |
| ----------------- | ------------------------------------------------------------------- |
| `-t, --template`  | Path to the Jinja2 template file (required)                         |
| `-d, --data`      | Path to JSON/YAML data file (optional, defaults to stdin)           |
| `-o, --output`    | Output file path (optional, defaults to stdout)                     |
| `--validate-only` | Validate template and data by rendering (without outputting result) |
| `--strict`        | Raise errors for undefined variables (default: treat as empty/null) |
| `--help`          | Show help message and exit                                          |

## Features

- ✅ **Simple & Focused**: Does one thing well - renders templates with data (Unix philosophy)
- ✅ **Full Jinja2 Support**: Variables, loops, conditionals, filters, inheritance
- ✅ **Flexible Input**: JSON or YAML data, or pipe from stdin
- ✅ **Optional Variables**: Undefined variables default gracefully (use `--strict` for validation)
- ✅ **AI-Agnostic**: No vendor lock-in. Works with Claude, ChatGPT, Gemini, Anthropic API, custom models
- ✅ **Pipeline-Friendly**: Designed for Unix pipes - integrate with bash scripts, cron jobs, cloud functions
- ✅ **Version Controllable**: Templates are text files. Store in Git. Track changes. Review diffs.
- ✅ **Validation**: Use `--validate-only` to catch template/data issues before deployment
- ✅ **Zero External Dependencies on AI**: Core tool has no AI integrations - you choose the LLM

## Template Syntax

The tool uses Jinja2 templating syntax. Here are some common patterns:

### Variables

```jinja2
{{company_name}}
{{current_quarter}}
```

### Loops

```jinja2
{% for deadline in critical_deadlines -%}
- {{deadline.description}} ({{deadline.date}})
{% endfor -%}
```

### Conditionals

```jinja2
{% if ticket.blocked_reason %}
"blockedReason": "{{ticket.blocked_reason}}"
{% endif %}
```

### JSON Output with Filters

```jinja2
{
  {% for team, count in allocation.resources.items() -%}
  "{{team}}": {{count}}{% if not loop.last %},{% endif %}
  {% endfor %}
}
```

Or use the `tojson` filter for automatic formatting:

```jinja2
{{team_structure|tojson}}
```

## Variable Handling: Optional vs Strict Mode

By default, the tool operates in **optional mode**, where undefined variables are treated gracefully:

```bash
# Default: undefined variables become empty strings or null
echo '{"name": "Alice"}' | uv run python src/context_generator.py -t template.md
```

**Optional Mode (Default)**:

- Missing variables render as empty strings in text
- Missing variables render as `null` in JSON output
- Loops over undefined lists produce no output
- Useful for partial data or iterative template development

**Strict Mode** (with `--strict` flag):

- Raises errors for any undefined variable
- Ensures all template variables have values
- Useful for production workflows where completeness is critical

```bash
# Strict mode: error if variables are missing
uv run python src/context_generator.py -t template.md -d data.json --strict
```

**When to use each mode:**

- 🔹 **Optional Mode**: Development, partial data, flexible prompts
- 🔹 **Strict Mode**: Production, data validation, ensuring completeness

## Data Structure

Your JSON/YAML data should match the variables used in your template. See `data/sample_data.json` and `data/data.yaml` for complete examples that work with `prompt/prompt_template.md`.

In optional mode (default), you can provide partial data and undefined variables will be handled gracefully. In strict mode, all template variables must be present in your data.

## Development

### Project Configuration

This project uses UV for dependency management with the following configuration:

- **Python Version**: 3.8+
- **Dependencies**: `jinja2>=3.0.0`, `pyyaml>=6.0`
- **Build System**: hatchling

### Adding Dependencies

```bash
# Add a new dependency
uv add package-name

# Add a development dependency
uv add --dev package-name
```

### Running Tests

```bash
# Run the demo script which includes basic tests
./scripts/demo.sh
```

## Troubleshooting

### Common Issues

**"uv: command not found"**

- Install uv: `curl -LsSf https://astral.sh/uv/install.sh | sh`
- Restart your terminal after installation

**Template rendering errors**

- Use `--validate-only` to check for syntax issues
- Ensure all template variables have corresponding data
- Check JSON/YAML syntax in your data file

**Permission denied on demo.sh**

- Run: `chmod +x scripts/demo.sh`

**JSON formatting issues in output**

- Use the `|tojson` filter in templates for proper JSON formatting
- Example: `{{variable_name|tojson}}`

### Getting Help

For command-line help:

```bash
uv run python src/context_generator.py --help
```

Run the demo to see examples in action:

```bash
./scripts/demo.sh
```

## Use Case: Context Engineering

This tool shows **one basic approach** to context engineering:

1. Identify a prompt you want to repeatedly generate
2. Extract the parts that change (data from Jira, GitHub, databases, etc.)
3. Template the rest (your prompt structure)
4. Merge them together (this tool)
5. Deploy in whatever way fits your workflow

The deployment can be:

- A manual CLI command when you need it
- A cron job running at 4am
- A Docker container in your pipeline
- Embedded in an existing process
- Any other way you can execute a command

All approaches use the same basic principle: **Template + Data = Output**. Version controlled.

## Who Uses This

- **Anyone with repetitive prompt patterns**: Running the same analysis, same question, different data
- **Teams automating decision-making**: Weekly reviews, risk assessments, incident analysis
- **Data pipelines**: Where the output is a structured prompt for AI analysis
- **Workflows**: Anywhere you'd normally copy/paste context into a chat tool

## License

Part of the context-engineering repository.
