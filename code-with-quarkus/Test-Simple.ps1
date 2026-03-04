# Script simples para testar JWT
# Teste rapido e direto

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  TESTE JWT/RBAC - QUARKUS" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Teste 1: Health Check
Write-Host "[1/5] Health Check" -ForegroundColor Cyan
Write-Host "Endpoint: http://localhost:8080/q/health"
try {
    $resp = Invoke-WebRequest http://localhost:8080/q/health -UseBasicParsing -ErrorAction Stop
    Write-Host "OK - Status: $($resp.StatusCode)" -ForegroundColor Green
    Write-Host ""
} catch {
    Write-Host "ERRO - $($_.Exception.Message)" -ForegroundColor Red
    Write-Host ""
}

# Teste 2: Star Wars API
Write-Host "[2/5] Star Wars API" -ForegroundColor Cyan
Write-Host "Endpoint: http://localhost:8080/starwars/starships"
try {
    $resp = Invoke-WebRequest http://localhost:8080/starwars/starships -UseBasicParsing -ErrorAction Stop
    Write-Host "OK - Status: $($resp.StatusCode)" -ForegroundColor Green
    $content = $resp.Content.Substring(0, [Math]::Min(150, $resp.Content.Length))
    Write-Host "Resposta (primeiros 150 chars): $content..." -ForegroundColor Gray
    Write-Host ""
} catch {
    Write-Host "ERRO - $($_.Exception.Message)" -ForegroundColor Red
    Write-Host ""
}

# Teste 3: Sem Token
Write-Host "[3/5] Endpoint Seguro SEM Token (deve falhar com 401)" -ForegroundColor Cyan
Write-Host "Endpoint: http://localhost:8080/secure/claim"
try {
    $resp = Invoke-WebRequest http://localhost:8080/secure/claim -UseBasicParsing -ErrorAction Stop
    Write-Host "PROBLEMA - Acesso permitido sem token!" -ForegroundColor Red
    Write-Host ""
} catch {
    if ($_.Exception.Response.StatusCode -eq "Unauthorized") {
        Write-Host "OK - Corretamente bloqueado (401 Unauthorized)" -ForegroundColor Green
        Write-Host ""
    } else {
        Write-Host "AVISO - Status: $($_.Exception.Response.StatusCode)" -ForegroundColor Yellow
        Write-Host ""
    }
}

# Teste 4: Baixar Token
Write-Host "[4/5] Baixando Token JWT" -ForegroundColor Cyan
Write-Host "URL: https://raw.githubusercontent.com/eldermoraes/unipds/main/jwt-token/quarkus.jwt.token"
$token = curl.exe -s https://raw.githubusercontent.com/eldermoraes/unipds/main/jwt-token/quarkus.jwt.token

if ($token -and $token.Length -gt 10) {
    Write-Host "OK - Token obtido!" -ForegroundColor Green
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Yellow
    Write-Host "  INFORMACOES DO TOKEN JWT" -ForegroundColor Yellow
    Write-Host "========================================" -ForegroundColor Yellow
    Write-Host "Tamanho: $($token.Length) caracteres" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "TOKEN COMPLETO:" -ForegroundColor Yellow
    Write-Host $token -ForegroundColor Magenta
    Write-Host ""

    # Decodificar JWT (extrair payload)
    try {
        $parts = $token.Split('.')
        if ($parts.Length -ge 2) {
            $payload = $parts[1]
            # Adicionar padding se necessário
            $padding = 4 - ($payload.Length % 4)
            if ($padding -lt 4) {
                $payload += "=" * $padding
            }
            $payloadBytes = [Convert]::FromBase64String($payload)
            $payloadJson = [System.Text.Encoding]::UTF8.GetString($payloadBytes)

            Write-Host "PAYLOAD DECODIFICADO:" -ForegroundColor Yellow
            Write-Host $payloadJson -ForegroundColor Cyan
            Write-Host ""

            # Formatar JSON
            $payloadObj = $payloadJson | ConvertFrom-Json
            Write-Host "INFORMACOES EXTRAIDAS:" -ForegroundColor Yellow
            Write-Host "  - Username: $($payloadObj.preferred_username)" -ForegroundColor Green
            Write-Host "  - Roles: $($payloadObj.groups -join ', ')" -ForegroundColor Green
            Write-Host "  - Issuer: $($payloadObj.iss)" -ForegroundColor Green
            Write-Host "  - Expiration: $(Get-Date -UnixTimeSeconds $payloadObj.exp -Format 'yyyy-MM-dd HH:mm:ss')" -ForegroundColor Green
            Write-Host ""
        }
    } catch {
        Write-Host "Aviso: Nao foi possivel decodificar o payload" -ForegroundColor Yellow
        Write-Host ""
    }
    Write-Host "========================================" -ForegroundColor Yellow
    Write-Host ""
} else {
    Write-Host "ERRO - Token nao obtido" -ForegroundColor Red
    Write-Host ""
    exit 1
}

# Teste 5: Com Token
Write-Host "[5/6] Endpoint Seguro COM Token (deve passar com 200)" -ForegroundColor Cyan
Write-Host "Endpoint: http://localhost:8080/secure/claim"
Write-Host "Header: Authorization: Bearer {token}"
try {
    $headers = @{ "Authorization" = "Bearer $token" }
    $resp = Invoke-WebRequest http://localhost:8080/secure/claim `
        -Headers $headers `
        -UseBasicParsing `
        -ErrorAction Stop
    Write-Host "OK - Status: $($resp.StatusCode)" -ForegroundColor Green
    Write-Host "Usuario autenticado: $($resp.Content)" -ForegroundColor Green
    Write-Host ""
} catch {
    Write-Host "ERRO - $($_.Exception.Message)" -ForegroundColor Red
    if ($_.Exception.Response) {
        Write-Host "Status: $($_.Exception.Response.StatusCode)" -ForegroundColor Red
        Write-Host "Motivo: Verifique se a role do token corresponde ao esperado" -ForegroundColor Yellow
    }
    Write-Host ""
}

# Teste 6: Informações completas do token
Write-Host "[6/6] Informacoes Completas do Token JWT" -ForegroundColor Cyan
Write-Host "Endpoint: http://localhost:8080/secure/info"
Write-Host "Header: Authorization: Bearer {token}"
try {
    $headers = @{ "Authorization" = "Bearer $token" }
    $resp = Invoke-WebRequest http://localhost:8080/secure/info `
        -Headers $headers `
        -UseBasicParsing `
        -ErrorAction Stop
    Write-Host "OK - Status: $($resp.StatusCode)" -ForegroundColor Green
    Write-Host "Informacoes do JWT extraidas pelo servidor:" -ForegroundColor Yellow
    $resp.Content | ConvertFrom-Json | ConvertTo-Json -Depth 3 | Write-Host -ForegroundColor Cyan
    Write-Host ""
} catch {
    Write-Host "ERRO - $($_.Exception.Message)" -ForegroundColor Red
    if ($_.Exception.Response) {
        Write-Host "Status: $($_.Exception.Response.StatusCode)" -ForegroundColor Red
    }
    Write-Host ""
}

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  TESTES CONCLUIDOS" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

