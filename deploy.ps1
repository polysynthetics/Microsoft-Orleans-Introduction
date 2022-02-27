$resourceGroup = "orleansintro"
$location = "eastus"
$storageAccount = "orleansintrostorage"
$clusterName = "orleansintro"
$containerRegistry = "orleansintroacr"

$acrLoginServer = $(az acr show --name $containerRegistry --resource-group $resourceGroup --query loginServer).Trim('"')
az acr login --name $containerRegistry

pushd site
npm run build
popd

docker build . -t $acrLoginServer/hanbaobao &&
docker push $acrLoginServer/hanbaobao &&
kubectl apply -f ./deployment.yaml &&
kubectl rollout restart deployment/hanbaobao
