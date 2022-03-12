# Powershell script - no shebang needed ;)

# Instructions
# The azure command line tool, az cli does not have great blocking for processes
# In order to make sure things happen in the correct order, we recommend executing 
# each command separately in your IDE. In VS Code, you can highlight code and use 
# F8 to execute the highlighted code 

# Set your resource name variables here. The following are for example purposes
$resourceGroup = "orleansbasics"
$location = "eastus"
$storageAccount = "orleansbasics1"
$clusterName = "orleansbasics"
$containerRegistry = "orleansbasicsacr1"

# Opens a browser tab to log in to Azure
az login

# Create a resource group
az group create --name $resourceGroup --location $location

# Create an Azure storage account
az storage account create --location $location --name $storageAccount --resource-group $resourceGroup --kind "StorageV2" --sku "Standard_LRS"

# If you haven't already, install the Kubernetes CLI
az aks install-cli

# Create an Azure Container Registry account and login to it
az acr create --name $containerRegistry --resource-group $resourceGroup --sku basic
$acrId = $(az acr show --name $containerRegistry --query id --output tsv)

# Create an AKS cluster. This can take a few minutes
az aks create --resource-group $resourceGroup --name $clusterName --node-count 1 --generate-ssh-keys --attach-acr $acrId

# Authenticate the Kubernetes CLI
az aks get-credentials --resource-group $resourceGroup --name $clusterName

# Configure the storage account that the application is going to use by adding a new secret to Kubernetes
kubectl create secret generic az-storage-acct --from-literal=key=$(az storage account show-connection-string --name $storageAccount --resource-group $resourceGroup --output tsv)
