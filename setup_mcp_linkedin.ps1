# Setup MCP LinkedIn - MadeinWeb
# Execute no PowerShell como administrador

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Setup MCP LinkedIn - MadeinWeb" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# -- 1. Verifica se uv esta instalado --
Write-Host "[1/4] Verificando instalacao do uv..." -ForegroundColor Yellow
if (Get-Command uv -ErrorAction SilentlyContinue) {
    Write-Host "       uv ja esta instalado!" -ForegroundColor Green
} else {
    Write-Host "       uv nao encontrado. Instalando..." -ForegroundColor Yellow
    try {
        Invoke-RestMethod https://astral.sh/uv/install.ps1 | Invoke-Expression
        Write-Host "       uv instalado com sucesso!" -ForegroundColor Green
    } catch {
        Write-Host "       ERRO ao instalar uv: $_" -ForegroundColor Red
        Write-Host "       Instale manualmente em: https://docs.astral.sh/uv/" -ForegroundColor Red
        pause
        exit 1
    }
}

# -- 2. Testa o mcp-server-linkedin --
Write-Host ""
Write-Host "[2/4] Verificando mcp-server-linkedin..." -ForegroundColor Yellow
try {
    $null = uvx mcp-server-linkedin@latest --help 2>&1
    Write-Host "       Pacote pronto!" -ForegroundColor Green
} catch {
    Write-Host "       Pacote sera baixado na primeira execucao." -ForegroundColor Yellow
}

# -- 3. Gera o mcp_config_linkedin.json --
Write-Host ""
Write-Host "[3/4] Gerando mcp_config_linkedin.json..." -ForegroundColor Yellow

$configPath = "$env:USERPROFILE\Documents\mcp_config_linkedin.json"
$config = @{
    mcpServers = @{
        linkedin = @{
            command = "uvx"
            args    = @("mcp-server-linkedin@latest")
            env     = @{
                UV_HTTP_TIMEOUT = "300"
            }
        }
    }
} | ConvertTo-Json -Depth 5

Set-Content -Path $configPath -Value $config -Encoding UTF8
Write-Host "       Arquivo gerado em: $configPath" -ForegroundColor Green

# -- 4. Instrucoes finais --
Write-Host ""
Write-Host "[4/4] Proximos passos:" -ForegroundColor Yellow
Write-Host ""
Write-Host "  1. Abra o Amazon Quick" -ForegroundColor White
Write-Host "  2. Va em Settings > Capabilities > MCP Servers" -ForegroundColor White
Write-Host "  3. Clique em Import e selecione:" -ForegroundColor White
Write-Host "     $configPath" -ForegroundColor Cyan
Write-Host "  4. Na primeira vez, o Quick vai abrir o browser" -ForegroundColor White
Write-Host "     para voce fazer login no LinkedIn." -ForegroundColor White
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Setup concluido com sucesso!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
pause
