#!/bin/bash
set -euo pipefail

# ================== CONFIG ==================
CERTS_DIR="./certs"
NODES=("node1" "node2" "node3")
PROXIES=("proxy1")
# ===========================================

echo "=== Generating TLS certificates ==="

# Always clean and regenerate
rm -rf "$CERTS_DIR"
mkdir -p "$CERTS_DIR"

# === Generate CA ===
echo "Generating CA..."
openssl req -x509 -newkey rsa:4096 -nodes -days 3650 \
    -subj "/CN=Cue Demo CA" \
    -keyout "$CERTS_DIR/ca_key.pem" \
    -out "$CERTS_DIR/ca_cert.pem" \
    -addext "basicConstraints=critical,CA:TRUE" \
    -addext "keyUsage=critical,keyCertSign,cRLSign" \
    -addext "subjectAltName=DNS:ca.localhost" \
    -set_serial 0x$(openssl rand -hex 16) > /dev/null 2>&1

echo "✅ CA generated"

# === Function to generate leaf cert with DNS-only SANs ===
generate_leaf_cert() {
    local name=$1
    local cert_dir="$CERTS_DIR/$name"
    
    echo "Generating certificate for $name..."
    mkdir -p "$cert_dir"
    
    # Create CSR config with DNS-only SANs
    cat > "$cert_dir/${name}.csr.conf" << EOF
[req]
default_bits = 2048
prompt = no
default_md = sha256
req_extensions = req_ext
distinguished_name = dn

[dn]
CN = ${name}

[req_ext]
subjectAltName = @alt_names

[alt_names]
DNS.1 = ${name}
DNS.2 = ${name}.localhost
DNS.3 = localhost
EOF

    # Generate private key and CSR
    openssl req -newkey rsa:2048 -nodes \
        -keyout "$cert_dir/key.pem" \
        -out "$cert_dir/${name}.csr" \
        -config "$cert_dir/${name}.csr.conf" \
        -subj "/CN=${name}" > /dev/null 2>&1

    # Sign with CA
    openssl x509 -req -in "$cert_dir/${name}.csr" \
        -CA "$CERTS_DIR/ca_cert.pem" \
        -CAkey "$CERTS_DIR/ca_key.pem" \
        -CAcreateserial \
        -out "$cert_dir/cert.pem" -days 3650 -sha256 \
        -extfile "$cert_dir/${name}.csr.conf" \
        -extensions req_ext > /dev/null 2>&1

    # Cleanup
    rm -f "$cert_dir/${name}.csr" "$cert_dir/${name}.csr.conf"
    echo "  ✅ $name"
}

# Generate certs for all nodes
echo "Generating node certificates..."
for node in "${NODES[@]}"; do
    generate_leaf_cert "$node"
done

# Generate certs for all proxies (cluster communication)
echo "Generating proxy cluster certificates..."
for proxy in "${PROXIES[@]}"; do
    generate_leaf_cert "$proxy"
done

# Generate API certificate for proxy (public-facing) - IN SAME DIRECTORY
echo "Generating proxy API certificate..."
for proxy in "${PROXIES[@]}"; do
    cert_dir="$CERTS_DIR/$proxy"
    
    cat > "$cert_dir/api.csr.conf" << EOF
[req]
default_bits = 2048
prompt = no
default_md = sha256
req_extensions = req_ext
distinguished_name = dn

[dn]
CN = proxy-api

[req_ext]
subjectAltName = @alt_names

[alt_names]
DNS.1 = localhost
DNS.2 = api.localhost
DNS.3 = ${proxy}
DNS.4 = ${proxy}.localhost
EOF

    openssl req -newkey rsa:2048 -nodes \
        -keyout "$cert_dir/api-key.pem" \
        -out "$cert_dir/api.csr" \
        -config "$cert_dir/api.csr.conf" \
        -subj "/CN=proxy-api" > /dev/null 2>&1

    openssl x509 -req -in "$cert_dir/api.csr" \
        -CA "$CERTS_DIR/ca_cert.pem" \
        -CAkey "$CERTS_DIR/ca_key.pem" \
        -CAcreateserial \
        -out "$cert_dir/api-cert.pem" -days 3650 -sha256 \
        -extfile "$cert_dir/api.csr.conf" \
        -extensions req_ext > /dev/null 2>&1

    rm -f "$cert_dir/api.csr" "$cert_dir/api.csr.conf"
    echo "  ✅ API certificate for $proxy"
done

# Cleanup serial files
find "$CERTS_DIR" -name "*.srl" -delete 2>/dev/null || true

echo ""
echo "✅ Certificate generation completed!"
echo "📁 All certificates saved to: $CERTS_DIR"
echo ""
echo "Generated:"
echo "  CA:"
echo "    - $CERTS_DIR/ca_cert.pem"
echo "    - $CERTS_DIR/ca_key.pem"
echo ""
echo "  Nodes (cluster communication):"
for node in "${NODES[@]}"; do
    echo "    - $CERTS_DIR/$node/cert.pem"
    echo "    - $CERTS_DIR/$node/key.pem"
done
echo ""
echo "  Proxy (both cluster + API certs):"
for proxy in "${PROXIES[@]}"; do
    echo "    - $CERTS_DIR/$proxy/cert.pem (cluster)"
    echo "    - $CERTS_DIR/$proxy/key.pem (cluster)"
    echo "    - $CERTS_DIR/$proxy/api-cert.pem (API)"
    echo "    - $CERTS_DIR/$proxy/api-key.pem (API)"
done
echo ""
echo "💡 All certificates are signed by the same CA"
echo "💡 Certificates are DNS-only (no IP SANs)"