# Setup MCP LinkedIn - MadeinWeb
# Rode via: irm https://raw.githubusercontent.com/kaueurias-ui/quick-suite-mcp-linkedin/main/setup_mcp_linkedin.ps1 | iex

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Setup MCP LinkedIn - MadeinWeb" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# -- 1. Verifica se uv esta instalado --
Write-Host "[1/4] Verificando instalacao do uv..." -ForegroundColor Yellow

$uvPath = Get-Command uv -ErrorAction SilentlyContinue
if ($uvPath) {
    Write-Host "       uv ja instalado: $($uvPath.Source)" -ForegroundColor Green
} else {
    Write-Host "       uv nao encontrado. Instalando..." -ForegroundColor Yellow
    try {
        $installScript = Invoke-RestMethod https://astral.sh/uv/install.ps1
        Invoke-Expression $installScript

        # Recarrega PATH da sessao atual
        $userPath    = [System.Environment]::GetEnvironmentVariable("PATH", "User")
        $machinePath = [System.Environment]::GetEnvironmentVariable("PATH", "Machine")
        $env:PATH    = "$userPath;$machinePath"

        # Tenta localizar manualmente se necessario
        if (-not (Get-Command uv -ErrorAction SilentlyContinue)) {
            $uvExe = "$env:USERPROFILE\.local\bin\uv.exe"
            if (Test-Path $uvExe) { $env:PATH = "$env:USERPROFILE\.local\bin;$env:PATH" }
        }

        if (Get-Command uv -ErrorAction SilentlyContinue) {
            Write-Host "       uv instalado com sucesso!" -ForegroundColor Green
        } else {
            Write-Host "       AVISO: feche e reabra o PowerShell e rode o comando novamente." -ForegroundColor Yellow
            Write-Host "Pressione qualquer tecla para fechar..."
            $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
            exit 0
        }
    } catch {
        Write-Host "       ERRO ao instalar o uv: $_" -ForegroundColor Red
        Write-Host "       Instale manualmente: https://docs.astral.sh/uv/" -ForegroundColor Red
        Write-Host "Pressione qualquer tecla para fechar..."
        $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        exit 1
    }
}

# -- 2. Pre-download do pacote --
Write-Host ""
Write-Host "[2/4] Baixando mcp-server-linkedin..." -ForegroundColor Yellow
try {
    $null = uvx mcp-server-linkedin@latest --version 2>&1
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
            env     = @{ UV_HTTP_TIMEOUT = "300" }
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
Write-Host "  4. Use o LinkedIn no Quick. Na primeira mensagem" -ForegroundColor White
Write-Host "     ele vai abrir o browser para voce fazer login." -ForegroundColor White
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Setup concluido com sucesso!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Pressione qualquer tecla para fechar..." -ForegroundColor DarkGray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
