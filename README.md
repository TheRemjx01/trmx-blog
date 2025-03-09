# TRMX Blog

[![Deploy to Vercel](https://github.com/TheRemjx01/trmx-blog/actions/workflows/deploy.yml/badge.svg)](https://github.com/TheRemjx01/trmx-blog/actions/workflows/deploy.yml)
[![Deployed on Vercel](https://img.shields.io/badge/Deployed%20on-Vercel-black?logo=vercel)](https://trmx-blog.vercel.app)
[![Built with Docusaurus](https://img.shields.io/badge/Built%20with-Docusaurus-teal?logo=docusaurus)](https://docusaurus.io)
[![Made with React](https://img.shields.io/badge/Made%20with-React-blue?logo=react)](https://reactjs.org)

My personal blog where I share insights about engineering best practices, architecture patterns, and real-world experiences.

## 🚀 Live Site

Visit the blog at: [https://trmx-blog.vercel.app](https://trmx-blog.vercel.app)

## 💻 Tech Stack

- [Docusaurus](https://docusaurus.io/) - Static site generator
- [React](https://reactjs.org/) - UI Framework
- [TypeScript](https://www.typescriptlang.org/) - Type safety
- [Vercel](https://vercel.com/) - Deployment platform

## ✨ Features

- Modern, responsive design
- Dark mode support
- Code syntax highlighting
- Mermaid diagram support
- Featured posts section
- RSS feed

## 🛠️ Development

```bash
# Install dependencies
npm install

# Start development server
npm start

# Build for production
npm run build

# Serve production build locally
npm run serve
```

## 🔐 Deployment Setup

1. Install GitHub CLI:
   ```bash
   # macOS
   brew install gh
   
   # Windows
   winget install --id GitHub.cli
   
   # Linux
   type -p curl >/dev/null || (sudo apt update && sudo apt install curl -y)
   curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
   && sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg \
   && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
   && sudo apt update \
   && sudo apt install gh -y
   ```

2. Login to GitHub CLI:
   ```bash
   gh auth login
   ```

3. Create Vercel Token:
   - Visit [Vercel Settings > Tokens](https://vercel.com/account/tokens)
   - Click "Create Token"
   - Name: "TRMX Blog Deployment"
   - **Important**: Select "Full Account" scope (required for deployment)
   - Create and copy the token immediately

4. Set up credentials (two options):

   **Option A: Using .env file**
   ```bash
   # Copy the example file
   cp .env.example .env
   
   # Edit .env with your credentials
   VERCEL_TOKEN=your_token_here
   VERCEL_ORG_ID=your_org_id_here
   VERCEL_PROJECT_ID=your_project_id_here
   ```

   **Option B: Interactive input**
   - Skip creating .env file
   - The script will prompt you for credentials

5. Run the setup script:
   ```bash
   ./scripts/setup-secrets.sh
   ```
   The script will:
   - Use credentials from .env if available
   - Fall back to interactive prompts if needed
   - Securely store credentials as GitHub secrets

This will securely set up all required Vercel deployment secrets in your GitHub repository.

## 📝 License

MIT
