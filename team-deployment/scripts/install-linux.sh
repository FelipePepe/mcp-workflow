#!/bin/bash

# ============================================================================
# Skills & MCP Servers - Linux Installation Script
# ============================================================================
# Este script instala automáticamente skills y servidores MCP en Linux
# ============================================================================

set -e

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Variables de configuración
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEPLOYMENT_DIR="$(dirname "$SCRIPT_DIR")"
SKILLS_PACKAGE_DIR="$DEPLOYMENT_DIR/skills-package"
MCP_SERVERS_DIR="$DEPLOYMENT_DIR/mcp-servers"
CONFIG_DIR="$DEPLOYMENT_DIR/config"

# Directorios de instalación
AGENTS_DIR="$HOME/.agents/skills"
CLAUDE_DIR="$HOME/.claude/skills"
MCP_INSTALL_DIR="$HOME/.mcp-servers"
VSCODE_USER_DIR="$HOME/.config/Code/User"

# ============================================================================
# FUNCIONES AUXILIARES
# ============================================================================

print_header() {
    echo ""
    echo -e "${CYAN}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${NC}  $1"
    echo -e "${CYAN}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

print_step() {
    echo -e "${BLUE}▶${NC} $1"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

check_command() {
    if command -v "$1" &> /dev/null; then
        print_success "$1 está instalado"
        return 0
    else
        print_error "$1 NO está instalado"
        return 1
    fi
}

# ============================================================================
# VERIFICACIONES PREVIAS
# ============================================================================

print_header "VERIFICANDO REQUISITOS"

REQUIREMENTS_OK=true

print_step "Verificando Node.js..."
if check_command node; then
    NODE_VERSION=$(node --version)
    echo "   Versión: $NODE_VERSION"
else
    REQUIREMENTS_OK=false
fi

print_step "Verificando npm..."
if check_command npm; then
    NPM_VERSION=$(npm --version)
    echo "   Versión: $NPM_VERSION"
else
    REQUIREMENTS_OK=false
fi

print_step "Verificando Git..."
if check_command git; then
    GIT_VERSION=$(git --version)
    echo "   $GIT_VERSION"
else
    REQUIREMENTS_OK=false
fi

if [ "$REQUIREMENTS_OK" = false ]; then
    print_error "Faltan requisitos necesarios. Por favor instala Node.js, npm y Git."
    exit 1
fi

# ============================================================================
# INSTALACIÓN DE SKILLS
# ============================================================================

print_header "INSTALANDO SKILLS"

install_skills() {
    local SOURCE_DIR=$1
    local TARGET_DIR=$2
    local LOCATION_NAME=$3

    print_step "Instalando skills en $LOCATION_NAME ($TARGET_DIR)..."

    if [ ! -d "$SOURCE_DIR" ]; then
        print_warning "Directorio de skills no encontrado: $SOURCE_DIR"
        return
    fi

    # Crear directorio destino
    mkdir -p "$TARGET_DIR"

    # Copiar skills
    local COUNT=0
    for skill_dir in "$SOURCE_DIR"/*; do
        if [ -d "$skill_dir" ]; then
            local skill_name=$(basename "$skill_dir")
            print_step "  → $skill_name"
            
            # Copiar el skill (sobrescribir si existe)
            cp -r "$skill_dir" "$TARGET_DIR/"
            ((COUNT++))
        fi
    done

    print_success "$COUNT skills instalados en $LOCATION_NAME"
}

# Instalar skills de proyecto (si existen)
if [ -d "$SKILLS_PACKAGE_DIR/project-skills" ]; then
    install_skills "$SKILLS_PACKAGE_DIR/project-skills" "$AGENTS_DIR" "project skills"
else
    print_warning "No se encontraron project skills para instalar"
fi

# Instalar skills de usuario (si existen)
if [ -d "$SKILLS_PACKAGE_DIR/user-skills" ]; then
    install_skills "$SKILLS_PACKAGE_DIR/user-skills" "$CLAUDE_DIR" "user skills"
else
    print_warning "No se encontraron user skills para instalar"
fi

# ============================================================================
# INSTALACIÓN DE SERVIDORES MCP
# ============================================================================

print_header "INSTALANDO SERVIDORES MCP"

install_mcp_server() {
    local SERVER_NAME=$1
    local SERVER_DIR="$MCP_SERVERS_DIR/$SERVER_NAME"

    print_step "Instalando $SERVER_NAME..."

    if [ ! -d "$SERVER_DIR" ]; then
        print_warning "Servidor MCP no encontrado: $SERVER_DIR"
        return 1
    fi

    local TARGET_DIR="$MCP_INSTALL_DIR/$SERVER_NAME"
    mkdir -p "$TARGET_DIR"

    # Copiar archivos del servidor
    cp -r "$SERVER_DIR"/* "$TARGET_DIR/"

    # Instalar dependencias
    print_step "  Instalando dependencias de $SERVER_NAME..."
    cd "$TARGET_DIR"
    npm install --quiet

    # Compilar TypeScript
    print_step "  Compilando $SERVER_NAME..."
    npm run build

    print_success "$SERVER_NAME instalado correctamente"
    return 0
}

# Instalar skills-reader
if install_mcp_server "skills-reader-mcp"; then
    SKILLS_READER_INSTALLED=true
else
    SKILLS_READER_INSTALLED=false
fi

# Instalar sand-assistant (si existe)
if [ -d "$MCP_SERVERS_DIR/sand-assistant" ]; then
    install_mcp_server "sand-assistant"
fi

# ============================================================================
# CONFIGURACIÓN DE VSCODE
# ============================================================================

print_header "CONFIGURANDO VSCODE"

# Crear directorio de configuración de VSCode si no existe
mkdir -p "$VSCODE_USER_DIR"

# Archivo de configuración MCP
MCP_CONFIG_FILE="$VSCODE_USER_DIR/mcp-servers.json"

print_step "Configurando servidores MCP..."

# Crear o actualizar configuración MCP
cat > "$MCP_CONFIG_FILE" << EOF
{
  "mcpServers": {
    "skills-reader": {
      "command": "node",
      "args": ["$MCP_INSTALL_DIR/skills-reader-mcp/dist/index.js"],
      "env": {},
      "disabled": false,
      "alwaysAllow": [
        "list_skills",
        "read_skill",
        "search_skills",
        "get_all_skills_content"
      ]
    }
  }
}
EOF

print_success "Configuración MCP creada: $MCP_CONFIG_FILE"

# Actualizar settings.json de VSCode
VSCODE_SETTINGS="$VSCODE_USER_DIR/settings.json"

if [ -f "$VSCODE_SETTINGS" ]; then
    print_step "Actualizando settings.json..."
    
    # Hacer backup
    cp "$VSCODE_SETTINGS" "$VSCODE_SETTINGS.backup-$(date +%Y%m%d-%H%M%S)"
    print_success "Backup creado"

    # Verificar si ya tiene la configuración MCP
    if ! grep -q "github.copilot.chat.mcp.configFile" "$VSCODE_SETTINGS"; then
        print_step "Añadiendo configuración MCP a settings.json..."
        
        # Usar jq si está disponible, si no, advertir al usuario
        if command -v jq &> /dev/null; then
            jq --arg config_path "$MCP_CONFIG_FILE" \
               '. + {"github.copilot.chat.mcp.configFile": $config_path, "github.copilot.chat.mcp.enabled": true}' \
               "$VSCODE_SETTINGS" > "$VSCODE_SETTINGS.tmp"
            mv "$VSCODE_SETTINGS.tmp" "$VSCODE_SETTINGS"
            print_success "settings.json actualizado automáticamente"
        else
            print_warning "jq no está instalado. Por favor añade manualmente a settings.json:"
            echo ""
            echo "  \"github.copilot.chat.mcp.configFile\": \"$MCP_CONFIG_FILE\","
            echo "  \"github.copilot.chat.mcp.enabled\": true"
            echo ""
        fi
    else
        print_success "Configuración MCP ya existe en settings.json"
    fi
else
    print_step "Creando settings.json..."
    cat > "$VSCODE_SETTINGS" << EOF
{
  "github.copilot.chat.mcp.configFile": "$MCP_CONFIG_FILE",
  "github.copilot.chat.mcp.enabled": true,
  "chat.mcp.autostart": "always"
}
EOF
    print_success "settings.json creado"
fi

# ============================================================================
# VERIFICACIÓN FINAL
# ============================================================================

print_header "VERIFICACIÓN DE INSTALACIÓN"

print_step "Contando skills instalados..."
PROJECT_SKILLS_COUNT=0
USER_SKILLS_COUNT=0

if [ -d "$AGENTS_DIR" ]; then
    PROJECT_SKILLS_COUNT=$(ls -1 "$AGENTS_DIR" 2>/dev/null | wc -l)
fi

if [ -d "$CLAUDE_DIR" ]; then
    USER_SKILLS_COUNT=$(ls -1 "$CLAUDE_DIR" 2>/dev/null | wc -l)
fi

echo "  Project skills: $PROJECT_SKILLS_COUNT"
echo "  User skills: $USER_SKILLS_COUNT"
echo "  Total: $((PROJECT_SKILLS_COUNT + USER_SKILLS_COUNT))"

print_step "Verificando servidores MCP..."
if [ -f "$MCP_INSTALL_DIR/skills-reader-mcp/dist/index.js" ]; then
    print_success "skills-reader-mcp instalado correctamente"
else
    print_error "skills-reader-mcp NO se instaló correctamente"
fi

print_step "Verificando configuración de VSCode..."
if [ -f "$MCP_CONFIG_FILE" ]; then
    print_success "Configuración MCP encontrada"
else
    print_error "Configuración MCP NO encontrada"
fi

# ============================================================================
# RESUMEN FINAL
# ============================================================================

print_header "¡INSTALACIÓN COMPLETADA!"

echo -e "${GREEN}✅ Skills instalados: $((PROJECT_SKILLS_COUNT + USER_SKILLS_COUNT))${NC}"
echo -e "${GREEN}✅ Servidores MCP instalados${NC}"
echo -e "${GREEN}✅ VSCode configurado${NC}"
echo ""
echo -e "${YELLOW}⚠️  IMPORTANTE:${NC}"
echo -e "   ${CYAN}Debes reiniciar VSCode para que los cambios tomen efecto${NC}"
echo -e "   ${CYAN}Ctrl + Shift + P → 'Reload Window'${NC}"
echo ""
echo -e "${BLUE}📝 Cómo usar:${NC}"
echo "   En el chat de Copilot escribe:"
echo "   ${GREEN}@skills-reader list_skills${NC}"
echo ""
echo -e "${BLUE}📚 Documentación:${NC}"
echo "   $DEPLOYMENT_DIR/docs/"
echo ""
echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
