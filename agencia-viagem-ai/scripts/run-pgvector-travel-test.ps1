param(
    [string]$Question = "Quais sao as formas de cancelamento dos pacote."
)

$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
Push-Location $repoRoot

try {
    Write-Host ">> Subindo Postgres + pgvector..."
    docker compose up -d

    Write-Host ">> Aguardando banco ficar saudavel..."
    $dbReady = $false
    for ($i = 0; $i -lt 40; $i++) {
        docker compose exec -T postgres pg_isready -U postgres -d agencia_viagem_ai *> $null
        if ($LASTEXITCODE -eq 0) {
            $dbReady = $true
            break
        }
        Start-Sleep -Seconds 2
    }

    if (-not $dbReady) {
        throw "Postgres nao ficou pronto no tempo esperado."
    }

    $stdoutLog = "quarkus-pgvector-dev.log"
    $stderrLog = "quarkus-pgvector-dev.err.log"

    Remove-Item $stdoutLog,$stderrLog -ErrorAction SilentlyContinue

    Write-Host ">> Subindo Quarkus em profile pgvector..."
    $quarkus = Start-Process -FilePath ".\mvnw.cmd" `
        -ArgumentList "-Ppgvector","quarkus:dev","-Dquarkus.profile=pgvector" `
        -PassThru `
        -RedirectStandardOutput $stdoutLog `
        -RedirectStandardError $stderrLog

    try {
        Write-Host ">> Aguardando endpoint http://localhost:8080/hello ..."
        $apiReady = $false
        for ($i = 0; $i -lt 45; $i++) {
            try {
                $resp = Invoke-WebRequest -UseBasicParsing -TimeoutSec 3 http://localhost:8080/hello
                if ($resp.StatusCode -eq 200) {
                    $apiReady = $true
                    break
                }
            }
            catch {
                Start-Sleep -Seconds 2
            }
        }

        if (-not $apiReady) {
            throw "Quarkus nao subiu a tempo. Verifique $stdoutLog e $stderrLog."
        }

        Write-Host ">> Chamando /travel ..."
        $answer = curl.exe -sS -X POST "http://localhost:8080/travel" -H "Content-Type: text/plain; charset=utf-8" --data-raw $Question
        Write-Host "\nResposta da API:"
        Write-Output $answer
    }
    finally {
        if ($quarkus -and -not $quarkus.HasExited) {
            Stop-Process -Id $quarkus.Id -Force
        }
    }
}
finally {
    Pop-Location
}

