#!/bin/bash

# 定义 acme.sh 的绝对路径
ACME_SH_PATH="/root/.acme.sh/acme.sh"

# 设置 Cloudflare API 凭据
export CF_Key="2a0685bca2bbdd144596d8573053ea7efb5af"
export CF_Email="zirongkong@outlook.com"

# 确保系统 PATH 正确
export PATH="/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin"

# 检查 acme.sh 是否存在且可执行
if [ ! -x "$ACME_SH_PATH" ]; then
    echo "错误: acme.sh 路径无效或不可执行 ($ACME_SH_PATH)"
    exit 1
fi

# 切换到 acme.sh 目录
cd /root/.acme.sh || exit 1

# 检查 /root/cert 目录是否存在
CERT_DIR="/root/cert"
if [ ! -d "$CERT_DIR" ]; then
    echo "错误: 证书目录不存在 ($CERT_DIR)"
    exit 1
fi

# 检查 /root/cert 目录下是否有 .cer 文件
if ! ls "$CERT_DIR"/*.cer 1>/dev/null 2>&1; then
    echo "错误: 证书目录中没有 .cer 文件"
    exit 1
fi

# 提取最长文件名中的域名
filename=$(ls -1 "$CERT_DIR"/*.cer | grep -Eo '[a-zA-Z0-9.-]+\.cer$' | awk '{print length($0), $0}' | sort -n | tail -1 | awk '{print $2}' | sed 's/\.cer$//')
domain=$(basename "$filename")

# 检查提取的域名是否为空
if [ -z "$domain" ]; then
    echo "错误: 未能提取域名"
    exit 1
fi

echo "提取出的域名是: $domain"

# 指定使用 Let’s Encrypt 作为 CA
CA_SERVER="letsencrypt"

# 执行 issue 命令
echo "执行 issue 命令..."
$ACME_SH_PATH --issue --dns dns_cf -d "$domain" --force --server "$CA_SERVER" --dnssleep 60
if [ $? -ne 0 ]; then
    echo "错误: issue 命令执行失败，请检查以下可能原因："
    echo "1. Cloudflare API 密钥是否正确。"
    echo "2. DNS 配置是否正确，特别是 _acme-challenge 记录。"
    echo "3. 网络连接是否正常。"
    exit 1
fi

# 执行 installcert 命令
echo "执行 installcert 命令..."
$ACME_SH_PATH --installcert -d "$domain" \
    --key-file "$CERT_DIR/${domain}.key" \
    --fullchain-file "$CERT_DIR/${domain}.cer"
if [ $? -ne 0 ]; then
    echo "错误: installcert 命令执行失败，请检查以下可能原因："
    echo "1. 目标目录 ($CERT_DIR) 是否可写。"
    echo "2. acme.sh 是否能够正确安装证书。"
    exit 1
fi

echo "证书更新完成！"
