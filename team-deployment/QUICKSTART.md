# Quick Start - Skills & MCP Deployment

## One-Line Install

### Linux / macOS
```bash
curl -fsSL https://your-server.com/install.sh | bash
```

### Windows (PowerShell as Admin)
```powershell
iwr -useb https://your-server.com/install.ps1 | iex
```

---

## Manual Install (Recommended)

### 1. Download

Download the latest package from your team's distribution channel.

### 2. Extract

**Linux/macOS:**
```bash
tar -xzf skills-mcp-deployment-*.tar.gz
cd team-deployment
```

**Windows:**
- Right-click the file → Extract All
- Or use 7-Zip / WinRAR

### 3. Install

**Linux/macOS:**
```bash
bash scripts/install-linux.sh
```

**Windows:**
```powershell
powershell -ExecutionPolicy Bypass -File scripts\install-windows.ps1
```

### 4. Restart VSCode

Press `Ctrl + Shift + P` and type "Reload Window"

### 5. Test

In Copilot chat:
```
@skills-reader list_skills
```

---

## What's Installed?

- **~/.agents/skills/** - Project skills (shared)
- **~/.claude/skills/** - User skills (personal)
- **~/.mcp-servers/** - MCP server
- **VSCode config** - Automatic MCP integration

---

## Next Steps

1. Read [DEPLOYMENT-GUIDE.md](DEPLOYMENT-GUIDE.md)
2. Try: `@skills-reader list_skills`
3. Read a skill: `@skills-reader read_skill skill_name="sdd-apply"`

---

## Need Help?

- **Documentation:** [DEPLOYMENT-GUIDE.md](DEPLOYMENT-GUIDE.md)
- **FAQ:** [FAQ.md](FAQ.md)
- **Contact:** Your team administrator
