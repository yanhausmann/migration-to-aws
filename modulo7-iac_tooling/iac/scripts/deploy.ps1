# Script de deploy para AWS S3 + CloudFront (PowerShell)

# Configurar para parar em erros
$ErrorActionPreference = "Stop"

Write-Host "=== Verificando dependências necessárias ===" -ForegroundColor Cyan

# Verificar Node.js
if (-not (Get-Command node -ErrorAction SilentlyContinue)) {
    Write-Host "❌ ERRO: Node.js não está instalado!" -ForegroundColor Red
    Write-Host "Por favor, instale o Node.js antes de continuar:" -ForegroundColor Yellow
    Write-Host "  - https://nodejs.org/" -ForegroundColor Yellow
    Write-Host "  - ou use nvm: https://github.com/coreybutler/nvm-windows" -ForegroundColor Yellow
    exit 1
}

# Verificar npm
if (-not (Get-Command npm -ErrorAction SilentlyContinue)) {
    Write-Host "❌ ERRO: npm não está instalado!" -ForegroundColor Red
    Write-Host "Por favor, instale o npm antes de continuar." -ForegroundColor Yellow
    Write-Host "Normalmente o npm vem junto com o Node.js." -ForegroundColor Yellow
    exit 1
}

# Verificar Terraform
if (-not (Get-Command terraform -ErrorAction SilentlyContinue)) {
    Write-Host "❌ ERRO: Terraform não está instalado!" -ForegroundColor Red
    Write-Host "Por favor, instale o Terraform antes de continuar:" -ForegroundColor Yellow
    Write-Host "  - https://www.terraform.io/downloads" -ForegroundColor Yellow
    exit 1
}

# Verificar AWS CLI
if (-not (Get-Command aws -ErrorAction SilentlyContinue)) {
    Write-Host "❌ ERRO: AWS CLI não está instalado!" -ForegroundColor Red
    Write-Host "Por favor, instale o AWS CLI antes de continuar:" -ForegroundColor Yellow
    Write-Host "  - https://aws.amazon.com/cli/" -ForegroundColor Yellow
    exit 1
}

Write-Host "✅ Todas as dependências estão instaladas!" -ForegroundColor Green
Write-Host "   Node.js: $(node --version)" -ForegroundColor Gray
Write-Host "   npm: $(npm --version)" -ForegroundColor Gray
Write-Host "   Terraform: $((terraform version -json | ConvertFrom-Json).terraform_version)" -ForegroundColor Gray
Write-Host "   AWS CLI: $((aws --version).Split()[0])" -ForegroundColor Gray

Write-Host "`n=== Build da aplicação ===" -ForegroundColor Green

# Instalar dependências com tratamento de erro
try {
    npm install
    if ($LASTEXITCODE -ne 0) { throw "npm install falhou" }
}
catch {
    Write-Host "❌ ERRO: Falha ao instalar dependências npm!" -ForegroundColor Red
    Write-Host "Verifique se:" -ForegroundColor Yellow
    Write-Host "  - O arquivo package.json existe" -ForegroundColor Yellow
    Write-Host "  - Você tem permissões adequadas" -ForegroundColor Yellow
    Write-Host "  - Sua conexão com a internet está funcionando" -ForegroundColor Yellow
    exit 1
}

# Build da aplicação com tratamento de erro
try {
    npm run build
    if ($LASTEXITCODE -ne 0) { throw "npm run build falhou" }
}
catch {
    Write-Host "❌ ERRO: Falha ao fazer build da aplicação!" -ForegroundColor Red
    Write-Host "Verifique os logs acima para mais detalhes." -ForegroundColor Yellow
    exit 1
}

Write-Host "✅ Build concluído com sucesso!" -ForegroundColor Green

Write-Host "`n=== Inicializando Terraform ===" -ForegroundColor Green
terraform init

Write-Host "`n=== Aplicando infraestrutura ===" -ForegroundColor Green
terraform apply -auto-approve

Write-Host "`n=== Fazendo upload dos arquivos para S3 ===" -ForegroundColor Green

# Verificar se a pasta dist existe
if (-not (Test-Path "dist")) {
    Write-Host "❌ ERRO: Pasta 'dist' não encontrada!" -ForegroundColor Red
    Write-Host "O build pode ter falhado. Verifique os logs acima." -ForegroundColor Yellow
    exit 1
}

$BUCKET_NAME = terraform output -raw s3_bucket_name

if ([string]::IsNullOrEmpty($BUCKET_NAME)) {
    Write-Host "❌ ERRO: Não foi possível obter o nome do bucket!" -ForegroundColor Red
    Write-Host "Verifique se o Terraform foi aplicado corretamente." -ForegroundColor Yellow
    exit 1
}

try {
    aws s3 sync dist/ "s3://$BUCKET_NAME/" --delete
    if ($LASTEXITCODE -ne 0) { throw "Upload para S3 falhou" }
}
catch {
    Write-Host "❌ ERRO: Falha ao fazer upload para S3!" -ForegroundColor Red
    Write-Host "Verifique suas credenciais AWS e permissões." -ForegroundColor Yellow
    exit 1
}

Write-Host "✅ Upload concluído com sucesso!" -ForegroundColor Green

Write-Host "`n=== Invalidando cache do CloudFront ===" -ForegroundColor Green
$DISTRIBUTION_ID = aws cloudfront list-distributions --query "DistributionList.Items[?Origins.Items[?Id=='S3-$BUCKET_NAME']].Id | [0]" --output text

if ($DISTRIBUTION_ID) {
    aws cloudfront create-invalidation --distribution-id $DISTRIBUTION_ID --paths "/*"
}

Write-Host "`n=== Deploy concluído! ===" -ForegroundColor Green
Write-Host "URL do CloudFront:" -ForegroundColor Yellow
terraform output cloudfront_url
