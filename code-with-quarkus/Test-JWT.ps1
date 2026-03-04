# Script PowerShell para Testar JWT no Quarkus
# Use este script para fazer teste de seguranca com JWT e RBAC

$ErrorActionPreference = "Continue"

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Teste JWT/RBAC - Quarkus" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Passo 1: Baixar o Token JWT
Write-Host "[1/3] Baixando token JWT..." -ForegroundColor Yellow

$token = $null
try {
    $token = curl.exe -s https://raw.githubusercontent.com/eldermoraes/unipds/main/jwt-token/quarkus.jwt.token

    if ($token -and $token.Length -gt 10) {
        Write-Host "OK - Token obtido com sucesso!" -ForegroundColor Green
    } else {
        Write-Host "ERRO - Token vazio ou invalido" -ForegroundColor Red
        Write-Host ""
        Write-Host "========================================" -ForegroundColor Cyan
        Write-Host "  Teste Concluido" -ForegroundColor Green
        Write-Host "========================================" -ForegroundColor Cyan
        exit 1
    }
} catch {
    Write-Host "ERRO ao baixar token: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "  Teste Concluido" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Cyan
    exit 1
}

# Passo 2: Exibir Token (primeiros 50 caracteres)
Write-Host "[2/3] Token obtido" -ForegroundColor Yellow
$tokenLength = $token.Length
Write-Host "Tamanho: $tokenLength caracteres" -ForegroundColor Cyan

if ($tokenLength -gt 50) {
    $preview = $token.Substring(0, 50)
    Write-Host "Primeiros 50 caracteres: $preview..." -ForegroundColor Magenta
} else {
    Write-Host "Token: $token" -ForegroundColor Magenta
}
Write-Host ""

# Passo 3: Fazer requisicao com autenticacao
Write-Host "[3/3] Testando requisicao com token..." -ForegroundColor Yellow
Write-Host "Endpoint: http://localhost:8080/api/secure/claim" -ForegroundColor Cyan
Write-Host ""

try {
    $headers = @{
        "Authorization" = "Bearer $token"
        "Content-Type" = "application/json"
    }

    $response = Invoke-WebRequest -Uri "http://localhost:8080/api/secure/claim" `
        -Headers $headers `
        -UseBasicParsing `
        -ErrorAction Stop

    Write-Host "OK - Requisicao bem-sucedida!" -ForegroundColor Green
    Write-Host "Status: $($response.StatusCode)" -ForegroundColor Green
    Write-Host "Resposta: $($response.Content)" -ForegroundColor Cyan

} catch {
    Write-Host "ERRO na requisicao:" -ForegroundColor Red

    if ($_.Exception.Response) {
        $statusCode = $_.Exception.Response.StatusCode
        Write-Host "Status Code: $statusCode" -ForegroundColor Red

        if ($statusCode -eq 401) {
            Write-Host "Motivo: Token invalido ou ausente" -ForegroundColor Yellow
        } elseif ($statusCode -eq 403) {
            Write-Host "Motivo: Permissao insuficiente" -ForegroundColor Yellow
        }
    } else {
        Write-Host "Mensagem: $($_.Exception.Message)" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Teste Concluido" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

