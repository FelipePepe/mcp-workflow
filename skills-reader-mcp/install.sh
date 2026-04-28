#!/bin/bash

set -e

echo "🚀 Instalando Skills Reader MCP Server..."
echo ""

# Colores
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Directorios
MCP_DIR="$HOME/Sources/MCP/skills-reader-mcp"
CONFIG_FILE="$HOME/Sources/CursoAI/agent-implementacion/mcp-server/mcp-config-vscode.json"

# 1. Verificar Node.js
echo "📦 Verificando Node.js..."
if ! command -v node &> /dev/null; then
    echo -e "${RED}❌ Node.js no está instalado${NC}"
    exit 1
fi
echo -e "${GREEN}✅ Node.js $(node --version)${NC}"
echo ""

# 2. Crear estructura de directorios
echo "📁 Creando estructura de directorios..."
mkdir -p "$MCP_DIR/src"
echo -e "${GREEN}✅ Directorios creados${NC}"
echo ""

# 3. Verificar que los archivos necesarios existen
echo "📝 Verificando archivos..."
if [ ! -f "$MCP_DIR/package.json" ]; then
    echo -e "${RED}❌ package.json no encontrado${NC}"
    exit 1
fi
if [ ! -f "$MCP_DIR/src/index.ts" ]; then
    echo -e "${RED}❌ src/index.ts no encontrado${NC}"
    exit 1
fi
echo -e "${GREEN}✅ Archivos verificados${NC}"
echo ""

# 4. Instalar dependencias
echo "📦 Instalando dependencias..."
cd "$MCP_DIR"
npm install --quiet
echo -e "${GREEN}✅ Dependencias instaladas${NC}"
echo ""

# 5. Compilar
echo "🔨 Compilando servidor..."
npm run build
echo -e "${GREEN}✅ Servidor compilado${NC}"
echo ""

# 6. Actualizar configuración MCP
echo "⚙️  Actualizando configuración MCP..."
if [ -f "$CONFIG_FILE" ]; then
    # Verificar si ya existe la configuración
    if grep -q "skills-reader" "$CONFIG_FILE"; then
        echo -e "${YELLOW}⚠️  skills-reader ya está configurado${NC}"
    else
        # Hacer backup
        cp "$CONFIG_FILE" "$CONFIG_FILE.backup-$(date +%Y%m%d-%H%M%S)"
        echo -e "${GREEN}✅ Backup creado${NC}"
        
        # Nota: La configuración debe actualizarse manualmente o con jq
        echo -e "${YELLOW}⚠️  Por favor, añade manualmente la configuración de skills-reader al archivo MCP${NC}"
        echo "   Archivo: $CONFIG_FILE"
    fi
else
    echo -e "${RED}❌ Archivo de configuración MCP no encontrado${NC}"
    echo "   Esperado en: $CONFIG_FILE"
fi
echo ""

# 7. Verificar instalación
echo "🔍 Verificando instalación..."
if [ -f "$MCP_DIR/verify.sh" ]; then
    bash "$MCP_DIR/verify.sh"
else
    echo -e "${YELLOW}⚠️  Script de verificación no encontrado${NC}"
fi

echo ""
echo -e "${GREEN}✅ Instalación completada!${NC}"
echo ""
echo "📋 Próximos pasos:"
echo "  1. Reinicia VSCode (Ctrl+Shift+P > 'Reload Window')"
echo "  2. Abre el chat de Copilot"
echo "  3. Prueba: @skills-reader list_skills"
echo ""
echo "📚 Documentación:"
echo "  - Guía rápida: $MCP_DIR/GUIA-RAPIDA.md"
echo "  - README: $MCP_DIR/README.md"
echo ""
