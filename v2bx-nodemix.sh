#!/bin/bash

#==============================================================================
# V2bX-Nodemix 交互式管理界面 v3.0  
# 统一管理所有功能：实例、密码、日志、配置、卸载、升级
#==============================================================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'
BOLD='\033[1m'

BASE_DIR="/opt/V2bX-Nodemix"
CONFIGS_DIR="${BASE_DIR}/configs"
INSTANCES_DIR="${BASE_DIR}/instances"
PASSWORD_FILE="${BASE_DIR}/.password"

# 检测 V2bX 二进制
detect_v2bx_binary() {
    local paths=(
        "${BASE_DIR}/bin/V2bX"
        "/usr/local/V2bX/V2bX"
        "/opt/V2bX/V2bX"
        "/usr/bin/V2bX"
        "$(which V2bX 2>/dev/null)"
    )
    
    for path in "${paths[@]}"; do
        if [[ -f "$path" ]] && [[ -x "$path" ]]; then
            echo "$path"
            return 0
        fi
    done
    return 1
}

BINARY_PATH=$(detect_v2bx_binary)

log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }
log_success() { echo -e "${GREEN}[✓]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[!]${NC} $1"; }

# 获取所有实例
get_instances() {
    [[ ! -d "$CONFIGS_DIR" ]] && return
    find "$CONFIGS_DIR" -maxdepth 1 -type d ! -name "configs" ! -name "template" -exec basename {} \;
}

# 获取实例 PID
get_pid() {
    local name=$1
    local pid_file="$INSTANCES_DIR/$name/pid"
    [[ -f "$pid_file" ]] && cat "$pid_file" || echo ""
}

# 检查实例是否运行
is_running() {
    local pid=$(get_pid $1)
    [[ -n "$pid" ]] && ps -p "$pid" > /dev/null 2>&1
}

# 显示主菜单
show_main_menu() {
    clear
    echo -e "${BOLD}${CYAN}╔════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BOLD}${CYAN}║                                                        ║${NC}"
    echo -e "${BOLD}${CYAN}║          🚀 V2bX-Nodemix 管理控制台 v3.0              ║${NC}"
    echo -e "${BOLD}${CYAN}║                                                        ║${NC}"
    echo -e "${BOLD}${CYAN}╚════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${BOLD}${GREEN}实例管理:${NC}"
    echo "  1) 📊 查看所有实例状态"
    echo "  2) ▶️  启动实例"
    echo "  3) ⏹️  停止实例"
    echo "  4) 🔄 重启实例"
    echo "  5) 📋 查看实例日志"
    echo "  6) 📁 打开配置目录"
    echo "  7) 🗑️  删除实例"
    echo ""
    echo -e "${BOLD}${YELLOW}批量操作:${NC}"
    echo "  8) ▶️  启动所有实例"
    echo "  9) ⏹️  停止所有实例"
    echo "  10) 🔄 重启所有实例"
    echo ""
    echo -e "${BOLD}${CYAN}自启管理:${NC}"
    echo "  11) ✅ 开启开机自启"
    echo "  12) ❌ 关闭开机自启"
    echo "  13) 📋 查看自启状态"
    echo ""
    echo -e "${BOLD}${BLUE}系统管理:${NC}"
    echo "  14) 🔐 修改 Web 密码"
    echo "  15) 🌐 Web 服务管理"
    echo "  16) 🔄 升级 V2bX-Nodemix"
    echo "  17) 🗑️  卸载 V2bX-Nodemix"
    echo ""
    echo "  0) ❌ 退出"
    echo ""
    echo -e "${CYAN}════════════════════════════════════════════════════════${NC}"
    read -p "请选择操作 [0-17]: " menu_choice
    echo "$menu_choice"
}

# 显示实例状态
show_instances_status() {
    clear
    echo -e "${BOLD}${GREEN}=== 实例状态 ===${NC}\n"
    
    local instances=$(get_instances)
    if [[ -z "$instances" ]]; then
        echo "暂无实例"
        return
    fi
    
    printf "%-20s %-10s %-10s %-30s\n" "实例名" "状态" "PID" "配置目录"
    echo "────────────────────────────────────────────────────────────────────"
    
    for name in $instances; do
        local pid=$(get_pid "$name")
        local status="已停止"
        local status_color="${RED}"
        
        if [[ -n "$pid" ]] && ps -p "$pid" > /dev/null 2>&1; then
            status="运行中"
            status_color="${GREEN}"
            printf "%-20s ${status_color}%-10s${NC} %-10s %-30s\n" "$name" "$status" "$pid" "$CONFIGS_DIR/$name"
        else
            printf "%-20s ${status_color}%-10s${NC} %-10s %-30s\n" "$name" "$status" "-" "$CONFIGS_DIR/$name"
        fi
    done
    
    echo ""
}

# 启动实例
start_instance() {
    local name=$1
    
    if [[ ! -d "$CONFIGS_DIR/$name" ]]; then
        log_error "实例配置不存在: $CONFIGS_DIR/$name"
        return 1
    fi
    
    if is_running "$name"; then
        log_info "实例 $name 已在运行 (PID: $(get_pid $name))"
        return 0
    fi
    
    local instance_dir="$INSTANCES_DIR/$name"
    mkdir -p "$instance_dir/logs"
    
    if [[ -z "$BINARY_PATH" ]]; then
        log_error "未找到 V2bX 二进制文件"
        return 1
    fi
    
    if [[ ! -f "$instance_dir/V2bX" ]]; then
        cp "$BINARY_PATH" "$instance_dir/V2bX" && chmod +x "$instance_dir/V2bX"
    fi
    
    cd "$instance_dir"
    nohup ./V2bX server -c "$CONFIGS_DIR/$name/config.json" > logs/output.log 2>&1 &
    echo $! > pid
    
    sleep 2
    if is_running "$name"; then
        log_success "实例 $name 启动成功 (PID: $(get_pid $name))"
    else
        log_error "实例 $name 启动失败"
        log_info "查看日志: tail -f $instance_dir/logs/output.log"
        return 1
    fi
}

# 停止实例
stop_instance() {
    local name=$1
    local pid=$(get_pid "$name")
    
    if [[ -z "$pid" ]]; then
        log_info "实例 $name 未运行"
        return 0
    fi
    
    log_info "停止实例: $name"
    kill "$pid" 2>/dev/null
    sleep 2
    [[ -f "$INSTANCES_DIR/$name/pid" ]] && rm "$INSTANCES_DIR/$name/pid"
    log_success "实例 $name 已停止"
}

# 查看日志
view_logs() {
    local name=$1
    local log_file="$INSTANCES_DIR/$name/logs/output.log"
    
    if [[ ! -f "$log_file" ]]; then
        log_error "日志文件不存在: $log_file"
        return 1
    fi
    
    clear
    echo -e "${BOLD}${GREEN}=== 实例日志: $name (最近100行) ===${NC}\n"
    tail -n 100 "$log_file"
    echo -e "\n${CYAN}────────────────────────────────────────────────────────${NC}"
    echo "完整日志: $log_file"
}

# 删除实例
delete_instance() {
    local name=$1
    
    echo -e "${YELLOW}警告: 此操作将删除实例 '$name' 的所有配置和数据！${NC}"
    read -p "确认删除? (yes/no): " confirm
    
    if [[ "$confirm" != "yes" ]]; then
        log_info "取消删除"
        return 0
    fi
    
    # 先停止实例
    stop_instance "$name"
    
    # 删除配置目录
    if [[ -d "$CONFIGS_DIR/$name" ]]; then
        rm -rf "$CONFIGS_DIR/$name"
        log_success "已删除配置: $CONFIGS_DIR/$name"
    fi
    
    # 删除运行时目录
    if [[ -d "$INSTANCES_DIR/$name" ]]; then
        rm -rf "$INSTANCES_DIR/$name"
        log_success "已删除运行时数据: $INSTANCES_DIR/$name"
    fi
    
    log_success "实例 $name 已完全删除"
}

# 修改 Web 密码
change_web_password() {
    clear
    echo -e "${BOLD}${GREEN}=== 修改 Web 管理密码 ===${NC}\n"
    
    read -sp "请输入新密码 (至少6位): " password
    echo ""
    
    if [[ ${#password} -lt 6 ]]; then
        log_error "密码长度至少6位"
        return 1
    fi
    
    read -sp "再次确认密码: " password2
    echo ""
    
    if [[ "$password" != "$password2" ]]; then
        log_error "两次密码不一致"
        return 1
    fi
    
    # 生成 SHA256 哈希
    local hash=$(echo -n "$password" | sha256sum | cut -d' ' -f1)
    echo "$hash" > "$PASSWORD_FILE"
    
    log_success "密码已更新"
    log_info "重启 Web 服务以生效..."
    
    if systemctl is-active --quiet v2bx-nodemix-web; then
        systemctl restart v2bx-nodemix-web
        log_success "Web 服务已重启"
    else
        log_warning "Web 服务未运行,请手动启动: systemctl start v2bx-nodemix-web"
    fi
}

# Web 服务管理
manage_web_service() {
    clear
    echo -e "${BOLD}${GREEN}=== Web 服务管理 ===${NC}\n"
    
    echo "1) 查看状态"
    echo "2) 启动服务"
    echo "3) 停止服务"
    echo "4) 重启服务"
    echo "0) 返回"
    echo ""
    read -p "选择操作: " choice
    
    case $choice in
        1)
            systemctl status v2bx-nodemix-web
            ;;
        2)
            systemctl start v2bx-nodemix-web
            log_success "Web 服务已启动"
            log_info "访问: http://$(hostname -I | awk '{print $1}'):5000"
            ;;
        3)
            systemctl stop v2bx-nodemix-web
            log_success "Web 服务已停止"
            ;;
        4)
            systemctl restart v2bx-nodemix-web
            log_success "Web 服务已重启"
            ;;
    esac
}

# 升级系统
upgrade_system() {
    clear
    echo -e "${BOLD}${GREEN}=== 升级 V2bX-Nodemix ===${NC}\n"
    
    # 检查并安装依赖
    log_info "检查升级所需依赖..."
    local missing_deps=()
    
    command -v wget &>/dev/null || missing_deps+=("wget")
    command -v unzip &>/dev/null || missing_deps+=("unzip")
    command -v rsync &>/dev/null || missing_deps+=("rsync")
    
    if [[ ${#missing_deps[@]} -gt 0 ]]; then
        log_warning "缺少依赖: ${missing_deps[*]}"
        read -p "是否自动安装? (y/n): " install_deps
        
        if [[ "$install_deps" == "y" ]]; then
            log_info "安装依赖..."
            if command -v apt &>/dev/null; then
                apt update -qq && apt install -y "${missing_deps[@]}"
            elif command -v yum &>/dev/null; then
                yum install -y "${missing_deps[@]}"
            else
                log_error "无法自动安装，请手动安装: ${missing_deps[*]}"
                return 1
            fi
        else
            log_error "缺少必要依赖，无法升级"
            return 1
        fi
    fi
    
    log_info "从 GitHub 下载最新代码..."
    
    # 备份当前配置
    if [[ -d "$BASE_DIR/configs" ]]; then
        log_info "备份当前配置..."
        BACKUP_DIR="$BASE_DIR/configs.backup.$(date +%Y%m%d_%H%M%S)"
        cp -r "$BASE_DIR/configs" "$BACKUP_DIR"
        log_success "配置已备份到: $BACKUP_DIR"
    fi
    
    # 备份密码文件
    if [[ -f "$PASSWORD_FILE" ]]; then
        cp "$PASSWORD_FILE" "/tmp/.v2bx-password.bak"
    fi
    
    # 下载最新版本
    cd /tmp
    rm -rf V2bX-Nodemix-main V2bX-Nodemix.zip 2>/dev/null
    
    log_info "下载最新版本..."
    if wget -q --show-progress "https://github.com/Cd1s/V2bX-Nodemix/archive/refs/heads/main.zip" -O V2bX-Nodemix.zip; then
        log_success "下载完成"
        
        log_info "解压并更新文件..."
        unzip -q -o V2bX-Nodemix.zip
        
        # 保留配置目录和密码文件，更新其他文件
        rsync -av --exclude='configs' --exclude='.password' V2bX-Nodemix-main/ "$BASE_DIR/"
        
        # 恢复密码文件
        if [[ -f "/tmp/.v2bx-password.bak" ]]; then
            mv "/tmp/.v2bx-password.bak" "$PASSWORD_FILE"
        fi
        
        # 设置权限
        chmod +x "$BASE_DIR/v2bx-nodemix.sh"
        chmod +x "$BASE_DIR/v2bx-manager.sh"
        chmod +x "$BASE_DIR/install.sh"
        chmod +x "$BASE_DIR/update.sh"
        chmod +x "$BASE_DIR/web/start-web.sh"
        
        # 重新创建符号链接
        ln -sf "$BASE_DIR/v2bx-nodemix.sh" /usr/local/bin/v2bx-nodemix
        
        # 清理临时文件
        rm -rf V2bX-Nodemix-main V2bX-Nodemix.zip
        
        log_success "文件已更新"
        
        # 重启 Web 服务
        if systemctl is-active --quiet v2bx-nodemix-web; then
            log_info "重启 Web 服务..."
            systemctl restart v2bx-nodemix-web
            log_success "Web 服务已重启"
        fi
        
        echo ""
        log_success "升级完成！"
        echo ""
        echo "已保留:"
        echo "  ✓ 所有配置文件 (configs/)"
        echo "  ✓ Web 管理密码"
        echo ""
        echo "已更新:"
        echo "  ✓ 管理脚本"
        echo "  ✓ Web 界面"
        echo "  ✓ 文档"
        echo ""
        
        if [[ -d "$BACKUP_DIR" ]]; then
            echo "配置备份: $BACKUP_DIR"
            echo "如无问题可删除: rm -rf $BACKUP_DIR"
        fi
    else
        log_error "下载失败,请检查网络连接"
        log_info "手动升级方法:"
        echo "  1. cd /tmp"
        echo "  2. wget https://github.com/Cd1s/V2bX-Nodemix/archive/refs/heads/main.zip"
        echo "  3. unzip main.zip"
        echo "  4. rsync -av --exclude='configs' V2bX-Nodemix-main/ $BASE_DIR/"
        return 1
    fi
}

# 卸载系统
uninstall_system() {
    clear
    echo -e "${BOLD}${RED}=== 卸载 V2bX-Nodemix ===${NC}\n"
    
    echo -e "${YELLOW}警告: 此操作将删除以下内容:${NC}"
    echo "  - 所有实例和配置文件"
    echo "  - 运行时数据和日志"
    echo "  - Web 管理服务"
    echo "  - 命令行工具"
    echo "  - 安装目录: $BASE_DIR"
    echo ""
    echo -e "${RED}此操作不可恢复！${NC}"
    echo ""
    read -p "确定要卸载吗? 输入 'yes' 确认: " confirm
    
    if [[ "$confirm" != "yes" ]]; then
        log_info "取消卸载"
        return 0
    fi
    
    log_info "停止所有实例..."
    for name in $(get_instances); do
        stop_instance "$name"
    done
    
    log_info "停止 Web 服务..."
    systemctl stop v2bx-nodemix-web 2>/dev/null
    systemctl disable v2bx-nodemix-web 2>/dev/null
    rm -f /etc/systemd/system/v2bx-nodemix-web.service
    
    log_info "停止实例自启服务..."
    systemctl stop v2bx-nodemix-instances 2>/dev/null
    systemctl disable v2bx-nodemix-instances 2>/dev/null
    rm -f /etc/systemd/system/v2bx-nodemix-instances.service
    
    systemctl daemon-reload
    
    log_info "删除命令行工具..."
    rm -f /usr/local/bin/v2bx-nodemix
    
    log_info "删除安装目录..."
    rm -rf "$BASE_DIR"
    
    log_success "V2bX-Nodemix 已完全卸载"
    echo ""
    echo "V2bX 主程序未被删除,如需删除请运行:"
    echo "  rm -rf /usr/local/V2bX"
    echo ""
    echo "感谢使用 V2bX-Nodemix!"
    exit 0
}

# 选择实例
select_instance() {
    local instances=$(get_instances)
    
    if [[ -z "$instances" ]]; then
        log_error "暂无实例"
        return 1
    fi
    
    echo -e "\n${BOLD}可用实例:${NC}"
    local i=1
    local instance_array=()
    
    for name in $instances; do
        instance_array+=("$name")
        local status="停止"
        local color="${RED}"
        if is_running "$name"; then
            status="运行中"
            color="${GREEN}"
        fi
        echo -e "  ${CYAN}$i.${NC} $name ${color}[$status]${NC}"
        ((i++))
    done
    
    echo ""
    read -p "选择实例编号 [1-${#instance_array[@]}]: " choice
    
    if [[ "$choice" =~ ^[0-9]+$ ]] && [[ $choice -ge 1 ]] && [[ $choice -le ${#instance_array[@]} ]]; then
        echo "${instance_array[$((choice-1))]}"
        return 0
    else
        log_error "无效选择"
        return 1
    fi
}

# 启动所有实例
start_all_instances() {
    local instances=$(get_instances)
    
    if [[ -z "$instances" ]]; then
        log_error "暂无实例"
        return 1
    fi
    
    log_info "启动所有实例..."
    echo ""
    
    local success=0
    local failed=0
    
    for name in $instances; do
        if start_instance "$name"; then
            ((success++))
        else
            ((failed++))
        fi
    done
    
    echo ""
    echo -e "${BOLD}启动结果:${NC}"
    echo "  ✓ 成功: $success"
    [[ $failed -gt 0 ]] && echo "  ✗ 失败: $failed"
}

# 停止所有实例
stop_all_instances() {
    local instances=$(get_instances)
    
    if [[ -z "$instances" ]]; then
        log_error "暂无实例"
        return 1
    fi
    
    log_info "停止所有实例..."
    echo ""
    
    for name in $instances; do
        stop_instance "$name"
    done
    
    log_success "所有实例已停止"
}

# 重启所有实例
restart_all_instances() {
    log_info "重启所有实例..."
    stop_all_instances
    sleep 2
    start_all_instances
}

# 启用开机自启
enable_autostart() {
    clear
    echo -e "${BOLD}${GREEN}=== 启用开机自启 ===${NC}\n"
    
    local service_file="/etc/systemd/system/v2bx-nodemix-instances.service"
    
    if [[ ! -f "$service_file" ]]; then
        log_info "创建自启服务..."
        
        cat > "$service_file" <<EOF
[Unit]
Description=V2bX-Nodemix Auto-start Instances
After=network.target

[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=${BASE_DIR}/v2bx-manager.sh start-all
ExecStop=${BASE_DIR}/v2bx-manager.sh stop-all

[Install]
WantedBy=multi-user.target
EOF
        
        systemctl daemon-reload
        log_success "服务文件已创建"
    fi
    
    systemctl enable v2bx-nodemix-instances
    log_success "已启用开机自启"
    
    read -p "是否立即启动所有实例? (y/n): " start_now
    if [[ "$start_now" == "y" ]]; then
        systemctl start v2bx-nodemix-instances
        log_success "所有实例已启动"
    fi
}

# 禁用开机自启
disable_autostart() {
    clear
    echo -e "${BOLD}${YELLOW}=== 关闭开机自启 ===${NC}\n"
    
    systemctl disable v2bx-nodemix-instances 2>/dev/null
    log_success "已关闭开机自启"
    
    read -p "是否停止所有实例? (y/n): " stop_now
    if [[ "$stop_now" == "y" ]]; then
        systemctl stop v2bx-nodemix-instances
        log_success "所有实例已停止"
    fi
}

# 查看自启状态
check_autostart_status() {
    clear
    echo -e "${BOLD}${GREEN}=== 开机自启状态 ===${NC}\n"
    
    if systemctl is-enabled --quiet v2bx-nodemix-instances 2>/dev/null; then
        echo -e "状态: ${GREEN}已启用${NC}"
    else
        echo -e "状态: ${RED}未启用${NC}"
    fi
    
    echo ""
    echo -e "${BOLD}服务详情:${NC}"
    systemctl status v2bx-nodemix-instances --no-pager 2>/dev/null || echo "服务未安装"
}

# 主循环
main() {
    # 非交互模式处理（命令行参数）
    if [[ $# -gt 0 ]]; then
        case "$1" in
            start|stop|restart|logs|status|start-all|stop-all)
                # 调用原有的 v2bx-manager.sh 处理命令行操作
                exec "${BASE_DIR}/v2bx-manager.sh" "$@"
                ;;
            *)
                echo "用法: v2bx-nodemix [命令] [参数]"
                echo ""
                echo "命令:"
                echo "  start <实例>    启动实例"
                echo "  stop <实例>     停止实例"  
                echo "  restart <实例>  重启实例"
                echo "  logs <实例>     查看日志"
                echo "  status          查看状态"
                echo ""
                echo "或直接运行 'v2bx-nodemix' 进入交互式管理界面"
                exit 1
                ;;
        esac
    fi
    
    # 交互模式主循环
    while true; do
        choice=$(show_main_menu)
        
        case $choice in
            1)
                show_instances_status
                read -p "按回车继续..."
                ;;
            2)
                instance=$(select_instance)
                if [[ -n "$instance" ]]; then
                    start_instance "$instance"
                    read -p "按回车继续..."
                fi
                ;;
            3)
                instance=$(select_instance)
                if [[ -n "$instance" ]]; then
                    stop_instance "$instance"
                    read -p "按回车继续..."
                fi
                ;;
            4)
                instance=$(select_instance)
                if [[ -n "$instance" ]]; then
                    stop_instance "$instance"
                    sleep 1
                    start_instance "$instance"
                    read -p "按回车继续..."
                fi
                ;;
            5)
                instance=$(select_instance)
                if [[ -n "$instance" ]]; then
                    view_logs "$instance"
                    read -p "按回车继续..."
                fi
                ;;
            6)
                instance=$(select_instance)
                if [[ -n "$instance" ]]; then
                    echo ""
                    log_info "配置目录: $CONFIGS_DIR/$instance"
                    echo "  - config.json: V2bX 配置"
                    echo "  - sing_origin.json: sing-box 配置"
                    echo ""
                    read -p "是否编辑 config.json? (y/n): " edit
                    if [[ "$edit" == "y" ]]; then
                        ${EDITOR:-vi} "$CONFIGS_DIR/$instance/config.json"
                    fi
                fi
                ;;
            7)
                instance=$(select_instance)
                if [[ -n "$instance" ]]; then
                    delete_instance "$instance"
                    read -p "按回车继续..."
                fi
                ;;
            8)
                start_all_instances
                read -p "按回车继续..."
                ;;
            9)
                stop_all_instances
                read -p "按回车继续..."
                ;;
            10)
                restart_all_instances
                read -p "按回车继续..."
                ;;
            11)
                enable_autostart
                read -p "按回车继续..."
                ;;
            12)
                disable_autostart
                read -p "按回车继续..."
                ;;
            13)
                check_autostart_status
                read -p "按回车继续..."
                ;;
            14)
                change_web_password
                read -p "按回车继续..."
                ;;
            15)
                manage_web_service
                read -p "按回车继续..."
                ;;
            16)
                upgrade_system
                read -p "按回车继续..."
                ;;
            17)
                uninstall_system
                ;;
            0)
                echo ""
                log_info "退出管理控制台"
                exit 0
                ;;
            *)
                log_error "无效选择"
                sleep 1
                ;;
        esac
    done
}

# 检查是否为 root (某些操作需要)
if [[ $EUID -ne 0 ]] && [[ $# -eq 0 ]]; then
    log_warning "某些功能需要 root 权限"
    log_info "建议使用: sudo v2bx-nodemix"
    echo ""
    read -p "继续? (y/n): " continue
    [[ "$continue" != "y" ]] && exit 0
fi

main "$@"
