#!/bin/bash

# Script de configuração do ambiente para o projeto

set -e

echo "===== Configurando ambiente para o projeto Jewelry App ====="
echo ""

# Cores para output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Função para verificar se comando existe
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Função para garantir que arquivos de configuração do shell existam
ensure_shell_config() {
    # Verificar e criar .bashrc se não existir
    if [ ! -f "$HOME/.bashrc" ]; then
        echo "Criando arquivo $HOME/.bashrc..."
        touch "$HOME/.bashrc"
    fi
    
    # Verificar e criar .zshrc se não existir
    if [ ! -f "$HOME/.zshrc" ]; then
        echo "Criando arquivo $HOME/.zshrc..."
        touch "$HOME/.zshrc"
    fi
    
    # Verificar e criar .profile se não existir
    if [ ! -f "$HOME/.profile" ]; then
        echo "Criando arquivo $HOME/.profile..."
        touch "$HOME/.profile"
    fi
}

# Garantir que os arquivos de configuração existam
ensure_shell_config

# Verificar Node.js
echo "[Node.js] Verificando instalacao..."
if command_exists node; then
    NODE_VERSION=$(node --version)
    echo -e "${GREEN}[OK] Node.js ja instalado: $NODE_VERSION${NC}"
else
    echo -e "${YELLOW}[AVISO] Node.js nao encontrado${NC}"
    echo "Deseja instalar Node.js via nvm? (recomendado) [y/N]"
    read -r response
    if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
        echo "Instalando nvm..."
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
        
        # Adicionar nvm ao shell config
        NVM_SCRIPT="export NVM_DIR=\"\$HOME/.nvm\"
[ -s \"\$NVM_DIR/nvm.sh\" ] && \\. \"\$NVM_DIR/nvm.sh\"
[ -s \"\$NVM_DIR/bash_completion\" ] && \\. \"\$NVM_DIR/bash_completion\""
        
        # Adicionar ao .bashrc se não existir
        if ! grep -q "NVM_DIR" "$HOME/.bashrc" 2>/dev/null; then
            echo "$NVM_SCRIPT" >> "$HOME/.bashrc"
        fi
        
        # Adicionar ao .zshrc se não existir
        if ! grep -q "NVM_DIR" "$HOME/.zshrc" 2>/dev/null; then
            echo "$NVM_SCRIPT" >> "$HOME/.zshrc"
        fi
        
        # Carregar nvm na sessão atual
        export NVM_DIR="$HOME/.nvm"
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
        
        echo "Instalando Node.js LTS..."
        nvm install --lts
        nvm use --lts
        
        echo -e "${GREEN}[OK] Node.js instalado com sucesso!${NC}"
    else
        echo -e "${RED}[ERRO] Node.js eh necessario. Instale manualmente.${NC}"
        exit 1
    fi
fi

# Verificar npm
echo ""
echo "[npm] Verificando instalacao..."
if command_exists npm; then
    NPM_VERSION=$(npm --version)
    echo -e "${GREEN}[OK] npm ja instalado: $NPM_VERSION${NC}"
else
    echo -e "${RED}[ERRO] npm nao encontrado (deveria vir com Node.js)${NC}"
    exit 1
fi

# Verificar Terraform
echo ""
echo "[Terraform] Verificando instalacao..."
if command_exists terraform; then
    TF_VERSION=$(terraform --version | head -n1)
    echo -e "${GREEN}[OK] Terraform ja instalado: $TF_VERSION${NC}"
else
    echo -e "${YELLOW}[AVISO] Terraform nao encontrado${NC}"
    echo "Deseja instalar Terraform? [y/N]"
    read -r response
    if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
        echo "Instalando Terraform..."
        
        # Detectar OS
        if [[ "$OSTYPE" == "linux-gnu"* ]]; then
            # Linux
            echo "Adicionando repositorio HashiCorp..."
            wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
            echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
            sudo apt update && sudo apt install -y terraform
        else
            echo -e "${RED}[ERRO] Instalacao automatica nao suportada para este SO${NC}"
            echo "Instale manualmente: https://www.terraform.io/downloads"
            exit 1
        fi
        
        echo -e "${GREEN}[OK] Terraform instalado com sucesso!${NC}"
    else
        echo -e "${RED}[ERRO] Terraform eh necessario. Instale manualmente.${NC}"
        exit 1
    fi
fi

# Verificar AWS CLI
echo ""
echo "[AWS CLI] Verificando instalacao..."
if command_exists aws; then
    AWS_VERSION=$(aws --version 2>&1 | cut -d' ' -f1)
    echo -e "${GREEN}[OK] AWS CLI ja instalado: $AWS_VERSION${NC}"
    
    # Verificar credenciais
    echo ""
    echo "[AWS] Verificando credenciais..."
    if aws sts get-caller-identity >/dev/null 2>&1; then
        echo -e "${GREEN}[OK] Credenciais AWS configuradas!${NC}"
        AWS_ACCOUNT=$(aws sts get-caller-identity --query Account --output text)
        echo "   Conta AWS: $AWS_ACCOUNT"
    else
        echo -e "${YELLOW}[AVISO] Credenciais AWS nao configuradas${NC}"
        echo "Execute: aws configure"
    fi
else
    echo -e "${YELLOW}[AVISO] AWS CLI nao encontrado${NC}"
    echo "Deseja instalar AWS CLI? [y/N]"
    read -r response
    if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
        echo "Instalando AWS CLI..."
        curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
        unzip -q awscliv2.zip
        sudo ./aws/install
        rm -rf aws awscliv2.zip
        
        echo -e "${GREEN}[OK] AWS CLI instalado com sucesso!${NC}"
        echo "Configure suas credenciais com: aws configure"
    else
        echo -e "${RED}[ERRO] AWS CLI eh necessario. Instale manualmente.${NC}"
        exit 1
    fi
fi

# Verificar make
echo ""
echo "[Make] Verificando instalacao..."
if command_exists make; then
    echo -e "${GREEN}[OK] make ja instalado${NC}"
else
    echo -e "${YELLOW}[AVISO] make nao encontrado${NC}"
    echo "Instalando make..."
    sudo apt-get update && sudo apt-get install -y make
    echo -e "${GREEN}[OK] make instalado com sucesso!${NC}"
fi

echo ""
echo "=========================================="
echo -e "${GREEN}[OK] Ambiente configurado com sucesso!${NC}"
echo "=========================================="
echo ""
echo "Proximos passos:"
echo ""
echo "1. Se ainda nao configurou AWS CLI, execute:"
echo "   ${YELLOW}aws configure${NC}"
echo ""
echo "2. Para fazer o deploy:"
echo "   ${YELLOW}make deploy${NC}"
echo ""
echo "3. Para ver todos os comandos disponiveis:"
echo "   ${YELLOW}make help${NC}"
echo ""
echo "IMPORTANTE: Se instalou nvm, recarregue seu shell:"
echo "   ${YELLOW}source ~/.bashrc${NC}  (bash)"
echo "   ${YELLOW}source ~/.zshrc${NC}   (zsh)"
echo ""
