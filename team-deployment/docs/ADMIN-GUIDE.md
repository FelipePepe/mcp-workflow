# 👨‍💼 Guía para Administradores - Deployment Package

## 🎯 Objetivo

Esta guía te ayuda a mantener y distribuir el paquete de Skills y MCP Servers al equipo.

## 📦 Crear un nuevo paquete

### 1. Preparar los skills

Asegúrate de tener los skills actualizados en tu máquina:

```bash
# Ver skills actuales
ls -la ~/.agents/skills/
ls -la ~/.claude/skills/

# O copia skills desde un repositorio
git clone https://github.com/tu-org/skills ~/.temp-skills
cp -r ~/.temp-skills/* ~/Sources/MCP/team-deployment/skills-package/
```

### 2. Ejecutar el script de empaquetado

```bash
cd ~/Sources/MCP/team-deployment
bash scripts/package.sh
```

Esto generará un archivo en `~/Downloads/`:
```
skills-mcp-deployment-YYYYMMDD-HHMMSS.tar.gz
```

### 3. Verificar el contenido

```bash
# Ver el contenido sin extraer
tar -tzf ~/Downloads/skills-mcp-deployment-*.tar.gz | head -20

# O extraer en un directorio temporal para revisar
mkdir -p /tmp/test-package
tar -xzf ~/Downloads/skills-mcp-deployment-*.tar.gz -C /tmp/test-package
ls -la /tmp/test-package/team-deployment/
```

### 4. Distribuir al equipo

Opciones de distribución:

#### A) Por red interna
```bash
# Copiar a un servidor compartido
cp ~/Downloads/skills-mcp-deployment-*.tar.gz /mnt/shared/software/

# O usar scp a un servidor
scp ~/Downloads/skills-mcp-deployment-*.tar.gz user@server:/var/www/downloads/
```

#### B) Por correo/Slack
- Adjunta el archivo (solo ~100-200 KB)
- Incluye enlace a la documentación
- Menciona la versión y changelog

#### C) Por repositorio Git
```bash
# Crear repositorio de deployment
cd ~/Downloads/
tar -xzf skills-mcp-deployment-*.tar.gz
cd team-deployment
git init
git add .
git commit -m "Initial deployment package"
git remote add origin https://github.com/tu-org/skills-deployment
git push -u origin main
```

## 📝 Añadir o actualizar skills

### Método 1: Copiar desde tu sistema

```bash
# Copiar un skill específico
cp -r ~/.claude/skills/mi-nuevo-skill ~/Sources/MCP/team-deployment/skills-package/user-skills/

# Copiar todos los skills actualizados
rm -rf ~/Sources/MCP/team-deployment/skills-package/user-skills/*
cp -r ~/.claude/skills/* ~/Sources/MCP/team-deployment/skills-package/user-skills/
```

### Método 2: Desde un repositorio

```bash
# Clonar repositorio de skills
git clone https://github.com/tu-org/skills /tmp/skills-repo

# Copiar al paquete
cp -r /tmp/skills-repo/project-skills/* ~/Sources/MCP/team-deployment/skills-package/project-skills/
cp -r /tmp/skills-repo/user-skills/* ~/Sources/MCP/team-deployment/skills-package/user-skills/
```

### Método 3: Crear skill manualmente

```bash
# Crear estructura
mkdir -p ~/Sources/MCP/team-deployment/skills-package/user-skills/mi-nuevo-skill

# Crear el archivo SKILL.md
cat > ~/Sources/MCP/team-deployment/skills-package/user-skills/mi-nuevo-skill/SKILL.md << 'EOF'
---
name: mi-nuevo-skill
description: Descripción del skill
version: 1.0.0
---

# Mi Nuevo Skill

## Propósito
[Descripción de qué hace el skill]

## Uso
[Cómo usar el skill]

## Ejemplos
[Ejemplos prácticos]
EOF
```

## 🔄 Actualizar el servidor MCP

Si necesitas modificar el servidor MCP:

```bash
# Editar el código
cd ~/Sources/MCP/skills-reader-mcp
nano src/index.ts

# Compilar y probar
npm run build
node dist/index.js  # Prueba básica

# Copiar al paquete de deployment
cp -r ~/Sources/MCP/skills-reader-mcp/* ~/Sources/MCP/team-deployment/mcp-servers/skills-reader-mcp/

# NO copiar node_modules ni dist (se generan en cada instalación)
rm -rf ~/Sources/MCP/team-deployment/mcp-servers/skills-reader-mcp/node_modules
rm -rf ~/Sources/MCP/team-deployment/mcp-servers/skills-reader-mcp/dist
```

## 📄 Mantener el changelog

Crea un archivo `CHANGELOG.md`:

```bash
cat > ~/Sources/MCP/team-deployment/CHANGELOG.md << 'EOF'
# Changelog

## [1.1.0] - 2026-04-28

### Added
- Nuevo skill: `database-migration`
- Documentación extendida en FAQ

### Changed
- Actualizado `sdd-apply` con nuevas opciones
- Mejorado rendimiento del servidor MCP

### Fixed
- Corregido error en Windows con rutas UNC
- Solucionado problema de encoding en skills con tildes

## [1.0.0] - 2026-04-01

### Added
- Release inicial
- 34 skills incluidos
- Servidor MCP skills-reader
- Scripts de instalación para Linux y Windows
EOF
```

## 🧪 Probar el paquete antes de distribuir

```bash
# 1. Crear un entorno de prueba
docker run -it --rm ubuntu:22.04 bash

# 2. O usar una VM/contenedor
# 3. Instalar requisitos
apt update && apt install -y nodejs npm git curl

# 4. Copiar el paquete y probar
# (en tu máquina)
scp ~/Downloads/skills-mcp-deployment-*.tar.gz testuser@testvm:~

# (en la VM de prueba)
tar -xzf skills-mcp-deployment-*.tar.gz
cd team-deployment
bash scripts/install-linux.sh

# 5. Verificar
ls -la ~/.agents/skills/
ls -la ~/.claude/skills/
ls -la ~/.mcp-servers/
```

## 📊 Estadísticas de uso

Para saber cuánto se usan los skills:

```bash
# En el servidor compartido (si tienes telemetría)
grep "@skills-reader" /var/log/vscode/*.log | wc -l

# O pide feedback al equipo:
# "¿Qué skills usas más?"
# "¿Qué skills faltan?"
```

## 🔐 Control de versiones

### Git tags para releases

```bash
cd ~/Sources/MCP/team-deployment
git tag -a v1.1.0 -m "Release 1.1.0 - Nuevos skills de database"
git push origin v1.1.0
```

### Semantic versioning

- **Major (X.0.0):** Cambios incompatibles (ej: nueva estructura de skills)
- **Minor (0.X.0):** Nuevas funcionalidades (ej: nuevos skills)
- **Patch (0.0.X):** Correcciones de bugs

## 📢 Comunicar actualizaciones al equipo

### Template de email/mensaje

```markdown
📦 Nueva versión de Skills & MCP disponible: v1.1.0

**¿Qué hay de nuevo?**
- ✨ 3 nuevos skills: database-migration, api-testing, performance-audit
- 🔧 Actualizado sdd-apply con soporte para Go
- 🐛 Corregidos bugs en Windows

**Cómo actualizar:**
1. Descarga: [enlace al paquete]
2. Ejecuta: `bash scripts/install-linux.sh` (Linux) o `install-windows.ps1` (Windows)
3. Reinicia VSCode

**Changelog completo:** [enlace]

**Problemas?** Revisa el FAQ o contacta al equipo de desarrollo.
```

## 🛠️ Personalización por equipo

### Para equipos con stack específico

```bash
# Crear variantes del paquete
cp -r team-deployment team-deployment-frontend
cp -r team-deployment team-deployment-backend

# Personalizar skills
# Frontend team: solo skills de React, Testing, etc.
# Backend team: solo skills de Node, Database, etc.
```

### Variables de entorno

Puedes añadir un archivo `.env.template`:

```bash
cat > ~/Sources/MCP/team-deployment/config/.env.template << 'EOF'
# Configuración del equipo
TEAM_NAME=mi-equipo
SKILLS_REPO_URL=https://github.com/mi-org/skills
MCP_SERVER_PORT=3000
EOF
```

## 📈 Métricas recomendadas

Track:
- Número de instalaciones exitosas
- Skills más usados
- Errores reportados
- Tiempo de adopción

## 🆘 Soporte al equipo

Crea un canal dedicado:
- Slack: `#skills-mcp-support`
- Teams: `Skills & MCP Support`
- Email: `skills-support@tu-org.com`

## 📚 Recursos adicionales

- [Documentación oficial de MCP](https://modelcontextprotocol.io)
- [GitHub Copilot Docs](https://docs.github.com/copilot)
- [VSCode Extension API](https://code.visualstudio.com/api)

---

## Checklist de release

- [ ] Skills actualizados y probados
- [ ] Servidor MCP compilado y funcional
- [ ] Documentación actualizada
- [ ] CHANGELOG.md actualizado
- [ ] VERSION.txt generado
- [ ] Paquete creado con `package.sh`
- [ ] Paquete probado en VM limpia (Linux + Windows)
- [ ] Tag de Git creado
- [ ] Comunicación preparada para el equipo
- [ ] Paquete subido al servidor/repo
- [ ] Equipo notificado
- [ ] Monitorear instalaciones y reportes

---

**¿Primera vez como admin?** Sigue el checklist paso a paso.

**¿Dudas?** Revisa la [FAQ](docs/FAQ.md) o contacta al equipo de desarrollo.
