# 🧰 MyDevToolbox

**MyDevToolbox** is a personal monorepo containing custom CLI tools, automation scripts, and utilities designed to speed up my development workflow on macOS and Windows.

## 🚀 Core Tools

### 1. Ignite (`ignite`)
A custom project scaffolder that instantly generates boilerplate code and folder structures.
- **Location:** `src/New-Project.ps1`
- **Usage:**
  - `ignite MyApp -Type Python` (Full Project)
  - `new script_name` (Quick Python Script)
  - `ignite list` (Show all options)

### 2. AD & LDAP Utilities
Scripts for managing and auditing Active Directory and LDAP environments.
- **Location:** `src/ad-tools/`
- **Features:** Circular group detection, remediation, and cross-platform LDAP testing.

### 3. Docker Helpers
Utilities for managing local container environments.
- **Location:** `src/docker-tools/`
- **Features:** Cleanup scripts, test environment spinners.

## 📂 Repository Structure

```text
MyDevToolbox/
├── src/                  # Source code for all tools
│   ├── New-Project.ps1   # The 'Ignite' tool
│   ├── ad-tools/         # Active Directory scripts
│   └── docker-tools/     # Docker helpers
├── tests/                # Pester tests for these tools
├── docs/                 # Documentation and cheat sheets
└── setup/                # Scripts to bootstrap this toolbox on a new machine
```

## 🛠️ Installation (How to use this on a new Mac)

1. **Clone the repo:**
   ```bash
   git clone https://github.com/YOUR_USERNAME/MyDevToolbox.git ~/DevTools/MyDevToolbox
   ```

2. **Add to Shell Configuration (`~/.zshrc`):**
   ```bash
   # Ignite Tool Alias
   function ignite() {
       pwsh ~/DevTools/MyDevToolbox/src/New-Project.ps1 "$@"
   }
   
   # Quick Shortcut
   function new() {
       if [ -z "$1" ]; then ignite; else ignite "$1" -Simple; fi
   }
   ```

3. **Reload Shell:**
   ```bash
   source ~/.zshrc
   ```

## 🔄 Updates
To pull the latest version of tools from any machine:
```bash
ignite update
```
