# Release
FROM alpine
# 安装必要的工具包
RUN apk --no-cache add tzdata ca-certificates 
    && cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime 
    && mkdir /etc/XrayR/

COPY --from=builder /app/XrayR /usr/local/bin/XrayR

RUN set -eux; 
    LIST=('geoip' 'geosite'); 
    for item in "${LIST[@]}"; do 
      DOWNLOAD_URL="https://raw.githubusercontent.com/Loyalsoldier/v2ray-rules-dat/release/${item}.dat"; 
      FILE_NAME="/etc/XrayR/${item}.dat"; 
      echo "Downloading ${DOWNLOAD_URL}..."; 
      wget "${DOWNLOAD_URL}" -O "${FILE_NAME}"; 
    done

ENTRYPOINT ["/usr/local/bin/XrayR", "--config", "/etc/XrayR/config.yml"]
