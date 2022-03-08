$resourceGroup = "orleansbasics"
$containerRegistry = "orleansbasicsacr"

$acrLoginServer = $(az acr show --name $containerRegistry --resource-group $resourceGroup --query loginServer).Trim('"')
az acr login --name $containerRegistry

Push-Location site
npm run build
Pop-Location

docker build . -t $acrLoginServer/orleansbasics &&
docker push $acrLoginServer/orleansbasics &&
kubectl apply -f ./deployment.yaml &&
kubectl rollout restart deployment/orleansbasics
