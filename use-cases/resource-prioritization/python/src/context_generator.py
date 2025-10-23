#!/usr/bin/env python3
"""
Context Generator - A CLI tool for filling prompt templates with data

Usage:
    python context_generator.py --template template.md --data data.json
    python context_generator.py -t template.md -d data.json --output result.md
    cat data.json | python context_generator.py --template template.md
"""

import argparse
import json
import sys
from pathlib import Path
from jinja2 import Environment, FileSystemLoader, StrictUndefined, Undefined
import yaml


class OptionalUndefined(Undefined):
    """
    Custom Undefined class that returns empty string for undefined variables
    and can be serialized to JSON as null.
    """

    def __str__(self):
        return ""

    def __repr__(self):
        return ""

    def __bool__(self):
        return False

    def __len__(self):
        return 0

    def __iter__(self):
        return iter([])

    def __getitem__(self, key):
        return self

    def __getattr__(self, name):
        return self


def load_data(data_source):
    """Load data from file or stdin, supporting JSON and YAML formats."""
    if data_source == "-" or data_source is None:
        # Read from stdin
        content = sys.stdin.read()
    else:
        # Read from file
        with open(data_source, "r", encoding="utf-8") as f:
            content = f.read()

    # Try to parse as JSON first, then YAML
    try:
        return json.loads(content)
    except json.JSONDecodeError:
        try:
            return yaml.safe_load(content)
        except yaml.YAMLError as e:
            print(f"Error: Unable to parse data as JSON or YAML: {e}", file=sys.stderr)
            sys.exit(1)


def load_template(template_path, strict=False):
    """Load and return the Jinja2 template.

    Args:
        template_path: Path to the template file
        strict: If True, raise errors for undefined variables. If False, treat them as empty.
    """
    template_path = Path(template_path)

    if not template_path.exists():
        print(f"Error: Template file '{template_path}' not found", file=sys.stderr)
        sys.exit(1)

    # Setup Jinja2 environment with optional or strict undefined handling
    env = Environment(
        loader=FileSystemLoader(template_path.parent),
        trim_blocks=True,
        lstrip_blocks=True,
        undefined=StrictUndefined if strict else OptionalUndefined,
    )

    # Add custom filters
    def to_json(value, indent=2):
        """Convert value to JSON string with proper formatting.
        Handles OptionalUndefined by converting to null.
        """
        if isinstance(value, OptionalUndefined):
            return "null"
        return json.dumps(value, indent=indent, ensure_ascii=False)

    env.filters["tojson"] = to_json

    try:
        return env.get_template(template_path.name)
    except Exception as e:
        print(f"Error loading template: {e}", file=sys.stderr)
        sys.exit(1)


def render_template(template, data):
    """Render the template with the provided data."""
    try:
        return template.render(**data)
    except Exception as e:
        print(f"Error rendering template: {e}", file=sys.stderr)
        sys.exit(1)


def main():
    parser = argparse.ArgumentParser(
        description="Generate context from template and data",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  # Basic usage with files
  python context_generator.py -t prompt_template.md -d sample_data.json

  # Pipe data from stdin
  cat sample_data.json | python context_generator.py -t prompt_template.md

  # Save output to file
  python context_generator.py -t prompt_template.md -d sample_data.json -o output.md

  # Use YAML data
  python context_generator.py -t prompt_template.md -d data.yaml

  # Pipe output to any AI tool
  python context_generator.py -t prompt_template.md -d data.json | gemini -p "Analyze this"
  python context_generator.py -t prompt_template.md -d data.json | pbcopy
        """,
    )

    parser.add_argument(
        "-t", "--template", required=True, help="Path to the Jinja2 template file"
    )

    parser.add_argument(
        "-d", "--data", help='Path to JSON/YAML data file (use "-" or omit for stdin)'
    )

    parser.add_argument("-o", "--output", help="Output file path (default: stdout)")

    parser.add_argument(
        "--validate-only",
        action="store_true",
        help="Validate template and data by rendering (without outputting result)",
    )

    parser.add_argument(
        "--strict",
        action="store_true",
        help="Raise errors for undefined variables (default: treat as empty/null)",
    )

    args = parser.parse_args()

    # Load data
    data = load_data(args.data)

    # Load template
    template = load_template(args.template, strict=args.strict)

    if args.validate_only:
        # Actually render the template to validate all variables
        try:
            _ = render_template(template, data)
            print(
                "✓ Template and data are valid (rendered successfully)", file=sys.stderr
            )
        except SystemExit:
            # render_template already printed the error
            sys.exit(1)
        return

    # Render template
    result = render_template(template, data)

    # Output result
    if args.output:
        with open(args.output, "w", encoding="utf-8") as f:
            f.write(result)
        print(f"✓ Generated context saved to {args.output}", file=sys.stderr)
    else:
        print(result)


if __name__ == "__main__":
    main()
