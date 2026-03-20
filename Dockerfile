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
download_url="https://github.com/FiloSottile/age/releases/download/v${AGE_VERSION}/age-v${AGE_VERSION}-linux-${TARGETARCH}.tar.gz"
wget -O /tmp/age.tar.gz "${download_url}"
if wget --spider "${download_url}.proof" 2>/dev/null; then
  wget -O /tmp/age.tar.gz.proof "${download_url}.proof"
  sigsum-verify -k /tmp/age-sigsum-key.pub -P sigsum-generic-2025-1 \
    /tmp/age.tar.gz.proof < /tmp/age.tar.gz
fi
tar -xzf /tmp/age.tar.gz -C /tmp
EOF

FROM scratch

COPY --from=builder /tmp/age/age /age
COPY --from=builder /tmp/age/age-keygen /age-keygen
