#!/bin/bash

# V2bX-Nodemix Web 管理界面启动脚本

cd "$(dirname "$0")"

# 检查 Python
if ! command -v python3 &> /dev/null; then
    echo "错误: 未安装 Python 3"
    echo "安装: apt install python3 python3-pip"
    exit 1
fi

# 检查并安装依赖
if ! python3 -c "import flask" 2>/dev/null; then
    echo "安装 Flask..."
    pip3 install flask
fi

# 启动 Web 服务
echo "启动 V2bX-Nodemix Web 管理界面..."
echo "访问地址: http://$(hostname -I | awk '{print $1}'):5000"
echo "本地访问: http://localhost:5000"
echo ""
echo "按 Ctrl+C 停止服务"
echo ""

python3 app.py
