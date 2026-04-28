# 📦 Deployment de Skills y MCP Servers - Guía del Equipo

## 🎯 Objetivo

Este paquete instala automáticamente:
- **Skills/Agentes** de desarrollo en `~/.agents/skills` y `~/.claude/skills`
- **Servidor MCP** para que VSCode/Ollama pueda leer los skills automáticamente

## 📋 Requisitos

### Para todos (Windows y Linux)

- **Node.js** 18 o superior ([Descargar](https://nodejs.org/))
- **npm** (incluido con Node.js)
- **Git** ([Descargar](https://git-scm.com/))
- **VSCode** con GitHub Copilot instalado

### Verificar requisitos

**Linux/macOS:**
```bash
node --version  # debe ser v18+
npm --version
git --version
```

**Windows (PowerShell):**
```powershell
node --version  # debe ser v18+
npm --version
git --version
```

## 🚀 Instalación

### Linux / macOS

1. **Descargar y descomprimir el paquete:**
   ```bash
   tar -xzf skills-mcp-deployment-XXXXXX.tar.gz
   cd team-deployment
   ```

2. **Ejecutar el script de instalación:**
   ```bash
   bash scripts/install-linux.sh
   ```

3. **Reiniciar VSCode:**
   - Presiona `Ctrl + Shift + P`
   - Escribe "Reload Window"
   - Presiona Enter

### Windows

1. **Descargar y descomprimir el paquete:**
   - Clic derecho en el archivo `.tar.gz` → Extraer todo
   - O usar 7-Zip / WinRAR

2. **Ejecutar el script de instalación:**
   - Clic derecho en `scripts\install-windows.ps1`
   - Selecciona "Ejecutar con PowerShell"
   
   **O desde PowerShell:**
   ```powershell
   cd team-deployment
   powershell -ExecutionPolicy Bypass -File scripts\install-windows.ps1
   ```

3. **Reiniciar VSCode:**
   - Presiona `Ctrl + Shift + P`
   - Escribe "Reload Window"
   - Presiona Enter

## ✅ Verificar instalación

Una vez reiniciado VSCode:

1. Abre el **chat de Copilot** (Ctrl + Shift + I o icono de chat)
2. Escribe: `@skills-reader list_skills`
3. Deberías ver una lista de todos los skills disponibles

## 📝 Uso diario

### Comandos básicos

```
@skills-reader list_skills
→ Ver todos los skills disponibles

@skills-reader read_skill skill_name="sdd-apply"
→ Leer el contenido de un skill específico

@skills-reader search_skills query="git"
→ Buscar skills por palabra clave

@skills-reader get_all_skills_content location="all"
→ Cargar todos los skills como contexto
```

### Ejemplos prácticos

**Ver qué hace un skill:**
```
@skills-reader read_skill skill_name="gitflow-feature"
```

**Buscar skills relacionados con testing:**
```
@skills-reader search_skills query="testing"
```

**Cargar todos los skills para contexto amplio:**
```
@skills-reader get_all_skills_content
```

## 🤖 Integración con Ollama

Si usas Ollama en VSCode, el servidor MCP permite que Ollama acceda automáticamente a todos los skills cuando sea necesario.

**Ejemplo de conversación:**
```
Usuario: "¿Cómo creo una feature con gitflow?"
Ollama: [automáticamente lee el skill gitflow-feature y responde]
```

## 🗂️ Estructura instalada

Después de la instalación:

```
~/.agents/skills/          # Skills de proyecto (compartidos)
~/.claude/skills/          # Skills de usuario (personales)
~/.mcp-servers/           # Servidores MCP instalados
  └── skills-reader-mcp/  # Servidor que lee los skills

~/.config/Code/User/      # Configuración de VSCode (Linux)
  ├── mcp-servers.json    # Config de servidores MCP
  └── settings.json       # Settings de VSCode

%APPDATA%\Code\User\      # Configuración de VSCode (Windows)
  ├── mcp-servers.json
  └── settings.json
```

## 🔧 Solución de problemas

### No aparece @skills-reader en VSCode

**Solución:**
1. Verifica que reiniciaste VSCode (`Ctrl + Shift + P` → "Reload Window")
2. Verifica la configuración:
   ```bash
   # Linux
   cat ~/.config/Code/User/mcp-servers.json
   
   # Windows
   type %APPDATA%\Code\User\mcp-servers.json
   ```
3. Abre Developer Tools (`Ctrl + Shift + I`) y revisa la consola por errores

### El comando falla con "command not found"

**Linux:**
```bash
# Verifica que Node.js esté en el PATH
which node
echo $PATH

# Si no está, añade a ~/.bashrc o ~/.zshrc:
export PATH="$PATH:/usr/local/bin"
```

**Windows:**
```powershell
# Verifica que Node.js esté en el PATH
where.exe node

# Si no está, reinstala Node.js marcando "Add to PATH"
```

### Los skills no se listan

**Solución:**
```bash
# Verifica que los skills se instalaron
ls -la ~/.agents/skills/
ls -la ~/.claude/skills/

# Si están vacíos, vuelve a ejecutar el script de instalación
```

### Error "cannot find module @modelcontextprotocol/sdk"

**Solución:**
```bash
cd ~/.mcp-servers/skills-reader-mcp
npm install
npm run build
```

Luego reinicia VSCode.

## 📚 Skills disponibles

### Project Skills (compartidos con el equipo)
- `find-skills` - Buscar y descubrir skills
- `gitflow-*` - Flujo de trabajo GitFlow
- `neon-postgres` - Trabajo con Neon Postgres
- `sentry-*` - Integración con Sentry
- `vercel-react-best-practices` - Best practices React/Vercel
- `webapp-testing` - Testing de aplicaciones web

### User Skills (personalizables)
- `sdd-*` - Spec-Driven Development workflow
- `branch-pr` - Gestión de branches y PRs
- `issue-creation` - Creación de issues
- `judgment-day` - Revisión adversarial
- `skill-creator` - Crear nuevos skills
- Y más...

## 🔄 Actualizar skills

Si hay una nueva versión del paquete:

1. Descarga el nuevo paquete
2. Vuelve a ejecutar el script de instalación
3. Los skills existentes se sobrescriben automáticamente
4. Reinicia VSCode

## 👥 Soporte

Si tienes problemas:

1. Revisa esta documentación
2. Consulta los logs en Developer Tools de VSCode
3. Contacta al equipo de desarrollo

## 📖 Recursos adicionales

- [Documentación completa de MCP](../README.md)
- [Guía de creación de skills](./CREATING-SKILLS.md)
- [FAQ](./FAQ.md)

---

**Última actualización:** $(date '+%Y-%m-%d')
