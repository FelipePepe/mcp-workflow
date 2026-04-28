# Skills Reader MCP Server

Servidor MCP para que Ollama/VSCode pueda leer automáticamente los archivos de skills/agentes.

## 📁 Directorios monitoreados

- `~/.agents/skills` (project skills)
- `~/.claude/skills` (user skills)

## 🚀 Instalación completada

El servidor ya está configurado y listo para usar con VSCode + Copilot.

## 🛠️ Herramientas disponibles

### 1. `list_skills`
Lista todos los skills disponibles

**Uso en VSCode:**
```
@skills-reader list_skills
```

### 2. `read_skill`
Lee el contenido completo de un skill específico

**Parámetros:**
- `skill_name`: Nombre del skill (ej: "sdd-apply", "gitflow-feature")

**Uso en VSCode:**
```
@skills-reader read_skill skill_name="sdd-apply"
```

### 3. `search_skills`
Busca skills por nombre o contenido

**Parámetros:**
- `query`: Término de búsqueda

**Uso en VSCode:**
```
@skills-reader search_skills query="git"
```

### 4. `get_all_skills_content`
Obtiene el contenido de todos los skills (útil para dar contexto completo a Ollama)

**Parámetros:**
- `location`: "project", "user", o "all" (opcional, default: "all")

**Uso en VSCode:**
```
@skills-reader get_all_skills_content location="all"
```

## 🔄 Reiniciar VSCode

**IMPORTANTE:** Para que los cambios tomen efecto, reinicia VSCode:

1. Presiona `Ctrl + Shift + P`
2. Escribe "Reload Window"
3. Presiona Enter

O simplemente cierra y abre VSCode.

## 🧪 Probar el servidor

Una vez reiniciado VSCode, abre el chat de Copilot y prueba:

```
@skills-reader list_skills
```

Deberías ver una lista de todos tus skills disponibles.

## 📝 Configuración actual

El servidor está configurado en:
`/home/sandman/Sources/CursoAI/agent-implementacion/mcp-server/mcp-config-vscode.json`

Y VSCode lo lee desde la configuración:
`github.copilot.chat.mcp.configFile`

## 🎯 Uso típico con Ollama

1. **Listar skills disponibles:**
   ```
   @skills-reader list_skills
   ```

2. **Leer un skill específico:**
   ```
   @skills-reader read_skill skill_name="sdd-apply"
   ```

3. **Cargar todos los skills como contexto:**
   ```
   @skills-reader get_all_skills_content location="all"
   ```

4. **Ahora Ollama tendrá acceso a todo el contenido de tus skills!**

## 📚 Estructura de un skill

Cada skill debe estar en su propio directorio con un archivo `SKILL.md`:

```
~/.agents/skills/
├── sdd-apply/
│   └── SKILL.md
├── gitflow-feature/
│   └── SKILL.md
└── ...
```

## 🔧 Desarrollo

Para modificar el servidor:

1. Edita el código fuente en `src/index.ts`
2. Recompila: `npm run build`
3. Reinicia VSCode

## ⚙️ Comandos útiles

```bash
# Recompilar
cd ~/Sources/MCP/skills-reader-mcp && npm run build

# Modo watch (recompila automáticamente)
cd ~/Sources/MCP/skills-reader-mcp && npm run watch

# Probar el servidor manualmente
cd ~/Sources/MCP/skills-reader-mcp && node dist/index.js
```

## 🐛 Troubleshooting

### El servidor no aparece en VSCode

1. Verifica que la configuración MCP está correcta:
   ```bash
   cat ~/Sources/CursoAI/agent-implementacion/mcp-server/mcp-config-vscode.json
   ```

2. Verifica que el servidor compiló correctamente:
   ```bash
   ls -la ~/Sources/MCP/skills-reader-mcp/dist/
   ```

3. Reinicia VSCode completamente

### Los skills no se listan

1. Verifica que existen skills en los directorios:
   ```bash
   ls -la ~/.agents/skills/
   ls -la ~/.claude/skills/
   ```

2. Verifica que cada skill tiene un archivo `SKILL.md` o al menos un `.md`

### El servidor da error

Revisa los logs de VSCode:
1. `Ctrl + Shift + P`
2. "Developer: Toggle Developer Tools"
3. Ve a la pestaña "Console"

## 📦 Dependencias

- `@modelcontextprotocol/sdk`: ^1.0.4
- `typescript`: ^5.7.3
- Node.js 18+

## 📄 Licencia

MIT
