#!/bin/bash

#==============================================================================
# V2bX-Nodemix 管理脚本 v2.0  
# 管理多个 V2bX 实例(不需要系统 WireGuard 接口)
#==============================================================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# 固定使用安装目录，避免符号链接导致的路径问题
BASE_DIR="/opt/V2bX-Nodemix"
CONFIGS_DIR="${BASE_DIR}/configs"
INSTANCES_DIR="${BASE_DIR}/instances"

# 自动检测 V2bX 二进制文件位置
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
if [[ -z "$BINARY_PATH" ]]; then
    log_error "未找到 V2bX 二进制文件，请先安装 V2bX"
    exit 1
fi

log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }
log_success() { echo -e "${GREEN}[✓]${NC} $1"; }

get_instances() {
    [[ ! -d "$CONFIGS_DIR" ]] && return
    find "$CONFIGS_DIR" -maxdepth 1 -type d ! -name "configs" ! -name "template" -exec basename {} \;
}

get_pid() {
    local name=$1
    local pid_file="$INSTANCES_DIR/$name/pid"
    [[ -f "$pid_file" ]] && cat "$pid_file" || echo ""
}

is_running() {
    local pid=$(get_pid $1)
    [[ -n "$pid" ]] && ps -p "$pid" > /dev/null 2>&1
}

start_instance() {
    local name=$1
    
    # 检查配置是否存在
    if [[ ! -d "$CONFIGS_DIR/$name" ]]; then
        log_error "实例配置不存在: $CONFIGS_DIR/$name"
        return 1
    fi
    
    if [[ ! -f "$CONFIGS_DIR/$name/config.json" ]]; then
        log_error "配置文件不存在: $CONFIGS_DIR/$name/config.json"
        return 1
    fi
    
    if is_running "$name"; then
        log_info "实例 $name 已在运行"
        return 0
    fi
    
    # 检查 V2bX 二进制
    if [[ ! -f "$BINARY_PATH" ]]; then
        log_error "V2bX 二进制文件不存在: $BINARY_PATH"
        return 1
    fi
    
    local instance_dir="$INSTANCES_DIR/$name"
    mkdir -p "$instance_dir/logs"
    
    # 创建或更新实例目录中的 V2bX 副本/链接
    if [[ ! -f "$instance_dir/V2bX" ]]; then
        log_info "复制 V2bX 到实例目录..."
        cp "$BINARY_PATH" "$instance_dir/V2bX" && chmod +x "$instance_dir/V2bX"
        if [[ $? -ne 0 ]]; then
            log_error "无法复制 V2bX 二进制文件"
            return 1
        fi
    fi
    
    log_info "启动实例: $name"
    log_info "使用配置: $CONFIGS_DIR/$name/config.json"
    log_info "使用二进制: $BINARY_PATH"
    
    cd "$instance_dir"
    nohup ./V2bX server -c "$CONFIGS_DIR/$name/config.json" > logs/output.log 2>&1 &
    echo $! > pid
    
    sleep 2
    if is_running "$name"; then
        log_success "实例 $name 启动成功 (PID: $(get_pid $name))"
    else
        log_error "实例 $name 启动失败,查看日志: tail $instance_dir/logs/output.log"
        return 1
    fi
}

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

show_status() {
    echo -e "\n${GREEN}=== V2bX 实例状态 ===${NC}\n"
    
    local instances=$(get_instances)
    [[ -z "$instances" ]] && { echo "未找到任何实例"; return; }
    
    for name in $instances; do
        local pid=$(get_pid "$name")
        if [[ -n "$pid" ]] && ps -p "$pid" > /dev/null 2>&1; then
            echo -e "  ${GREEN}●${NC} $name (PID: $pid)"
        else
            echo -e "  ${RED}●${NC} $name (已停止)"
        fi
    done
    echo ""
}

show_logs() {
    local name=$1
    local lines=${2:-50}
    tail -n "$lines" "$INSTANCES_DIR/$name/logs/output.log"
}

case "$1" in
    start)
        [[ -z "$2" ]] && { log_error "请指定实例名"; exit 1; }
        start_instance "$2"
        ;;
    stop)
        [[ -z "$2" ]] && { log_error "请指定实例名"; exit 1; }
        stop_instance "$2"
        ;;
    restart)
        [[ -z "$2" ]] && { log_error "请指定实例名"; exit 1; }
        stop_instance "$2"
        sleep 1
        start_instance "$2"
        ;;
    status)
        show_status
        ;;
    logs)
        [[ -z "$2" ]] && { log_error "请指定实例名"; exit 1; }
        show_logs "$2" "$3"
        ;;
    start-all)
        for name in $(get_instances); do
            start_instance "$name"
        done
        ;;
    stop-all)
        for name in $(get_instances); do
            stop_instance "$name"
        done
        ;;
    *)
        cat << EOF

V2bX-Nodemix 管理脚本

用法:
    $0 start <实例名>     # 启动实例
    $0 stop <实例名>      # 停止实例  
    $0 restart <实例名>   # 重启实例
    $0 status            # 查看状态
    $0 logs <实例名>     # 查看日志
    $0 start-all         # 启动所有
    $0 stop-all          # 停止所有

EOF
        show_status
        ;;
esac
