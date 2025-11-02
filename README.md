# V2bX-Nodemix

> 基于 sing-box 的 V2bX 多实例管理系统

在单台服务器上运行多个 V2bX 实例，每个实例通过 sing-box 内置的 WireGuard 使用不同的出口节点。

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

## ✨ 特性

- 🚀 **多实例管理** - 一台服务器运行多个 V2bX 实例
- 🔐 **WireGuard 出站** - 在 `sing_origin.json` 中配置 WireGuard
- 🌐 **Web 管理界面** - 在线编辑配置文件
- ⚡ **简单高效** - 无需系统级 WireGuard 接口
- 🔌 **插件式设计** - 可作为 V2bX 的扩展插件使用
- 📦 **一键安装** - 自动检测环境并完成配置

## 📁 项目结构

```
V2bX-Nodemix/
├── v2bx-manager.sh             # 实例管理脚本
├── web/                        # Web 管理界面
│   ├── app.py                 # Flask 后端
│   ├── start-web.sh           # 启动脚本
│   └── templates/             # HTML 模板
├── configs/                    # 配置文件目录
│   ├── node1/                 # 实例1
│   │   ├── config.json        # V2bX 配置
│   │   └── sing_origin.json   # sing-box 配置
│   ├── node2/                 # 实例2
│   │   └── ...
│   └── template/              # 配置模板
└── instances/                  # 运行时目录
    ├── node1/
    │   ├── V2bX
    │   ├── logs/
    │   └── pid
    └── node2/
        └── ...
```

## 🚀 快速开始

### 方式一：一键安装（推荐）

```bash
# 下载并运行安装脚本
wget -O install.sh https://raw.githubusercontent.com/Cd1s/V2bX-Nodemix/main/install.sh
chmod +x install.sh
sudo ./install.sh
```

安装脚本会自动：
- ✅ 检测并安装依赖
- ✅ 检测或下载 V2bX
- ✅ 安装 V2bX-Nodemix 管理系统
- ✅ 创建示例配置
- ✅ 配置系统服务
- ✅ 创建命令行快捷方式
- ✅ 自动处理 Python 环境（Debian 12+ 兼容）

安装完成后：
```bash
# 1. 编辑配置文件
vi /opt/V2bX-Nodemix/configs/example/config.json
vi /opt/V2bX-Nodemix/configs/example/sing_origin.json

# 2. 生成 WireGuard 密钥（如需要）
V2bX x25519

# 3. 进入管理控制台
v2bx-nodemix

# 或使用命令行
v2bx-nodemix start example   # 启动实例
v2bx-nodemix status          # 查看状态
v2bx-nodemix logs example    # 查看日志
```

> **🎮 管理控制台功能**:
> - 📊 查看所有实例状态
> - ▶️ 启动/停止/重启实例
> - 📋 查看实时日志
> - 📁 快速访问配置目录
> - 🗑️ 删除实例
> - 🔐 修改 Web 管理密码
> - 🌐 Web 服务管理
> - 🔄 一键升级系统
> - 🗑️ 完全卸载

> **📖 配置说明**:
> - 面板配置: 编辑 `config.json` 中的 ApiHost、ApiKey、NodeID
> - WireGuard 配置: 参考 [WIREGUARD.md](WIREGUARD.md) 生成密钥和配置
> - 如不需要 WireGuard，可删除 `sing_origin.json` 中的 wireguard outbound

> **注意**: Debian 12/Ubuntu 24.04+ 使用外部管理的 Python 环境，安装脚本会自动使用系统包 `python3-flask` 或添加 `--break-system-packages` 参数。

### 方式二：手动安装

#### 1. 安装依赖

```bash
# Debian/Ubuntu
apt update
apt install -y python3 python3-pip wget unzip

# 安装 Flask
# Debian 12/Ubuntu 24.04+
apt install -y python3-flask

# 或使用 pip (旧版本系统)
pip3 install flask

# 下载 V2bX
mkdir -p bin && cd bin
wget https://github.com/wyx2685/V2bX/releases/latest/download/V2bX-linux-amd64.zip
unzip V2bX-linux-amd64.zip
chmod +x V2bX
cd ..
```

#### 2. 克隆项目

```bash
# 克隆仓库
git clone https://github.com/你的用户名/V2bX-Nodemix.git
cd V2bX-Nodemix

# 或者下载 zip
wget https://github.com/你的用户名/V2bX-Nodemix/archive/main.zip
unzip main.zip
cd V2bX-Nodemix-main
```

### 2. 创建实例配置

### 3. 创建实例配置

在 `configs/` 目录下为每个实例创建文件夹，例如 `node1`, `node2`...

每个实例需要两个配置文件：

#### config.json (V2bX 主配置)

```json
{
  "Log": {
    "Level": "info"
  },
  "Cores": [
    {
      "Type": "sing",
      "OriginalPath": "/opt/V2bX-Nodemix/configs/node1/sing_origin.json"
    }
  ],
  "Nodes": [
    {
      "Core": "sing",
      "ApiHost": "https://your-panel.com",
      "ApiKey": "your-api-key",
      "NodeID": 1,
      "NodeType": "vless",
      "ListenIP": "0.0.0.0"
    }
  ]
}
```

#### sing_origin.json (sing-box 核心配置 + WireGuard 出站)

```json
{
  "dns": {
    "servers": [
      {
        "tag": "dns_direct",
        "address": "local",
        "detour": "direct"
      },
      {
        "tag": "dns_cf",
        "address": "1.1.1.1",
        "detour": "direct"
      },
      {
        "tag": "dns_wg",
        "address": "8.8.8.8",
        "detour": "wg-out"
      }
    ],
    "rules": [
      {
        "rule_set": ["geosite-netflix", "geosite-disney"],
        "server": "dns_wg"
      },
      {
        "server": "dns_direct"
      }
    ],
    "fakeip": {
      "enabled": true,
      "inet4_range": "198.18.0.0/16"
    }
  },
  "outbounds": [
    {
      "type": "direct",
      "tag": "direct"
    },
    {
      "type": "block",
      "tag": "block"
    },
    {
      "type": "wireguard",
      "tag": "wg-out",
      "server": "wg.example.com",
      "server_port": 51820,
      "system_interface": false,
      "private_key": "your-wireguard-private-key",
      "peer_public_key": "server-public-key",
      "local_address": ["10.0.1.2/16"],
      "mtu": 1280,
      "workers": 4
    }
  ],
  "route": {
    "rule_set": [
      {
        "tag": "geoip-cn",
        "type": "remote",
        "format": "binary",
        "url": "https://raw.githubusercontent.com/SagerNet/sing-geoip/rule-set/geoip-cn.srs",
        "download_detour": "direct"
      },
      {
        "tag": "geosite-cn",
        "type": "remote",
        "format": "binary",
        "url": "https://raw.githubusercontent.com/SagerNet/sing-geosite/rule-set/geosite-cn.srs",
        "download_detour": "direct"
      },
      {
        "tag": "geosite-category-ads-all",
        "type": "remote",
        "format": "binary",
        "url": "https://raw.githubusercontent.com/SagerNet/sing-geosite/rule-set/geosite-category-ads-all.srs",
        "download_detour": "direct"
      },
      {
        "tag": "geosite-netflix",
        "type": "remote",
        "format": "binary",
        "url": "https://raw.githubusercontent.com/SagerNet/sing-geosite/rule-set/geosite-netflix.srs",
        "download_detour": "direct"
      },
      {
        "tag": "geosite-disney",
        "type": "remote",
        "format": "binary",
        "url": "https://raw.githubusercontent.com/SagerNet/sing-geosite/rule-set/geosite-disney.srs",
        "download_detour": "direct"
      }
    ],
    "rules": [
      {
        "rule_set": ["geosite-netflix", "geosite-disney"],
        "outbound": "wg-out"
      },
      {
        "ip_is_private": true,
        "outbound": "block"
      },
      {
        "rule_set": ["geosite-category-ads-all", "geosite-cn", "geoip-cn"],
        "outbound": "block"
      },
      {
        "ip_cidr": ["198.18.0.0/16"],
        "outbound": "direct"
      }
    ]
  },
  "experimental": {
    "cache_file": {
      "enabled": true
    }
  }
}
```

### 3. 启动实例

```bash
chmod +x v2bx-manager.sh

# 启动实例
./v2bx-manager.sh start node1

# 查看状态
./v2bx-manager.sh status

# 查看日志
./v2bx-manager.sh logs node1
```

### 4. 启动 Web 管理界面

```bash
cd web
chmod +x start-web.sh
./start-web.sh
```

访问: `http://你的服务器IP:5000`

## 🎮 管理命令

```bash
# 启动实例
./v2bx-manager.sh start <实例名>

# 停止实例
./v2bx-manager.sh stop <实例名>

# 重启实例
./v2bx-manager.sh restart <实例名>

# 查看所有实例状态
./v2bx-manager.sh status

# 查看实例日志
./v2bx-manager.sh logs <实例名> [行数]

# 启动所有实例
./v2bx-manager.sh start-all

# 停止所有实例
./v2bx-manager.sh stop-all
```

## 🌐 Web 管理界面

### 功能

- **实例列表** - 查看所有实例运行状态
- **配置编辑** - 在线编辑 `config.json` 和 `sing_origin.json`
- **实例控制** - 启动/停止/重启实例
- **日志查看** - 实时查看运行日志

### 使用

1. 在主页查看所有实例状态
2. 点击"编辑配置"在线修改配置文件
3. 修改后保存，然后重启实例使配置生效

## 📝 配置说明

### WireGuard 密钥生成

```bash
# 安装 WireGuard 工具
apt install wireguard-tools

# 生成密钥对
wg genkey | tee privatekey | wg pubkey > publickey

# 查看密钥
cat privatekey  # 私钥（填入 sing_origin.json）
cat publickey   # 公钥（发给 WG 服务器管理员）
```

### 配置文件位置

- **V2bX 配置**: `configs/<实例名>/config.json`
- **sing-box 配置**: `configs/<实例名>/sing_origin.json`

### 主要配置项

#### config.json

- `OriginalPath`: sing_origin.json 的完整路径
- `ApiHost`: V2Board 面板地址
- `ApiKey`: API 密钥
- `NodeID`: 节点 ID

#### sing_origin.json

- `outbounds[0].server`: WireGuard 服务器地址
- `outbounds[0].server_port`: WireGuard 端口
- `outbounds[0].local_address`: 本地虚拟 IP
- `outbounds[0].private_key`: WireGuard 私钥
- `outbounds[0].peer_public_key`: WireGuard 服务器公钥
- `route.final`: 默认出站（通常是 WireGuard）

## 💡 使用场景

### 多地出口节点

```
服务器
├── node1 → WireGuard → 出口A (如: 日本)
├── node2 → WireGuard → 出口B (如: 美国)
└── node3 → WireGuard → 出口C (如: 新加坡)
```

### 不同用途分流

```
服务器
├── node1 → 游戏专用 (低延迟出口)
├── node2 → 流媒体专用 (高带宽出口)
└── node3 → 通用节点 (常规出口)
```

## 🔧 高级配置

### 自定义路由规则

编辑 `sing_origin.json`:

```json
{
  "route": {
    "rules": [
      {
        "geosite": ["netflix", "disney"],
        "outbound": "wg-out"
      },
      {
        "geosite": "cn",
        "outbound": "direct"
      },
      {
        "domain_suffix": [".cn"],
        "outbound": "direct"
      }
    ],
    "final": "wg-out"
  }
}
```

### 多个 WireGuard 出站

```json
{
  "outbounds": [
    {
      "type": "wireguard",
      "tag": "wg-primary",
      "server": "primary.wg.example.com",
      "server_port": 51820,
      "local_address": ["10.0.1.2/24"],
      "private_key": "...",
      "peer_public_key": "..."
    },
    {
      "type": "wireguard",
      "tag": "wg-backup",
      "server": "backup.wg.example.com",
      "server_port": 51820,
      "local_address": ["10.0.2.2/24"],
      "private_key": "...",
      "peer_public_key": "..."
    }
  ],
  "route": {
    "final": "wg-primary"
  }
}
```

## 🔒 安全建议

### 1. 使用 Nginx 反向代理

```nginx
server {
    listen 80;
    server_name v2bx.yourdomain.com;
    
    location / {
        proxy_pass http://127.0.0.1:5000;
        auth_basic "Admin Area";
        auth_basic_user_file /etc/nginx/.htpasswd;
    }
}
```

### 2. 配置防火墙

```bash
# 限制 Web 界面访问
ufw allow from <你的IP> to any port 5000
```

### 3. 定期备份配置

```bash
tar -czf v2bx-backup-$(date +%Y%m%d).tar.gz configs/
```

## ❓ 常见问题

**Q: 如何添加新实例？**  
A: 在 `configs/` 下创建新文件夹，添加 `config.json` 和 `sing_origin.json`，然后启动即可。

**Q: 如何修改配置？**  
A: 可以直接编辑配置文件，或通过 Web 界面在线编辑，修改后重启实例生效。

**Q: 实例启动失败？**  
A: 查看日志 `./v2bx-manager.sh logs <实例名>`，检查配置文件格式和 WireGuard 连接。

**Q: Web 界面如何设置密码？**  
A: 使用 Nginx 反向代理配置 HTTP Basic Auth，或修改 `web/app.py` 添加认证。

**Q: Debian 12 安装 Flask 报错 "externally-managed-environment"？**  
A: 这是正常的。安装脚本会自动处理，使用以下任一方法：
```bash
# 方法1: 使用系统包（推荐）
apt install python3-flask

# 方法2: 使用 pip 的特殊参数
pip3 install flask --break-system-packages

# 方法3: 手动运行安装脚本，它会自动选择正确的方法
./install.sh
```

## 📚 相关资源

- [快速开始指南](QUICKSTART.md) - 一键安装和快速使用
- [sing-box 文档](https://sing-box.sagernet.org/)
- [V2bX 项目](https://github.com/wyx2685/V2bX)
- [WireGuard 官网](https://www.wireguard.com/)

## 🔄 更新

```bash
cd /opt/V2bX-Nodemix
./update.sh
```

或手动更新：

```bash
cd /opt/V2bX-Nodemix
git pull
systemctl restart v2bx-nodemix-web
```

## �️ 卸载

### 方法一：使用卸载脚本（推荐）

```bash
# 下载并运行卸载脚本
wget -O uninstall.sh https://raw.githubusercontent.com/Cd1s/V2bX-Nodemix/main/uninstall.sh
chmod +x uninstall.sh
sudo ./uninstall.sh
```

### 方法二：手动卸载

```bash
# 停止所有实例
v2bx-nodemix stop-all

# 停止并禁用 Web 服务
systemctl stop v2bx-nodemix-web
systemctl disable v2bx-nodemix-web
rm -f /etc/systemd/system/v2bx-nodemix-web.service
systemctl daemon-reload

# 删除命令行工具
rm -f /usr/local/bin/v2bx-nodemix

# 删除安装目录
rm -rf /opt/V2bX-Nodemix
```

**注意**: 卸载 V2bX-Nodemix 不会删除 V2bX 主程序。如需删除 V2bX：
```bash
rm -rf /usr/local/V2bX
```

## �📄 许可证

MIT License

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！

---

**简单高效的多实例管理** 🚀
