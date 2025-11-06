# 💎 Jewelry App - AWS Migration

> Aplicação Vue.js hospedada na AWS usando S3 + CloudFront com Terraform

[![AWS](https://img.shields.io/badge/AWS-S3%20%2B%20CloudFront-orange)](https://aws.amazon.com/)
[![Terraform](https://img.shields.io/badge/Terraform-1.0%2B-purple)](https://www.terraform.io/)
[![Vue.js](https://img.shields.io/badge/Vue.js-3-green)](https://vuejs.org/)

---

## 🚀 Início Rápido

### Pré-requisitos

- Node.js 18+
- Terraform 1.0+
- AWS CLI configurado
- Make instalado

### Deploy

```bash
# 1. Configurar AWS
aws configure

# 2. Executar setup (primeira vez)
./iac/scripts/setup.sh

# 3. Fazer deploy
make deploy
```

---

## 📂 Estrutura do Projeto

```
modulo7-iac_tooling/
├── src/                    # Código Vue.js
│   ├── App.vue
│   └── main.js
│
├── iac/                    # Infraestrutura
│   ├── terraform/         # Configuração Terraform
│   │   ├── main.tf       # Recursos AWS (S3 + CloudFront)
│   │   └── terraform.tfvars.example
│   │
│   └── scripts/           # Scripts de automação
│       ├── setup.sh      # Setup do ambiente
│       ├── deploy.sh     # Deploy (Bash)
│       └── deploy.ps1    # Deploy (PowerShell)
│
├── Makefile               # Comandos automatizados
├── package.json           # Dependências Node.js
├── vite.config.js         # Config Vite
└── index.html             # HTML principal
```

---

## 🛠️ Comandos Principais

### Make (Recomendado)

```bash
make deploy      # Deploy completo
make update      # Atualizar aplicação
make get-url     # Ver URL do CloudFront
make destroy     # Remover infraestrutura
make clean       # Limpar arquivos temporários
```

### Scripts Manuais

```bash
# Setup do ambiente (primeira vez)
./iac/scripts/setup.sh

# Deploy
./iac/scripts/deploy.sh      # Linux/Mac
./iac/scripts/deploy.ps1     # Windows
```

---

## 🏗️ Infraestrutura AWS

### Recursos Provisionados

| Recurso | Descrição | Custo |
|---------|-----------|-------|
| **S3 Bucket** | Hospedagem estática | ~$0.02/mês |
| **CloudFront** | CDN global + HTTPS | Free tier 1TB/mês |

### Arquitetura

```
┌─────────┐
│ Usuário │
└────┬────┘
     │ HTTPS
     ▼
┌────────────┐
│ CloudFront │ ◄── CDN + SSL
└─────┬──────┘
      │ HTTP
      ▼
┌────────────┐
│ S3 Bucket  │ ◄── Static Hosting
└────────────┘
```

---

## 💻 Desenvolvimento Local

```bash
# Instalar dependências
npm install

# Modo desenvolvimento
npm run dev

# Build
npm run build
```

---

## 📝 Workflow

### Primeiro Deploy

```bash
# 1. Configurar AWS
aws configure

# 2. Deploy
make deploy

# 3. Aguardar ~20 min (CloudFront)

# 4. Acessar URL
make get-url
```

### Atualizar Código

```bash
# 1. Editar src/App.vue
# 2. Atualizar
make update
```

---

## 🔧 Configuração

### Variáveis Terraform

Copie e edite o arquivo de exemplo:

```bash
cp iac/terraform/terraform.tfvars.example iac/terraform/terraform.tfvars
```

Edite conforme necessário:

```terraform
aws_region   = "us-east-1"
project_name = "jewelry-app"
```

---

## 🗑️ Limpeza

```bash
# Remover infraestrutura AWS
make destroy

# Limpar arquivos locais
make clean
```

---

## 📚 Tecnologias

- **Vue.js 3** - Framework JavaScript
- **Vite 4** - Build tool
- **Terraform** - Infrastructure as Code
- **AWS S3** - Object storage
- **AWS CloudFront** - CDN

---

## 🎓 Projeto Devs2Blu

**Módulo 7**: DevOps  
**Desafio**: Migração para AWS usando IaC  
**Autor**: Yan Hausmann

---

## 📞 Suporte

- [AWS Documentation](https://docs.aws.amazon.com/)
- [Terraform Documentation](https://www.terraform.io/docs)
- [Vue.js Documentation](https://vuejs.org/)

---

**Desenvolvido para o curso Devs2Blu** 🚀
