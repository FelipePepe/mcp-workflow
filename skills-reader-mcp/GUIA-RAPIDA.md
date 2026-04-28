# 🎯 Guía Rápida: Skills Reader MCP

## ✅ Instalación Completada

Tu servidor MCP para leer skills ya está configurado y listo para usar con VSCode + Ollama.

## 📊 Resumen de tu configuración

- **Skills en ~/.agents/skills:** 11
- **Skills en ~/.claude/skills:** 23
- **Total de skills:** 34

## 🚀 Cómo usar (IMPORTANTE)

### Paso 1: Reiniciar VSCode

**DEBES reiniciar VSCode** para que cargue el nuevo servidor MCP:

```
Ctrl + Shift + P → "Reload Window"
```

O simplemente cierra y abre VSCode.

### Paso 2: Usar en el chat

Una vez reiniciado, en el chat de Copilot puedes usar:

#### Listar todos los skills
```
@skills-reader list_skills
```

#### Leer un skill específico
```
@skills-reader read_skill skill_name="sdd-apply"
```

#### Buscar skills
```
@skills-reader search_skills query="git"
```

#### Cargar todos los skills como contexto
```
@skills-reader get_all_skills_content location="all"
```

## 🤖 Uso con Ollama

Ollama podrá leer automáticamente tus skills cuando uses el servidor MCP. Por ejemplo:

```
# En el chat de Copilot con Ollama
¿Qué hace el skill sdd-apply?

# Copilot + Ollama usará automáticamente:
@skills-reader read_skill skill_name="sdd-apply"
```

## 📝 Skills disponibles

### Project Skills (~/.agents/skills)
- find-skills
- gitflow
- gitflow-feature
- gitflow-hotfix
- gitflow-release
- neon-postgres
- sentry-fix-issues
- sentry-react-setup
- sentry-setup-logging
- vercel-react-best-practices
- webapp-testing

### User Skills (~/.claude/skills)
- branch-pr
- engram-sync
- find-skills
- go-testing
- issue-creation
- judgment-day
- neon-postgres
- sdd-apply
- sdd-archive
- sdd-design
- sdd-explore
- sdd-init
- sdd-propose
- sdd-spec
- sdd-tasks
- sdd-verify
- sentry-fix-issues
- sentry-react-setup
- sentry-setup-logging
- skill-creator
- vercel-react-best-practices
- webapp-testing

## 🛠️ Configuración técnica

### Archivos de configuración

1. **Servidor MCP:**
   - Ubicación: `~/Sources/MCP/skills-reader-mcp/`
   - Compilado: `~/Sources/MCP/skills-reader-mcp/dist/index.js`

2. **Configuración VSCode:**
   - MCP Config: `~/Sources/CursoAI/agent-implementacion/mcp-server/mcp-config-vscode.json`
   - Settings: `~/.config/Code/User/settings.json`

### Verificar que funciona

Después de reiniciar VSCode:

1. Abre el chat de Copilot
2. Escribe: `@skills-reader list_skills`
3. Deberías ver la lista de todos tus skills

Si no aparece `@skills-reader` en el autocompletado, significa que VSCode aún no cargó el servidor. Reinicia VSCode nuevamente.

## 🔄 Recompilar el servidor (si haces cambios)

```bash
cd ~/Sources/MCP/skills-reader-mcp
npm run build
```

Luego reinicia VSCode.

## 🐛 Troubleshooting

### No aparece @skills-reader

1. Verifica que reiniciaste VSCode
2. Revisa Developer Tools (Ctrl+Shift+I) en la pestaña Console
3. Verifica la configuración MCP:
   ```bash
   cat ~/Sources/CursoAI/agent-implementacion/mcp-server/mcp-config-vscode.json
   ```

### No muestra los skills

1. Verifica que existen:
   ```bash
   ls -la ~/.agents/skills/
   ls -la ~/.claude/skills/
   ```

2. Ejecuta el script de verificación:
   ```bash
   ~/Sources/MCP/skills-reader-mcp/verify.sh
   ```

## 📚 Documentación completa

Para más detalles, consulta: `~/Sources/MCP/skills-reader-mcp/README.md`

---

**¡Listo!** Ahora Ollama en VSCode puede leer todos tus ficheros de agentes/skills automáticamente. 🎉
