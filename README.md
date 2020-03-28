# aks-keyvault-certs

Sample for using Azure Key Vault for mounting certificates in containers running in Kubernetes.

The basis for this source comes from the aspnetapp sample application from the
[Microsoft dotnet docker repo](https://github.com/dotnet/dotnet-docker).

## Requirements

- .NET Core 3.1
- Docker
- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest)
- A Microsoft Azure account with
  - An Azure Container Registry
  - A Key Vault
  - An Azure Kubernetes Service cluster
- Recommended: Visual Studio Code with the Docker and Kubernetes extensions.

## Notes

The [aspnetapp/certs](aspnetapp/certs) folder has self-signed localhost certificates for
development and testing. Password for the localhost.pfx cert in this sample is: "abcdefghijklmnopqrstuvwxyz0123456789". Of course these are not meant for
production use :-).
