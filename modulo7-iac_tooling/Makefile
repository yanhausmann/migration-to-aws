.PHONY: help deploy build upload init plan apply destroy clean get-url invalidate-cache

default: help

help:
	@echo "=== Makefile AWS S3 + CloudFront ==="
	@echo ""
	@echo "Comandos disponíveis:"
	@echo "  make deploy          - Deploy completo (build + infra + upload)"
	@echo "  make build           - Build da aplicação Vue.js"
	@echo "  make init            - Inicializar Terraform"
	@echo "  make plan            - Ver plano de execução do Terraform"
	@echo "  make apply           - Aplicar infraestrutura AWS"
	@echo "  make upload          - Upload dos arquivos para S3"
	@echo "  make get-url         - Ver URL do CloudFront"
	@echo "  make invalidate      - Invalidar cache do CloudFront"
	@echo "  make destroy         - Destruir toda infraestrutura"
	@echo "  make clean           - Limpar arquivos temporários"
	@echo ""

# Deploy completo
deploy: build init apply upload get-url
	@echo ""
	@echo "Deploy concluído com sucesso!"
	@echo ""

# Build da aplicação
build:
	@echo "Fazendo build da aplicação..."
	npm install
	npm run build
	@echo "Build concluído!"

# Inicializar Terraform
init:
	@echo "Inicializando Terraform..."
	cd iac/terraform && terraform init

# Ver plano
plan: init
	@echo "Mostrando plano de execução..."
	cd iac/terraform && terraform plan

# Aplicar infraestrutura
apply: init
	@echo "Criando infraestrutura AWS..."
	cd iac/terraform && terraform apply -auto-approve
	@echo "Infraestrutura criada!"

# Upload para S3
upload:
	@echo "Fazendo upload para S3..."
	@bash -c 'BUCKET=$$(cd iac/terraform && terraform output -raw s3_bucket_name 2>/dev/null); \
		if [ -z "$$BUCKET" ]; then \
			echo "Erro: Bucket não encontrado. Execute make apply primeiro."; \
			exit 1; \
		fi; \
		aws s3 sync dist/ s3://$$BUCKET/ --delete'
	@echo "Upload concluído!"

# Ver URL do CloudFront
get-url:
	@echo ""
	@echo "URL da aplicação:"
	@cd iac/terraform && terraform output cloudfront_url
	@echo ""
	@echo "Bucket S3:"
	@cd iac/terraform && terraform output s3_bucket_name
	@echo ""

# Invalidar cache do CloudFront
invalidate:
	@echo "Invalidando cache do CloudFront..."
	@bash -c 'BUCKET=$$(cd iac/terraform && terraform output -raw s3_bucket_name 2>/dev/null); \
		DIST_ID=$$(aws cloudfront list-distributions --query "DistributionList.Items[?Origins.Items[?Id=='\''S3-$$BUCKET'\'']].Id | [0]" --output text 2>/dev/null); \
		if [ ! -z "$$DIST_ID" ] && [ "$$DIST_ID" != "None" ]; then \
			aws cloudfront create-invalidation --distribution-id $$DIST_ID --paths "/*"; \
			echo "Cache invalidado!"; \
		else \
			echo "Distribution não encontrada ou ainda não criada"; \
		fi'

# Atualizar aplicação (rebuild + upload + invalidate)
update: build upload invalidate
	@echo "Aplicação atualizada!"

# Destruir infraestrutura
destroy:
	@echo "Destruindo infraestrutura AWS..."
	@read -p "Tem certeza? [y/N] " -n 1 -r; \
	echo; \
	if [[ $$REPLY =~ ^[Yy]$$ ]]; then \
		cd iac/terraform && terraform destroy -auto-approve; \
		echo "Infraestrutura removida!"; \
	else \
		echo "Operação cancelada."; \
	fi

# Limpar arquivos temporários
clean:
	@echo "Limpando arquivos temporários..."
	rm -rf node_modules dist iac/terraform/.terraform iac/terraform/terraform.tfstate* iac/terraform/.terraform.lock.hcl
	@echo "Limpeza concluída!"
