#!/bin/bash

# https://github.com/acmesh-official/acme.sh
# https://github.com/acmesh-official/acme.sh/blob/master/deploy/synology_dsm.sh

set -e  # Exit immediately on error

BASEDIR=$(dirname "$(realpath "$0")")

# Required environment variables
if [ -z "$DOMAIN" ]; then
    echo "❌ Error: DOMAIN variable is not set! Please use export DOMAIN='example.com'"
    exit 1
fi

if [ -z "$CF_Token" ]; then
    echo "❌ Error: CF_Token variable is not set! Please use export CF_Token='your Cloudflare API Token'"
    exit 1
fi

if [ -z "$ACME_EMAIL" ]; then
    echo "❌ Error: ACME_EMAIL variable is not set! Please use export ACME_EMAIL='your email'"
    exit 1
fi

ACME_HOME="$BASEDIR/acme"  # Use local directory in test mode
ACME_SH="$ACME_HOME/acme.sh"
CONFIG_DIR="$ACME_HOME/data"
CERT_DIR="$ACME_HOME/certs"

echo "📂 Certificate storage path: $CERT_DIR"

ACME_ARGS="--home $ACME_HOME --config-home $CONFIG_DIR --cert-home $CERT_DIR"

# 1. Install acme.sh if not installed
if [ ! -f "$ACME_SH" ]; then
    echo "🔧 acme.sh is not installed, installing..."
    curl https://raw.githubusercontent.com/acmesh-official/acme.sh/master/acme.sh | sh -s -- --install-online -m email="$ACME_EMAIL" $ACME_ARGS --noprofile --nocron || { echo "❌ Error: acme.sh installation failed"; exit 1; }

    echo "🔑 Registering account..."
    $ACME_SH --register-account -m "$ACME_EMAIL" $ACME_ARGS || { echo "❌ Error: acme.sh account registration failed"; exit 1; }
fi

# 2. Issue certificate if not already issued
if [ ! -f "$CERT_DIR/${DOMAIN}_ecc/fullchain.cer" ]; then
    echo "🔑 Certificate not found, issuing a new one..."
    $ACME_SH --issue --dns dns_cf --ecc -d "$DOMAIN" -d "*.$DOMAIN" $ACME_ARGS || { echo "❌ Error: Certificate issuance failed"; exit 1; }

    echo "📤 Deploying certificate to Synology DSM..."
    $ACME_SH --deploy -d "$DOMAIN" --deploy-hook synology_dsm $ACME_ARGS || { echo "❌ Error: Certificate deployment failed"; exit 1; }
else
    # 3. Renew and deploy certificate to Synology DSM
    echo "🔄 Certificate already exists, checking for renewal..."
    $ACME_SH --renew -d "$DOMAIN" --ecc --deploy-hook synology_dsm $ACME_ARGS || { echo "❌ Error: Certificate renewal failed"; exit 1; }
fi

echo "📂 Certificates are stored in: $CERT_DIR"
echo "🎉 SSL certificate update completed!"

