#!/usr/bin/env python3
"""
V2bX-Nodemix Web 管理界面
提供 Web 界面来管理多个 V2bX 实例的配置
"""

from flask import Flask, render_template, request, jsonify, redirect, url_for, session
from functools import wraps
import json
import os
import subprocess
from pathlib import Path
import hashlib

app = Flask(__name__)
app.config['SECRET_KEY'] = os.urandom(24).hex()

# 默认管理密码 (SHA256): admin123
# 可以通过 .password 文件设置
DEFAULT_PASSWORD_HASH = '240be518fabd2724ddb6f04eeb1da5967448d7e831c08c8fa822809f74c720a9'  # admin123

BASE_DIR = Path(__file__).parent.parent
CONFIGS_DIR = BASE_DIR / 'configs'
INSTANCES_DIR = BASE_DIR / 'instances'
MANAGER_SCRIPT = BASE_DIR / 'v2bx-manager.sh'
PASSWORD_FILE = BASE_DIR / '.password'

def get_password_hash():
    """获取密码哈希"""
    if PASSWORD_FILE.exists():
        return PASSWORD_FILE.read_text().strip()
    return DEFAULT_PASSWORD_HASH

def hash_password(password):
    """SHA256 哈希密码"""
    return hashlib.sha256(password.encode()).hexdigest()

def login_required(f):
    """登录验证装饰器"""
    @wraps(f)
    def decorated_function(*args, **kwargs):
        if not session.get('logged_in'):
            return redirect(url_for('login'))
        return f(*args, **kwargs)
    return decorated_function

@app.route('/login', methods=['GET', 'POST'])
def login():
    """登录页面"""
    if request.method == 'POST':
        password = request.form.get('password', '')
        if hash_password(password) == get_password_hash():
            session['logged_in'] = True
            return redirect(url_for('index'))
        else:
            return render_template('login.html', error='密码错误')
    
    return render_template('login.html')

@app.route('/logout')
def logout():
    """登出"""
    session.pop('logged_in', None)
    return redirect(url_for('login'))

def get_instances():
    """获取所有实例"""
    if not CONFIGS_DIR.exists():
        return []
    
    instances = []
    for item in CONFIGS_DIR.iterdir():
        if item.is_dir() and item.name != 'template':
            config_file = item / 'config.json'
            sing_file = item / 'sing_origin.json'
            
            if config_file.exists():
                with open(config_file, 'r', encoding='utf-8') as f:
                    config = json.load(f)
                
                sing_config = {}
                if sing_file.exists():
                    with open(sing_file, 'r', encoding='utf-8') as f:
                        sing_config = json.load(f)
                
                instances.append({
                    'name': item.name,
                    'config': config,
                    'sing_config': sing_config,
                    'status': get_instance_status(item.name)
                })
    
    return instances

def get_instance_status(name):
    """获取实例状态"""
    pid_file = INSTANCES_DIR / name / 'pid'
    if pid_file.exists():
        try:
            pid = int(pid_file.read_text().strip())
            # 检查进程是否存在
            os.kill(pid, 0)
            return 'running'
        except (ValueError, ProcessLookupError, OSError):
            return 'stopped'
    return 'stopped'

def run_manager_command(command, instance_name=None):
    """执行管理脚本命令"""
    cmd = ['bash', str(MANAGER_SCRIPT), command]
    if instance_name:
        cmd.append(instance_name)
    
    try:
        result = subprocess.run(cmd, capture_output=True, text=True, timeout=10)
        return {
            'success': result.returncode == 0,
            'output': result.stdout,
            'error': result.stderr
        }
    except Exception as e:
        return {
            'success': False,
            'output': '',
            'error': str(e)
        }

@app.route('/')
@login_required
def index():
    """主页 - 显示所有实例"""
    instances = get_instances()
    return render_template('index.html', instances=instances)

@app.route('/instance/<name>')
@login_required
def view_instance(name):
    """查看实例详情"""
    config_file = CONFIGS_DIR / name / 'config.json'
    sing_file = CONFIGS_DIR / name / 'sing_origin.json'
    
    if not config_file.exists():
        return "实例不存在", 404
    
    with open(config_file, 'r', encoding='utf-8') as f:
        config = json.load(f)
    
    sing_config = {}
    if sing_file.exists():
        with open(sing_file, 'r', encoding='utf-8') as f:
            sing_config = json.load(f)
    
    return render_template('instance.html', 
                         name=name, 
                         config=config, 
                         sing_config=sing_config,
                         status=get_instance_status(name))

@app.route('/edit/<name>', methods=['GET', 'POST'])
@login_required
def edit_instance(name):
    """编辑实例配置"""
    sing_file = CONFIGS_DIR / name / 'sing_origin.json'
    config_file = CONFIGS_DIR / name / 'config.json'
    
    if request.method == 'POST':
        # 保存配置
        try:
            # 保存 sing_origin.json
            sing_config_data = request.form.get('sing_config')
            if sing_config_data:
                sing_config = json.loads(sing_config_data)
                with open(sing_file, 'w', encoding='utf-8') as f:
                    json.dump(sing_config, f, indent=2, ensure_ascii=False)
            
            # 保存 config.json
            config_data = request.form.get('v2bx_config')
            if config_data:
                config = json.loads(config_data)
                with open(config_file, 'w', encoding='utf-8') as f:
                    json.dump(config, f, indent=2, ensure_ascii=False)
            
            return jsonify({'success': True, 'message': '配置已保存'})
        except json.JSONDecodeError as e:
            return jsonify({'success': False, 'message': f'JSON 格式错误: {str(e)}'})
        except Exception as e:
            return jsonify({'success': False, 'message': f'保存失败: {str(e)}'})
    
    # 读取配置
    with open(config_file, 'r', encoding='utf-8') as f:
        config = json.load(f)
    
    sing_config = {}
    if sing_file.exists():
        with open(sing_file, 'r', encoding='utf-8') as f:
            sing_config = json.load(f)
    
    return render_template('edit.html', 
                         name=name, 
                         config=config, 
                         sing_config=sing_config)

@app.route('/api/start/<name>', methods=['POST'])
@login_required
def api_start(name):
    """启动实例"""
    result = run_manager_command('start', name)
    return jsonify(result)

@app.route('/api/stop/<name>', methods=['POST'])
@login_required
def api_stop(name):
    """停止实例"""
    result = run_manager_command('stop', name)
    return jsonify(result)

@app.route('/api/restart/<name>', methods=['POST'])
@login_required
def api_restart(name):
    """重启实例"""
    result = run_manager_command('restart', name)
    return jsonify(result)

@app.route('/api/status')
@login_required
def api_status():
    """获取所有实例状态"""
    instances = get_instances()
    return jsonify({
        'instances': [
            {
                'name': inst['name'],
                'status': inst['status']
            }
            for inst in instances
        ]
    })

@app.route('/api/logs/<name>')
@login_required
def api_logs(name):
    """获取实例日志"""
    log_file = INSTANCES_DIR / name / 'logs' / 'output.log'
    lines = request.args.get('lines', 100, type=int)
    
    if not log_file.exists():
        return jsonify({'logs': '日志文件不存在'})
    
    try:
        result = subprocess.run(['tail', '-n', str(lines), str(log_file)],
                              capture_output=True, text=True)
        return jsonify({'logs': result.stdout})
    except Exception as e:
        return jsonify({'logs': f'读取日志失败: {str(e)}'})

@app.route('/settings', methods=['GET', 'POST'])
@login_required
def settings():
    """系统设置"""
    if request.method == 'POST':
        action = request.form.get('action')
        
        if action == 'change_password':
            new_password = request.form.get('new_password')
            confirm_password = request.form.get('confirm_password')
            
            if not new_password or len(new_password) < 6:
                return jsonify({'success': False, 'message': '密码至少6个字符'})
            
            if new_password != confirm_password:
                return jsonify({'success': False, 'message': '两次密码不一致'})
            
            # 保存密码到配置文件
            password_file = BASE_DIR / '.password'
            new_hash = hash_password(new_password)
            password_file.write_text(new_hash)
            
            return jsonify({'success': True, 'message': '密码已更新，请重新登录'})
    
    return render_template('settings.html')

@app.route('/create', methods=['GET', 'POST'])
@login_required
def create_instance():
    """创建新实例"""
    if request.method == 'POST':
        try:
            name = request.form.get('name', '').strip()
            
            # 验证实例名
            if not name or not name.replace('-', '').replace('_', '').isalnum():
                return jsonify({'success': False, 'message': '实例名只能包含字母、数字、下划线和横线'})
            
            instance_dir = CONFIGS_DIR / name
            if instance_dir.exists():
                return jsonify({'success': False, 'message': '实例已存在'})
            
            # 创建实例目录
            instance_dir.mkdir(parents=True)
            
            # 获取表单数据
            api_host = request.form.get('api_host', 'https://your-panel.com')
            api_key = request.form.get('api_key', 'your-api-key')
            node_id = request.form.get('node_id', '1')
            node_type = request.form.get('node_type', 'shadowsocks')
            
            # 创建 config.json
            config = {
                "Log": {"Level": "info"},
                "Cores": [{
                    "Type": "sing",
                    "OriginalPath": f"/opt/V2bX-Nodemix/configs/{name}/sing_origin.json"
                }],
                "Nodes": [{
                    "Core": "sing",
                    "ApiHost": api_host,
                    "ApiKey": api_key,
                    "NodeID": int(node_id),
                    "NodeType": node_type,
                    "Timeout": 30,
                    "ListenIP": "::",
                    "SendIP": "0.0.0.0",
                    "DeviceOnlineMinTraffic": 1000,
                    "TCPFastOpen": True,
                    "SniffEnabled": True,
                    "EnableDNS": True,
                    "CertConfig": {
                        "CertMode": "none",
                        "RejectUnknownSni": False,
                        "CertDomain": "example.com",
                        "CertFile": "/etc/V2bX/fullchain.cer",
                        "KeyFile": "/etc/V2bX/cert.key",
                        "Email": "v2bx@github.com",
                        "Provider": "cloudflare",
                        "DNSEnv": {"EnvName": "env1"}
                    },
                    "LimitConfig": {
                        "EnableDeviceLimit": True,
                        "DeviceLimit": 0
                    }
                }]
            }
            
            with open(instance_dir / 'config.json', 'w', encoding='utf-8') as f:
                json.dump(config, f, indent=2, ensure_ascii=False)
            
            # 创建 sing_origin.json
            use_wireguard = request.form.get('use_wireguard') == 'on'
            
            outbounds = [
                {"type": "direct", "tag": "direct"},
                {"type": "block", "tag": "block"}
            ]
            
            if use_wireguard:
                wg_server = request.form.get('wg_server', 'wg.example.com')
                wg_port = request.form.get('wg_port', '51820')
                wg_private_key = request.form.get('wg_private_key', 'REPLACE_WITH_YOUR_PRIVATE_KEY')
                wg_public_key = request.form.get('wg_public_key', 'REPLACE_WITH_SERVER_PUBLIC_KEY')
                wg_local_ip = request.form.get('wg_local_ip', '10.0.1.2/16')
                
                outbounds.insert(0, {
                    "type": "wireguard",
                    "tag": "wg-out",
                    "server": wg_server,
                    "server_port": int(wg_port),
                    "system_interface": False,
                    "private_key": wg_private_key,
                    "peer_public_key": wg_public_key,
                    "local_address": [wg_local_ip],
                    "mtu": 1280,
                    "workers": 4
                })
            
            sing_config = {
                "dns": {
                    "servers": [
                        {"tag": "dns_direct", "address": "local", "detour": "direct"},
                        {"tag": "dns_cf", "address": "1.1.1.1", "detour": "direct"}
                    ],
                    "rules": [{"server": "dns_direct"}],
                    "fakeip": {"enabled": True, "inet4_range": "198.18.0.0/16"}
                },
                "outbounds": outbounds,
                "route": {
                    "rules": [
                        {"ip_is_private": True, "outbound": "block"},
                        {"ip_cidr": ["198.18.0.0/16"], "outbound": "direct"}
                    ]
                },
                "experimental": {"cache_file": {"enabled": True}}
            }
            
            with open(instance_dir / 'sing_origin.json', 'w', encoding='utf-8') as f:
                json.dump(sing_config, f, indent=2, ensure_ascii=False)
            
            return jsonify({'success': True, 'message': f'实例 {name} 创建成功', 'redirect': f'/edit/{name}'})
            
        except Exception as e:
            return jsonify({'success': False, 'message': f'创建失败: {str(e)}'})
    
    return render_template('create.html')

if __name__ == '__main__':
    # 创建必要的目录
    CONFIGS_DIR.mkdir(exist_ok=True)
    INSTANCES_DIR.mkdir(exist_ok=True)
    
    # 启动 Web 服务器
    print("=" * 50)
    print("V2bX-Nodemix Web 管理界面启动")
    print("=" * 50)
    print(f"访问地址: http://0.0.0.0:5000")
    print(f"默认密码: admin123")
    print(f"")
    print(f"修改密码方法:")
    print(f"  export V2BX_WEB_PASSWORD_HASH=$(echo -n '你的密码' | sha256sum | cut -d' ' -f1)")
    print(f"  systemctl restart v2bx-nodemix-web")
    print("=" * 50)
    app.run(host='0.0.0.0', port=5000, debug=False)
