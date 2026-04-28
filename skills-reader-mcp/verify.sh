#!/bin/bash

echo "🔍 Verificando configuración de Skills Reader MCP..."
echo ""

# 1. Verificar directorios de skills
echo "📁 Verificando directorios de skills..."
if [ -d "$HOME/.agents/skills" ]; then
    AGENT_COUNT=$(ls -1 "$HOME/.agents/skills" | wc -l)
    echo "  ✅ ~/.agents/skills existe ($AGENT_COUNT skills)"
else
    echo "  ⚠️  ~/.agents/skills no existe"
fi

if [ -d "$HOME/.claude/skills" ]; then
    CLAUDE_COUNT=$(ls -1 "$HOME/.claude/skills" | wc -l)
    echo "  ✅ ~/.claude/skills existe ($CLAUDE_COUNT skills)"
else
    echo "  ⚠️  ~/.claude/skills no existe"
fi

echo ""

# 2. Verificar compilación del servidor
echo "🔨 Verificando compilación..."
if [ -f "$HOME/Sources/MCP/skills-reader-mcp/dist/index.js" ]; then
    echo "  ✅ Servidor compilado correctamente"
else
    echo "  ❌ Servidor no compilado. Ejecuta: npm run build"
    exit 1
fi

echo ""

# 3. Verificar configuración MCP
echo "⚙️  Verificando configuración MCP..."
MCP_CONFIG="$HOME/Sources/CursoAI/agent-implementacion/mcp-server/mcp-config-vscode.json"
if [ -f "$MCP_CONFIG" ]; then
    echo "  ✅ Archivo de configuración existe"
    
    if grep -q "skills-reader" "$MCP_CONFIG"; then
        echo "  ✅ skills-reader configurado en MCP"
    else
        echo "  ❌ skills-reader NO encontrado en configuración MCP"
        exit 1
    fi
else
    echo "  ❌ Archivo de configuración MCP no existe"
    exit 1
fi

echo ""

# 4. Verificar configuración de VSCode
echo "🖥️  Verificando configuración de VSCode..."
VSCODE_SETTINGS="$HOME/.config/Code/User/settings.json"
if [ -f "$VSCODE_SETTINGS" ]; then
    echo "  ✅ settings.json existe"
    
    if grep -q "github.copilot.chat.mcp.configFile" "$VSCODE_SETTINGS"; then
        echo "  ✅ Ruta MCP configurada en VSCode"
    else
        echo "  ⚠️  Ruta MCP no encontrada en settings.json"
    fi
else
    echo "  ⚠️  settings.json no existe"
fi

echo ""

# 5. Listar algunos skills como ejemplo
echo "📝 Ejemplo de skills disponibles:"
echo ""
echo "  En ~/.agents/skills:"
ls -1 "$HOME/.agents/skills" 2>/dev/null | head -5 | sed 's/^/    - /'

echo ""
echo "  En ~/.claude/skills:"
ls -1 "$HOME/.claude/skills" 2>/dev/null | head -5 | sed 's/^/    - /'

echo ""
echo "✅ Verificación completada!"
echo ""
echo "🚀 Próximos pasos:"
echo "  1. Reinicia VSCode (Ctrl+Shift+P > 'Reload Window')"
echo "  2. Abre el chat de Copilot"
echo "  3. Prueba: @skills-reader list_skills"
echo ""
