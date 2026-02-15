#!/bin/bash

# V2bX-Nodemix 快速更新脚本
# 用于从 GitHub 拉取最新版本并更新系统中的脚本

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# 检查是否为 root
if [ "$EUID" -ne 0 ]; then
    print_error "请使用 root 权限运行此脚本"
    echo "运行: sudo bash update.sh"
    exit 1
fi

INSTALL_DIR="/opt/V2bX-Nodemix"

echo ""
echo "=========================================="
echo "   V2bX-Nodemix 更新脚本"
echo "=========================================="
echo ""

if [ ! -d "$INSTALL_DIR" ]; then
    print_error "未找到安装目录: $INSTALL_DIR"
    print_info "请先运行安装脚本"
    exit 1
fi

print_info "备份当前版本..."
BACKUP_DIR="${INSTALL_DIR}/backup_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"
cp -p "$INSTALL_DIR"/*.sh "$BACKUP_DIR/" 2>/dev/null || true
print_success "已备份到: $BACKUP_DIR"

print_info "从 GitHub 下载最新版本..."
cd /tmp
rm -rf V2bX-Nodemix-main V2bX-Nodemix.zip 2>/dev/null

if wget -q --show-progress "https://github.com/Cd1s/V2bX-Nodemix/archive/refs/heads/main.zip" -O V2bX-Nodemix.zip; then
    unzip -q -o V2bX-Nodemix.zip
    
    print_info "更新脚本文件..."
    cp -f V2bX-Nodemix-main/v2bx-manager.sh "$INSTALL_DIR/"
    cp -f V2bX-Nodemix-main/v2bx-nodemix.sh "$INSTALL_DIR/"
    cp -f V2bX-Nodemix-main/install.sh "$INSTALL_DIR/"
    cp -f V2bX-Nodemix-main/update.sh "$INSTALL_DIR/"
    
    # 如果有诊断脚本也更新
    if [ -f "V2bX-Nodemix-main/diagnose.sh" ]; then
        cp -f V2bX-Nodemix-main/diagnose.sh "$INSTALL_DIR/"
        chmod +x "$INSTALL_DIR/diagnose.sh"
    fi
    
    # 设置执行权限
    chmod +x "$INSTALL_DIR"/*.sh
    
    # 清理
    rm -rf V2bX-Nodemix-main V2bX-Nodemix.zip
    
    print_success "更新完成!"
    echo ""
    print_info "更新内容:"
    echo "  - 修复了 'file: command not found' 错误"
    echo "  - 修复了 'log_error: command not found' 错误"
    echo "  - 改进了 V2bX 二进制文件检测逻辑"
    echo "  - 优化了安装后的重新检测逻辑"
    echo ""
    print_info "如需回滚,备份文件在: $BACKUP_DIR"
    echo ""
else
    print_error "无法从 GitHub 下载更新"
    print_info "请检查网络连接或手动更新"
    exit 1
fi

echo "=========================================="
print_success "V2bX-Nodemix 更新成功!"
echo "=========================================="
