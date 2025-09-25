# DNS Configuration Commands for myintellx.my

## Your Static Web App Details:
- **Domain**: myintellx.my (from Namecheap)
- **Static Web App URL**: victorious-coast-06ac35700.1.azurestaticapps.net
- **Azure DNS Zone**: Already configured ✅

## DNS Configuration Commands:

# Add CNAME record for www subdomain
az network dns record-set cname set-record \
  --resource-group myintellx-rg \
  --zone-name myintellx.my \
  --record-set-name www \
  --cname victorious-coast-06ac35700.1.azurestaticapps.net

# Add CNAME record for apex domain (alternative method)
# Note: Some DNS providers don't support CNAME for apex domains
# In that case, use ALIAS or A record pointing to the IP

# For apex domain, you might need to create a TXT record for verification
az network dns record-set txt add-record \
  --resource-group myintellx-rg \
  --zone-name myintellx.my \
  --record-set-name "@" \
  --value "azure-staticwebapp-verification=<verification-string-from-azure>"

## Alternative: Using Azure Portal
# 1. Go to your DNS zone "myintellx.my" in Azure Portal
# 2. Add CNAME record:
#    - Name: www
#    - Value: victorious-coast-06ac35700.1.azurestaticapps.net
# 3. Add A record for apex domain (get IP from Static Web App settings)

## In your Static Web App settings:
# 1. Go to "Custom domains"
# 2. Add custom domain: www.myintellx.my
# 3. Follow the verification process
# 4. Azure will provide SSL certificate automatically