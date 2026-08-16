$ErrorActionPreference = "Stop"

$ProjectDir = Split-Path -Parent $PSScriptRoot
$Model = if ($env:OLLAMA_EMBEDDING_MODEL) { $env:OLLAMA_EMBEDDING_MODEL } else { "nomic-embed-text" }
$OllamaHost = if ($env:OLLAMA_HOST) { $env:OLLAMA_HOST } else { "http://localhost:11434" }
$env:OLLAMA_HOST = $OllamaHost

Write-Host "Starting Qdrant and Ollama..."
docker compose -f (Join-Path $ProjectDir "docker-compose.yml") up -d qdrant ollama

Write-Host "Waiting for Ollama at $OllamaHost..."
$ready = $false
for ($i = 0; $i -lt 30; $i++) {
    try {
        Invoke-RestMethod -Uri "$OllamaHost/api/tags" -Method Get | Out-Null
        $ready = $true
        break
    } catch {
        Start-Sleep -Seconds 2
    }
}

if (-not $ready) {
    throw "Ollama did not become ready at $OllamaHost"
}

Write-Host "Pulling Ollama embedding model: $Model"
docker compose -f (Join-Path $ProjectDir "docker-compose.yml") exec -T ollama ollama pull $Model
Write-Host "Ollama embedding configuration initialized."
