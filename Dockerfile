FROM golang:alpine AS sigsum

ARG SIGSUM_VERIFY_VERSION=0.14.0

RUN go install sigsum.org/sigsum-go/cmd/sigsum-verify@v${SIGSUM_VERIFY_VERSION}

FROM alpine AS builder

ARG AGE_VERSION=1.3.1
ARG TARGETARCH

COPY --from=sigsum /go/bin/sigsum-verify /usr/local/bin/sigsum-verify

# age sigsum public keys (https://github.com/FiloSottile/age/blob/main/SIGSUM.md)
COPY <<EOF /tmp/age-sigsum-key.pub
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM1WpnEswJLPzvXJDiswowy48U+G+G1kmgwUE2eaRHZG
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAz2WM5CyPLqiNjk7CLl4roDXwKhQ0QExXLebukZEZFS
EOF

# Download age binary and proof, then verify with sigsum
RUN <<EOF
set -ex
case "${TARGETARCH}" in
  amd64) ARCH="amd64" ;;
  arm64) ARCH="arm64" ;;
  arm)   ARCH="arm"   ;;
  *)     echo "Unsupported architecture: ${TARGETARCH}" && exit 1 ;;
esac
download_url="https://github.com/FiloSottile/age/releases/download/v${AGE_VERSION}/age-v${AGE_VERSION}-linux-${ARCH}.tar.gz"
wget -O /tmp/age.tar.gz "${download_url}"
wget -O /tmp/age.tar.gz.proof "${download_url}.proof"
sigsum-verify -k /tmp/age-sigsum-key.pub -P sigsum-generic-2025-1 \
  /tmp/age.tar.gz.proof < /tmp/age.tar.gz
tar -xzf /tmp/age.tar.gz -C /tmp
EOF

FROM scratch

COPY --from=builder /tmp/age/age /age
COPY --from=builder /tmp/age/age-keygen /age-keygen
