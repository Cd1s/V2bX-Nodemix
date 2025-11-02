#!/bin/bash

#==============================================================================
# V2bX-Nodemix 快速更新脚本
# 用法: bash update.sh 或 sudo bash update.sh
#==============================================================================

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

BASE_DIR="/opt/V2bX-Nodemix"

log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }
log_success() { echo -e "${GREEN}[✓]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[!]${NC} $1"; }

# 检查 root 权限
if [[ $EUID -ne 0 ]]; then
   log_error "请使用 root 权限运行此脚本"
   echo "使用: sudo bash update.sh"
   exit 1
fi

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}       V2bX-Nodemix 快速更新工具${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# 检查是否已安装
if [[ ! -d "$BASE_DIR" ]]; then
    log_error "V2bX-Nodemix 未安装"
    log_info "请先运行安装脚本: bash install.sh"
    exit 1
fi

# 检查依赖
log_info "检查依赖..."
for cmd in wget unzip; do
    if ! command -v $cmd &>/dev/null; then
        log_warning "$cmd 未安装，正在安装..."
        if command -v apt &>/dev/null; then
            apt update -qq && apt install -y $cmd
        elif command -v yum &>/dev/null; then
            yum install -y $cmd
        else
            log_error "无法自动安装 $cmd，请手动安装"
            exit 1
        fi
    fi
done

# 创建备份
backup_dir="/tmp/v2bx-backup-$(date +%Y%m%d_%H%M%S)"
mkdir -p "$backup_dir"

log_info "备份当前配置..."
[[ -d "$BASE_DIR/configs" ]] && cp -r "$BASE_DIR/configs" "$backup_dir/"
[[ -f "$BASE_DIR/.password" ]] && cp "$BASE_DIR/.password" "$backup_dir/"
[[ -d "$BASE_DIR/instances" ]] && mkdir -p "$backup_dir/instances" && \
    find "$BASE_DIR/instances" -name "pid" -exec cp --parents {} "$backup_dir/" \; 2>/dev/null || true

log_success "备份完成: $backup_dir"

# 下载最新版本
cd /tmp
rm -rf V2bX-Nodemix-main V2bX-Nodemix.zip 2>/dev/null

log_info "下载最新版本..."
if ! wget -q --show-progress "https://github.com/Cd1s/V2bX-Nodemix/archive/refs/heads/main.zip" -O V2bX-Nodemix.zip; then
    log_error "下载失败，请检查网络"
    exit 1
fi

log_info "解压文件..."
unzip -q -o V2bX-Nodemix.zip

# 停止服务
log_info "停止 Web 服务..."
systemctl stop v2bx-nodemix-web 2>/dev/null || true

# 更新文件
log_info "更新文件..."
cp -f V2bX-Nodemix-main/v2bx-nodemix.sh "$BASE_DIR/"
cp -f V2bX-Nodemix-main/v2bx-manager.sh "$BASE_DIR/"
cp -f V2bX-Nodemix-main/install.sh "$BASE_DIR/"
cp -f V2bX-Nodemix-main/update.sh "$BASE_DIR/"
cp -rf V2bX-Nodemix-main/web/* "$BASE_DIR/web/"

# 更新配置模板（不影响现有配置）
if [[ -d "V2bX-Nodemix-main/configs/template" ]]; then
    mkdir -p "$BASE_DIR/configs/template"
    cp -f V2bX-Nodemix-main/configs/template/* "$BASE_DIR/configs/template/"
fi

# 更新文档
cp -f V2bX-Nodemix-main/*.md "$BASE_DIR/" 2>/dev/null || true

# 恢复配置
log_info "恢复配置..."
[[ -d "$backup_dir/configs" ]] && cp -r "$backup_dir/configs"/* "$BASE_DIR/configs/" 2>/dev/null || true
[[ -f "$backup_dir/.password" ]] && cp "$backup_dir/.password" "$BASE_DIR/.password"

# 设置权限
log_info "设置权限..."
chmod +x "$BASE_DIR"/*.sh
chmod +x "$BASE_DIR/web/start-web.sh"
ln -sf "$BASE_DIR/v2bx-nodemix.sh" /usr/local/bin/v2bx-nodemix

# 检查 Python 依赖
if command -v python3 &>/dev/null; then
    python3 -c "import flask" 2>/dev/null || {
        log_warning "Flask 未安装，正在安装..."
        if command -v apt &>/dev/null; then
            apt install -y python3-flask 2>/dev/null || pip3 install flask
        else
            pip3 install flask 2>/dev/null || true
        fi
    }
fi

# 重启服务
if systemctl is-enabled --quiet v2bx-nodemix-web 2>/dev/null; then
    log_info "重启 Web 服务..."
    systemctl restart v2bx-nodemix-web
fi

# 清理
rm -rf V2bX-Nodemix-main V2bX-Nodemix.zip

echo ""
log_success "更新完成！"
echo ""
echo -e "${GREEN}已保留:${NC}"
echo "  ✓ 所有实例配置 (configs/)"
echo "  ✓ Web 管理密码"
echo "  ✓ 实例运行数据"
echo ""
echo -e "${GREEN}已更新:${NC}"
echo "  ✓ v2bx-nodemix.sh (管理脚本)"
echo "  ✓ v2bx-manager.sh (实例管理器)"
echo "  ✓ web/ (Web 界面)"
echo "  ✓ 配置模板"
echo ""
echo -e "${BLUE}备份位置:${NC} $backup_dir"
echo "确认无问题后可删除: rm -rf $backup_dir"
echo ""
log_info "运行管理控制台: v2bx-nodemix"
echo ""
