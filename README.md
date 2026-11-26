# Azure Terraform + Terragrunt platform

Starter repository for an Azure platform built with Terraform, Terragrunt, AKS, Helm, and GitHub Actions workload identity federation (OIDC).

## Current scope

The first increment is intentionally small: Terraform creates a development resource group through a reusable module. It does **not** create an AKS cluster, network, or Helm release yet. Those will be added after the state, access, and deployment workflow is validated; staging and production should wait until then.

## Layout

- `modules/resource-group/` — small reusable Azure resource-group module.
- `environments/dev/` — non-production Terraform root module and AzureRM remote-state configuration.
- `environments/dev/backend.hcl.example` — example backend settings; copy and fill in your own Azure storage details outside source control.

## Target cloud, environments, and ownership

- **Cloud:** Microsoft Azure; Terraform uses the `azurerm` provider.
- **Environment now:** `dev` only. Staging and production are intentionally not scaffolded yet.
- **Platform ownership:** platform/infrastructure maintainers own shared Terraform modules, remote-state storage and access, environment foundations, and (in later increments) cluster configuration and CI workflows.
- **Application ownership:** application teams own their workloads and Helm release values within the boundaries of a platform-provided cluster/namespace. This initial increment does not grant application teams cloud-level permissions.
- **State isolation:** use a distinct state key per environment. Do not share a state file between environments.

## Prerequisites

- Terraform `>= 1.6.0` and Azure CLI.
- An Azure subscription and permission to create resource groups.
- A pre-created Azure Storage account and blob container for Terraform state. Keep the state storage in a separately managed bootstrap/security boundary; Terraform cannot create the backend before initializing it.
- Authentication to Azure. For local setup, use `az login` and select the intended subscription. CI should use GitHub Actions OIDC/workload identity federation rather than a stored client secret; the Azure app/service principal, federated credential, RBAC assignments, and GitHub variables/secrets must be configured by an authorized administrator before CI can authenticate.

## Configure and run the dev environment

From the repository root, copy `environments/dev/backend.hcl.example` to a local, untracked file named `environments/dev/backend.hcl` and replace the placeholders with your state storage account details. The example uses Azure AD authentication for the backend. Ensure the authenticated identity has appropriate blob data-plane access to the state container.

```sh
az login
az account set --subscription "<subscription-id>"
export ARM_SUBSCRIPTION_ID="<subscription-id>"
cp environments/dev/backend.hcl.example environments/dev/backend.hcl
# Edit backend.hcl with the actual resource group, storage account, and container.
terraform -chdir=environments/dev init -backend-config=backend.hcl
terraform -chdir=environments/dev fmt -check -recursive
terraform -chdir=environments/dev validate
terraform -chdir=environments/dev plan
```

Apply only after reviewing the plan and confirming the selected subscription and state backend:

```sh
terraform -chdir=environments/dev apply -backend-config=backend.hcl
```

The `backend.hcl` file is ignored by Git. Never commit credentials, state files, or environment-specific secret values. Backend storage must have restricted access, encryption, and recovery protections (such as blob versioning/soft delete) enabled by the organization.

## Next increments

1. Validate backend recovery, least-privilege access, and dev-only isolation.
2. Configure GitHub-to-Azure OIDC and add plan/apply workflows with protected-environment approval gates.
3. Add AKS using Terragrunt and deploy a small non-production Helm release.
4. Add staging and production only after the dev workflow is proven and ownership/approval boundaries are agreed.

No cloud resources are created by this commit; Terraform must be initialized, reviewed, and applied by an authorized operator.
