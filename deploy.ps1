$resourceGroup = "orleansbasics"
$location = "eastus"
$storageAccount = "orleansbasics1"
$clusterName = "orleansbasics"
$containerRegistry = "orleansbasicsacr"

$acrLoginServer = $(az acr show --name $containerRegistry --resource-group $resourceGroup --query loginServer).Trim('"')
az acr login --name $containerRegistry

pushd site
npm run build
popd

docker build . -t $acrLoginServer/orleansbasics &&
docker push $acrLoginServer/orleansbasics &&
kubectl apply -f ./deployment.yaml &&
kubectl rollout restart deployment/orleansbasics
