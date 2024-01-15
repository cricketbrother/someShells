#!/bin/bash

set -e

# 在Ubuntu上安装Docker Engine
INFO="本脚本运行要求:\n1. 以root身份运行\n2. 操作系统为Ubuntu 20.04,22.04,23.04,23.10\n3. 架构为x64"

# 检查脚本是否以root身份运行
echo ">>> 检查脚本是否以root身份运行"
if [ $(id -u) -ne 0 ]; then
    echo $INFO
    exit 1
fi

# 检查操作系统版本和架构
echo ">>> 检查操作系统版本和架构"

if [ $(. /etc/os-release && echo "$NAME") != "Ubuntu" ]; then
    echo $INFO
    exit 1
fi

if [ $(uname -m) != "x86_64" ]; then
    echo $INFO
    exit 1
fi

VERSION_ID=$(. /etc/os-release && echo "$VERSION_ID")
if [ $VERSION_ID != "20.04" ] && [ $VERSION_ID != "22.04" ] && [ $VERSION_ID != "23.04" ] && [ $VERSION_ID != "23.10" ]; then
    echo $INFO
    exit 1
fi

echo "$(. /etc/os-release && echo "$PRETTY_NAME") x64满足操作系统要求"

# 安装Docker Engine
echo ">>> 安装Docker Engine"

echo ">>> 卸载旧版本"
for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do apt remove $pkg >/dev/null 2>&1; done

echo ">>> 安装新版本"
apt update -y >/dev/null 2>&1
apt install -y ca-certificates curl gnupg >/dev/null 2>&1
install -m 0755 -d /etc/apt/keyrings
if [ -f /etc/apt/keyrings/docker.gpg ]; then
    rm -f /etc/apt/keyrings/docker.gpg
fi
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
chmod a+r /etc/apt/keyrings/docker.gpg
echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" |
    tee /etc/apt/sources.list.d/docker.list >/dev/null
apt update -y >/dev/null 2>&1
apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin >/dev/null 2>&1

# 打印Docker版本
echo ">>> 打印Docker版本"
docker -v
docker compose version

echo ">>> 安装完成"
