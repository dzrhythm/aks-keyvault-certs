$resourceGroup = "YOUR RESOURCE GROUP"
$location =      "EastUS"
$aksName =       "YOUR AKS NAME"
$acrName =       "YOUR ACR NAME"
$keyVaultName =  "YOUR KEY VAULT NAME"
$clientID =      "YOUR AAD APPCLIENT ID"
$clientSecret =  "YOUR AAD APPCLIENT SECRET"

az login

# Resource Group
az group create --name "$resourceGroup" --location "$location"

# ACR
az acr create --resource-group "$resourceGroup" --name "$acrName" --sku Basic

az acr login --name "$acrName"


# Key Vault permissions

az keyvault set-policy -n "$keyVaultName" --secret-permissions get --spn "$appClientID"

# AKS
az aks create --resource-group "$resourceGroup" --name "$aksName" --node-count 2 --generate-ssh-keys --attach-acr "$acrName"

az aks get-credentials --resource-group "$resourceGroup" --name "$aksName"

kubectl create -f https://raw.githubusercontent.com/Azure/kubernetes-keyvault-flexvol/master/deployment/kv-flexvol-installer.yaml

kubectl create secret generic kvcreds --from-literal "clientid=$clientID" --from-literal "clientsecret=$clientSecret" --type=azure/kv

kubectl apply -f k8s-aspnetapp-all-in-one.yaml

# delete everything when done
#az aks delete --name "$aksName" --resource-group "$resourceGroup" --yes --no-wait