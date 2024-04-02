# Build go
FROM golang:1.22.0-alpine AS builder
WORKDIR /app
COPY . .
ENV CGO_ENABLED=0
RUN go mod download
RUN go build -v -o XrayR -trimpath -ldflags "-s -w -buildid="

# Release
FROM  alpine
# 安装必要的工具包
RUN  apk --update --no-cache add tzdata ca-certificates \
    && cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && mkdir /etc/XrayR/
COPY --from=builder /app/XrayR /usr/local/bin
RUN set -eux; \
    LIST=('geoip' 'geosite'); \
    for item in "${LIST[@]}"; do \
      DOWNLOAD_URL="https://raw.githubusercontent.com/Loyalsoldier/v2ray-rules-dat/release/${item}.dat"; \
      FILE_NAME="/etc/XrayR/${item}.dat"; \
      echo "Downloading ${DOWNLOAD_URL}..."; \
      wget "${DOWNLOAD_URL}" -O "${FILE_NAME}"; \
    done

ENTRYPOINT [ "XrayR", "--config", "/etc/XrayR/config.yml"]
