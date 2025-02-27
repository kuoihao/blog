---
date:
    created: 2025-02-21

---
<!-- more -->

1. dnschecker.org查询路由器ip地址
2. ssh root@[ipv6地址] 密码 lierwang
3. cat /proc/net/arp 获得设备mac  （/tmp/dhcp.leases）
4. 
5. wakeonlan -i 192.168.1.2 08:BF:B8:17:B5:92 
6. cat /tmp/hosts/odhcpd  获得设备ipv6地址


禁止debian休眠：
# Disable Debian休眠
sudo nano /etc/systemd/logind.conf
HandleLidSwitch=ignore
sudo service systemd-logind restart


# 笔记本合盖息屏不挂起

在tweak内general设置合盖不挂起即可
