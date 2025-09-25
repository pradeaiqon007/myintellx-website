# Custom Domain Setup Guide

## Overview
Setting up myintellx.my custom domain for your Static Web App: **victorious-coast-06ac35700**

## Step 1: Azure Portal Configuration

### Add Custom Domain
1. Go to [Azure Portal](https://portal.azure.com)
2. Navigate to: **Static Web Apps** > **victorious-coast-06ac35700**
3. In the left menu, click **Custom domains**
4. Click **+ Add** button

### Configure WWW Subdomain First
1. Enter domain: `www.myintellx.my`
2. Select **CNAME** as domain type
3. Click **Next**
4. Azure will show you the CNAME record details:
   - **Host**: `www`
   - **Points to**: `victorious-coast-06ac35700.1.azurestaticapps.net`

### Configure Root Domain (Apex)
1. Click **+ Add** again
2. Enter domain: `myintellx.my`
3. Select **A record** as domain type
4. Azure will provide:
   - **TXT Record** for verification
   - **A Record** IP addresses

## Step 2: Namecheap DNS Configuration

### For WWW Subdomain (CNAME)
1. Login to [Namecheap](https://www.namecheap.com)
2. Go to **Domain List** > **Manage** for myintellx.my
3. Click **Advanced DNS** tab
4. Add new record:
   - **Type**: CNAME Record
   - **Host**: www
   - **Value**: victorious-coast-06ac35700.1.azurestaticapps.net
   - **TTL**: Automatic (or 300)

### For Root Domain (A Record)
1. Add TXT record first (for verification):
   - **Type**: TXT Record
   - **Host**: @
   - **Value**: [Copy from Azure Portal]
   - **TTL**: 300

2. Add A records (copy IP addresses from Azure):
   - **Type**: A Record
   - **Host**: @
   - **Value**: [IP Address 1 from Azure]
   - **TTL**: 300
   
   Repeat for all IP addresses provided by Azure.

## Step 3: Verification Timeline
- DNS changes can take 24-48 hours to propagate
- Azure verification typically completes within 1-2 hours
- Test with: `nslookup www.myintellx.my` and `nslookup myintellx.my`

## Step 4: Testing
Once configured, test access:
- https://www.myintellx.my
- https://myintellx.my
- Both should redirect to your MyIntellX website

## Important Notes
- Configure www subdomain first (easier)
- Root domain requires both TXT verification and A records
- Keep the Azure Static Web App URL as backup: victorious-coast-06ac35700.1.azurestaticapps.net