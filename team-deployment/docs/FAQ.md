# ❓ FAQ - Preguntas Frecuentes

## Instalación

### ¿Necesito permisos de administrador?

**No.** La instalación se realiza completamente en tu directorio home (`~` o `%USERPROFILE%`). No necesitas permisos de administrador.

### ¿Puedo instalar en una máquina sin internet?

**Parcialmente.** Necesitas internet para:
- Instalar Node.js, npm y Git (una sola vez)
- Descargar dependencias de npm durante la instalación

Una vez instalado, puedes trabajar offline.

### ¿Qué pasa si ya tengo skills instalados?

Los skills existentes se **sobrescriben** con las nuevas versiones. Si tienes skills personalizados que no quieres perder, haz un backup antes:

```bash
# Linux/macOS
cp -r ~/.claude/skills ~/.claude/skills.backup

# Windows
xcopy /E /I %USERPROFILE%\.claude\skills %USERPROFILE%\.claude\skills.backup
```

## Uso

### ¿Cómo sé qué skills tengo disponibles?

En el chat de Copilot:
```
@skills-reader list_skills
```

O directamente en tu sistema:
```bash
# Linux/macOS
ls ~/.agents/skills/
ls ~/.claude/skills/

# Windows
dir %USERPROFILE%\.agents\skills
dir %USERPROFILE%\.claude\skills
```

### ¿Puedo crear mis propios skills?

**Sí.** Usa el skill `skill-creator`:

```
@skills-reader read_skill skill_name="skill-creator"
```

O crea manualmente un directorio en `~/.claude/skills/mi-skill/` con un archivo `SKILL.md`.

### ¿Los skills funcionan con otros LLMs además de Copilot?

El servidor MCP está diseñado para VSCode, pero los skills son archivos Markdown que puedes usar con cualquier LLM que soporte el protocolo MCP o simplemente copiando el contenido.

### ¿Puedo compartir mis skills personalizados con el equipo?

**Sí.** Coloca tus skills en un repositorio Git o comparte el directorio directamente. El administrador puede incluirlos en el próximo paquete de deployment.

## Configuración

### ¿Cómo cambio las rutas de instalación?

Edita las variables en el script de instalación:

**Linux** (`scripts/install-linux.sh`):
```bash
AGENTS_DIR="$HOME/.agents/skills"
CLAUDE_DIR="$HOME/.claude/skills"
MCP_INSTALL_DIR="$HOME/.mcp-servers"
```

**Windows** (`scripts/install-windows.ps1`):
```powershell
$AgentsDir = Join-Path $HomeDir ".agents\skills"
$ClaudeDir = Join-Path $HomeDir ".claude\skills"
$McpInstallDir = Join-Path $HomeDir ".mcp-servers"
```

### ¿Cómo añado más directorios de skills?

Edita el código fuente del servidor MCP:

1. Abre: `~/.mcp-servers/skills-reader-mcp/src/index.ts`
2. Modifica la constante `SKILLS_PATHS`:
   ```typescript
   const SKILLS_PATHS = [
     join(homedir(), ".agents", "skills"),
     join(homedir(), ".claude", "skills"),
     join(homedir(), "mis-skills-extra"), // Añadir aquí
   ];
   ```
3. Recompila:
   ```bash
   cd ~/.mcp-servers/skills-reader-mcp
   npm run build
   ```
4. Reinicia VSCode

### ¿Puedo desactivar el servidor MCP temporalmente?

**Sí.** En VSCode settings (`Ctrl + ,`):

```json
{
  "github.copilot.chat.mcp.enabled": false
}
```

O edita `mcp-servers.json` y marca `"disabled": true`.

## Problemas comunes

### Error: "EACCES: permission denied"

**Causa:** Problemas de permisos.

**Solución:**
```bash
# Linux/macOS - Arreglar permisos de node_modules
cd ~/.mcp-servers/skills-reader-mcp
sudo chown -R $(whoami) node_modules
npm install
```

### Error: "Cannot find module 'typescript'"

**Causa:** Dependencias no instaladas.

**Solución:**
```bash
cd ~/.mcp-servers/skills-reader-mcp
npm install --save-dev typescript
npm run build
```

### VSCode no detecta el servidor MCP

**Causa:** Configuración incorrecta o VSCode no reiniciado.

**Solución:**
1. Verifica que el archivo existe:
   ```bash
   cat ~/.config/Code/User/mcp-servers.json  # Linux
   type %APPDATA%\Code\User\mcp-servers.json  # Windows
   ```

2. Verifica que settings.json apunta al archivo correcto

3. **Reinicia VSCode completamente** (cierra y abre, no solo Reload Window)

### El servidor se cuelga o va muy lento

**Causa:** Demasiados skills o archivos muy grandes.

**Solución:**
1. Reduce el número de skills
2. Usa `get_all_skills_content` solo cuando sea necesario
3. Considera implementar caché (ver ADVANCED.md)

### Error: "spawn node ENOENT"

**Causa:** Node.js no está en el PATH.

**Solución:**

**Linux/macOS:**
```bash
# Añade a ~/.bashrc o ~/.zshrc
export PATH="/usr/local/bin:$PATH"
```

**Windows:**
1. Panel de Control → Sistema → Configuración avanzada
2. Variables de entorno
3. Edita PATH y añade la ruta de Node.js (ej: `C:\Program Files\nodejs`)

## Desarrollo

### ¿Cómo modifico el servidor MCP?

1. Edita el código fuente: `~/.mcp-servers/skills-reader-mcp/src/index.ts`
2. Recompila: `npm run build`
3. Reinicia VSCode

Ver `ADVANCED.md` para más detalles.

### ¿Dónde están los logs del servidor?

**VSCode Developer Tools:**
1. `Ctrl + Shift + I` (o `Cmd + Shift + I` en macOS)
2. Pestaña "Console"
3. Filtra por "MCP" o "skills-reader"

**Logs del sistema:**
```bash
# Linux
journalctl --user -u code --since today

# macOS
log show --predicate 'process == "Electron"' --last 1h

# Windows (Event Viewer)
eventvwr.msc
```

### ¿Puedo contribuir con nuevos skills?

**Sí.** Contacta al administrador del paquete o:

1. Crea el skill en `~/.claude/skills/mi-skill/`
2. Pruébalo localmente
3. Comparte el directorio con el equipo
4. El administrador lo incluirá en el siguiente deployment

## Performance

### ¿Cuántos skills puedo tener?

No hay límite técnico, pero:
- **< 50 skills:** Performance óptima
- **50-100 skills:** Performance buena
- **> 100 skills:** Considera dividir en categorías

### ¿El servidor consume muchos recursos?

**No.** El servidor MCP es muy ligero:
- **RAM:** ~20-50 MB
- **CPU:** Casi nulo en reposo
- Solo se activa cuando usas comandos `@skills-reader`

### ¿Puedo cachear los skills?

**Sí.** El servidor ya implementa caché básico. Para caché avanzado, ver `ADVANCED.md`.

## Seguridad

### ¿Es seguro instalar esto?

**Sí.** Todo el código está en:
- `scripts/` - Scripts de instalación (revísalos antes de ejecutar)
- `mcp-servers/skills-reader-mcp/src/` - Código fuente del servidor

No hay binarios opacos. Todo es código abierto y auditable.

### ¿Los skills pueden ejecutar código arbitrario?

**No.** Los skills son archivos Markdown (`.md`) de solo lectura. El servidor MCP solo los lee, nunca los ejecuta.

### ¿Dónde se almacena mi información?

Todo es **local**:
- Skills: `~/.agents/skills`, `~/.claude/skills`
- Servidor: `~/.mcp-servers/`
- Config: `~/.config/Code/User/` (Linux) o `%APPDATA%\Code\User\` (Windows)

**No hay comunicación con servidores externos** excepto:
- npm para instalar dependencias (una vez)
- GitHub Copilot (si lo usas)

## Desinstalación

### ¿Cómo desinstalo todo?

**Linux/macOS:**
```bash
rm -rf ~/.agents/skills
rm -rf ~/.claude/skills
rm -rf ~/.mcp-servers
rm ~/.config/Code/User/mcp-servers.json

# Edita settings.json y elimina las líneas de MCP
nano ~/.config/Code/User/settings.json
```

**Windows:**
```powershell
Remove-Item -Recurse -Force $env:USERPROFILE\.agents\skills
Remove-Item -Recurse -Force $env:USERPROFILE\.claude\skills
Remove-Item -Recurse -Force $env:USERPROFILE\.mcp-servers
Remove-Item $env:APPDATA\Code\User\mcp-servers.json

# Edita settings.json y elimina las líneas de MCP
notepad $env:APPDATA\Code\User\settings.json
```

### ¿Puedo mantener los skills pero desinstalar el servidor MCP?

**Sí:**
```bash
# Solo elimina el servidor MCP
rm -rf ~/.mcp-servers/skills-reader-mcp

# Y desactívalo en VSCode
# settings.json: "github.copilot.chat.mcp.enabled": false
```

Los skills siguen estando en `~/.agents/skills` y `~/.claude/skills` para usar manualmente.

---

## ¿No encuentras tu pregunta aquí?

- Revisa la [Guía de Deployment](./DEPLOYMENT-GUIDE.md)
- Consulta la [documentación avanzada](../skills-reader-mcp/ADVANCED.md)
- Contacta al equipo de desarrollo
