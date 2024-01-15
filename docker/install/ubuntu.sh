#!/bin/bash

set -e

# 在Ubuntu上安装Docker Engine

# 检查脚本是否以root身份运行
echo ">>> 检查脚本是否以root身份运行"
if [ $(id -u) -ne 0 ]; then
    echo "请以root身份运行此脚本"
    exit 1
fi

# 检查操作系统版本和架构
echo ">>> 检查操作系统版本和架构"

if [ $(. /etc/os-release && echo "$NAME") != "Ubuntu" ]; then
    echo "此脚本仅支持Ubuntu操作系统,退出"
    goto exit
fi

if [ $(uname -m) != "x86_64" ]; then
    echo "此脚本仅支持x86_64架构,退出"
    goto exit
fi

if [ $(. /etc/os-release && echo "$VERSION_ID") == "20.04" ]; then
    echo "$(. /etc/os-release && echo "$PRETTY_NAME") x64满足操作系统要求"
    goto install
fi

if [ $(. /etc/os-release && echo "$VERSION_ID") == "22.04" ]; then
    echo "$(. /etc/os-release && echo "$PRETTY_NAME") x64满足操作系统要求"
    goto install
fi

if [ $(. /etc/os-release && echo "$VERSION_ID") == "23.04" ]; then
    echo "$(. /etc/os-release && echo "$PRETTY_NAME") x64满足操作系统要求"
    goto install
fi

if [ $(. /etc/os-release && echo "$VERSION_ID") == "23.10" ]; then
    echo "$(. /etc/os-release && echo "$PRETTY_NAME") x64满足操作系统要求"
    goto install
fi

echo "$(. /etc/os-release && echo "$PRETTY_NAME")不满足操作系统要求,退出"
goto exit

# 安装Docker Engine
:install
echo ">>> 安装Docker Engine"

echo ">>> 卸载旧版本"
for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do sudo apt-get remove $pkg; done

echo ">>> 安装新版本"
apt update -y
apt install -y ca-certificates curl gnupg
install -m 0755 -d /etc/apt/keyrings
if [ -f /etc/apt/keyrings/docker.gpg ]; then
    rm -f /etc/apt/keyrings/docker.gpg
fi
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
chmod a+r /etc/apt/keyrings/docker.gpg
echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" |
    tee /etc/apt/sources.list.d/docker.list >/dev/null
apt update -y
apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# 退出
:exit
echo "本脚本运行要求:"
echo "1. 以root身份运行"
echo "2. 操作系统为Ubuntu 20.04,22.04,23.04,23.10"
echo "3. 架构为x64"
