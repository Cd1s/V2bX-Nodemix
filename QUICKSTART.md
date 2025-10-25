# V2bX-Nodemix 快速使用指南

## 🚀 一键安装

```bash
wget -O install.sh https://raw.githubusercontent.com/你的用户名/V2bX-Nodemix/main/install.sh
chmod +x install.sh
sudo ./install.sh
```

## 📝 安装后操作

### 1. 编辑配置

```bash
# 进入配置目录
cd /opt/V2bX-Nodemix/configs/example

# 编辑 V2bX 配置
nano config.json

# 编辑 sing-box + WireGuard 配置
nano sing_origin.json
```

### 2. 启动实例

```bash
# 启动示例实例
v2bx-nodemix start example

# 查看运行状态
v2bx-nodemix status

# 查看日志
v2bx-nodemix logs example
```

### 3. Web 管理界面

```bash
# 启动 Web 界面
systemctl start v2bx-nodemix-web

# 设置开机自启
systemctl enable v2bx-nodemix-web

# 访问 Web 界面
# 浏览器打开: http://你的服务器IP:5000
```

## 🎮 常用命令

```bash
# 实例管理
v2bx-nodemix start <实例名>      # 启动实例
v2bx-nodemix stop <实例名>       # 停止实例
v2bx-nodemix restart <实例名>    # 重启实例
v2bx-nodemix status              # 查看所有实例状态
v2bx-nodemix logs <实例名>       # 查看实例日志

# Web 服务管理
systemctl start v2bx-nodemix-web     # 启动 Web 界面
systemctl stop v2bx-nodemix-web      # 停止 Web 界面
systemctl restart v2bx-nodemix-web   # 重启 Web 界面
systemctl status v2bx-nodemix-web    # 查看 Web 状态
```

## 📁 添加新实例

### 方法1：复制模板

```bash
cd /opt/V2bX-Nodemix/configs
cp -r template node2

# 编辑新实例配置
nano node2/config.json
nano node2/sing_origin.json

# 启动新实例
v2bx-nodemix start node2
```

### 方法2：使用 Web 界面

1. 浏览器访问 `http://服务器IP:5000`
2. 点击"添加实例"（如果有此功能）
3. 在线编辑配置
4. 保存并启动

## 🔧 配置 WireGuard

### 生成密钥对

```bash
# 安装 WireGuard 工具
apt install wireguard-tools

# 生成密钥
wg genkey | tee privatekey | wg pubkey > publickey

# 查看私钥（填入 sing_origin.json）
cat privatekey

# 查看公钥（发给 WireGuard 服务器管理员）
cat publickey
```

### 编辑 sing_origin.json

```bash
nano /opt/V2bX-Nodemix/configs/example/sing_origin.json
```

修改以下字段：
```json
{
  "outbounds": [
    {
      "type": "wireguard",
      "tag": "wg-out",
      "server": "你的WireGuard服务器地址",
      "server_port": 51820,
      "private_key": "你的私钥",
      "peer_public_key": "服务器公钥",
      "local_address": ["分配给你的IP/掩码"]
    }
  ]
}
```

## 🔄 更新系统

```bash
cd /opt/V2bX-Nodemix
./update.sh
```

## ❓ 故障排查

### 实例无法启动

```bash
# 查看详细日志
v2bx-nodemix logs example 100

# 检查配置文件格式
cat /opt/V2bX-Nodemix/configs/example/config.json | jq .
cat /opt/V2bX-Nodemix/configs/example/sing_origin.json | jq .
```

### Web 界面无法访问

```bash
# 检查服务状态
systemctl status v2bx-nodemix-web

# 查看服务日志
journalctl -u v2bx-nodemix-web -f

# 检查端口占用
netstat -tlnp | grep 5000
```

### WireGuard 连接失败

```bash
# 测试 WireGuard 服务器连通性
ping WireGuard服务器地址
nc -zv WireGuard服务器地址 51820

# 检查密钥配置
grep -A 10 '"type": "wireguard"' /opt/V2bX-Nodemix/configs/example/sing_origin.json
```

## 🔒 安全建议

### 1. 限制 Web 访问

```bash
# 使用防火墙限制访问
ufw allow from 你的IP地址 to any port 5000
```

### 2. 使用 Nginx 反向代理

```nginx
server {
    listen 80;
    server_name v2bx.yourdomain.com;
    
    location / {
        proxy_pass http://127.0.0.1:5000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        
        # HTTP 基本认证
        auth_basic "Admin Area";
        auth_basic_user_file /etc/nginx/.htpasswd;
    }
}
```

### 3. 定期备份

```bash
# 备份配置
tar -czf v2bx-backup-$(date +%Y%m%d).tar.gz /opt/V2bX-Nodemix/configs/

# 自动备份（添加到 crontab）
0 2 * * * tar -czf /root/backups/v2bx-backup-$(date +\%Y\%m\%d).tar.gz /opt/V2bX-Nodemix/configs/
```

## 📚 更多帮助

- 详细文档: `/opt/V2bX-Nodemix/README.md`
- sing-box 文档: https://sing-box.sagernet.org/
- V2bX 项目: https://github.com/wyx2685/V2bX
- WireGuard 文档: https://www.wireguard.com/

---

**快速、简单、高效** 🚀
