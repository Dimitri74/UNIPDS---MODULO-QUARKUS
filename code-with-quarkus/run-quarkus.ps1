#!/usr/bin/env powershell
# Script para validar e subir o Quarkus

Write-Host "======================================" -ForegroundColor Green
Write-Host "Validando e iniciando Quarkus" -ForegroundColor Green
Write-Host "======================================" -ForegroundColor Green

$projectPath = "C:\Users\dell\workspace_itellJ\Desenvolvimento de Aplicações Back-End-Quarkus\MÓDULO 01 - QUARKUS\code-with-quarkus"

Set-Location $projectPath

Write-Host "`nEtapa 1: Limpando build anterior..." -ForegroundColor Yellow
& .\mvnw.cmd clean -q

Write-Host "Etapa 2: Compilando projeto..." -ForegroundColor Yellow
& .\mvnw.cmd compile -q

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Compilação bem-sucedida!" -ForegroundColor Green
    Write-Host "`nEtapa 3: Iniciando Quarkus em modo dev..." -ForegroundColor Yellow
    & .\mvnw.cmd quarkus:dev
} else {
    Write-Host "❌ Compilação falhou!" -ForegroundColor Red
    exit 1
}

