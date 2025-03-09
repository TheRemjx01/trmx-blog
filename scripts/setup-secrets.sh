#!/bin/bash

# Check if gh CLI is installed
if ! command -v gh &> /dev/null; then
    echo "GitHub CLI (gh) is not installed. Please install it first:"
    echo "https://cli.github.com/"
    exit 1
fi

# Check if logged in to GitHub
if ! gh auth status &> /dev/null; then
    echo "Please login to GitHub first:"
    echo "gh auth login"
    exit 1
fi

# Function to validate input is not empty
validate_input() {
    if [ -z "$1" ]; then
        echo "Input cannot be empty" >&2
        exit 1
    fi
}

# Instructions for getting Vercel credentials
print_instructions() {
    echo "=== Vercel Token Setup Guide ==="
    echo "1. Go to https://vercel.com/account/tokens"
    echo "2. Click 'Create Token'"
    echo "3. Name it 'TRMX Blog Deployment'"
    echo "4. Select 'Full Account' scope (required for deployment)"
    echo "5. Copy the token immediately after creation"
    echo
    echo "=== Vercel Project Setup ==="
    echo "For Organization ID:"
    echo "1. Go to Vercel Dashboard"
    echo "2. Click on your organization/username"
    echo "3. Copy the ID from the URL: vercel.com/team_id"
    echo
    echo "For Project ID:"
    echo "1. Go to your project settings"
    echo "2. Scroll to 'Project ID'"
    echo "3. Copy the ID"
    echo
} >&2

# Try to load from .env file
ENV_FILE=".env"
if [ -f "$ENV_FILE" ]; then
    echo "Loading credentials from .env file..." >&2
    source "$ENV_FILE"
else
    echo "No .env file found. You can create one with:" >&2
    echo "VERCEL_TOKEN=your_token" >&2
    echo "VERCEL_ORG_ID=your_org_id" >&2
    echo "VERCEL_PROJECT_ID=your_project_id" >&2
    echo >&2
    print_instructions
fi

# Function to get credential with fallback to interactive input
get_credential() {
    local var_name=$1
    local prompt=$2
    local value=${!var_name}

    if [ -z "$value" ]; then
        echo "No $var_name found in .env file" >&2
        read -p "$prompt: " value
    else
        echo "✓ Found $var_name in .env file" >&2
    fi

    validate_input "$value"
    printf "%s" "$value"
}

# Get credentials with fallback to interactive input
VERCEL_TOKEN=$(get_credential "VERCEL_TOKEN" "Vercel Token (with Full Account scope)")
VERCEL_ORG_ID=$(get_credential "VERCEL_ORG_ID" "Vercel Organization ID")
VERCEL_PROJECT_ID=$(get_credential "VERCEL_PROJECT_ID" "Vercel Project ID")

# Set GitHub secrets
echo "Setting up GitHub secrets..." >&2

gh secret set VERCEL_TOKEN --body "$VERCEL_TOKEN"
if [ $? -eq 0 ]; then
    echo "✅ VERCEL_TOKEN set successfully" >&2
else
    echo "❌ Failed to set VERCEL_TOKEN" >&2
    exit 1
fi

gh secret set VERCEL_ORG_ID --body "$VERCEL_ORG_ID"
if [ $? -eq 0 ]; then
    echo "✅ VERCEL_ORG_ID set successfully" >&2
else
    echo "❌ Failed to set VERCEL_ORG_ID" >&2
    exit 1
fi

gh secret set VERCEL_PROJECT_ID --body "$VERCEL_PROJECT_ID"
if [ $? -eq 0 ]; then
    echo "✅ VERCEL_PROJECT_ID set successfully" >&2
else
    echo "❌ Failed to set VERCEL_PROJECT_ID" >&2
    exit 1
fi

echo >&2
echo "🎉 All secrets have been set successfully!" >&2
echo "Your GitHub Actions workflow should now be able to deploy to Vercel" >&2 