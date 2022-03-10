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
$containerRegistry = "orleansbasicsacr"

# Opens a browser tab to log in to Azure
az login

# Create a resource group
az group create --name $resourceGroup --location $location

# Create an Azure storage account
az storage account create --location $location --name $storageAccount --resource-group $resourceGroup --kind "StorageV2" --sku "Standard_LRS"

# Create an AKS cluster. This can take a few minutes
az aks create --resource-group $resourceGroup --name $clusterName --node-count 3

# If you haven't already, install the Kubernetes CLI
az aks install-cli

# Authenticate the Kubernetes CLI
az aks get-credentials --resource-group $resourceGroup --name $clusterName

# Create an Azure Container Registry account and login to it
az acr create --name $containerRegistry --resource-group $resourceGroup --sku Standard

# Create a service principal for the container registry and register it with Kubernetes as an image pulling secret
$acrId = $(az acr show --name $containerRegistry --query id --output tsv)
$acrServicePrincipalName = "$($containerRegistry)-aks-service-principal"
$acrSpPw = $(az ad sp create-for-rbac --name http://$acrServicePrincipalName --scopes $acrId --role acrpull --query password --output tsv)
$acrSpAppId = $(az ad sp show --id http://$acrServicePrincipalName --query appId --output tsv)
$acrLoginServer = $(az acr show --name $containerRegistry --resource-group $resourceGroup --query loginServer).Trim('"')
kubectl create secret docker-registry $containerRegistry --namespace default --docker-server=$acrLoginServer --docker-username=$acrSpAppId --docker-password=$acrSpPw

# Configure the storage account that the application is going to use by adding a new secret to Kubernetes
kubectl create secret generic az-storage-acct --from-literal=key=$(az storage account show-connection-string --name $storageAccount --resource-group $resourceGroup --output tsv)
