<h1 align="center">VaultAI Code Assistant</h1>

<div align="center">

**On-premise AI Code Assistant for Enterprises**

**Data Sovereignty • Customizable • Multi-model Support**

</div>

<div align="center">

Available on [VS Code](https://marketplace.visualstudio.com/items?itemName=VaultAI.vaultai-code-assistant) and JetBrains (coming soon)

📚 [Documentation](https://docs.vaultai.eu) • 🌐 [Website](https://vaultai.eu) • 📄 [License: Apache 2.0](./LICENSE)

</div>

---

**🔒 Enterprise fork of [Continue.dev](https://github.com/continuedev/continue) with focus on data sovereignty**

## 🚀 Features

### 💬 AI Chat

Ask questions about your code, get explanations and intelligent suggestions.

### ✏️ Code Editing

Modify your code with natural language instructions without leaving your file.

### ⚡ Autocomplete

Receive inline code suggestions as you type.

### 🤖 Autonomous Agents

Delegate complex tasks to AI agents that work alongside you.

## 🔐 Why VaultAI?

- **🏢 On-premise**: Your data stays in your infrastructure
- **🔒 Data Sovereignty**: Full control over your models and data
- **🎯 Customizable**: Adapt the assistant to your specific needs
- **🌍 Multi-model**: Support for OpenAI, Anthropic, Mistral, LLaMA, and more
- **🇪🇺 EU-focused**: Built for European enterprises with GDPR compliance in mind

## 📦 Installation

### VS Code

```bash
# Via marketplace
code --install-extension VaultAI.vaultai-code-assistant

# Or search "VaultAI" in the Extensions tab
```

### JetBrains

🚧 Coming soon on JetBrains Marketplace

## 🛠️ Configuration

1. Open VaultAI in your IDE
2. Configure your AI models (OpenAI, Anthropic, Mistral, or local models)
3. Start coding with AI!

Full documentation: [docs.vaultai.eu](https://docs.vaultai.eu)

## 🏗️ Development

This project is a fork of [Continue.dev](https://github.com/continuedev/continue) with enhancements for secure enterprises.

### Build from source

```bash
# Clone the repo
git clone https://github.com/VaultAI/vault-code-assistant.git
cd vault-code-assistant

# Install dependencies
npm install

# Build core
cd core && npm run build

# Build VS Code extension
cd ../extensions/vscode
npm run package-all
```

See [BUILD_EXTENSION_GUIDE.md](BUILD_EXTENSION_GUIDE.md) for more details.

## 📄 License

[Apache 2.0 © 2023-2025 Continue Dev, Inc.](./LICENSE)

VaultAI Fork © 2024-2025 VaultAI SAS

## 🤝 Support

- 📧 Email: [support@vaultai.eu](mailto:support@vaultai.eu)
- 🌐 Website: [vaultai.eu](https://vaultai.eu)
- 📚 Documentation: [docs.vaultai.eu](https://docs.vaultai.eu)

---

**Powered by Continue.dev • Adapted for European Enterprises**
