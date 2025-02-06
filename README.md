# SSL Certificate Automation with acme.sh

This script automates the process of issuing, renewing, and deploying SSL certificates using [`acme.sh`](https://github.com/acmesh-official/acme.sh) with Cloudflare DNS verification and deployment to Synology DSM.

## 📌 Prerequisites

Before running the script, ensure that:
1. You have `curl` installed.
2. You have a Cloudflare API token with DNS editing permissions.
3. Your Synology DSM is set up to accept certificate updates.
4. You have the required environment variables set.

## 🛠 Environment Variables

Before running the script, make sure you have the following variables:

```sh
export DOMAIN="yourdomain.com"
export CF_Token="your-cloudflare-api-token"
export ACME_EMAIL="your-email@example.com"
```

### Synology DSM Deployment Variables

To deploy the certificate to Synology DSM, you must set either:
- `SYNO_USE_TEMP_ADMIN=true` (for temporary admin mode), **or**
- Both `SYNO_USERNAME` and `SYNO_PASSWORD` (for permanent admin authentication).
- If you change ports/hostname/scheme, you can also set `SYNO_SCHEME`, `SYNO_HOSTNAME`, `SYNO_PORT`. see https://github.com/acmesh-official/acme.sh/blob/master/deploy/synology_dsm.sh
- If variables has special characters, you can escape them with `\`.

Example:

```sh
export SYNO_USE_TEMP_ADMIN=true
# OR
export SYNO_USERNAME="your-synology-admin"
export SYNO_PASSWORD="your-synology-password"
```

## 🚀 Usage

### Standard Installation (GitHub Source)

Clone the repository and run the script:

```sh
mkdir acme_synology.sh
wget https://raw.githubusercontent.com/ibesty/acme_synology.sh/refs/heads/main/acme_synology.sh -O acme_synology.sh/acme_synology.sh
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
mkdir acme_synology.sh
wget https://gitee.com/best1e/acme_synology.sh/raw/main/acme_synology.sh -O acme_synology.sh/acme_synology.sh
```

This will install `acme.sh` from:

```
https://gitee.com/best1e/acme.sh.git
```

instead of GitHub.

## 🔄 Automate with Synology DSM Task Scheduler

After downloading the script, follow these steps to set up automatic execution in Synology DSM:

1. **Open Synology DSM Control Panel**
2. **Navigate to `Control Panel > Task Scheduler`**
3. **Click `Create` and select `Scheduled Task > User-defined Script`**
4. **Enter Task Name** (e.g., `Auto SSL Renewal`)
5. **Set User Account**
   - Choose any administrator account.
6. **Set Schedule**
   - Configure the task to run weekly or at your preferred interval.
7. **Define the User Script**
   - Add the following environment variables in the script:

   ```sh
   export CF_Token="your-cloudflare-api-token"
   export ACME_EMAIL="your-email@example.com"
   export SYNO_USERNAME="your-synology-admin"
   export SYNO_PASSWORD="your-synology-password"
   
   bash /path/to/your/acme_synology.sh/acme_synology.sh --use-gitee
   ```

8. **Save and Confirm**
9. **Manually Run the Task Once**
   - Click the `Run` button in the menu bar.
10. **Check Execution Results**
   - Click `Action > View Results` to confirm successful deployment.

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

