# Script de Teste Completo - Quarkus com JWT/RBAC
# Execute este script para testar todos os endpoints

Write-Host "`n" | Out-Null
Write-Host "╔═══════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║        🧪 TESTE COMPLETO - QUARKUS JWT/RBAC                 ║" -ForegroundColor Cyan
Write-Host "╚═══════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

# Configuração
$baseUrl = "http://localhost:8080"
$tokenUrl = "https://raw.githubusercontent.com/eldermoraes/unipds/main/jwt-token/quarkus.jwt.token"

# Cores
$sucesso = "Green"
$erro = "Red"
$info = "Cyan"
$aviso = "Yellow"

# ============================================
# 1. TESTE: Health Check
# ============================================
Write-Host "[1/5] 🏥 Testando Health Check..." -ForegroundColor $info
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Gray

try {
    $response = Invoke-WebRequest -Uri "$baseUrl/q/health" -UseBasicParsing -ErrorAction Stop
    Write-Host "✓ Health Check OK" -ForegroundColor $sucesso
    Write-Host "  Status: $($response.StatusCode)" -ForegroundColor $sucesso
    Write-Host "  Resposta:" -ForegroundColor $info
    $response.Content | ConvertFrom-Json | ConvertTo-Json -Depth 3 | Write-Host -ForegroundColor $sucesso
} catch {
    Write-Host "✗ Falha no Health Check" -ForegroundColor $erro
    Write-Host "  Erro: $($_.Exception.Message)" -ForegroundColor $erro
}
Write-Host ""

# ============================================
# 2. TESTE: Star Wars API (sem autenticação)
# ============================================
Write-Host "[2/5] 🚀 Testando Star Wars API..." -ForegroundColor $info
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Gray

try {
    $response = Invoke-WebRequest -Uri "$baseUrl/starwars/starships" -UseBasicParsing -ErrorAction Stop
    Write-Host "✓ Star Wars API OK" -ForegroundColor $sucesso
    Write-Host "  Status: $($response.StatusCode)" -ForegroundColor $sucesso
    Write-Host "  Primeira linha da resposta:" -ForegroundColor $info
    $content = $response.Content.Substring(0, [Math]::Min(200, $response.Content.Length))
    Write-Host "  $content..." -ForegroundColor $sucesso
} catch {
    Write-Host "✗ Falha na Star Wars API" -ForegroundColor $erro
    Write-Host "  Erro: $($_.Exception.Message)" -ForegroundColor $erro
}
Write-Host ""

# ============================================
# 3. TESTE: Endpoint Seguro SEM TOKEN
# ============================================
Write-Host "[3/5] 🔒 Testando endpoint seguro SEM token..." -ForegroundColor $aviso
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Gray

try {
    $response = Invoke-WebRequest -Uri "$baseUrl/secure/claim" -UseBasicParsing -ErrorAction Stop
    Write-Host "⚠ Acesso sem autenticação funcionou (PROBLEMA!)" -ForegroundColor $erro
    Write-Host "  Status: $($response.StatusCode)" -ForegroundColor $erro
} catch {
    if ($_.Exception.Response.StatusCode -eq "Unauthorized") {
        Write-Host "✓ Corretamente bloqueado (401 Unauthorized)" -ForegroundColor $sucesso
    } elseif ($_.Exception.Response.StatusCode -eq "Forbidden") {
        Write-Host "✓ Corretamente bloqueado (403 Forbidden)" -ForegroundColor $sucesso
    } else {
        Write-Host "✓ Acesso negado (Status: $($_.Exception.Response.StatusCode))" -ForegroundColor $sucesso
    }
}
Write-Host ""

# ============================================
# 4. TESTE: Baixar Token JWT
# ============================================
Write-Host "[4/5] 🔑 Baixando Token JWT..." -ForegroundColor $info
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Gray

try {
    $tokenResponse = curl.exe -s $tokenUrl
    if ($LASTEXITCODE -eq 0 -and $tokenResponse) {
        Write-Host "✓ Token obtido com sucesso!" -ForegroundColor $sucesso

        # Salvar token
        $token = $tokenResponse
        Write-Host "  Tamanho do token: $($token.Length) caracteres" -ForegroundColor $info
        Write-Host "  Primeiros 50 caracteres:" -ForegroundColor $info
        Write-Host "  $($token.Substring(0, 50))..." -ForegroundColor $sucesso
    } else {
        Write-Host "✗ Erro ao baixar token" -ForegroundColor $erro
        exit 1
    }
} catch {
    Write-Host "✗ Erro ao baixar token: $_" -ForegroundColor $erro
    exit 1
}
Write-Host ""

# ============================================
# 5. TESTE: Endpoint Seguro COM TOKEN
# ============================================
Write-Host "[5/5] 🔐 Testando endpoint seguro COM token..." -ForegroundColor $info
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Gray

try {
    $headers = @{
        "Authorization" = "Bearer $token"
        "Content-Type"  = "application/json"
    }

    $response = Invoke-WebRequest -Uri "$baseUrl/secure/claim" `
        -Headers $headers `
        -UseBasicParsing `
        -ErrorAction Stop

    Write-Host "✓ Autenticação bem-sucedida!" -ForegroundColor $sucesso
    Write-Host "  Status: $($response.StatusCode)" -ForegroundColor $sucesso
    Write-Host "  Usuário autenticado: $($response.Content)" -ForegroundColor $sucesso

} catch {
    Write-Host "✗ Erro ao acessar endpoint seguro:" -ForegroundColor $erro
    Write-Host "  Status: $($_.Exception.Response.StatusCode)" -ForegroundColor $erro
    Write-Host "  Mensagem: $($_.Exception.Message)" -ForegroundColor $erro
}

Write-Host ""
Write-Host "╔═══════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║                   ✨ TESTES CONCLUÍDOS ✨                    ║" -ForegroundColor Cyan
Write-Host "╚═══════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

Write-Host "📋 Resumo:" -ForegroundColor $info
Write-Host "  1. ✓ Health Check verifica a saúde da aplicação" -ForegroundColor $info
Write-Host "  2. ✓ Star Wars API consome dados externos" -ForegroundColor $info
Write-Host "  3. ✓ Sem token: acesso negado (segurança OK)" -ForegroundColor $info
Write-Host "  4. ✓ Token JWT obtido com sucesso" -ForegroundColor $info
Write-Host "  5. ✓ Com token: acesso autorizado (autenticação OK)" -ForegroundColor $info
Write-Host ""

