# 🏗️ Infraestrutura como Código (IaC)

## 📂 Estrutura

```
iac/
├── terraform/              # Configuração Terraform
│   ├── main.tf            # Recursos AWS
│   └── terraform.tfvars.example
│
└── scripts/               # Scripts de automação
    ├── setup.sh          # Setup do ambiente
    ├── deploy.sh         # Deploy (Bash)
    └── deploy.ps1        # Deploy (PowerShell)
```

---

## 🚀 Como Usar

### Setup Inicial

```bash
# Configurar AWS CLI
aws configure

# Executar setup
./scripts/setup.sh
```

### Deploy

```bash
# Opção 1: Script automático
./scripts/deploy.sh

# Opção 2: Manual
cd terraform
terraform init
terraform apply
```

---

## 📦 Recursos Terraform

O arquivo `terraform/main.tf` provisiona:

- **S3 Bucket** - Website hosting estático
- **CloudFront Distribution** - CDN global com HTTPS
- **Random String** - Sufixo único para bucket
- **Políticas** - Acesso público configurado

---

## ⚙️ Configuração

### Variáveis

Copie o exemplo:

```bash
cp terraform/terraform.tfvars.example terraform/terraform.tfvars
```

Edite conforme necessário:

```terraform
aws_region   = "us-east-1"
project_name = "jewelry-app"
```

---

## 🔧 Comandos Terraform

```bash
cd terraform

# Inicializar
terraform init

# Ver plano
terraform plan

# Aplicar
terraform apply

# Ver outputs
terraform output

# Destruir
terraform destroy
```

---

## 📝 Scripts Disponíveis

### `setup.sh`

Configura o ambiente:
- Verifica Node.js/npm
- Verifica Terraform
- Verifica AWS CLI
- Instala dependências faltantes

### `deploy.sh` / `deploy.ps1`

Deploy completo:
1. Build da aplicação
2. Terraform init
3. Terraform apply
4. Upload para S3
5. Invalidação do cache

---

## 🌐 Outputs

Após o deploy, você terá:

```bash
# Ver URL do CloudFront
terraform output cloudfront_url

# Ver nome do bucket
terraform output s3_bucket_name
```

---

## 🗑️ Limpeza

```bash
cd terraform
terraform destroy
```

---

**Voltar para**: [README principal](../README.md)
