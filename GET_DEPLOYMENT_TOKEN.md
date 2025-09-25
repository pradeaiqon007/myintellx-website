# Get Deployment Token for Website3 Resource

## Steps to Get Deployment Token

1. **Sign in to Azure Portal**: https://portal.azure.com

2. **Navigate to your Static Web App**:
   - Go to **Resource groups**
   - Select **website3** resource group
   - Click on **lemon-mud-09e77df00** (Static Web App)

3. **Get Deployment Token**:
   - In the Static Web App overview page
   - Click **"Manage deployment token"**
   - Copy the deployment token

4. **Deploy with Token**:
   ```powershell
   .\deploy-simple.ps1 -Token "YOUR_ACTUAL_TOKEN_HERE"
   ```

## Current Setup
- **Resource Group**: website3
- **Static Web App**: lemon-mud-09e77df00  
- **Hostname**: lemon-mud-09e77df00.1.azurestaticapps.net
- **Custom Domain**: www.myintellx.my (already configured)

## What the Script Does
1. Updates build marker in index.html
2. Deploys using Azure Static Web Apps CLI
3. Verifies deployment by checking the live site
4. Maintains the same hostname: lemon-mud-09e77df00.1.azurestaticapps.net

The website3 resource group already contains the correct lemon-mud Static Web App that provides your hostname.