# Script para testar integração OpenTelemetry
# Executa requisições e verifica traces no Jaeger

param(
    [string]$AppUrl = "http://localhost:8080",
    [string]$JaegerUrl = "http://localhost:16686"
)

Write-Host "======================================" -ForegroundColor Cyan
Write-Host "OpenTelemetry Integration Test" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan
Write-Host ""

# Função para fazer requisição com medição de tempo
function Test-Endpoint {
    param(
        [string]$Method = "GET",
        [string]$Url,
        [string]$Body = ""
    )

    $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

    try {
        if ($Method -eq "GET") {
            $response = Invoke-WebRequest -Uri $Url -Method GET -ErrorAction Stop
        } else {
            $response = Invoke-WebRequest -Uri $Url -Method POST `
                -ContentType "application/json" `
                -Body $Body -ErrorAction Stop
        }

        $stopwatch.Stop()

        Write-Host "✓ $Method $Url" -ForegroundColor Green
        Write-Host "  Status: $($response.StatusCode)" -ForegroundColor Green
        Write-Host "  Tempo: $($stopwatch.ElapsedMilliseconds)ms" -ForegroundColor Yellow
        Write-Host ""

        return $response
    } catch {
        $stopwatch.Stop()
        Write-Host "✗ $Method $Url" -ForegroundColor Red
        Write-Host "  Erro: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host "  Tempo: $($stopwatch.ElapsedMilliseconds)ms" -ForegroundColor Yellow
        Write-Host ""
        return $null
    }
}

# 1. Verificar saúde da aplicação
Write-Host "1️⃣  Testando Health Check..." -ForegroundColor Cyan
Test-Endpoint -Method "GET" -Url "$AppUrl/q/health" | Out-Null

# 2. Testar endpoint de Star Wars
Write-Host "2️⃣  Testando Star Wars API..." -ForegroundColor Cyan
Test-Endpoint -Method "GET" -Url "$AppUrl/starwars/starships" | Out-Null

# 3. Criar pessoa
Write-Host "3️⃣  Criando pessoa (POST)..." -ForegroundColor Cyan
$pessoaBody = @{
    nome = "João Silva"
    anoNascimento = 1990
} | ConvertTo-Json

Test-Endpoint -Method "POST" -Url "$AppUrl/pessoa" -Body $pessoaBody | Out-Null

# 4. Listar pessoas
Write-Host "4️⃣  Listando pessoas..." -ForegroundColor Cyan
Test-Endpoint -Method "GET" -Url "$AppUrl/pessoa" | Out-Null

# 5. Filtrar por ano de nascimento
Write-Host "5️⃣  Filtrando por ano de nascimento..." -ForegroundColor Cyan
Test-Endpoint -Method "GET" -Url "$AppUrl/pessoa/findByAnoNascimento?anoNascimento=1990" | Out-Null

# 6. Acessar métricas Prometheus
Write-Host "6️⃣  Verificando métricas Prometheus..." -ForegroundColor Cyan
Test-Endpoint -Method "GET" -Url "$AppUrl/q/metrics" | Out-Null

# Aguardar propagação de traces
Write-Host "⏳ Aguardando 5 segundos para traces serem propagados..." -ForegroundColor Yellow
Start-Sleep -Seconds 5

# 7. Verificar Jaeger
Write-Host "7️⃣  Verificando Jaeger Traces..." -ForegroundColor Cyan
try {
    $jaegerResponse = Invoke-WebRequest -Uri "$JaegerUrl/api/services" -ErrorAction Stop
    $services = $jaegerResponse.Content | ConvertFrom-Json

    Write-Host "✓ Jaeger UI: $JaegerUrl" -ForegroundColor Green
    Write-Host "  Serviços encontrados:" -ForegroundColor Yellow

    if ($services.data -and $services.data.Count -gt 0) {
        foreach ($service in $services.data) {
            Write-Host "    - $service" -ForegroundColor Cyan
        }
    } else {
        Write-Host "    ⚠️  Nenhum serviço encontrado ainda" -ForegroundColor Yellow
    }
    Write-Host ""
} catch {
    Write-Host "✗ Erro ao conectar ao Jaeger: $($_.Exception.Message)" -ForegroundColor Red
}

# 8. Verificar Prometheus
Write-Host "8️⃣  Verificando Prometheus..." -ForegroundColor Cyan
try {
    $promResponse = Invoke-WebRequest -Uri "http://localhost:9090/api/v1/targets" -ErrorAction Stop
    Write-Host "✓ Prometheus acessível" -ForegroundColor Green
    Write-Host "  URL: http://localhost:9090" -ForegroundColor Cyan
    Write-Host ""
} catch {
    Write-Host "✗ Prometheus não disponível: $($_.Exception.Message)" -ForegroundColor Red
}

# 9. Verificar Grafana
Write-Host "9️⃣  Verificando Grafana..." -ForegroundColor Cyan
try {
    $grafanaResponse = Invoke-WebRequest -Uri "http://localhost:3000/api/health" -ErrorAction Stop
    Write-Host "✓ Grafana acessível" -ForegroundColor Green
    Write-Host "  URL: http://localhost:3000" -ForegroundColor Cyan
    Write-Host "  Credenciais: admin / admin" -ForegroundColor Yellow
    Write-Host ""
} catch {
    Write-Host "✗ Grafana não disponível: $($_.Exception.Message)" -ForegroundColor Red
}

# Resumo
Write-Host "======================================" -ForegroundColor Cyan
Write-Host "📊 Resumo - Acessar Dashboards" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "🔗 Jaeger (Tracing):    $JaegerUrl" -ForegroundColor Green
Write-Host "🔗 Prometheus (Métricas): http://localhost:9090" -ForegroundColor Green
Write-Host "🔗 Grafana (Dashboard):   http://localhost:3000" -ForegroundColor Green
Write-Host "🔗 App Health:            $AppUrl/q/health" -ForegroundColor Green
Write-Host "🔗 App Metrics:           $AppUrl/q/metrics" -ForegroundColor Green
Write-Host ""
Write-Host "✅ Teste concluído!" -ForegroundColor Green
Write-Host ""

