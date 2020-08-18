# Commands for setting up required resources in Azure and AKS
# Update the variables for your environment.
# To run lines individually in a PowerShell integrated termainal
# in VS Code, place the cursor on the line and press F8.

$resourceGroup = "YOUR RESOURCE GROUP"
$location =      "EastUS"
$aksName =       "YOUR AKS NAME"
$acrName =       "YOUR ACR NAME"
$keyVaultName =  "YOUR KEY VAULT NAME"
$clientID =      "YOUR AAD APPCLIENT ID"
$clientSecret =  "YOUR AAD APPCLIENT SECRET"

# Login with Azure CLI
az login

# Create Resource Group
az group create --name "$resourceGroup" --location "$location"

# Create ACR and login
az acr create --resource-group "$resourceGroup" --name "$acrName" --sku Basic
az acr login --name "$acrName"

# Docker build
docker build -f Dockerfile -t aspnet-keyvault .

# Docker tag and push the image to the ACR
docker tag aspnet-keyvault "$acrName.azurecr.io/aspnet-keyvault"
docker push "$acrName.azurecr.io/aspnet-keyvault"

# As per README.md, first:
# 1. Create your Key Vault. Update the $keyVaultName accordingly.
# 2. Create the Azure AD app regsitration; update $clientID accordingly.
# 3. Import the PFX
# The command below grants your clientID access to get the Key Vault secrets.
az keyvault set-policy -n "$keyVaultName" --secret-permissions get --spn "$clientID"

# Create an AKS cluster
az aks create --resource-group "$resourceGroup" --name "$aksName" --node-count 2 --generate-ssh-keys --attach-acr "$acrName"

# Get credentials for the AKS cluster
az aks get-credentials --resource-group "$resourceGroup" --name "$aksName"

# Install teh FlexVol driver for Key Vault
kubectl create -f https://raw.githubusercontent.com/Azure/kubernetes-keyvault-flexvol/master/deployment/kv-flexvol-installer.yaml

# Set up a credential secret for your Auzre AD app registration (update $clientSecret accordingly)
kubectl create secret generic kvcreds --from-literal "clientid=$clientID" --from-literal "clientsecret=$clientSecret" --type=azure/kv

# Apply the Kubernetes YAML
kubectl apply -f k8s-aspnetapp-all-in-one.yaml

# Check status
kubectl get pods
kubectl get services

# delete everything when done
#az aks delete --name "$aksName" --resource-group "$resourceGroup" --yes --no-wait