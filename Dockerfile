# Build go
FROM golang:1.22.0-alpine AS builder
WORKDIR /app
COPY . .
ENV CGO_ENABLED=0
RUN go mod download
RUN go build -v -o XrayR -trimpath -ldflags "-s -w -buildid="

# Release
FROM  alpine:latest
COPY --from=builder /app/XrayR /usr/local/bin
COPY *.sh /app/
# 安装必要的工具包
RUN apk --update --no-cache add git curl tzdata ca-certificates \
    && cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && mkdir /etc/XrayR/ \
    && curl -L "https://raw.githubusercontent.com/Loyalsoldier/v2ray-rules-dat/release/geoip.dat" -o /etc/XrayR/geoip.dat \
    && curl -L "https://raw.githubusercontent.com/Loyalsoldier/v2ray-rules-dat/release/geosite.dat" -o /etc/XrayR/geosite.dat \
    && git clone --depth 1 https://github.com/acmesh-official/acme.sh.git acme \
    && cd /acme && ./acme.sh --install --nocron --accountemail $ACME_EMAIL && rm -rf acme \
    && chmod +x /app/acme.sh \
    && chmod +x /app/entrypoint.sh
    
# ENTRYPOINT [ "XrayR", "--config", "/etc/XrayR/config.yml"]
ENTRYPOINT ["/app/entrypoint.sh"]
