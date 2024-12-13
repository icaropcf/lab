#!/bin/bash

# Perguntar o nome do cluster ao usuário
echo "Digite o nome do cluster (padrão: my-kind-cluster):"
read USER_CLUSTER_NAME
CLUSTER_NAME=${USER_CLUSTER_NAME:-my-kind-cluster}

CONFIG_FILE="kind-config.yaml"

# Verificação de pré-requisitos (instalar Homebrew caso não exista)
command -v brew >/dev/null 2>&1 || {
  echo >&2 "Homebrew não está instalado. Instalando Homebrew...";
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" || { echo "Erro ao instalar o Homebrew."; exit 1; };
  echo "Homebrew instalado com sucesso!"
}

# Atualizar e instalar Kind
echo "Instalando Kind..."
brew install kind || { echo "Erro ao instalar Kind."; exit 1; }
echo "Kind instalado com sucesso!"

# Atualizar e instalar kubectl
echo "Instalando kubectl..."
brew install kubectl || { echo "Erro ao instalar kubectl."; exit 1; }
echo "kubectl instalado com sucesso!"

# Criar arquivo de configuração do cluster
cat <<EOF > $CONFIG_FILE
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
  - role: control-plane
  - role: worker
  - role: worker
EOF

echo "Arquivo de configuração do Kind criado: $CONFIG_FILE"

# Remover cluster antigo (se existir)
echo "Removendo clusters antigos..."
kind delete cluster --name $CLUSTER_NAME

# Criar cluster com configuração avançada
echo "Criando cluster Kind com configuração avançada..."
kind create cluster --name $CLUSTER_NAME --config $CONFIG_FILE || { echo "Erro ao criar cluster."; exit 1; }
echo "Cluster criado com sucesso!"

# Verificar se o cluster está funcionando
echo "Verificando o cluster..."
kubectl cluster-info --context kind-$CLUSTER_NAME
kubectl get nodes

# Limpeza opcional (remover arquivo de configuração do cluster)
# Uncomment para limpar o arquivo de configuração
# rm -f $CONFIG_FILE

echo "Setup completo!"
