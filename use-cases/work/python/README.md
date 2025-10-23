# Context Generator CLI Tool

A command-line tool for filling Jinja2 prompt templates with JSON or YAML data. This tool helps you generate rich, data-driven prompts for AI systems by combining reusable templates with structured data.

**Philosophy**: This tool focuses on doing one thing well - generating context from templates. It's completely AI-agnostic and integrates with any AI system via standard Unix piping.

## Project Structure

```
use-cases/work/python/
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
cd use-cases/work/python

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

- ✅ **Flexible Input**: Supports JSON and YAML data formats
- ✅ **Stdin Support**: Can read data from pipes or stdin
- ✅ **Optional Variables**: Undefined variables default to empty/null (use `--strict` for errors)
- ✅ **Error Handling**: Clear error messages for template and data issues
- ✅ **Full Validation**: `--validate-only` renders template to catch issues before generation
- ✅ **Jinja2 Features**: Full support for Jinja2 templating including loops, conditionals, and filters
- ✅ **AI-Agnostic**: Works with any AI system via standard Unix pipes
- ✅ **Clean Structure**: Organized project layout with separation of concerns
- ✅ **Zero Dependencies on AI Tools**: Core tool has no external AI integrations

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

This tool is designed for **context engineering** - the practice of crafting effective prompts for AI systems. It's particularly useful for:

### Who Should Use This

- **Engineering Managers**: Generate weekly priority analysis from project data
- **Product Teams**: Create structured context from user research and metrics
- **Development Teams**: Combine code metrics, sprint data, and technical context for AI analysis
- **AI Workflows**: Any scenario where you need to repeatedly generate similar prompts with different data

### Benefits

By separating your prompt template from your data, you can:

- ✅ **Reuse** prompt structures across different contexts
- ✅ **Version control** your prompt templates
- ✅ **Generate consistent**, well-structured prompts
- ✅ **Easily update** prompts without modifying data pipelines
- ✅ **Work with any AI** - Claude, ChatGPT, Gemini, or custom models
- ✅ **Automate** prompt generation in your workflows

### Example Use Cases

1. **Weekly Team Reviews**

   - Template: Team structure, current sprint, blockers
   - Data: Pull from JIRA, GitHub, etc.
   - Question: "What should I prioritize this week?"

2. **Risk Assessment**

   - Template: Project status, deadlines, resource allocation
   - Data: Project management tools
   - Question: "What are the biggest risks?"

3. **Technical Decisions**

   - Template: System architecture, constraints, requirements
   - Data: Architecture diagrams, performance metrics
   - Question: "What approach should we take?"

4. **User Research Analysis**
   - Template: User feedback, metrics, goals
   - Data: Analytics, surveys, interviews
   - Question: "What features should we build next?"

## Philosophy: Unix Way

This tool follows the Unix philosophy:

- **Do one thing well**: Generate context from templates
- **Work together**: Pipe to any AI tool or system
- **Text streams**: Universal interface via stdin/stdout

We intentionally avoid baking in specific AI integrations. Instead, we provide a solid foundation that works with any tool you choose.

## License

Part of the context-engineering repository.
