#!/bin/bash

# �г�/root/cert/Ŀ¼�������� .cer ��β���ļ�������ȡ�ļ����е���������
filename=$(ls -1 /root/cert/*.cer | grep -Eo '[a-zA-Z0-9.-]+\.cer$' | awk '{print length($0), $0}' | sort -n | tail -1 | awk '{print $2}' | sed 's/\.cer$//')
domain=$(basename "$filename")

echo "��ȡ����������: $domain"

# ִ�� issue ����
echo "ִ�� issue ����..."
~/.acme.sh/acme.sh --issue -d $domain --standalone --force

# ִ�� installcert ����
echo "ִ�� installcert ����..."
~/.acme.sh/acme.sh --installcert -d $domain --key-file /root/cert/${domain}.key --fullchain-file /root/cert/${domain}.cer