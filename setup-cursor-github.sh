#!/bin/bash

# Script to pull .cursor and .github folders from python-lib-template repository
# Usage: curl -sSL https://raw.githubusercontent.com/dotle-git/python-lib-template/main/setup-cursor-github.sh | bash

set -e

REPO_URL="https://github.com/dotle-git/python-lib-template"
RAW_URL="https://raw.githubusercontent.com/dotle-git/python-lib-template/main"

echo "🚀 Setting up .cursor and .github folders from python-lib-template..."

# Check if we're in a git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo "❌ Error: Not in a git repository. Please run this script from within a git repository."
    exit 1
fi

# Function to detect if this is already a Python project
detect_existing_project() {
    local has_pyproject=false
    local has_setup_py=false
    local has_requirements=false
    local has_src_structure=false
    local has_tests=false
    
    # Check for common Python project files
    if [[ -f "pyproject.toml" ]] || [[ -f "setup.py" ]] || [[ -f "setup.cfg" ]]; then
        has_pyproject=true
    fi
    
    if [[ -f "requirements.txt" ]] || [[ -f "requirements-dev.txt" ]]; then
        has_requirements=true
    fi
    
    if [[ -d "src" ]] && [[ -n "$(find src -name "*.py" 2>/dev/null)" ]]; then
        has_src_structure=true
    fi
    
    if [[ -d "tests" ]] && [[ -n "$(find tests -name "*.py" 2>/dev/null)" ]]; then
        has_tests=true
    fi
    
    # Consider it an existing project if it has at least 2 of these indicators
    local indicators=0
    [[ "$has_pyproject" == true ]] && ((indicators++))
    [[ "$has_requirements" == true ]] && ((indicators++))
    [[ "$has_src_structure" == true ]] && ((indicators++))
    [[ "$has_tests" == true ]] && ((indicators++))
    
    if [[ $indicators -ge 2 ]]; then
        echo "true"
    else
        echo "false"
    fi
}

# Detect if this is an existing project
IS_EXISTING_PROJECT=$(detect_existing_project)

if [[ "$IS_EXISTING_PROJECT" == "true" ]]; then
    echo "📋 Detected existing Python project - only copying .cursor, .github, and docs/agentdocs"
    COPY_TEMPLATE=false
else
    echo "🆕 No existing Python project detected - will copy full template"
    COPY_TEMPLATE=true
fi

# Always create .cursor directory and download files
echo "📁 Creating .cursor directory..."
mkdir -p .cursor

# Download .cursor files
echo "⬇️  Downloading .cursor files..."
curl -sSL "$RAW_URL/.cursor/environment.json" -o .cursor/environment.json
curl -sSL "$RAW_URL/.cursor/Dockerfile" -o .cursor/Dockerfile

# Create .cursor/rules directory and download rules
echo "📁 Creating .cursor/rules directory..."
mkdir -p .cursor/rules

# Download .cursor/rules files
echo "⬇️  Downloading .cursor/rules files..."
curl -sSL "$RAW_URL/.cursor/rules/pypi-publish-rules.mdc" -o .cursor/rules/pypi-publish-rules.mdc
curl -sSL "$RAW_URL/.cursor/rules/doc-writing-rules.md" -o .cursor/rules/doc-writing-rules.md

# Always create .github directory structure
echo "📁 Creating .github directory structure..."
mkdir -p .github/workflows

# Download .github/workflows files
echo "⬇️  Downloading GitHub Actions workflows..."
curl -sSL "$RAW_URL/.github/workflows/test.yml" -o .github/workflows/test.yml
curl -sSL "$RAW_URL/.github/workflows/pypi-publish.yml" -o .github/workflows/pypi-publish.yml

# Always create docs/agentdocs directory
echo "📁 Creating docs/agentdocs directory..."
mkdir -p docs/agentdocs
echo "# Agent Documentation" > docs/agentdocs/.gitkeep
echo "# This directory is for agent-specific documentation" >> docs/agentdocs/.gitkeep

# Copy template files only if no existing project
if [[ "$COPY_TEMPLATE" == "true" ]]; then
    echo "📋 Copying Python library template files..."
    
    # Download pyproject.toml
    echo "⬇️  Downloading pyproject.toml..."
    curl -sSL "$RAW_URL/pyproject.toml" -o pyproject.toml
    
    # Download .gitignore
    echo "⬇️  Downloading .gitignore..."
    curl -sSL "$RAW_URL/.gitignore" -o .gitignore
    
    # Download LICENSE
    echo "⬇️  Downloading LICENSE..."
    curl -sSL "$RAW_URL/LICENSE" -o LICENSE
    
    # Create src directory structure
    echo "📁 Creating src directory structure..."
    mkdir -p src/python_lib_template
    
    # Download __init__.py
    echo "⬇️  Downloading src/python_lib_template/__init__.py..."
    curl -sSL "$RAW_URL/src/python_lib_template/__init__.py" -o src/python_lib_template/__init__.py
    
    # Create tests directory and download test file
    echo "📁 Creating tests directory..."
    mkdir -p tests
    
    # Download test file
    echo "⬇️  Downloading tests/test_dummy.py..."
    curl -sSL "$RAW_URL/tests/test_dummy.py" -o tests/test_dummy.py
    
    # Download README.md (only if it doesn't exist or is very basic)
    if [[ ! -f "README.md" ]] || [[ $(wc -l < README.md) -lt 5 ]]; then
        echo "⬇️  Downloading README.md..."
        curl -sSL "$RAW_URL/README.md" -o README.md
    fi
    
    echo "✅ Template files copied successfully!"
else
    echo "⏭️  Skipping template files (existing project detected)"
fi

# Add files to git
echo "📝 Adding files to git..."
git add .cursor/ .github/ docs/

if [[ "$COPY_TEMPLATE" == "true" ]]; then
    git add pyproject.toml .gitignore LICENSE src/ tests/ README.md
fi

echo ""
echo "✅ Successfully set up project with .cursor, .github folders, and docs/agentdocs directory!"
if [[ "$COPY_TEMPLATE" == "true" ]]; then
    echo "📋 Full Python library template has been applied!"
fi

echo ""
echo "📋 Next steps:"
echo "   1. Review the downloaded files and customize them for your project"
if [[ "$COPY_TEMPLATE" == "true" ]]; then
    echo "   2. Update pyproject.toml with your project details (name, description, author, etc.)"
    echo "   3. Rename src/python_lib_template/ to match your project name"
    echo "   4. Update the package name in pyproject.toml and src directory"
fi
echo "   5. Commit the changes: git commit -m 'Add .cursor and .github configuration from python-lib-template'"
echo "   6. Push to your repository: git push"
echo ""
echo "🔗 Original repository: $REPO_URL"
echo "📚 You may want to customize the GitHub Actions workflows and Cursor rules for your specific project needs."
echo "📖 The docs/agentdocs directory is ready for your agent documentation."
