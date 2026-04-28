# ============================================================================
# Skills & MCP Servers - Windows Installation Script
# ============================================================================
# Este script instala automáticamente skills y servidores MCP en Windows
# Uso: .\install-windows.ps1
# ============================================================================

# Configuración de ejecución
$ErrorActionPreference = "Stop"
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# Variables de configuración
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$DeploymentDir = Split-Path -Parent $ScriptDir
$SkillsPackageDir = Join-Path $DeploymentDir "skills-package"
$McpServersDir = Join-Path $DeploymentDir "mcp-servers"
$ConfigDir = Join-Path $DeploymentDir "config"

# Directorios de instalación
$HomeDir = $env:USERPROFILE
$AgentsDir = Join-Path $HomeDir ".agents\skills"
$ClaudeDir = Join-Path $HomeDir ".claude\skills"
$McpInstallDir = Join-Path $HomeDir ".mcp-servers"
$VscodeUserDir = Join-Path $HomeDir "AppData\Roaming\Code\User"

# ============================================================================
# FUNCIONES AUXILIARES
# ============================================================================

function Write-Header {
    param([string]$Message)
    Write-Host ""
    Write-Host "╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║  $Message" -ForegroundColor Cyan
    Write-Host "╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
    Write-Host ""
}

function Write-Step {
    param([string]$Message)
    Write-Host "▶ $Message" -ForegroundColor Blue
}

function Write-Success {
    param([string]$Message)
    Write-Host "✅ $Message" -ForegroundColor Green
}

function Write-Warning-Custom {
    param([string]$Message)
    Write-Host "⚠️  $Message" -ForegroundColor Yellow
}

function Write-Error-Custom {
    param([string]$Message)
    Write-Host "❌ $Message" -ForegroundColor Red
}

function Test-Command {
    param([string]$Command)
    try {
        if (Get-Command $Command -ErrorAction SilentlyContinue) {
            Write-Success "$Command está instalado"
            return $true
        } else {
            Write-Error-Custom "$Command NO está instalado"
            return $false
        }
    } catch {
        Write-Error-Custom "$Command NO está instalado"
        return $false
    }
}

# ============================================================================
# VERIFICACIONES PREVIAS
# ============================================================================

Write-Header "VERIFICANDO REQUISITOS"

$RequirementsOk = $true

Write-Step "Verificando Node.js..."
if (Test-Command "node") {
    $NodeVersion = node --version
    Write-Host "   Versión: $NodeVersion"
} else {
    $RequirementsOk = $false
}

Write-Step "Verificando npm..."
if (Test-Command "npm") {
    $NpmVersion = npm --version
    Write-Host "   Versión: $NpmVersion"
} else {
    $RequirementsOk = $false
}

Write-Step "Verificando Git..."
if (Test-Command "git") {
    $GitVersion = git --version
    Write-Host "   $GitVersion"
} else {
    $RequirementsOk = $false
}

if (-not $RequirementsOk) {
    Write-Error-Custom "Faltan requisitos necesarios."
    Write-Host ""
    Write-Host "Por favor instala:" -ForegroundColor Yellow
    Write-Host "  - Node.js: https://nodejs.org/" -ForegroundColor Yellow
    Write-Host "  - Git: https://git-scm.com/download/win" -ForegroundColor Yellow
    Write-Host ""
    exit 1
}

# ============================================================================
# INSTALACIÓN DE SKILLS
# ============================================================================

Write-Header "INSTALANDO SKILLS"

function Install-Skills {
    param(
        [string]$SourceDir,
        [string]$TargetDir,
        [string]$LocationName
    )

    Write-Step "Instalando skills en $LocationName ($TargetDir)..."

    if (-not (Test-Path $SourceDir)) {
        Write-Warning-Custom "Directorio de skills no encontrado: $SourceDir"
        return
    }

    # Crear directorio destino
    if (-not (Test-Path $TargetDir)) {
        New-Item -ItemType Directory -Path $TargetDir -Force | Out-Null
    }

    # Copiar skills
    $Count = 0
    Get-ChildItem -Path $SourceDir -Directory | ForEach-Object {
        $SkillName = $_.Name
        Write-Step "  → $SkillName"
        
        $DestSkill = Join-Path $TargetDir $SkillName
        if (Test-Path $DestSkill) {
            Remove-Item -Path $DestSkill -Recurse -Force
        }
        
        Copy-Item -Path $_.FullName -Destination $TargetDir -Recurse -Force
        $Count++
    }

    Write-Success "$Count skills instalados en $LocationName"
}

# Instalar skills de proyecto
$ProjectSkillsDir = Join-Path $SkillsPackageDir "project-skills"
if (Test-Path $ProjectSkillsDir) {
    Install-Skills -SourceDir $ProjectSkillsDir -TargetDir $AgentsDir -LocationName "project skills"
} else {
    Write-Warning-Custom "No se encontraron project skills para instalar"
}

# Instalar skills de usuario
$UserSkillsDir = Join-Path $SkillsPackageDir "user-skills"
if (Test-Path $UserSkillsDir) {
    Install-Skills -SourceDir $UserSkillsDir -TargetDir $ClaudeDir -LocationName "user skills"
} else {
    Write-Warning-Custom "No se encontraron user skills para instalar"
}

# ============================================================================
# INSTALACIÓN DE SERVIDORES MCP
# ============================================================================

Write-Header "INSTALANDO SERVIDORES MCP"

function Install-McpServer {
    param([string]$ServerName)

    Write-Step "Instalando $ServerName..."

    $ServerDir = Join-Path $McpServersDir $ServerName
    if (-not (Test-Path $ServerDir)) {
        Write-Warning-Custom "Servidor MCP no encontrado: $ServerDir"
        return $false
    }

    $TargetDir = Join-Path $McpInstallDir $ServerName
    if (-not (Test-Path $TargetDir)) {
        New-Item -ItemType Directory -Path $TargetDir -Force | Out-Null
    }

    # Copiar archivos del servidor
    Copy-Item -Path "$ServerDir\*" -Destination $TargetDir -Recurse -Force

    # Instalar dependencias
    Write-Step "  Instalando dependencias de $ServerName..."
    Push-Location $TargetDir
    npm install --quiet 2>&1 | Out-Null

    # Compilar TypeScript
    Write-Step "  Compilando $ServerName..."
    npm run build 2>&1 | Out-Null
    Pop-Location

    Write-Success "$ServerName instalado correctamente"
    return $true
}

# Instalar skills-reader
$SkillsReaderInstalled = Install-McpServer -ServerName "skills-reader-mcp"

# Instalar sand-assistant (si existe)
$SandAssistantDir = Join-Path $McpServersDir "sand-assistant"
if (Test-Path $SandAssistantDir) {
    Install-McpServer -ServerName "sand-assistant"
}

# ============================================================================
# CONFIGURACIÓN DE VSCODE
# ============================================================================

Write-Header "CONFIGURANDO VSCODE"

# Crear directorio de configuración de VSCode si no existe
if (-not (Test-Path $VscodeUserDir)) {
    New-Item -ItemType Directory -Path $VscodeUserDir -Force | Out-Null
}

# Archivo de configuración MCP
$McpConfigFile = Join-Path $VscodeUserDir "mcp-servers.json"

Write-Step "Configurando servidores MCP..."

# Crear ruta para Node.js (normalizada para JSON)
$SkillsReaderPath = (Join-Path $McpInstallDir "skills-reader-mcp\dist\index.js") -replace '\\', '/'

# Crear configuración MCP
$McpConfig = @{
    mcpServers = @{
        "skills-reader" = @{
            command = "node"
            args = @($SkillsReaderPath)
            env = @{}
            disabled = $false
            alwaysAllow = @(
                "list_skills",
                "read_skill",
                "search_skills",
                "get_all_skills_content"
            )
        }
    }
} | ConvertTo-Json -Depth 10

$McpConfig | Set-Content -Path $McpConfigFile -Encoding UTF8
Write-Success "Configuración MCP creada: $McpConfigFile"

# Actualizar settings.json de VSCode
$VscodeSettings = Join-Path $VscodeUserDir "settings.json"

if (Test-Path $VscodeSettings) {
    Write-Step "Actualizando settings.json..."
    
    # Hacer backup
    $BackupFile = "$VscodeSettings.backup-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
    Copy-Item $VscodeSettings $BackupFile
    Write-Success "Backup creado"

    # Leer settings actual
    try {
        $Settings = Get-Content $VscodeSettings -Raw | ConvertFrom-Json
        
        # Añadir configuración MCP si no existe
        if (-not $Settings.'github.copilot.chat.mcp.configFile') {
            $Settings | Add-Member -NotePropertyName 'github.copilot.chat.mcp.configFile' -NotePropertyValue $McpConfigFile -Force
            $Settings | Add-Member -NotePropertyName 'github.copilot.chat.mcp.enabled' -NotePropertyValue $true -Force
            
            $Settings | ConvertTo-Json -Depth 10 | Set-Content -Path $VscodeSettings -Encoding UTF8
            Write-Success "settings.json actualizado automáticamente"
        } else {
            Write-Success "Configuración MCP ya existe en settings.json"
        }
    } catch {
        Write-Warning-Custom "Error al actualizar settings.json. Por favor añade manualmente:"
        Write-Host "  `"github.copilot.chat.mcp.configFile`": `"$McpConfigFile`","
        Write-Host "  `"github.copilot.chat.mcp.enabled`": true"
    }
} else {
    Write-Step "Creando settings.json..."
    $NewSettings = @{
        'github.copilot.chat.mcp.configFile' = $McpConfigFile
        'github.copilot.chat.mcp.enabled' = $true
        'chat.mcp.autostart' = 'always'
    } | ConvertTo-Json -Depth 10
    
    $NewSettings | Set-Content -Path $VscodeSettings -Encoding UTF8
    Write-Success "settings.json creado"
}

# ============================================================================
# VERIFICACIÓN FINAL
# ============================================================================

Write-Header "VERIFICACIÓN DE INSTALACIÓN"

Write-Step "Contando skills instalados..."
$ProjectSkillsCount = 0
$UserSkillsCount = 0

if (Test-Path $AgentsDir) {
    $ProjectSkillsCount = (Get-ChildItem $AgentsDir -Directory -ErrorAction SilentlyContinue).Count
}

if (Test-Path $ClaudeDir) {
    $UserSkillsCount = (Get-ChildItem $ClaudeDir -Directory -ErrorAction SilentlyContinue).Count
}

Write-Host "  Project skills: $ProjectSkillsCount"
Write-Host "  User skills: $UserSkillsCount"
Write-Host "  Total: $($ProjectSkillsCount + $UserSkillsCount)"

Write-Step "Verificando servidores MCP..."
$SkillsReaderIndex = Join-Path $McpInstallDir "skills-reader-mcp\dist\index.js"
if (Test-Path $SkillsReaderIndex) {
    Write-Success "skills-reader-mcp instalado correctamente"
} else {
    Write-Error-Custom "skills-reader-mcp NO se instaló correctamente"
}

Write-Step "Verificando configuración de VSCode..."
if (Test-Path $McpConfigFile) {
    Write-Success "Configuración MCP encontrada"
} else {
    Write-Error-Custom "Configuración MCP NO encontrada"
}

# ============================================================================
# RESUMEN FINAL
# ============================================================================

Write-Header "¡INSTALACIÓN COMPLETADA!"

Write-Host "✅ Skills instalados: $($ProjectSkillsCount + $UserSkillsCount)" -ForegroundColor Green
Write-Host "✅ Servidores MCP instalados" -ForegroundColor Green
Write-Host "✅ VSCode configurado" -ForegroundColor Green
Write-Host ""
Write-Host "⚠️  IMPORTANTE:" -ForegroundColor Yellow
Write-Host "   Debes reiniciar VSCode para que los cambios tomen efecto" -ForegroundColor Cyan
Write-Host "   Ctrl + Shift + P → 'Reload Window'" -ForegroundColor Cyan
Write-Host ""
Write-Host "📝 Cómo usar:" -ForegroundColor Blue
Write-Host "   En el chat de Copilot escribe:"
Write-Host "   @skills-reader list_skills" -ForegroundColor Green
Write-Host ""
Write-Host "📚 Documentación:" -ForegroundColor Blue
Write-Host "   $DeploymentDir\docs\"
Write-Host ""
Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
