#!/bin/bash

# https://github.com/acmesh-official/acme.sh
# https://gitee.com/best1e/acme.sh.git
# https://github.com/acmesh-official/acme.sh/blob/master/deploy/synology_dsm.sh

set -e  # Exit immediately on error

BASEDIR=$(dirname "$(realpath "$0")")

# Parse arguments
USE_GITEE=false
for arg in "$@"; do
    case $arg in
        --use-gitee)
            USE_GITEE=true
            shift
            ;;
    esac
done

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
CONFIG_DIR="$ACME_HOME/data"
CERT_DIR="$ACME_HOME/certs"

echo "📂 Certificate storage path: $CERT_DIR"

ACME_ARGS="--home $ACME_HOME --config-home $CONFIG_DIR --cert-home $CERT_DIR"

# 1. Install acme.sh if not installed
if [ ! -f "$ACME_HOME/acme.sh" ]; then
    echo "🔧 acme.sh is not installed, installing..."

    if [ "$USE_GITEE" = true ]; then
        echo "🌐 Using Gitee mirror for installation..."
        CLONE_NAME="acme.sh-master"
        rm -rf "$CLONE_NAME"
        wget https://gitee.com/best1e/acme.sh/repository/archive/master.zip -O $CLONE_NAME.zip
        unzip $CLONE_NAME.zip
        cd "$CLONE_NAME"
        ./acme.sh --install -m "$ACME_EMAIL" --home "$ACME_HOME" --config-home "$CONFIG_DIR" --cert-home "$CERT_DIR" --noprofile --nocron || { echo "❌ Error: acme.sh installation failed"; exit 1; }
        cd ..
        rm acme.sh-master.zip
        rm -rf "$CLONE_NAME"
    else
        echo "🌐 Using GitHub for installation..."
        curl https://raw.githubusercontent.com/acmesh-official/acme.sh/master/acme.sh | sh -s -- --install-online -m "$ACME_EMAIL" --home "$ACME_HOME" --config-home "$CONFIG_DIR" --cert-home "$CERT_DIR" --noprofile --nocron || { echo "❌ Error: acme.sh installation failed"; exit 1; }
    fi

    echo "🔑 Registering account..."
    "$ACME_HOME/acme.sh" --register-account -m "$ACME_EMAIL" $ACME_ARGS || { echo "❌ Error: acme.sh account registration failed"; exit 1; }
fi

# 2. Issue certificate if not already issued
if [ ! -f "$CERT_DIR/${DOMAIN}_ecc/fullchain.cer" ]; then
    echo "🔑 Certificate not found, issuing a new one..."
    "$ACME_HOME/acme.sh" --issue --dns dns_cf --ecc -d "$DOMAIN" -d "*.$DOMAIN" $ACME_ARGS || { echo "❌ Error: Certificate issuance failed"; exit 1; }
else
    # 3. Renew and deploy certificate to Synology DSM
    echo "🔄 Certificate already exists, checking for renewal..."
    "$ACME_HOME/acme.sh" --renew -d "$DOMAIN" --ecc $ACME_ARGS || { echo "❌ Error: Certificate renewal failed"; exit 1; }
fi

echo "📤 Deploying certificate to Synology DSM..."
"$ACME_HOME/acme.sh" --ecc --deploy -d "$DOMAIN" --deploy-hook synology_dsm $ACME_ARGS || { echo "❌ Error: Certificate deployment failed"; exit 1; }

echo "📂 Certificates are stored in: $CERT_DIR"
echo "🎉 SSL certificate update completed!"
