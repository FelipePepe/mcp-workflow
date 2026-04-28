# 📦 Skills & MCP Servers - Team Deployment Package

Paquete de instalación automática de Skills y Servidores MCP para equipos de desarrollo con Windows y Linux.

## 🎯 ¿Qué instala este paquete?

1. **Skills de desarrollo** - Agentes especializados para tareas comunes
   - GitFlow workflow
   - Spec-Driven Development (SDD)
   - Testing strategies
   - Integración con Sentry, Neon, Vercel
   - Y más...

2. **Servidor MCP Skills Reader** - Permite que VSCode/Ollama lea automáticamente los skills
   - Acceso transparente desde Copilot
   - Búsqueda y listado de skills
   - Carga de contexto completo

## 🚀 Instalación rápida

### Linux / macOS

```bash
# 1. Descomprimir
tar -xzf skills-mcp-deployment-*.tar.gz
cd team-deployment

# 2. Instalar
bash scripts/install-linux.sh

# 3. Reiniciar VSCode
# Ctrl + Shift + P → "Reload Window"
```

### Windows

```powershell
# 1. Descomprimir el archivo (clic derecho → Extraer)

# 2. Instalar (clic derecho en el script → Ejecutar con PowerShell)
cd team-deployment
powershell -ExecutionPolicy Bypass -File scripts\install-windows.ps1

# 3. Reiniciar VSCode
# Ctrl + Shift + P → "Reload Window"
```

## ✅ Verificar instalación

En el chat de Copilot en VSCode:

```
@skills-reader list_skills
```

Deberías ver una lista de todos los skills disponibles.

## 📋 Requisitos

- Node.js 18+ ([Descargar](https://nodejs.org/))
- npm (incluido con Node.js)
- Git ([Descargar](https://git-scm.com/))
- VSCode con GitHub Copilot

## 📚 Documentación

- **[Guía de Deployment](docs/DEPLOYMENT-GUIDE.md)** - Instrucciones detalladas de instalación
- **[FAQ](docs/FAQ.md)** - Preguntas frecuentes y solución de problemas
- **[Skills Reader README](mcp-servers/skills-reader-mcp/README.md)** - Documentación del servidor MCP

## 🗂️ Estructura del paquete

```
team-deployment/
├── scripts/
│   ├── install-linux.sh       # Script de instalación para Linux/macOS
│   ├── install-windows.ps1    # Script de instalación para Windows
│   └── package.sh             # Script para crear el paquete (admin)
├── skills-package/
│   ├── project-skills/        # Skills compartidos del equipo
│   └── user-skills/           # Skills personales del usuario
├── mcp-servers/
│   └── skills-reader-mcp/     # Servidor MCP para leer skills
├── docs/
│   ├── DEPLOYMENT-GUIDE.md    # Guía completa de deployment
│   └── FAQ.md                 # Preguntas frecuentes
├── README.md                  # Este archivo
└── VERSION.txt                # Información de versión del paquete
```

## 📝 Uso diario

### Listar skills disponibles
```
@skills-reader list_skills
```

### Leer un skill específico
```
@skills-reader read_skill skill_name="sdd-apply"
```

### Buscar skills
```
@skills-reader search_skills query="testing"
```

### Cargar todos los skills como contexto
```
@skills-reader get_all_skills_content location="all"
```

## 🤖 Integración con Ollama

Si usas Ollama en VSCode, el servidor MCP permite que Ollama acceda automáticamente a todos los skills cuando sea necesario.

## 🔄 Actualizar

Para actualizar a una nueva versión:

1. Descarga el nuevo paquete
2. Vuelve a ejecutar el script de instalación
3. Reinicia VSCode

Los skills existentes se sobrescriben automáticamente.

## 🛠️ Para administradores

### Crear un nuevo paquete de deployment

```bash
# 1. Asegúrate de tener los skills actualizados en:
#    ~/.agents/skills/
#    ~/.claude/skills/

# 2. Ejecuta el script de empaquetado
bash scripts/package.sh

# 3. El paquete se crea en ~/Downloads/
#    skills-mcp-deployment-YYYYMMDD-HHMMSS.tar.gz

# 4. Distribuye el paquete al equipo
```

### Añadir nuevos skills al paquete

1. Coloca los skills en:
   - `skills-package/project-skills/` - Para skills del equipo
   - `skills-package/user-skills/` - Para skills personales

2. Vuelve a ejecutar `scripts/package.sh`

### Modificar el servidor MCP

Edita el código en `mcp-servers/skills-reader-mcp/src/index.ts` y vuelve a empaquetar.

## 🐛 Solución de problemas

### No aparece @skills-reader

1. Reinicia VSCode completamente (cierra y abre)
2. Verifica Developer Tools (Ctrl+Shift+I) → Console
3. Revisa [FAQ.md](docs/FAQ.md) para más soluciones

### Los skills no se listan

```bash
# Verifica que se instalaron
ls ~/.agents/skills/
ls ~/.claude/skills/

# Si no, vuelve a ejecutar el script de instalación
```

### Error en npm install

```bash
# Limpia la caché de npm
npm cache clean --force

# Vuelve a instalar
cd ~/.mcp-servers/skills-reader-mcp
npm install
npm run build
```

Para más problemas, consulta [FAQ.md](docs/FAQ.md).

## 📊 Estadísticas

- **Skills incluidos:** Ver VERSION.txt
- **Servidores MCP:** 1 (skills-reader)
- **Plataformas soportadas:** Linux, macOS, Windows
- **Tamaño del paquete:** ~50-100 KB (comprimido)

## 🔒 Seguridad

- Todo el código es de código abierto y auditable
- No hay comunicación con servidores externos (excepto npm al instalar)
- Los skills son archivos Markdown de solo lectura
- La instalación es completamente local en tu directorio home

## 📄 Licencia

MIT

## 👥 Soporte

- Documentación: `docs/`
- Issues: Contacta al administrador del paquete
- Preguntas: Revisa [FAQ.md](docs/FAQ.md)

---

**¿Primera vez instalando?** → Lee [DEPLOYMENT-GUIDE.md](docs/DEPLOYMENT-GUIDE.md)

**¿Problemas?** → Revisa [FAQ.md](docs/FAQ.md)

**¿Quieres crear skills personalizados?** → Usa `@skills-reader read_skill skill_name="skill-creator"`
