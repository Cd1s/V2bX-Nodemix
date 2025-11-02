# V2bX-Nodemix# V2bX-Nodemix# V2bX-Nodemix



V2bX 多实例管理系统 - 支持独立 WireGuard 出站 + Web 管理界面



## 一键安装> V2bX 多实例管理系统 - 支持 WireGuard 出站 + Web 管理界面> 基于 sing-box 的 V2bX 多实例管理系统



```bash

wget -O install.sh https://raw.githubusercontent.com/Cd1s/V2bX-Nodemix/main/install.sh

chmod +x install.sh一台服务器运行多个 V2bX 实例,每个实例通过 sing-box 配置独立的 WireGuard 出口节点。在单台服务器上运行多个 V2bX 实例，每个实例通过 sing-box 内置的 WireGuard 使用不同的出口节点。

sudo bash install.sh

```



安装完成后运行: `v2bx-nodemix`## ✨ 核心功能[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)



---



## 管理脚本- 🚀 多实例管理 - 单服务器运行多个 V2bX 节点## ✨ 特性



### 交互式管理界面- 🔐 WireGuard 出站 - 每个实例独立 WireGuard 配置



```bash- 🌐 Web 管理界面 - 在线管理实例和配置- 🚀 **多实例管理** - 一台服务器运行多个 V2bX 实例

v2bx-nodemix

```- 🎮 交互式控制台 - 17项管理功能- 🔐 **WireGuard 出站** - 在 `sing_origin.json` 中配置 WireGuard



提供 17 项功能:- 🔄 批量操作 - 一键启动/停止所有实例- 🌐 **Web 管理界面** - 在线编辑配置文件

- 实例管理 (启动/停止/重启/删除/日志)

- 批量操作 (启动所有/停止所有/重启所有)- 🚦 开机自启 - systemd 服务管理- ⚡ **简单高效** - 无需系统级 WireGuard 接口

- 自启管理 (开启/关闭开机自启)

- 系统管理 (修改密码/升级/卸载)- 📦 一键安装 - 自动处理所有依赖- 🔌 **插件式设计** - 可作为 V2bX 的扩展插件使用



### 命令行模式- 📦 **一键安装** - 自动检测环境并完成配置



```bash---

v2bx-nodemix start <实例名>      # 启动实例

v2bx-nodemix stop <实例名>       # 停止实例## 📁 项目结构

v2bx-nodemix restart <实例名>    # 重启实例

v2bx-nodemix logs <实例名>       # 查看日志## 🚀 安装

v2bx-nodemix status              # 查看状态

``````



---```bashV2bX-Nodemix/



## Web 管理界面wget -O install.sh https://raw.githubusercontent.com/Cd1s/V2bX-Nodemix/main/install.sh├── v2bx-manager.sh             # 实例管理脚本



访问: `http://服务器IP:5000`chmod +x install.sh├── web/                        # Web 管理界面



默认密码: `admin123`sudo bash install.sh│   ├── app.py                 # Flask 后端



功能:```│   ├── start-web.sh           # 启动脚本

- 📊 实例状态监控

- ⚙️ 在线编辑配置文件│   └── templates/             # HTML 模板

- 🎛️ 启动/停止/重启实例

- 📋 查看实时日志安装完成后运行:├── configs/                    # 配置文件目录

- ➕ 创建新实例

- 🗑️ 删除实例```bash│   ├── node1/                 # 实例1



修改密码: 运行 `v2bx-nodemix` 选择 `14) 修改 Web 密码`v2bx-nodemix│   │   ├── config.json        # V2bX 配置



---```│   │   └── sing_origin.json   # sing-box 配置



## 配置文件│   ├── node2/                 # 实例2



### 配置目录结构---│   │   └── ...



```│   └── template/              # 配置模板

/opt/V2bX-Nodemix/configs/

├── 实例1/## 📖 使用方法└── instances/                  # 运行时目录

│   ├── config.json          # V2bX 配置

│   └── sing_origin.json     # sing-box 配置 (WireGuard 出站)    ├── node1/

├── 实例2/

│   └── ...### 1. 管理控制台    │   ├── V2bX

└── template/                # 配置模板

```    │   ├── logs/



### config.json 示例```bash    │   └── pid



```json# 启动交互式管理界面    └── node2/

{

  "Log": { "Level": "info" },v2bx-nodemix        └── ...

  "Cores": [{

    "Type": "sing",```

    "OriginalPath": "/opt/V2bX-Nodemix/configs/实例名/sing_origin.json"

  }],# 或使用命令行参数

  "Nodes": [{

    "Core": "sing",v2bx-nodemix start <实例名>      # 启动实例## 🚀 快速开始

    "ApiHost": "https://your-panel.com",

    "ApiKey": "your-api-key",v2bx-nodemix stop <实例名>       # 停止实例

    "NodeID": 1,

    "NodeType": "vless",v2bx-nodemix restart <实例名>    # 重启实例### 方式一：一键安装（推荐）

    "ListenIP": "0.0.0.0"

  }]v2bx-nodemix logs <实例名>       # 查看日志

}

```v2bx-nodemix status              # 查看状态```bash



### sing_origin.json 示例```# 下载并运行安装脚本



```jsonwget -O install.sh https://raw.githubusercontent.com/Cd1s/V2bX-Nodemix/main/install.sh

{

  "outbounds": [### 2. 管理菜单功能chmod +x install.sh

    { "type": "direct", "tag": "direct" },

    {sudo ./install.sh

      "type": "wireguard",

      "tag": "wg-out",``````

      "server": "wg服务器地址",

      "server_port": 51820,实例管理:

      "system_interface": false,

      "private_key": "WireGuard私钥",  1  📊 查看所有实例状态安装脚本会自动：

      "peer_public_key": "WireGuard服务器公钥",

      "local_address": ["10.0.1.2/16"]  2  ▶️  启动实例- ✅ 检测并安装依赖

    }

  ],  3  ⏹️  停止实例- ✅ 检测或下载 V2bX

  "route": {

    "rules": [  4  🔄 重启实例- ✅ 安装 V2bX-Nodemix 管理系统

      { "geosite": ["netflix"], "outbound": "wg-out" }

    ],  5  📋 查看实例日志- ✅ 创建示例配置

    "final": "wg-out"

  }  6  📁 打开配置目录- ✅ 配置系统服务

}

```  7  🗑️  删除实例- ✅ 创建命令行快捷方式



生成 WireGuard 密钥:- ✅ 自动处理 Python 环境（Debian 12+ 兼容）

```bash

V2bX x25519批量操作:

```

  8  ▶️  启动所有实例安装完成后：

---

  9  ⏹️  停止所有实例```bash

## 更新

  10 🔄 重启所有实例# 1. 编辑配置文件

```bash

v2bx-nodemixvi /opt/V2bX-Nodemix/configs/example/config.json

# 选择 16) 升级 V2bX-Nodemix

```自启管理:vi /opt/V2bX-Nodemix/configs/example/sing_origin.json



或命令行:  11 ✅ 开启开机自启

```bash

cd /opt/V2bX-Nodemix  12 ❌ 关闭开机自启# 2. 生成 WireGuard 密钥（如需要）

sudo bash update.sh

```  13 📋 查看自启状态V2bX x25519



---



## 卸载系统管理:# 3. 进入管理控制台



```bash  14 🔐 修改 Web 密码v2bx-nodemix

v2bx-nodemix

# 选择 17) 卸载 V2bX-Nodemix  15 🌐 Web 服务管理

```

  16 🔄 升级 V2bX-Nodemix# 或使用命令行

或命令行:

```bash  17 🗑️  卸载 V2bX-Nodemixv2bx-nodemix start example   # 启动实例

systemctl stop v2bx-nodemix-web

systemctl stop v2bx-nodemix-instances```v2bx-nodemix status          # 查看状态

rm -rf /opt/V2bX-Nodemix

rm -f /usr/local/bin/v2bx-nodemixv2bx-nodemix logs example    # 查看日志

rm -f /etc/systemd/system/v2bx-nodemix-*.service

systemctl daemon-reload### 3. Web 管理界面```

```



---

访问: `http://服务器IP:5000`> **🎮 管理控制台功能**:

## 许可证

> - 📊 查看所有实例状态

MIT License

默认密码: `admin123` (首次登录后请修改)> - ▶️ 启动/停止/重启实例

> - 📋 查看实时日志

功能:> - 📁 快速访问配置目录

- 📊 实例列表和状态监控> - 🗑️ 删除实例

- ⚙️ 在线编辑配置文件> - 🔐 修改 Web 管理密码

- 🎛️ 启动/停止/重启实例> - 🌐 Web 服务管理

- 📋 查看实时日志> - 🔄 一键升级系统

- ➕ 创建新实例> - 🗑️ 完全卸载

- 🗑️ 删除实例

> **📖 配置说明**:

---> - 面板配置: 编辑 `config.json` 中的 ApiHost、ApiKey、NodeID

> - WireGuard 配置: 参考 [WIREGUARD.md](WIREGUARD.md) 生成密钥和配置

## ⚙️ 配置说明> - 如不需要 WireGuard，可删除 `sing_origin.json` 中的 wireguard outbound



### 配置文件位置> **注意**: Debian 12/Ubuntu 24.04+ 使用外部管理的 Python 环境，安装脚本会自动使用系统包 `python3-flask` 或添加 `--break-system-packages` 参数。



```### 方式二：手动安装

/opt/V2bX-Nodemix/configs/

├── 实例1/#### 1. 安装依赖

│   ├── config.json          # V2bX 配置

│   └── sing_origin.json     # sing-box 配置```bash

├── 实例2/# Debian/Ubuntu

│   └── ...apt update

└── template/                # 配置模板apt install -y python3 python3-pip wget unzip

```

# 安装 Flask

### config.json (V2bX 主配置)# Debian 12/Ubuntu 24.04+

apt install -y python3-flask

```json

{# 或使用 pip (旧版本系统)

  "Log": { "Level": "info" },pip3 install flask

  "Cores": [{

    "Type": "sing",# 下载 V2bX

    "OriginalPath": "/opt/V2bX-Nodemix/configs/实例名/sing_origin.json"mkdir -p bin && cd bin

  }],wget https://github.com/wyx2685/V2bX/releases/latest/download/V2bX-linux-amd64.zip

  "Nodes": [{unzip V2bX-linux-amd64.zip

    "Core": "sing",chmod +x V2bX

    "ApiHost": "https://your-panel.com",cd ..

    "ApiKey": "your-api-key",```

    "NodeID": 1,

    "NodeType": "vless",#### 2. 克隆项目

    "ListenIP": "0.0.0.0"

  }]```bash

}# 克隆仓库

```git clone https://github.com/Cd1s/V2bX-Nodemix.git

cd V2bX-Nodemix

### sing_origin.json (WireGuard 配置)

# 或者下载 zip

```jsonwget https://github.com/Cd1s/V2bX-Nodemix/archive/main.zip

{unzip main.zip

  "outbounds": [cd V2bX-Nodemix-main

    { "type": "direct", "tag": "direct" },```

    {

      "type": "wireguard",### 2. 创建实例配置

      "tag": "wg-out",

      "server": "wg.example.com",### 3. 创建实例配置

      "server_port": 51820,

      "system_interface": false,在 `configs/` 目录下为每个实例创建文件夹，例如 `node1`, `node2`...

      "private_key": "你的WireGuard私钥",

      "peer_public_key": "服务器公钥",每个实例需要两个配置文件：

      "local_address": ["10.0.1.2/16"]

    }#### config.json (V2bX 主配置)

  ],

  "route": {```json

    "rules": [{

      { "geosite": ["netflix"], "outbound": "wg-out" }  "Log": {

    ],    "Level": "info"

    "final": "wg-out"  },

  }  "Cores": [

}    {

```      "Type": "sing",

      "OriginalPath": "/opt/V2bX-Nodemix/configs/node1/sing_origin.json"

### 生成 WireGuard 密钥    }

  ],

```bash  "Nodes": [

# 方法1: 使用 V2bX    {

V2bX x25519      "Core": "sing",

      "ApiHost": "https://your-panel.com",

# 方法2: 使用 wg 工具      "ApiKey": "your-api-key",

wg genkey | tee privatekey | wg pubkey > publickey      "NodeID": 1,

```      "NodeType": "vless",

      "ListenIP": "0.0.0.0"

---    }

  ]

## 🔄 更新}

```

### 方法1: 管理界面更新

#### sing_origin.json (sing-box 核心配置 + WireGuard 出站)

```bash

v2bx-nodemix```json

# 选择 16) 🔄 升级 V2bX-Nodemix{

```  "dns": {

    "servers": [

### 方法2: 命令行更新      {

        "tag": "dns_direct",

```bash        "address": "local",

cd /opt/V2bX-Nodemix        "detour": "direct"

sudo bash update.sh      },

```      {

        "tag": "dns_cf",

更新后会保留:        "address": "1.1.1.1",

- ✅ 所有实例配置        "detour": "direct"

- ✅ Web 管理密码      },

- ✅ 实例运行数据      {

        "tag": "dns_wg",

---        "address": "8.8.8.8",

        "detour": "wg-out"

## 🗑️ 卸载      }

    ],

### 方法1: 管理界面卸载    "rules": [

      {

```bash        "rule_set": ["geosite-netflix", "geosite-disney"],

v2bx-nodemix        "server": "dns_wg"

# 选择 17) 🗑️ 卸载 V2bX-Nodemix      },

```      {

        "server": "dns_direct"

### 方法2: 命令行卸载      }

    ],

```bash    "fakeip": {

# 停止所有服务      "enabled": true,

systemctl stop v2bx-nodemix-web      "inet4_range": "198.18.0.0/16"

systemctl stop v2bx-nodemix-instances    }

  },

# 删除所有文件  "outbounds": [

rm -rf /opt/V2bX-Nodemix    {

rm -f /usr/local/bin/v2bx-nodemix      "type": "direct",

rm -f /etc/systemd/system/v2bx-nodemix-*.service      "tag": "direct"

systemctl daemon-reload    },

```    {

      "type": "block",

> 注意: 卸载不会删除 V2bX 主程序,如需删除: `rm -rf /usr/local/V2bX`      "tag": "block"

    },

---    {

      "type": "wireguard",

## 💡 使用场景      "tag": "wg-out",

      "server": "wg.example.com",

### 多地出口节点      "server_port": 51820,

```      "system_interface": false,

服务器      "private_key": "your-wireguard-private-key",

├── 日本节点 → WireGuard → 日本出口      "peer_public_key": "server-public-key",

├── 美国节点 → WireGuard → 美国出口      "local_address": ["10.0.1.2/16"],

└── 香港节点 → WireGuard → 香港出口      "mtu": 1280,

```      "workers": 4

    }

### 分流专用节点  ],

```  "route": {

服务器    "rule_set": [

├── 流媒体节点 → WireGuard → 流媒体专线      {

├── 游戏节点 → WireGuard → 游戏专线        "tag": "geoip-cn",

└── 通用节点 → WireGuard → 常规出口        "type": "remote",

```        "format": "binary",

        "url": "https://raw.githubusercontent.com/SagerNet/sing-geoip/rule-set/geoip-cn.srs",

---        "download_detour": "direct"

      },

## ❓ 常见问题      {

        "tag": "geosite-cn",

**Q: 如何创建新实例?**          "type": "remote",

A: Web 界面点击"创建新实例",或复制 `configs/template/` 到 `configs/新实例名/`        "format": "binary",

        "url": "https://raw.githubusercontent.com/SagerNet/sing-geosite/rule-set/geosite-cn.srs",

**Q: 如何修改配置?**          "download_detour": "direct"

A: Web 界面在线编辑,或直接编辑 `/opt/V2bX-Nodemix/configs/实例名/` 下的文件      },

      {

**Q: 实例启动失败?**          "tag": "geosite-category-ads-all",

A: 运行 `v2bx-nodemix` 选择 5) 查看实例日志,检查配置和 WireGuard 连接        "type": "remote",

        "format": "binary",

**Q: 如何修改 Web 密码?**          "url": "https://raw.githubusercontent.com/SagerNet/sing-geosite/rule-set/geosite-category-ads-all.srs",

A: 运行 `v2bx-nodemix` 选择 14) 修改 Web 密码        "download_detour": "direct"

      },

**Q: 如何设置开机自启?**        {

A: 运行 `v2bx-nodemix` 选择 11) 开启开机自启        "tag": "geosite-netflix",

        "type": "remote",

---        "format": "binary",

        "url": "https://raw.githubusercontent.com/SagerNet/sing-geosite/rule-set/geosite-netflix.srs",

## 📚 相关文档        "download_detour": "direct"

      },

- [V2bX 项目](https://github.com/wyx2685/V2bX)      {

- [sing-box 文档](https://sing-box.sagernet.org/)        "tag": "geosite-disney",

- [WireGuard 官网](https://www.wireguard.com/)        "type": "remote",

        "format": "binary",

## 📄 许可证        "url": "https://raw.githubusercontent.com/SagerNet/sing-geosite/rule-set/geosite-disney.srs",

        "download_detour": "direct"

MIT License      }

    ],

---    "rules": [

      {

**简单 · 高效 · 强大** 🚀        "rule_set": ["geosite-netflix", "geosite-disney"],

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
