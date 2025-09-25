# Azure Portal Deployment Guide

## Step-by-Step Deployment via Azure Portal

### 1. Go to Azure Portal
- Open https://portal.azure.com
- Sign in with your Azure account

### 2. Create Static Web App
- Click "Create a resource" (+ icon)
- Search for "Static Web App"
- Click "Create"

### 3. Fill in Basic Details
- **Subscription**: Select your subscription
- **Resource Group**: Use existing or create new (e.g., "myintellx-rg")
- **Name**: myintellx-website
- **Plan type**: Free (for development) or Standard (for production)
- **Region**: East US 2 (or closest to your users)
- **Source**: Other

### 4. Deployment Details
- **Source**: Choose "Other" since we're uploading files directly
- Leave GitHub details empty for now

### 5. Review and Create
- Click "Review + create"
- Click "Create"
- Wait for deployment to complete

### 6. Upload Your Files
After deployment:
- Go to your Static Web App resource
- Click "Browse" to see the default page
- Note the URL (e.g., https://myintellx-website.azurestaticwebapps.net)

### 7. Deploy Your Content
Method A - Using Azure CLI (after installing):
```bash
# Navigate to your website folder
cd "C:\Users\orapr\Downloads\myown\website"

# Deploy content
az staticwebapp deploy --name myintellx-website --resource-group myintellx-rg --source .
```

Method B - Using GitHub (recommended for continuous deployment):
1. Create a GitHub repository
2. Push your code to GitHub
3. Connect your Static Web App to the GitHub repository

### 8. Custom Domain Configuration for myintellx.my
- In your Static Web App, go to "Custom domains"
- Click "Add custom domain"
- Enter: www.myintellx.my (your Namecheap domain)
- Follow verification steps
- Add DNS records as shown in dns-setup.md

#### Your Domain Details:
- **Domain**: myintellx.my (purchased from Namecheap)
- **Static Web App URL**: https://victorious-coast-06ac35700.1.azurestaticapps.net/
- **DNS Zone**: Already configured in Azure DNS

## Files to Deploy
Make sure these files are in your root directory:
- index.html
- styles.css
- script.js
- (README.md and .gitignore are optional for deployment)

---

## 9. Manual Deployment (SWA CLI) – When GitHub Integration Is Not Used

If you selected "Other" as the source and did not connect GitHub, you can deploy manually using the Static Web Apps CLI (SWA CLI) or Azure CLI.

### Option A: SWA CLI (fastest once installed)
Prerequisites:
- Node.js installed (run `node -v` to verify)
- SWA CLI installed globally (`npm install -g @azure/static-web-apps-cli`) OR use `npx`

Deployment steps (PowerShell):
```powershell
# 1. (RECOMMENDED) Regenerate your deployment token in Azure Portal (Overview > Manage deployment token > Regenerate)

# 2. Set the token in an environment variable (replace YOUR_NEW_TOKEN)
$env:SWA_DEPLOYMENT_TOKEN="YOUR_NEW_TOKEN"

# 3. From your project folder
cd "C:\Users\orapr\Downloads\myown\website"

# 4. Deploy using npx (works even if global install path not on PATH)
npx @azure/static-web-apps-cli deploy `
	--deployment-token $env:SWA_DEPLOYMENT_TOKEN `
	--env production `
	--app-location . `
	--output-location .

# Add --verbose if you need more logs
```

Common issues:
- `swa : The term 'swa' is not recognized` → Use `npx` form above (global bin path not on PATH)
- Token rejected → You regenerated it but used the old one; re-copy carefully (no spaces / quotes)
- 404 after deploy → Browser caching; hard refresh (Ctrl+F5)

### Option B: Azure Cloud Shell + Azure CLI
Azure Cloud Shell already has `az` installed.
```bash
# (In Cloud Shell) Add the staticwebapp extension once
az extension add --name staticwebapp

# Upload current folder contents (after uploading files to Cloud Shell)
az staticwebapp upload \
	--name victorious-coast-06ac35700 \
	--resource-group myintellx-rg \
	--source .
```

If `upload` is not available, fallback to SWA CLI method.

### Option C: Create a GitHub Workflow Later
You can still switch to CI/CD:
1. Create (or push to) GitHub repo.
2. In GitHub repo settings → Secrets → Actions: add secret `AZURE_STATIC_WEB_APPS_API_TOKEN` with the (regenerated) token.
3. Add a workflow file at `.github/workflows/azure-static-web-apps.yml` (template can be generated from Azure Portal under **Deployment** > **GitHub** section).
4. Commit & push – workflow will build and deploy automatically.

---

## 🔐 Deployment Token Security
The deployment token you pasted in chat should be considered exposed. For security:
1. Go to your Static Web App in Azure Portal.
2. Click **Overview** → **Manage deployment token**.
3. Click **Regenerate**.
4. Copy new token and store securely (password manager / GitHub secret).
5. Replace any local env variable using the old token.

Never commit the token into source control.

---

## ✅ Post-Deployment Verification Checklist
After running the deploy command:
1. Visit: https://victorious-coast-06ac35700.1.azurestaticapps.net/
2. Confirm your custom content (hero section, MyIntellX heading) appears.
3. Open DevTools → Network (Disable cache) → Hard refresh to avoid stale content.
4. Add `www.myintellx.my` custom domain (after deploy) and wait for DNS + certificate (can take up to 15 mins for HTTPS).
5. Test both URLs:
	 - Azure default URL
	 - https://www.myintellx.my (after CNAME + verification)

Optional: Add apex redirect
- Add a Static Web Apps route rule (`staticwebapp.config.json`) later to redirect `myintellx.my` → `www.myintellx.my`.

---

## Next Suggested Improvement
Add a `staticwebapp.config.json` for future routing, headers, and redirects.

Example (create in project root):
```json
{
	"navigationFallback": {
		"rewrite": "/index.html"
	},
	"globalHeaders": {
		"X-Frame-Options": "DENY",
		"X-Content-Type-Options": "nosniff",
		"Referrer-Policy": "strict-origin-when-cross-origin"
	}
}
```

This isn’t required yet, but positions you for growth.