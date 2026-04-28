# Configuración avanzada de Skills Reader

## Añadir más rutas de skills

Si quieres que el servidor lea skills de otros directorios, edita el archivo `src/index.ts`:

```typescript
// Línea 17-20
const SKILLS_PATHS = [
  join(homedir(), ".agents", "skills"),
  join(homedir(), ".claude", "skills"),
  // Añade más rutas aquí:
  join(homedir(), "mis-skills-personalizados"),
  "/ruta/absoluta/a/otros/skills",
];
```

Luego recompila:
```bash
npm run build
```

Y reinicia VSCode.

## Filtrar skills por tipo

Puedes modificar la función `findAllSkills()` para filtrar skills por tipo, añadiendo lógica adicional:

```typescript
// Ejemplo: solo skills que empiecen con "sdd-"
if (entry.name.startsWith("sdd-")) {
  // ... añadir skill
}
```

## Cambiar el formato de salida

Puedes personalizar cómo se muestran los skills editando los handlers en `src/index.ts`:

```typescript
// Por ejemplo, en el caso "list_skills":
const skillList = skills
  .map((s) => `- ${s.name} [${s.location}]`)
  .join("\n");
```

## Integración con Ollama

Para que Ollama use automáticamente los skills, puedes:

1. **Crear un prompt del sistema** que incluya los skills:
   ```
   @skills-reader get_all_skills_content location="user"
   ```

2. **Usar en el contexto de conversación:**
   Cuando preguntes algo a Ollama, incluye el contenido del skill relevante.

3. **Automatizar con scripts:**
   Crea aliases o scripts que carguen skills automáticamente.

## Configuración de VSCode

### Habilitar autocompletado de skills

En `.config/Code/User/settings.json`:

```json
{
  "chat.tools.autoApprove": true,
  "chat.mcp.autostart": "always"
}
```

### Crear snippets personalizados

Archivo: `.config/Code/User/snippets/copilot.json`

```json
{
  "List Skills": {
    "prefix": "@ls",
    "body": ["@skills-reader list_skills"],
    "description": "Lista todos los skills disponibles"
  },
  "Read Skill": {
    "prefix": "@rs",
    "body": ["@skills-reader read_skill skill_name=\"$1\""],
    "description": "Lee un skill específico"
  }
}
```

## Debugging

Para ver logs del servidor MCP en VSCode:

1. `Ctrl + Shift + P`
2. "Developer: Toggle Developer Tools"
3. Console > Filtrar por "MCP"

## Performance

Si tienes muchos skills (>50), considera:

1. **Lazy loading:** Cargar skills bajo demanda
2. **Caché:** Cachear el contenido de skills
3. **Indexación:** Crear un índice de skills para búsquedas rápidas

Ejemplo de caché simple:

```typescript
const skillCache = new Map<string, { content: string; timestamp: number }>();
const CACHE_TTL = 5 * 60 * 1000; // 5 minutos

async function getCachedSkill(path: string): Promise<string> {
  const cached = skillCache.get(path);
  if (cached && Date.now() - cached.timestamp < CACHE_TTL) {
    return cached.content;
  }
  
  const content = await readSkillContent(path);
  skillCache.set(path, { content, timestamp: Date.now() });
  return content;
}
```

## Recursos adicionales

- [MCP SDK Docs](https://github.com/modelcontextprotocol/sdk)
- [VSCode MCP Integration](https://code.visualstudio.com/docs)
- [Ollama Documentation](https://ollama.ai/docs)
