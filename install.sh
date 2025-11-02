#!/bin/bash

# V2bX-Nodemix 一键安装脚本
# 适用于已安装 V2bX 的服务器

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 打印彩色信息
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 检查是否为 root
check_root() {
    if [ "$EUID" -ne 0 ]; then
        print_error "请使用 root 权限运行此脚本"
        exit 1
    fi
}

# 检测系统
detect_system() {
    print_info "检测系统信息..."
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS=$ID
        VER=$VERSION_ID
        print_success "检测到系统: $PRETTY_NAME"
    else
        print_error "无法检测系统类型"
        exit 1
    fi
}

# 安装依赖
install_dependencies() {
    print_info "安装依赖包..."
    
    if [[ "$OS" == "debian" ]] || [[ "$OS" == "ubuntu" ]]; then
        apt update -qq
        
        # 基础工具
        print_info "安装基础工具..."
        apt install -y wget curl unzip rsync ca-certificates
        
        # Python 和 Flask
        print_info "安装 Python 和 Flask..."
        apt install -y python3 python3-pip
        
        # 尝试使用系统包安装 Flask (Debian 12+)
        if apt install -y python3-flask 2>/dev/null; then
            print_success "Flask 已通过系统包安装"
        else
            # 旧版本系统使用 pip
            print_info "使用 pip 安装 Flask..."
            if pip3 install flask --break-system-packages 2>/dev/null; then
                print_success "Flask 已安装"
            else
                pip3 install flask
            fi
        fi
        
    elif [[ "$OS" == "centos" ]] || [[ "$OS" == "rhel" ]]; then
        yum install -y wget curl unzip rsync ca-certificates python3 python3-pip
        pip3 install flask
    else
        print_warning "未知系统，请手动安装: wget curl unzip rsync python3 python3-pip flask"
    fi
    
    print_success "依赖安装完成"
}

# 检测或安装 V2bX
detect_v2bx() {
    print_info "检测 V2bX..."
    
    # 检测 V2bX 二进制文件
    V2BX_BIN=""
    
    # 优先检查常见路径
    if command -v V2bX &> /dev/null; then
        V2BX_BIN=$(which V2bX)
        V2BX_DIR="$(dirname "$V2BX_BIN")"
        print_success "找到 V2bX: $V2BX_BIN"
        return 0
    fi
    
    # 手动检查常见位置的可执行文件
    V2BX_PATHS=(
        "/usr/local/bin/V2bX"
        "/usr/local/V2bX/V2bX"
        "/opt/V2bX/V2bX"
        "/usr/bin/V2bX"
    )
    
    for path in "${V2BX_PATHS[@]}"; do
        if [[ -f "$path" ]] && [[ -x "$path" ]]; then
            V2BX_BIN="$path"
            V2BX_DIR="$(dirname "$path")"
            print_success "找到 V2bX: $V2BX_BIN"
            return 0
        fi
    done
    
    # 未找到可执行的 V2bX 二进制文件
    print_warning "未检测到 V2bX 可执行文件"
    echo ""
    read -p "是否使用官方脚本安装 V2bX? (y/n): " install_v2bx
    
    if [[ "$install_v2bx" == "y" ]]; then
        print_info "下载并运行官方 V2bX 安装脚本..."
        wget -N https://raw.githubusercontent.com/wyx2685/V2bX-script/master/install.sh -O /tmp/v2bx-install.sh
        bash /tmp/v2bx-install.sh
        rm -f /tmp/v2bx-install.sh
        
        echo ""
        print_info "重新检测 V2bX..."
        
        # 重新检测
        if command -v V2bX &> /dev/null; then
            V2BX_BIN=$(which V2bX)
            V2BX_DIR="$(dirname "$V2BX_BIN")"
            print_success "V2bX 安装成功: $V2BX_BIN"
            return 0
        fi
        
        for path in "${V2BX_PATHS[@]}"; do
            if [[ -f "$path" ]] && [[ -x "$path" ]]; then
                V2BX_BIN="$path"
                V2BX_DIR="$(dirname "$path")"
                print_success "V2bX 安装成功: $V2BX_BIN"
                return 0
            fi
        done
        
        print_error "V2bX 安装失败或未找到可执行文件"
        exit 1
    else
        print_error "需要先安装 V2bX"
        echo ""
        echo "请手动运行官方安装脚本:"
        echo "  wget -N https://raw.githubusercontent.com/wyx2685/V2bX-script/master/install.sh && bash install.sh"
        echo ""
        exit 1
    fi
}

# 下载 V2bX
download_v2bx() {
    print_info "下载 V2bX..."
    
    INSTALL_DIR="/opt/V2bX-Nodemix"
    mkdir -p "$INSTALL_DIR/bin"
    cd "$INSTALL_DIR/bin"
    
    # 检测架构
    ARCH=$(uname -m)
    case $ARCH in
        x86_64)
            DOWNLOAD_ARCH="amd64"
            ;;
        aarch64)
            DOWNLOAD_ARCH="arm64"
            ;;
        armv7l)
            DOWNLOAD_ARCH="armv7"
            ;;
        *)
            print_error "不支持的架构: $ARCH"
            exit 1
            ;;
    esac
    
    DOWNLOAD_URL="https://github.com/wyx2685/V2bX/releases/latest/download/V2bX-linux-${DOWNLOAD_ARCH}.zip"
    
    wget -q --show-progress "$DOWNLOAD_URL" -O V2bX.zip
    unzip -q -o V2bX.zip
    chmod +x V2bX
    rm V2bX.zip
    
    V2BX_BIN="$INSTALL_DIR/bin/V2bX"
    V2BX_DIR="$INSTALL_DIR/bin"
    
    print_success "V2bX 下载完成: $V2BX_BIN"
}

# 安装 V2bX-Nodemix
install_nodemix() {
    print_info "安装 V2bX-Nodemix 管理系统..."
    
    # 确定安装目录
    if [ -z "$INSTALL_DIR" ]; then
        INSTALL_DIR="/opt/V2bX-Nodemix"
    fi
    
    mkdir -p "$INSTALL_DIR"
    
    # 下载项目文件
    print_info "从 GitHub 下载项目文件..."
    cd /tmp
    rm -rf V2bX-Nodemix-main V2bX-Nodemix.zip 2>/dev/null
    
    if wget -q --show-progress "https://github.com/Cd1s/V2bX-Nodemix/archive/refs/heads/main.zip" -O V2bX-Nodemix.zip; then
        unzip -q -o V2bX-Nodemix.zip
        cp -r V2bX-Nodemix-main/* "$INSTALL_DIR/"
        rm -rf V2bX-Nodemix-main V2bX-Nodemix.zip
        print_success "项目文件下载完成"
    else
        print_error "无法从 GitHub 下载项目文件"
        print_info "请检查网络连接或手动克隆: git clone https://github.com/Cd1s/V2bX-Nodemix.git $INSTALL_DIR"
        exit 1
    fi
    
    cd "$INSTALL_DIR"
    
    # 创建必要的目录
    mkdir -p "$INSTALL_DIR/configs/template"
    mkdir -p "$INSTALL_DIR/instances"
    mkdir -p "$INSTALL_DIR/logs"
    
    # 设置权限
    chmod +x "$INSTALL_DIR/v2bx-manager.sh" 2>/dev/null || true
    chmod +x "$INSTALL_DIR/web/start-web.sh" 2>/dev/null || true
    chmod +x "$INSTALL_DIR/update.sh" 2>/dev/null || true
    
    # 更新管理脚本中的 V2bX 路径
    if [ -n "$V2BX_BIN" ]; then
        sed -i "s|V2BX_BIN=.*|V2BX_BIN=\"$V2BX_BIN\"|" "$INSTALL_DIR/v2bx-manager.sh" 2>/dev/null || true
    fi

    # 如果系统中已经存在 V2bX 二进制，创建 bin 目录并建立符号链接，
    # 以便旧的管理逻辑可以在 $INSTALL_DIR/bin/V2bX 找到可执行文件
    if [ -n "$V2BX_BIN" ]; then
        mkdir -p "$INSTALL_DIR/bin"
        if [ -f "$V2BX_BIN" ]; then
            ln -sf "$V2BX_BIN" "$INSTALL_DIR/bin/V2bX" 2>/dev/null || cp -a "$V2BX_BIN" "$INSTALL_DIR/bin/V2bX" 2>/dev/null || true
            chmod +x "$INSTALL_DIR/bin/V2bX" 2>/dev/null || true
            print_info "已为 V2bX 创建符号链接: $INSTALL_DIR/bin/V2bX -> $V2BX_BIN"
        fi
    fi
    
    print_success "V2bX-Nodemix 安装完成"
}

# 创建示例配置
create_example_config() {
    print_info "创建示例配置..."
    
    EXAMPLE_DIR="$INSTALL_DIR/configs/example"
    mkdir -p "$EXAMPLE_DIR"
    
    # 直接复制模板文件，不做任何修改
    if [ -f "$INSTALL_DIR/configs/template/config.json" ]; then
        cp "$INSTALL_DIR/configs/template/config.json" "$EXAMPLE_DIR/config.json"
        print_success "已创建 config.json (请手动编辑面板信息)"
    else
        print_error "模板文件不存在: $INSTALL_DIR/configs/template/config.json"
    fi
    
    if [ -f "$INSTALL_DIR/configs/template/sing_origin.json" ]; then
        cp "$INSTALL_DIR/configs/template/sing_origin.json" "$EXAMPLE_DIR/sing_origin.json"
        print_success "已创建 sing_origin.json (请手动配置 WireGuard)"
    else
        print_error "模板文件不存在: $INSTALL_DIR/configs/template/sing_origin.json"
    fi
    
    # 更新 config.json 中的 OriginalPath 为正确路径
    if [ -f "$EXAMPLE_DIR/config.json" ]; then
        sed -i "s|\"OriginalPath\":.*|\"OriginalPath\": \"$INSTALL_DIR/configs/example/sing_origin.json\"|" "$EXAMPLE_DIR/config.json"
    fi
    
    echo ""
    print_warning "请手动编辑以下配置文件："
    echo "  1. $EXAMPLE_DIR/config.json"
    echo "     - 修改 ApiHost (面板地址)"
    echo "     - 修改 ApiKey (API密钥)"
    echo "     - 修改 NodeID (节点ID)"
    echo "     - 修改 NodeType (节点类型: shadowsocks/vmess/vless等)"
    echo ""
    echo "  2. $EXAMPLE_DIR/sing_origin.json"
    echo "     - 修改 WireGuard 配置 (server, private_key, peer_public_key 等)"
    echo ""
    
    print_success "示例配置已创建: $EXAMPLE_DIR"
}

# 创建系统服务
create_systemd_service() {
    print_info "创建系统服务..."
    
    # 检测 Python 路径
    PYTHON_BIN=$(which python3)
    
    # Web 管理服务
    cat > /etc/systemd/system/v2bx-nodemix-web.service <<EOF
[Unit]
Description=V2bX-Nodemix Web Management
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=$INSTALL_DIR/web
ExecStart=$PYTHON_BIN $INSTALL_DIR/web/app.py
Restart=on-failure
RestartSec=5s
Environment="PYTHONUNBUFFERED=1"

[Install]
WantedBy=multi-user.target
EOF
    
    # 实例自启服务
    cat > /etc/systemd/system/v2bx-nodemix-instances.service <<EOF
[Unit]
Description=V2bX-Nodemix Instances Auto-start
After=network.target v2bx-nodemix-web.service

[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=$INSTALL_DIR/v2bx-manager.sh start-all
ExecStop=$INSTALL_DIR/v2bx-manager.sh stop-all

[Install]
WantedBy=multi-user.target
EOF
    
    systemctl daemon-reload
    systemctl enable v2bx-nodemix-web.service
    systemctl enable v2bx-nodemix-instances.service
    
    print_success "系统服务已创建并设置开机自启"
}

# 创建命令行快捷方式
create_command_alias() {
    print_info "创建命令行快捷方式..."
    
    # 创建符号链接到交互式管理脚本
    ln -sf "$INSTALL_DIR/v2bx-nodemix.sh" /usr/local/bin/v2bx-nodemix
    chmod +x "$INSTALL_DIR/v2bx-nodemix.sh"
    chmod +x "$INSTALL_DIR/v2bx-manager.sh"
    
    print_success "现在可以使用 'v2bx-nodemix' 命令进入管理控制台"
}

# 显示安装总结
show_summary() {
    echo ""
    echo "=========================================="
    print_success "V2bX-Nodemix 安装完成！"
    echo "=========================================="
    echo ""
    echo "📁 安装目录: $INSTALL_DIR"
    echo "🔧 V2bX 路径: $V2BX_BIN"
    echo "📝 配置目录: $INSTALL_DIR/configs"
    echo "📋 示例配置: $INSTALL_DIR/configs/example"
    echo ""
    echo "🎮 管理命令:"
    echo "  v2bx-nodemix                     # 进入交互式管理控制台 ⭐"
    echo "  v2bx-nodemix status              # 查看实例状态"
    echo "  v2bx-nodemix start <实例>        # 启动实例"
    echo ""
    echo "🌐 Web 管理界面:"
    echo "  访问: http://$(hostname -I | awk '{print $1}'):5000"
    echo "  默认密码: admin123"
    echo "  状态: systemctl status v2bx-nodemix-web"
    echo ""
    echo "⚙️  配置步骤:"
    echo "  1. 编辑面板配置: vi $INSTALL_DIR/configs/example/config.json"
    echo "     - 修改 ApiHost、ApiKey、NodeID"
    echo ""
    echo "  2. 配置 WireGuard (可选):"
    echo "     - 生成密钥: V2bX x25519"
    echo "     - 编辑配置: vi $INSTALL_DIR/configs/example/sing_origin.json"
    echo "     - 详细说明: cat $INSTALL_DIR/WIREGUARD.md"
    echo ""
    echo "  3. 启动实例: v2bx-nodemix start example"
    echo ""
    print_warning "重要: 必须先编辑配置文件,替换 ApiHost/ApiKey 和 WireGuard 密钥!"
    echo ""
    print_info "✅ 已设置开机自启:"
    echo "  - Web 管理界面: v2bx-nodemix-web.service"
    echo "  - 所有实例: v2bx-nodemix-instances.service"
    echo ""
    print_info "详细文档: $INSTALL_DIR/README.md"
    print_info "WireGuard 配置: $INSTALL_DIR/WIREGUARD.md"
    echo "=========================================="
}

# 主安装流程
main() {
    echo ""
    echo "=========================================="
    echo "   V2bX-Nodemix 一键安装脚本"
    echo "   多实例管理 + WireGuard 出站"
    echo "=========================================="
    echo ""
    
    check_root
    detect_system
    install_dependencies
    detect_v2bx
    install_nodemix
    create_example_config
    create_systemd_service
    create_command_alias
    
    # 默认启动 Web 管理界面
    print_info "启动服务..."
    systemctl start v2bx-nodemix-web
    
    show_summary
    
    echo ""
    print_success "安装完成！Web 管理界面已启动"
    print_info "实例将在系统重启后自动启动（需先配置实例）"
}

# 运行主函数
main
