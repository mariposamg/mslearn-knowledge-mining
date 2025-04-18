#!/bin/bash
# filepath: /workspaces/mslearn-knowledge-mining/Labfiles/02-search-skill/setup.sh

# Set values for your subscription and resource group
subscription_id="e9751f69-bcb1-4bb6-99bb-611fa8576df0"
resource_group="ResourceGroup1"
location="eastus"

# Get random numbers to create unique resource names
unique_id=$RANDOM$RANDOM

echo "Creating storage..."
az storage account create --name "ai102str$unique_id" --subscription "$subscription_id" --resource-group "$resource_group" --location "$location" --sku Standard_LRS --encryption-services blob --default-action Allow --allow-blob-public-access true --only-show-errors --output none

echo "Uploading files..."
# Get storage key
key_json=$(az storage account keys list --subscription "$subscription_id" --resource-group "$resource_group" --account-name "ai102str$unique_id" --query "[?keyName=='key1'].value" -o tsv)
export AZURE_STORAGE_KEY="$key_json"

az storage container create --account-name "ai102str$unique_id" --name margies --public-access blob --auth-mode key --account-key "$AZURE_STORAGE_KEY" --output none
az storage blob upload-batch -d margies -s data --account-name "ai102str$unique_id" --auth-mode key --account-key "$AZURE_STORAGE_KEY" --output none

echo "Creating search service..."
az search service create --name "ai102srch$unique_id" --subscription "$subscription_id" --resource-group "$resource_group" --location "$location" --sku basic --output none

echo "-------------------------------------"
echo "Storage account: ai102str$unique_id"
az storage account show-connection-string --subscription "$subscription_id" --resource-group "$resource_group" --name "ai102str$unique_id"

echo "----"
echo "Search Service: ai102srch"
echo "  Url: https://ai102srch$unique_id.search.windows.net"
echo "  Admin Keys:"
az search admin-key show --subscription "$subscription_id" --resource-group "$resource_group" --service-name "ai102srch$unique_id"
echo "  Query Keys:"
az search query-key list --subscription "$subscription_id" --resource-group "$resource_group" --service-name "ai102srch$unique_id"