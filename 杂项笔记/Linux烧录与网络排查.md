# Linux 烧录 & 网络（K7 / RK3576）

> KickPi K7 · 串口 `1500000` / `console=ttyFIQ0`

## 烧录（upgrade_tool）

```bash
cd /home/li/rk3576/rk3576-linux-2026091008
TOOL=tools/linux/Linux_Upgrade_Tool/Linux_Upgrade_Tool/upgrade_tool
FW=output/firmware
IMG=$FW/update.img

# 须进 Loader/MaskRom；2207:0006 是运行态，不能烧
lsusb | grep -i 2207
sudo $TOOL ld

# 整包
sudo $TOOL uf $IMG
sudo $TOOL uf $IMG -noreset   # 不重启

# 分烧（先 Loader）
sudo $TOOL ul -noreset $FW/MiniLoaderAll.bin
sudo $TOOL di -p $FW/parameter.txt
sudo $TOOL di -u $FW/uboot.img
sudo $TOOL di -b $FW/boot.img
sudo $TOOL di -r $FW/recovery.img
sudo $TOOL di -rootfs $FW/rootfs.img
sudo $TOOL di -oem $FW/oem.img
sudo $TOOL di -userdata $FW/userdata.img
sudo $TOOL rd

# 维护
sudo $TOOL sfi $IMG
sudo $TOOL rci
sudo $TOOL rfi
sudo $TOOL pl
sudo $TOOL rd 3                          # Loader → MaskRom
sudo $TOOL db $FW/MiniLoaderAll.bin      # MaskRom 只下 Boot
sudo $TOOL ef $FW/MiniLoaderAll.bin      # 整片擦除，慎用
```

| 参数 | 分区 |
|------|------|
| `-p` | parameter |
| `-u` | uboot |
| `-b` | boot |
| `-r` | recovery |
| `-m` | misc |
| `-oem` / `-rootfs` / `-userdata` | 同名分区 |

| 场景 | 命令 |
|------|------|
| 全量 | `uf $IMG` |
| 只改内核 | `di -b` → `rd` |
| 只改 U-Boot | `di -u` → `rd` |
| 只改 rootfs | `di -rootfs` → `rd` |
| 救砖 | MaskRom → `uf $IMG` |

路径：`tools/linux/Linux_Upgrade_Tool/Linux_Upgrade_Tool/upgrade_tool`  
镜像：`output/firmware/update.img`（可有 `update-rk3576-kickpi-k7-….img` 同内容）  
说明 PDF：同目录 `命令行开发工具使用文档.pdf`

## 网络谁在管

```bash
# 服务
systemctl is-active NetworkManager
systemctl is-active systemd-networkd
systemctl is-active networking

# 配置落点
ls /etc/netplan 2>/dev/null
ls /etc/NetworkManager 2>/dev/null
ls /etc/systemd/network 2>/dev/null
ls /etc/network/interfaces /etc/network/interfaces.d 2>/dev/null

# 进程
ps aux | grep -E 'NetworkManager|systemd-networkd|dhclient|dhcpcd|udhcpc|wpa_supplicant|connmand' | grep -v grep

ip link
ip addr
nmcli general
nmcli device status
nmcli connection show
```

按实际 `active` 的服务 + 进程改配置；`failed` 忽略。

### K7 Ubuntu 实测

```text
NetworkManager=active  systemd-networkd=inactive  networking=failed
end1 / Wired connection 2 → connected
```

NM 在管。有 `interfaces.d` 也不以 ifupdown 为准。

### 改 IP（NM）

```bash
nmcli connection show
nmcli device show end1 | grep -E 'IP4|GATEWAY|DNS'

sudo nmcli connection modify "Wired connection 2" \
  ipv4.method manual \
  ipv4.addresses 192.168.1.100/24 \
  ipv4.gateway 192.168.1.1 \
  ipv4.dns "8.8.8.8 114.114.114.114"
sudo nmcli connection up "Wired connection 2"

# DHCP
sudo nmcli connection modify "Wired connection 2" \
  ipv4.method auto ipv4.addresses "" ipv4.gateway "" ipv4.dns ""
sudo nmcli connection up "Wired connection 2"

ip addr show end1
```
