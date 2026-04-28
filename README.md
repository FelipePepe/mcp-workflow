# 🚀 MCP Workflow - Skills & MCP Servers

Repositorio completo de herramientas de desarrollo con Skills especializados y Servidores MCP para potenciar GitHub Copilot CLI.

## 📦 Componentes

### 1. **Skills Reader MCP Server** (`skills-reader-mcp/`)

Servidor MCP que permite a VSCode/Ollama leer automáticamente archivos de skills y agentes.

**Características:**
- 🔍 Búsqueda y listado de skills disponibles
- 📖 Lectura de contenido completo de skills
- 🔄 Monitoreo de directorios `~/.agents/skills` y `~/.claude/skills`
- 🎯 Integración transparente con Copilot

**Herramientas:**
- `list_skills` - Lista todos los skills disponibles
- `read_skill` - Lee el contenido de un skill específico

[Ver documentación completa →](skills-reader-mcp/README.md)

### 2. **Team Deployment Package** (`team-deployment/`)

Paquete de instalación automática para equipos con Windows y Linux.

**Incluye:**
- ✨ **Skills de desarrollo:** GitFlow, SDD, Testing, Issue Creation, PR Creation
- 🔌 **Integraciones:** Sentry, Neon Postgres, Vercel React
- 🛠️ **Herramientas:** Judgment Day review, Skill Creator
- 📚 **Documentación:** Guías de administración, deployment y FAQ

**Instalación rápida:**

**Linux/macOS:**
```bash
cd team-deployment
bash scripts/install-linux.sh
```

**Windows:**
```powershell
cd team-deployment
.\scripts\install-windows.ps1
```

[Ver documentación completa →](team-deployment/README.md)

## 🎯 Skills Disponibles

### Workflow & Git
- `gitflow` - Modelo de branching GitFlow
- `gitflow-feature` - Gestión de feature branches
- `gitflow-hotfix` - Gestión de hotfix branches
- `gitflow-release` - Gestión de release branches
- `branch-pr` - Creación de Pull Requests
- `issue-creation` - Creación de GitHub Issues

### Spec-Driven Development (SDD)
- `sdd-init` - Inicializar SDD en proyecto
- `sdd-propose` - Crear propuestas de cambio
- `sdd-design` - Diseño técnico
- `sdd-spec` - Escribir especificaciones
- `sdd-tasks` - Descomponer en tareas
- `sdd-apply` - Implementar cambios
- `sdd-verify` - Verificar implementación
- `sdd-archive` - Archivar cambios completados

### Testing & Quality
- `go-testing` - Patrones de testing en Go
- `webapp-testing` - Testing de aplicaciones web con Playwright
- `judgment-day` - Review adversarial paralelo

### Integraciones
- `sentry-fix-issues` - Arreglar errores de Sentry
- `sentry-react-setup` - Configurar Sentry en React
- `sentry-setup-logging` - Configurar logging de Sentry
- `neon-postgres` - Guías para Neon Serverless Postgres
- `vercel-react-best-practices` - Optimización React/Next.js

### Utilidades
- `find-skills` - Descubrir e instalar skills
- `skill-creator` - Crear nuevos skills

## 🚀 Inicio Rápido

1. **Clonar el repositorio:**
```bash
git clone https://github.com/FelipePepe/mcp-workflow.git
cd mcp-workflow
```

2. **Instalar componentes:**
```bash
# Opción A: Instalación completa para equipos
cd team-deployment
bash scripts/install-linux.sh  # o install-windows.ps1 en Windows

# Opción B: Solo MCP Server
cd skills-reader-mcp
bash install.sh
```

3. **Verificar instalación:**
```bash
# Desde VSCode con Copilot CLI
@skills-reader list_skills
```

## 📖 Documentación

- [Guía de Administración](team-deployment/docs/ADMIN-GUIDE.md)
- [Guía de Deployment](team-deployment/docs/DEPLOYMENT-GUIDE.md)
- [FAQ](team-deployment/docs/FAQ.md)
- [Quick Start](team-deployment/QUICKSTART.md)
- [Skills Reader - Guía Rápida](skills-reader-mcp/GUIA-RAPIDA.md)
- [Skills Reader - Avanzado](skills-reader-mcp/ADVANCED.md)

## 🛠️ Requisitos

- **Node.js** 18+ (para MCP Server)
- **Git** 2.23+
- **GitHub CLI** (opcional, para integraciones)
- **VSCode** + GitHub Copilot (recomendado)

## 🤝 Contribuir

Las contribuciones son bienvenidas. Por favor:

1. Fork el proyecto
2. Crea tu feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'feat: Add AmazingFeature'`)
4. Push al branch (`git push origin feature/AmazingFeature`)
5. Abre un Pull Request

## 📝 Convenciones de Commits

Usamos [Conventional Commits](https://www.conventionalcommits.org/):

- `feat:` - Nueva funcionalidad
- `fix:` - Corrección de bugs
- `docs:` - Cambios en documentación
- `refactor:` - Refactorización de código
- `test:` - Agregar o modificar tests
- `chore:` - Tareas de mantenimiento

## 📄 Licencia

Este proyecto incluye componentes con diferentes licencias. Ver archivos LICENSE individuales en cada directorio.

## 🙏 Agradecimientos

- Skills basados en especificaciones de la comunidad de desarrollo
- Integración con GitHub Copilot CLI
- MCP (Model Context Protocol) por Anthropic

---

**Desarrollado con ❤️ para mejorar el flujo de desarrollo con IA**
