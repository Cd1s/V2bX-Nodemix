# V2bX-Nodemix

V2bX 多实例管理系统 - 支持 WireGuard 出站 + Web 界面

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
