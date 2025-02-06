# SSL Certificate Automation with acme.sh

This script automates the process of issuing, renewing, and deploying SSL certificates using [`acme.sh`](https://github.com/acmesh-official/acme.sh) with Cloudflare DNS verification and deployment to Synology DSM.

## 📌 Prerequisites

Before running the script, ensure that:
1. You have `curl` installed.
2. You have a Cloudflare API token with DNS editing permissions.
3. Your Synology DSM is set up to accept certificate updates.
4. You have the required environment variables set.

## 🛠 Environment Variables

Before running the script, export the following variables:

```sh
export DOMAIN="yourdomain.com"
export CF_Token="your-cloudflare-api-token"
export ACME_EMAIL="your-email@example.com"
```

### Synology DSM Deployment Variables

To deploy the certificate to Synology DSM, you must set either:
- `SYNO_USE_TEMP_ADMIN=true` (for temporary admin mode), **or**
- Both `SYNO_USERNAME` and `SYNO_PASSWORD` (for permanent admin authentication).

Example:

```sh
export SYNO_USE_TEMP_ADMIN=true
# OR
export SYNO_USERNAME="your-synology-admin"
export SYNO_PASSWORD="your-synology-password"
```

## 🚀 Usage

### Standard Installation (GitHub Source)

Run the script:

```sh
bash ssl_cert.sh
```

This will:
1. Check for required environment variables.
2. Install `acme.sh` from GitHub (if not already installed).
3. Register an ACME account if necessary.
4. Issue a wildcard SSL certificate for the domain using Cloudflare DNS.
5. Deploy the certificate to Synology DSM.
6. Automatically renew and deploy the certificate when needed.

### Using Gitee Mirror

If you have trouble accessing GitHub, use the `--use-gitee` flag to install `acme.sh` from Gitee:

```sh
bash ssl_cert.sh --use-gitee
```

This will install `acme.sh` from:

```
https://gitee.com/best1e/acme.sh.git
```

instead of GitHub.

## 📂 Certificate Storage

Certificates are stored in:

```
/path/to/script/acme/certs
```

You can configure the path by modifying the `CERT_DIR` variable in the script.

## 📝 Notes

- The script uses the `--deploy-hook synology_dsm` option to automatically deploy certificates to Synology DSM.
- Ensure your DSM allows certificate updates via `acme.sh`.
- If you encounter issues, check `acme.sh` logs for details.

## 🎉 Enjoy your automated SSL setup!