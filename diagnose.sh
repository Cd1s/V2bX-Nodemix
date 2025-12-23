#!/bin/bash

# V2bX-Nodemix 诊断脚本
# 帮助排查启动失败的问题

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  V2bX-Nodemix 诊断工具${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# 1. 检查安装目录
echo -e "${GREEN}[1] 检查安装目录${NC}"
if [ -d "/opt/V2bX-Nodemix" ]; then
    echo -e "  ${GREEN}✓${NC} /opt/V2bX-Nodemix 存在"
    ls -la /opt/V2bX-Nodemix/ | head -15
else
    echo -e "  ${RED}✗${NC} /opt/V2bX-Nodemix 不存在"
    echo -e "  ${YELLOW}建议: 运行安装脚本${NC}"
fi
echo ""

# 2. 检查 V2bX 二进制
echo -e "${GREEN}[2] 检查 V2bX 二进制文件${NC}"
V2BX_PATHS=(
    "/opt/V2bX-Nodemix/bin/V2bX"
    "/usr/local/V2bX/V2bX"
    "/opt/V2bX/V2bX"
    "/usr/bin/V2bX"
)

FOUND_V2BX=""
for path in "${V2BX_PATHS[@]}" "$(which V2bX 2>/dev/null)"; do
    if [ -f "$path" ] && [ -x "$path" ]; then
        echo -e "  ${GREEN}✓${NC} 找到: $path"
        FOUND_V2BX="$path"
        $path version 2>&1 | head -3
        break
    fi
done

if [ -z "$FOUND_V2BX" ]; then
    echo -e "  ${RED}✗${NC} 未找到 V2bX 可执行文件"
    echo -e "  ${YELLOW}建议: 先安装 V2bX${NC}"
    echo -e "  wget -N https://raw.githubusercontent.com/wyx2685/V2bX-script/master/install.sh && bash install.sh"
fi
echo ""

# 3. 检查配置目录
echo -e "${GREEN}[3] 检查配置目录${NC}"
if [ -d "/opt/V2bX-Nodemix/configs" ]; then
    echo -e "  ${GREEN}✓${NC} 配置目录存在"
    echo "  实例列表:"
    for dir in /opt/V2bX-Nodemix/configs/*/; do
        if [ -d "$dir" ]; then
            name=$(basename "$dir")
            if [ "$name" != "template" ]; then
                if [ -f "$dir/config.json" ]; then
                    echo -e "    ${GREEN}✓${NC} $name (有 config.json)"
                else
                    echo -e "    ${RED}✗${NC} $name (缺少 config.json)"
                fi
            fi
        fi
    done
else
    echo -e "  ${RED}✗${NC} 配置目录不存在"
fi
echo ""

# 4. 检查实例进程
echo -e "${GREEN}[4] 检查运行中的实例${NC}"
if [ -d "/opt/V2bX-Nodemix/instances" ]; then
    for pid_file in /opt/V2bX-Nodemix/instances/*/pid; do
        if [ -f "$pid_file" ]; then
            name=$(basename $(dirname "$pid_file"))
            pid=$(cat "$pid_file")
            if ps -p "$pid" > /dev/null 2>&1; then
                echo -e "  ${GREEN}✓${NC} $name 运行中 (PID: $pid)"
            else
                echo -e "  ${RED}✗${NC} $name PID 文件存在但进程已停止 (PID: $pid)"
            fi
        fi
    done
    
    # 检查是否有无 PID 文件的实例
    for dir in /opt/V2bX-Nodemix/configs/*/; do
        name=$(basename "$dir")
        if [ "$name" != "template" ] && [ ! -f "/opt/V2bX-Nodemix/instances/$name/pid" ]; then
            echo -e "  ${YELLOW}○${NC} $name 未启动"
        fi
    done
else
    echo -e "  ${YELLOW}!${NC} 实例目录不存在"
fi
echo ""

# 5. 检查配置文件有效性
echo -e "${GREEN}[5] 检查配置文件${NC}"
for config in /opt/V2bX-Nodemix/configs/*/config.json; do
    if [ -f "$config" ]; then
        name=$(basename $(dirname "$config"))
        echo "  检查: $name"
        
        # 检查 JSON 格式
        if python3 -c "import json; json.load(open('$config'))" 2>/dev/null; then
            echo -e "    ${GREEN}✓${NC} JSON 格式正确"
        else
            echo -e "    ${RED}✗${NC} JSON 格式错误"
            continue
        fi
        
        # 检查关键字段
        api_host=$(python3 -c "import json; print(json.load(open('$config'))['Nodes'][0]['ApiHost'])" 2>/dev/null)
        api_key=$(python3 -c "import json; print(json.load(open('$config'))['Nodes'][0]['ApiKey'])" 2>/dev/null)
        node_id=$(python3 -c "import json; print(json.load(open('$config'))['Nodes'][0]['NodeID'])" 2>/dev/null)
        
        if [ "$api_host" = "https://your-panel.com" ]; then
            echo -e "    ${YELLOW}!${NC} ApiHost 未修改 (仍为默认值)"
        else
            echo -e "    ${GREEN}✓${NC} ApiHost: $api_host"
        fi
        
        if [ "$api_key" = "your-api-key" ]; then
            echo -e "    ${YELLOW}!${NC} ApiKey 未修改 (仍为默认值)"
        else
            echo -e "    ${GREEN}✓${NC} ApiKey: ${api_key:0:10}..."
        fi
        
        echo -e "    ${BLUE}i${NC} NodeID: $node_id"
        
        # 检查 sing_origin.json
        original_path=$(python3 -c "import json; print(json.load(open('$config'))['Cores'][0]['OriginalPath'])" 2>/dev/null)
        if [ -f "$original_path" ]; then
            echo -e "    ${GREEN}✓${NC} sing_origin.json 存在: $original_path"
            
            # 检查 WireGuard 配置
            wg_key=$(python3 -c "import json; d=json.load(open('$original_path')); print([o['private_key'] for o in d['outbounds'] if o.get('type')=='wireguard'][0])" 2>/dev/null)
            if [ "$wg_key" = "REPLACE_WITH_YOUR_WG_PRIVATE_KEY" ]; then
                echo -e "    ${YELLOW}!${NC} WireGuard private_key 未修改"
            else
                echo -e "    ${GREEN}✓${NC} WireGuard 已配置"
            fi
        else
            echo -e "    ${RED}✗${NC} sing_origin.json 不存在: $original_path"
        fi
    fi
done
echo ""

# 6. 检查最近的日志
echo -e "${GREEN}[6] 检查最近的错误日志${NC}"
for log in /opt/V2bX-Nodemix/instances/*/logs/output.log; do
    if [ -f "$log" ]; then
        name=$(basename $(dirname $(dirname "$log")))
        echo "  $name 最后 5 行日志:"
        tail -5 "$log" 2>/dev/null | sed 's/^/    /'
        echo ""
    fi
done

# 7. 检查系统服务
echo -e "${GREEN}[7] 检查系统服务${NC}"
if systemctl list-unit-files | grep -q v2bx-nodemix-web; then
    echo -e "  ${GREEN}✓${NC} v2bx-nodemix-web.service 已安装"
    systemctl is-active v2bx-nodemix-web >/dev/null 2>&1 && \
        echo -e "    ${GREEN}●${NC} 运行中" || \
        echo -e "    ${RED}●${NC} 已停止"
else
    echo -e "  ${YELLOW}!${NC} v2bx-nodemix-web.service 未安装"
fi

if systemctl list-unit-files | grep -q v2bx-nodemix-instances; then
    echo -e "  ${GREEN}✓${NC} v2bx-nodemix-instances.service 已安装"
    systemctl is-enabled v2bx-nodemix-instances >/dev/null 2>&1 && \
        echo -e "    ${GREEN}✓${NC} 已启用开机自启" || \
        echo -e "    ${YELLOW}!${NC} 未启用开机自启"
else
    echo -e "  ${YELLOW}!${NC} v2bx-nodemix-instances.service 未安装"
fi
echo ""

# 8. 测试启动一个实例
echo -e "${GREEN}[8] 建议操作${NC}"
echo ""

HAS_ISSUES=false

if [ -z "$FOUND_V2BX" ]; then
    echo -e "${YELLOW}► 先安装 V2bX:${NC}"
    echo "  wget -N https://raw.githubusercontent.com/wyx2685/V2bX-script/master/install.sh && bash install.sh"
    HAS_ISSUES=true
fi

if [ ! -d "/opt/V2bX-Nodemix" ]; then
    echo -e "${YELLOW}► 安装 V2bX-Nodemix:${NC}"
    echo "  bash <(curl -fsSL https://raw.githubusercontent.com/Cd1s/V2bX-Nodemix/main/install.sh)"
    HAS_ISSUES=true
fi

# 检查是否有未修改的配置
for config in /opt/V2bX-Nodemix/configs/*/config.json; do
    if [ -f "$config" ]; then
        api_host=$(python3 -c "import json; print(json.load(open('$config'))['Nodes'][0]['ApiHost'])" 2>/dev/null)
        if [ "$api_host" = "https://your-panel.com" ]; then
            name=$(basename $(dirname "$config"))
            echo -e "${YELLOW}► 修改配置文件:${NC}"
            echo "  vi /opt/V2bX-Nodemix/configs/$name/config.json"
            echo "  # 修改 ApiHost, ApiKey, NodeID"
            HAS_ISSUES=true
            break
        fi
    fi
done

if [ "$HAS_ISSUES" = false ]; then
    echo -e "${GREEN}✓ 所有检查通过！${NC}"
    echo ""
    echo "尝试启动实例:"
    echo "  v2bx-nodemix start <实例名>"
    echo ""
    echo "或者使用 Web 界面:"
    echo "  systemctl start v2bx-nodemix-web"
    echo "  访问: http://$(hostname -I | awk '{print $1}'):5000"
fi

echo ""
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  诊断完成${NC}"
echo -e "${BLUE}========================================${NC}"
