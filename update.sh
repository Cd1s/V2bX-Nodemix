#!/bin/bash

# V2bX-Nodemix 更新脚本

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}正在更新 V2bX-Nodemix...${NC}"

# 检测安装目录
if [ -f "/usr/local/bin/v2bx-nodemix" ]; then
    INSTALL_DIR=$(dirname $(readlink -f /usr/local/bin/v2bx-nodemix))
elif [ -d "/opt/V2bX-Nodemix" ]; then
    INSTALL_DIR="/opt/V2bX-Nodemix"
else
    echo "未找到 V2bX-Nodemix 安装目录"
    exit 1
fi

echo "安装目录: $INSTALL_DIR"

cd "$INSTALL_DIR"

# 备份配置
echo "备份配置文件..."
tar -czf "backup-$(date +%Y%m%d-%H%M%S).tar.gz" configs/ 2>/dev/null || true

# 更新代码
if [ -d ".git" ]; then
    echo "从 git 仓库更新..."
    git pull
else
    echo "请手动下载最新版本替换"
fi

# 重启服务
if systemctl is-active --quiet v2bx-nodemix-web; then
    echo "重启 Web 服务..."
    systemctl restart v2bx-nodemix-web
fi

echo -e "${GREEN}更新完成！${NC}"
