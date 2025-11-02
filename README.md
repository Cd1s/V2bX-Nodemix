# V2bX-Nodemix

> 基于 sing-box 的 V2bX 多实例管理系统

在单台服务器上运行多个 V2bX 实例，每个实例通过 sing-box 内置的 WireGuard 使用不同的出口节点。

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

## ✨ 特性

- 🚀 **多实例管理** - 一台服务器运行多个 V2bX 实例
- 🔐 **WireGuard 出站** - 每个实例独立 WireGuard 配置
- 🌐 **Web 管理界面** - 在线编辑配置文件
- 🎮 **交互式控制台** - 17项管理功能
- 🔄 **批量操作** - 一键启动/停止所有实例
- 🚦 **开机自启** - systemd 服务管理
- 📦 **一键安装** - 自动检测环境并完成配置

## 📁 项目结构

```
V2bX-Nodemix/
├── v2bx-nodemix.sh          # 交互式管理控制台
├── v2bx-manager.sh          # 实例管理脚本
├── install.sh               # 一键安装脚本
├── update.sh                # 更新脚本
├── configs/                 # 配置文件目录
│   ├── template/           # 配置模板
│   │   ├── config.json
│   │   └── sing_origin.json
│   └── 实例名/              # 各实例配置
│       ├── config.json
│       └── sing_origin.json
├── instances/               # 运行时目录
│   └── 实例名/
│       ├── V2bX            # V2bX 二进制
│       ├── pid             # 进程 PID
│       └── logs/           # 日志文件
└── web/                     # Web 管理界面
    ├── app.py              # Flask 后端
    ├── start-web.sh        # 启动脚本
    └── templates/          # HTML 模板
```

---

## 一键安装

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/Cd1s/V2bX-Nodemix/main/install.sh)
```

安装完成后运行:
```bash
v2bx-nodemix
```

---

## 管理脚本

### 交互式界面

```bash
v2bx-nodemix
```

17 项管理功能:
- 实例管理: 启动/停止/重启/删除/查看日志
- 批量操作: 启动所有/停止所有/重启所有
- 自启管理: 开启/关闭开机自启
- 系统管理: 修改密码/升级/卸载

### 命令行模式

```bash
v2bx-nodemix start <实例名>      # 启动
v2bx-nodemix stop <实例名>       # 停止
v2bx-nodemix restart <实例名>    # 重启
v2bx-nodemix logs <实例名>       # 日志
v2bx-nodemix status              # 状态
```

---

## Web 管理界面

访问地址: `http://服务器IP:5000`

默认密码: `admin123`

功能:
- 实例状态监控
- 在线编辑配置
- 启动/停止/重启实例
- 查看实时日志
- 创建/删除实例

修改密码: `v2bx-nodemix`  `14) 修改 Web 密码`

---

## 配置说明

### 配置目录

```
/opt/V2bX-Nodemix/configs/
 实例1/
    config.json          # V2bX 配置
    sing_origin.json     # sing-box 配置
 实例2/
    ...
 template/                # 模板
```

### config.json

```json
{
  "Log": { "Level": "info" },
  "Cores": [{
    "Type": "sing",
    "OriginalPath": "/opt/V2bX-Nodemix/configs/实例名/sing_origin.json"
  }],
  "Nodes": [{
    "Core": "sing",
    "ApiHost": "https://your-panel.com",
    "ApiKey": "your-api-key",
    "NodeID": 1,
    "NodeType": "vless",
    "ListenIP": "0.0.0.0"
  }]
}
```

### sing_origin.json

```json
{
  "outbounds": [
    { "type": "direct", "tag": "direct" },
    {
      "type": "wireguard",
      "tag": "wg-out",
      "server": "wg.example.com",
      "server_port": 51820,
      "system_interface": false,
      "private_key": "你的私钥",
      "peer_public_key": "服务器公钥",
      "local_address": ["10.0.1.2/16"]
    }
  ],
  "route": {
    "rules": [
      { "geosite": ["netflix"], "outbound": "wg-out" }
    ],
    "final": "wg-out"
  }
}
```

生成 WireGuard 密钥:
```bash
V2bX x25519
```

---

## 更新

方法1: 管理界面
```bash
v2bx-nodemix
# 选择 16) 升级 V2bX-Nodemix
```

方法2: 命令行
```bash
cd /opt/V2bX-Nodemix
sudo bash update.sh
```

---

## 卸载

方法1: 管理界面
```bash
v2bx-nodemix
# 选择 17) 卸载 V2bX-Nodemix
```

方法2: 命令行
```bash
systemctl stop v2bx-nodemix-web v2bx-nodemix-instances
rm -rf /opt/V2bX-Nodemix
rm -f /usr/local/bin/v2bx-nodemix
rm -f /etc/systemd/system/v2bx-nodemix-*.service
systemctl daemon-reload
```

---

## 许可证

MIT License
