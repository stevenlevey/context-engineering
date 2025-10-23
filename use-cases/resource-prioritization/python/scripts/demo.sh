#!/bin/bash

echo "🚀 Context Generator Demo"
echo "========================"
echo

# Check if uv is available
if ! command -v uv &> /dev/null; then
    echo "❌ uv is required but not found. Install it with:"
    echo "   curl -LsSf https://astral.sh/uv/install.sh | sh"
    exit 1
fi

# Install dependencies
echo "📦 Installing dependencies with uv..."
cd "$(dirname "$0")/.." || exit 1
uv sync

echo ""
echo "✅ Testing core functionality..."

# Test 1: Basic generation
echo "📄 Test 1: Generate context from template and data file"
uv run python src/context_generator.py -t prompt/prompt_template.md -d data/sample_data.json -o output/test_output.md
if [ $? -eq 0 ]; then
    echo "✅ Generated output/test_output.md successfully"
else
    echo "❌ Failed to generate output"
    exit 1
fi

# Test 2: Validation only
echo ""
echo "🔍 Test 2: Validate template and data"
uv run python src/context_generator.py -t prompt/prompt_template.md -d data/sample_data.json --validate-only
if [ $? -eq 0 ]; then
    echo "✅ Template and data validation passed"
else
    echo "❌ Validation failed"
    exit 1
fi

# Test 3: Pipe data
echo ""
echo "🔄 Test 3: Pipe data from stdin"
cat data/sample_data.json | uv run python src/context_generator.py -t prompt/prompt_template.md > /dev/null
if [ $? -eq 0 ]; then
    echo "✅ Stdin piping works correctly"
else
    echo "❌ Stdin piping failed"
    exit 1
fi

# Test 4: Output to stdout
echo ""
echo "📤 Test 4: Output to stdout (showing first 10 lines)"
uv run python src/context_generator.py -t prompt/prompt_template.md -d data/sample_data.json | head -10
if [ $? -eq 0 ]; then
    echo "✅ Stdout output works correctly"
else
    echo "❌ Stdout output failed"
    exit 1
fi

echo ""
echo "🎉 All tests passed! The context generator is working correctly."
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📖 Usage Examples"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "  # Generate and view context"
echo "  uv run python src/context_generator.py -t prompt/prompt_template.md -d data/sample_data.json"
echo ""
echo "  # Save to output directory"
echo "  uv run python src/context_generator.py -t prompt/prompt_template.md -d data/sample_data.json -o output/result.md"
echo ""
echo "  # Pipe data from stdin"
echo "  cat data/sample_data.json | uv run python src/context_generator.py -t prompt/prompt_template.md"
echo ""
echo "  # Validate without generating"
echo "  uv run python src/context_generator.py -t prompt/prompt_template.md -d data/sample_data.json --validate-only"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔌 Pipe to AI Tools"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "The generated context can be piped to any AI tool or system:"
echo ""
echo "  # Copy to clipboard (macOS)"
echo "  uv run python src/context_generator.py -t prompt/prompt_template.md -d data/sample_data.json | pbcopy"
echo ""
echo "  # Pipe to Gemini CLI"
echo "  uv run python src/context_generator.py -t prompt/prompt_template.md -d data/sample_data.json | gemini -p 'What should I prioritize?'"
echo ""
echo "  # Pipe to any custom tool"
echo "  uv run python src/context_generator.py -t prompt/prompt_template.md -d data/sample_data.json | your-ai-tool"
echo ""
echo "  # Save and use with Claude, ChatGPT, or other AI systems"
echo "  uv run python src/context_generator.py -t prompt/prompt_template.md -d data/sample_data.json -o prompt.txt"
echo ""

# Show preview of generated output
if [ -f "output/test_output.md" ]; then
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "📄 Preview of Generated Context"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    head -20 output/test_output.md
    echo ""
    echo "... (see output/test_output.md for full content)"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
fi

echo ""
echo "✨ Demo complete! For more help: uv run python src/context_generator.py --help"
