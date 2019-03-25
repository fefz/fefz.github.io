---
title: shadowsocks配置netflix broker
date: 2019-03-22 22:32:49
tags: 科学上网
---

最近Netflix又有好剧了，虽然正在用的GGS家的LAX是US原生的IP，但是依然被Ban掉了，只能想点办法曲线救国。


### 步骤：

首先获取ss最新代码

`git clone https://github.com/shadowsocks/shadowsocks/ -b master `

CentOS安装所需依赖

```bash
sudo yum groupinstall 'Development Tools'
sudo yum install gettext gcc autoconf libtool automake make asciidoc xmlto c-ares-devel libev-devel
```

使用`chacha20`AEAD加密需要额外安装`libsodium`
```bash 
yum install epel-release
yum install libsodium`
```

打开shadowsocks所在路径,找到`shadowsocks/asyncdns.py`这个文件，找到`_send_req`这个方法,修改如下
```python
def _send_req(self, hostname, qtype):
        nfNameServer = '获取的DNS地址'
        req = build_request(hostname, qtype)
        for server in self._servers:
            logging.debug('resolving %s with type %d using server %s',
                          hostname, qtype, server)
            if 'netflix' in hostname or 'nflx' in hostname:
                self._sock.sendto(req, ('你获取的解锁DNS', 53))
            else:
                self._sock.sendto(req, (server, 53))

            self._sock.sendto(req, (server, 53))
```

修改完毕后，创建ss的服务并启动

```bash
echo "[Unit]
Description=ss deamon
After=rc-local.service

[Service]
Type=simple
User=root
Group=root
WorkingDirectory=/root/ss
ExecStart=/usr/bin/python shadowsocks/server.py -c config.json
Restart=always
LimitNOFILE=512000
[Install]
WantedBy=multi-user.target" > /etc/systemd/system/ss.service

systemctl start ss && systemctl enable ss

```

至此，可以Netflix试试看了。


