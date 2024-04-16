#!/bin/bash

# 列出/root/cert/目录下所有以 .cer 结尾的文件，并提取文件名中的域名部分
filename=$(ls -1 /root/cert/*.cer | grep -Eo '[a-zA-Z0-9.-]+\.cer$' | awk '{print length($0), $0}' | sort -n | tail -1 | awk '{print $2}' | sed 's/\.cer$//')
domain=$(basename "$filename")

echo "提取出的域名是: $domain"

# 执行 issue 命令
echo "执行 issue 命令..."
~/.acme.sh/acme.sh --issue -d $domain --standalone --force

# 执行 installcert 命令
echo "执行 installcert 命令..."
~/.acme.sh/acme.sh --installcert -d $domain --key-file /root/cert/${domain}.key --fullchain-file /root/cert/${domain}.cer