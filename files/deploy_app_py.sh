#!/bin/bash
# Este script é projetado para ser usado como EC2 User Data para configurar um servidor web
# e implantar uma aplicação web de um repositório GitHub usando um servidor HTTP Python simples.

# --- Variáveis de Configuração ---
# IMPORTANTE: Substitua esta com a URL real do seu repositório GitHub.
# Certifique-se de que o repositório seja publicamente acessível ou configure chaves SSH/tokens de acesso
# se for privado (o que está além do escopo deste script básico).
GITHUB_REPO_URL="https://github.com/mxcastro/order-webapp.git" # <--- SUBSTITUA ISSO
APP_DIR="/var/www/acme-corp-webapp" # Diretório onde a aplicação será clonada
PORT=8001 # Porta em que o servidor Python irá escutar

# --- 1. Atualizar Pacotes do Sistema ---
echo "Atualizando pacotes do sistema..."
sudo apt-get update -y
echo "Pacotes do sistema atualizados."

# --- 2. Instalar Git e Python3 ---
echo "Instalando Git e Python3..."
sudo apt-get install -y git python3
echo "Git e Python3 instalados."

# --- 3. Clonar o Repositório GitHub ---
echo "Clonando o repositório GitHub: /${GITHUB_REPO_URL}..."
# Criar o diretório se ele não existir
sudo mkdir -p /${APP_DIR}
# Clonar o repositório para o diretório da aplicação designado
# Usando --depth 1 para um clone superficial para economizar tempo e espaço
sudo git clone --depth 1 /${GITHUB_REPO_URL} /${APP_DIR}
# Verificar se o clone foi bem-sucedido
if [ $? -eq 0 ]; then
    echo "Repositório clonado com sucesso para /${APP_DIR}."
else
    echo "Erro: Falha ao clonar o repositório. Por favor, verifique GITHUB_REPO_URL e permissões."
    exit 1
fi

# --- 4. Iniciar o Servidor HTTP Python ---
echo "Iniciando o servidor HTTP Python na porta /${PORT}..."
# Navega para o diretório da aplicação e inicia o servidor Python em segundo plano
# usando nohup para que continue rodando mesmo após o user_data terminar
# e redirecionando a saída para um log.
cd /${APP_DIR}
nohup python3 -m http.server /${PORT} > /var/log/python_http_server.log 2>&1 &
echo "Servidor HTTP Python iniciado em segundo plano na porta /${PORT}."

echo "Implantação da aplicação web concluída!"
echo "Você agora deve ser capaz de acessar seu site ACME Corp Widgets através do endereço IP público da instância EC2 na porta /${PORT}."
