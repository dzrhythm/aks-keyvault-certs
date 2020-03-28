#
# Requires the Azure CLI: https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest
#

$acrName = "YOUR ACR NAME"

# Build Docker image
docker build -f Dockerfile -t aspnet-keyvault .

# Login to azure and our Azure Container Registry
az Login
az acr login --name "$acrName"

# Tag and push the image to the ACR
docker tag aspnet-keyvault "$acrName.azurecr.io/aspnet-keyvault"
docker push "$acrName.azurecr.io/aspnet-keyvault"