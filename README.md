# [DEPRECATED] aks-keyvault-certs

WARNING ⚠️ This repo has been deprecated since the FlexVolume driver has also been deprecated.
Please see [aks-csi-keyvault-certs](https://github.com/dzrhythm/aks-csi-keyvault-certs) instead.

------------------------------------------------------------------------------------------------

Sample for using Azure Key Vault for mounting certificates in containers running
in Kubernetes, via the
[Kuberntes Key Vault FlexVolume driver](https://github.com/Azure/kubernetes-keyvault-flexvol).

The basis for the application source comes from the aspnetapp sample application in the
[Microsoft dotnet docker repo](https://github.com/dotnet/dotnet-docker).

This code is for demonstration purposes only and is not intended for production.

## Requirements

- [.NET Core 3.1](https://dotnet.microsoft.com/download/dotnet-core/3.1)
- [Docker](https://docs.docker.com/get-docker/)
- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest)
- A [Microsoft Azure](https://azure.microsoft.com/) account.
- Recommended: [Visual Studio Code](https://code.visualstudio.com/)
  with the Docker and Kubernetes extensions.

## Local Debugging

You can run and debug locally in Docker, simulating the certificate mount, by using
Visual Studio Code and using the `Docker .NET Core Launch` target in
[.vscode\launch.json](.vscode\launch.json) to run. The required Docker configuration
is in [.vscode\tasks.json](.vscode\tasks.json).

## Deploying to AKS

These instructions assume you have basic knowledge about:

- building and pushing Docker images
- deploying simple applications to Azure Kubernetes Service.

See [AKS-Deploy.ps1](AKS-Deploy.ps1) for example Azure CLI commands
for most of these steps. To run this sample in AKS:

1. Create a self-signed private key certificate, or use the one included in this repo:
   [aspnetapp\certs\localhost.pfx](aspnetapp\certs\localhost.pfx).
   (Password: `abcdefghijklmnopqrstuvwxyz0123456789`).

2. Create an [Azure Key Vault](https://azure.microsoft.com/en-us/services/key-vault/)
   in your subscription.

3. Import the certificate into your Key Vault using the name "aks-https".

4. Create an [Azure Container Registry (ACR)](https://azure.microsoft.com/en-us/services/container-registry/).

5. Build a Docker image of the app using the [Dockerfile](Dockerfile),
   then tag and push the image to your registry.

6. Create an [Azure Kubernetes Service (AKS)](https://azure.microsoft.com/en-us/services/kubernetes-service/)
   cluster attached to your ACR.

7. Create an [app registration](https://docs.microsoft.com/en-us/azure/active-directory/develop/quickstart-register-app)
   in Azure Active Directory (AAD) to use as a service principal. Get the client ID,
   then generate and save a secret to use.

8. In your Key Vault, add an Access Policy to grant your service principal "Get"
   permissions for keys, secrets and certificates.

9. Edit the [k8s-aspnetapp-all-in-one.yaml](k8s-aspnetapp-all-in-one.yaml) file:
   - Update the Deployment section with the registry path to your Docker `image`.
   - Update the Deployment section with the name of your Key Vault and
     Azure Active Directory tenant ("Directory ID" on the Key Vault page in the portal) in the
     `keyvaultname` and `tenantid` under the volumes configuration.

10. In a terminal get credentials to your cluster with `az aks get-credentials`.

11. Deploy the Key Vault FlexVolume driver to your cluster:

    `kubectl create -f https://raw.githubusercontent.com/Azure/kubernetes-keyvault-flexvol/master/deployment/kv-flexvol-installer.yaml`

12. Using the AAD registration client id and secret, create a Kubernetes Secret for the
    Key Vault FlexVolume driver:

    `kubectl create secret generic kvcreds --from-literal clientid=<CLIENTID> --from-literal clientsecret=<CLIENTSECRET> --type=azure/kv`

13. Apply the application YAML:

    `kubectl apply -f k8s-aspnetapp-all-in-one.yaml`

14. Make sure the pod is running:

    `kubectl get pods`

15. List the service:

    `kubectl get service aks-keyvault-aspnetcore-svc`

    Get the EXTERNAL-IP value and browse to it using <https://YOUR-IP>
    (you'll likely need to bypass the browser warning about the self-signed cert).

## Notes

The [aspnetapp/certs](aspnetapp/certs) folder has self-signed localhost certificates for
development and testing. Of course these are not meant for production use :-).
