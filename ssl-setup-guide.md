# SSL Certificate Setup for MyIntellX Custom Domain

## Issue: "Not Secure" Warning
Your website www.myintellx.my is loading but shows "Not Secure" because the SSL certificate isn't configured for your custom domain.

## Solution: Azure Portal SSL Configuration

### Step 1: Add Custom Domain with SSL in Azure Portal

1. **Go to Azure Portal**: https://portal.azure.com
2. **Navigate to**: Resource groups → **website3** → **lemon-mud-09e77df00** (Static Web App)
3. **Click**: Custom domains (left menu)
4. **Click**: + Add button
5. **Enter Domain**: `www.myintellx.my`
6. **Select Domain Type**: Custom domain on other DNS
7. **Click**: Next

### Step 2: DNS Validation Process

Azure will show you validation requirements:
- **CNAME Record**: www → lemon-mud-09e77df00.1.azurestaticapps.net ✅ (Already done!)
- **TXT Record**: May be required for domain verification

### Step 3: SSL Certificate Configuration

Once domain is added:
1. **Automatic SSL**: Azure Static Web Apps provides **free SSL certificates** automatically
2. **Certificate Type**: Let's Encrypt (managed by Azure)
3. **Validation**: Azure will validate domain ownership via DNS
4. **Provisioning Time**: 5-30 minutes for SSL certificate generation

### Step 4: Force HTTPS (Recommended)

After SSL is configured:
1. **Go to**: Configuration → General settings
2. **Enable**: "Require HTTPS" - redirects all HTTP to HTTPS
3. **Enable**: "HSTS" (HTTP Strict Transport Security) - forces browsers to use HTTPS

## Current Status Check Commands

```powershell
# Test SSL certificate status
nslookup www.myintellx.my

# Test HTTPS after configuration
Invoke-WebRequest -Uri "https://www.myintellx.my" -UseBasicParsing
```

## Expected Timeline
- **DNS Validation**: 5-15 minutes
- **SSL Certificate**: 5-30 minutes  
- **Full HTTPS**: 15-45 minutes total

## Troubleshooting

### If SSL fails:
1. Verify CNAME record is correct in Namecheap
2. Check domain validation in Azure Portal
3. Wait longer - SSL provisioning can take up to 1 hour
4. Try removing and re-adding the custom domain

### Common Issues:
- **Domain not verified**: Add TXT record if requested by Azure
- **SSL pending**: Normal - Azure is generating certificate
- **Certificate error**: Wait 24 hours for full propagation

## Final Result
Once complete, https://www.myintellx.my will show:
- ✅ Green padlock (Secure)
- ✅ Valid SSL certificate
- ✅ MyIntellX website content
- ✅ Fast loading via Azure CDN