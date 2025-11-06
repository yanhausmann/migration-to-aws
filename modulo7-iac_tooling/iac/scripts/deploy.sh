#!/bin/bash

# Script de deploy para AWS S3 + CloudFront

set -e

echo "=== Verificando dependências necessárias ==="

# Verificar Node.js
if ! command -v node &> /dev/null; then
    echo "ERRO: Node.js não está instalado!"
    echo "Por favor, instale o Node.js antes de continuar."
    exit 1
fi

# Verificar npm
if ! command -v npm &> /dev/null; then
    echo "ERRO: npm não está instalado!"
    echo "Por favor, instale o npm antes de continuar."
    exit 1
fi

# Verificar Terraform
if ! command -v terraform &> /dev/null; then
    echo "ERRO: Terraform não está instalado!"
    echo "Por favor, instale o Terraform antes de continuar."
    exit 1
fi

# Verificar AWS CLI
if ! command -v aws &> /dev/null; then
    echo "ERRO: AWS CLI não está instalado!"
    echo "Por favor, instale o AWS CLI antes de continuar."
    exit 1
fi

echo "Todas as dependências estão instaladas!"
echo "   Node.js: $(node --version)"
echo "   npm: $(npm --version)"
echo "   Terraform: $(terraform version -json | grep -o '"terraform_version":"[^"]*"' | cut -d'"' -f4)"
echo "   AWS CLI: $(aws --version | cut -d' ' -f1)"

echo ""
echo "=== Build da aplicação ==="

# Instalar dependências com tratamento de erro
if ! npm install; then
    echo "ERRO: Falha ao instalar dependências npm!"
    echo "Verifique se:"
    echo "  - O arquivo package.json existe"
    echo "  - Você tem permissões adequadas"
    echo "  - Sua conexão com a internet está funcionando"
    exit 1
fi

# Build da aplicação com tratamento de erro
if ! npm run build; then
    echo "ERRO: Falha ao fazer build da aplicação!"
    echo "Verifique os logs acima para mais detalhes."
    exit 1
fi

echo "Build concluído com sucesso!"

echo ""
echo "=== Inicializando Terraform ==="
terraform init

echo ""
echo "=== Aplicando infraestrutura ==="
terraform apply -auto-approve

echo ""
echo "=== Fazendo upload dos arquivos para S3 ==="

# Verificar se a pasta dist existe
if [ ! -d "dist" ]; then
    echo "ERRO: Pasta 'dist' não encontrada!"
    echo "O build pode ter falhado. Verifique os logs acima."
    exit 1
fi

BUCKET_NAME=$(terraform output -raw s3_bucket_name)

if [ -z "$BUCKET_NAME" ]; then
    echo "ERRO: Não foi possível obter o nome do bucket!"
    echo "Verifique se o Terraform foi aplicado corretamente."
    exit 1
fi

if ! aws s3 sync dist/ s3://${BUCKET_NAME}/ --delete; then
    echo "ERRO: Falha ao fazer upload para S3!"
    echo "Verifique suas credenciais AWS e permissões."
    exit 1
fi

echo "Upload concluído com sucesso!"

echo ""
echo "=== Invalidando cache do CloudFront ==="
DISTRIBUTION_ID=$(aws cloudfront list-distributions --query "DistributionList.Items[?Origins.Items[?Id=='S3-${BUCKET_NAME}']].Id | [0]" --output text)
if [ ! -z "$DISTRIBUTION_ID" ]; then
    aws cloudfront create-invalidation --distribution-id ${DISTRIBUTION_ID} --paths "/*"
fi

echo ""
echo "=== Deploy concluído! ==="
echo "URL do CloudFront:"
terraform output cloudfront_url
