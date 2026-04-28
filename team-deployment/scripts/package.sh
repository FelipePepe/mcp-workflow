#!/bin/bash

# ============================================================================
# Script de empaquetado para deployment de Skills y MCP Servers
# ============================================================================
# Este script empaqueta todo lo necesario para distribuir al equipo
# ============================================================================

set -e

# Colores
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

# Directorios
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEPLOYMENT_DIR="$(dirname "$SCRIPT_DIR")"
PACKAGE_DIR="$DEPLOYMENT_DIR/skills-package"
MCP_DIR="$DEPLOYMENT_DIR/mcp-servers"

# Directorios origen
SOURCE_AGENTS="$HOME/.agents/skills"
SOURCE_CLAUDE="$HOME/.claude/skills"
SOURCE_MCP_SKILLS="$HOME/Sources/MCP/skills-reader-mcp"

echo -e "${CYAN}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║${NC}  Empaquetando Skills y MCP Servers para distribución"
echo -e "${CYAN}╚══════════════════════════════════════════════════════════════╝${NC}"
echo ""

# ============================================================================
# 1. EMPAQUETAR SKILLS
# ============================================================================

echo -e "${BLUE}▶${NC} Empaquetando skills..."

# Project skills
if [ -d "$SOURCE_AGENTS" ]; then
    echo "  Copiando project skills..."
    mkdir -p "$PACKAGE_DIR/project-skills"
    cp -r "$SOURCE_AGENTS"/* "$PACKAGE_DIR/project-skills/" 2>/dev/null || true
    PROJECT_COUNT=$(ls -1 "$PACKAGE_DIR/project-skills" 2>/dev/null | wc -l)
    echo -e "${GREEN}  ✅ $PROJECT_COUNT project skills empaquetados${NC}"
else
    echo -e "${YELLOW}  ⚠️  No se encontraron project skills${NC}"
fi

# User skills
if [ -d "$SOURCE_CLAUDE" ]; then
    echo "  Copiando user skills..."
    mkdir -p "$PACKAGE_DIR/user-skills"
    cp -r "$SOURCE_CLAUDE"/* "$PACKAGE_DIR/user-skills/" 2>/dev/null || true
    USER_COUNT=$(ls -1 "$PACKAGE_DIR/user-skills" 2>/dev/null | wc -l)
    echo -e "${GREEN}  ✅ $USER_COUNT user skills empaquetados${NC}"
else
    echo -e "${YELLOW}  ⚠️  No se encontraron user skills${NC}"
fi

# ============================================================================
# 2. EMPAQUETAR SERVIDORES MCP
# ============================================================================

echo ""
echo -e "${BLUE}▶${NC} Empaquetando servidores MCP..."

# Skills reader MCP
if [ -d "$SOURCE_MCP_SKILLS" ]; then
    echo "  Copiando skills-reader-mcp..."
    mkdir -p "$MCP_DIR/skills-reader-mcp"
    
    # Copiar solo archivos necesarios (no node_modules ni dist)
    cp "$SOURCE_MCP_SKILLS/package.json" "$MCP_DIR/skills-reader-mcp/"
    cp "$SOURCE_MCP_SKILLS/tsconfig.json" "$MCP_DIR/skills-reader-mcp/"
    cp -r "$SOURCE_MCP_SKILLS/src" "$MCP_DIR/skills-reader-mcp/"
    
    # Copiar documentación si existe
    [ -f "$SOURCE_MCP_SKILLS/README.md" ] && cp "$SOURCE_MCP_SKILLS/README.md" "$MCP_DIR/skills-reader-mcp/"
    
    echo -e "${GREEN}  ✅ skills-reader-mcp empaquetado${NC}"
else
    echo -e "${YELLOW}  ⚠️  No se encontró skills-reader-mcp en $SOURCE_MCP_SKILLS${NC}"
fi

# ============================================================================
# 3. CREAR ARCHIVO DE VERSIÓN
# ============================================================================

echo ""
echo -e "${BLUE}▶${NC} Creando archivo de versión..."

VERSION_FILE="$DEPLOYMENT_DIR/VERSION.txt"
cat > "$VERSION_FILE" << EOF
Skills & MCP Servers Deployment Package
========================================

Fecha: $(date '+%Y-%m-%d %H:%M:%S')
Usuario: $(whoami)
Hostname: $(hostname)

Contenido:
----------
Project Skills: $PROJECT_COUNT
User Skills: $USER_COUNT
Total Skills: $((PROJECT_COUNT + USER_COUNT))

Servidores MCP:
- skills-reader-mcp

Instrucciones:
--------------
Linux:   bash scripts/install-linux.sh
Windows: powershell -ExecutionPolicy Bypass -File scripts\install-windows.ps1

EOF

echo -e "${GREEN}  ✅ VERSION.txt creado${NC}"

# ============================================================================
# 4. CREAR ARCHIVO TAR.GZ PARA DISTRIBUCIÓN
# ============================================================================

echo ""
echo -e "${BLUE}▶${NC} Creando paquete tar.gz para distribución..."

PACKAGE_NAME="skills-mcp-deployment-$(date +%Y%m%d-%H%M%S).tar.gz"
PACKAGE_PATH="$HOME/Downloads/$PACKAGE_NAME"

cd "$(dirname "$DEPLOYMENT_DIR")"
tar -czf "$PACKAGE_PATH" "$(basename "$DEPLOYMENT_DIR")"

PACKAGE_SIZE=$(du -h "$PACKAGE_PATH" | cut -f1)

echo -e "${GREEN}  ✅ Paquete creado: $PACKAGE_PATH${NC}"
echo -e "${GREEN}     Tamaño: $PACKAGE_SIZE${NC}"

# ============================================================================
# 5. RESUMEN
# ============================================================================

echo ""
echo -e "${CYAN}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║${NC}  ¡Empaquetado completado!"
echo -e "${CYAN}╚══════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${GREEN}📦 Paquete de distribución:${NC}"
echo "   $PACKAGE_PATH"
echo ""
echo -e "${GREEN}📊 Contenido:${NC}"
echo "   • Project skills: $PROJECT_COUNT"
echo "   • User skills: $USER_COUNT"
echo "   • Servidores MCP: skills-reader-mcp"
echo ""
echo -e "${BLUE}📤 Distribución al equipo:${NC}"
echo "   1. Envía el archivo $PACKAGE_NAME al equipo"
echo "   2. Descomprime: tar -xzf $PACKAGE_NAME"
echo "   3. Ejecuta:"
echo "      - Linux: bash scripts/install-linux.sh"
echo "      - Windows: powershell -ExecutionPolicy Bypass -File scripts\\install-windows.ps1"
echo ""
echo -e "${BLUE}📚 Documentación en:${NC}"
echo "   $DEPLOYMENT_DIR/docs/"
echo ""
