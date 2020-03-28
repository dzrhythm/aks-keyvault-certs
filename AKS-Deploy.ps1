$resourceGroup = "YOUR RESOURCE GROUP"
$location = "eastus"
$aksName = "YOUR AKS NAME"
$acr = "YOUR ACR NAME"

az login

az group create --name "$resourceGroup" --location "$location"

az aks create --resource-group "$resourceGroup" --name "$aksName" --node-count 2 --generate-ssh-keys --attach-acr "$acr"

az aks get-credentials --resource-group "$resourceGroup" --name "$aksName"

kubectl create -f https://raw.githubusercontent.com/Azure/kubernetes-keyvault-flexvol/master/deployment/kv-flexvol-installer.yaml

kubectl apply -f k8s-aspnetapp-all-in-one.yaml

# delete everything when done
#az aks delete --name "$aksName" --resource-group "$resourceGroup"