# 启动顺序（KickPi K7 / RK3576）

> 板：KickPi K7 · RK3576  
> SDK：rk3576-linux-2026091008  
> 配置：`rockchip_rk3576_kickpi_k7_ubuntu_defconfig`  
> 日期：2026-11-09

## 链条

```text
上电
 → MaskRom / MiniLoader（MiniLoaderAll.bin）
 → U-Boot（uboot 分区）
 → 加载 boot 分区 FIT（内核 + DTB + resource）
 → Kernel（bootargs 挂 rootfs）
 → Ubuntu systemd → 登录
```

| 串口特征 | 阶段 |
|----------|------|
| `U-Boot` / `Hit any key` | 仍在 U-Boot |
| `Starting kernel` / `Linux version` / `Kernel command line` | U-Boot 已过 |
| `login:` / `kickpi@` | rootfs 起来 |

## 板级 DTS 叠层

入口（lunch：`RK_KERNEL_DTS_NAME=rk3576-kickpi-k7-linux`）：

`kernel-6.1/arch/arm64/boot/dts/rockchip/rk3576-kickpi-k7-linux.dts`

```text
#include "rk3576.dtsi"              # SoC 公共（先别通读）
#include "rk3576-kickpi-k7.dtsi"    # 本板外设
#include "rk3576-linux.dtsi"        # bootargs + 调试串口
```

本板外设入口：`rk3576-kickpi-k7.dtsi`（HDMI/网口/WiFi/cam 等 include）。

## 串口与 bootargs

文件：`rk3576-linux.dtsi`

| 项 | 值 |
|----|-----|
| earlycon | `uart8250,mmio32,0x2ad40000`（UART0） |
| console | `ttyFIQ0` |
| FIQ | `rockchip,serial-id = <0>`，`baudrate = <1500000>` |
| root | `PARTUUID=614e0000-0000`（对齐 parameter 的 rootfs uuid） |

只改 DTS 里 `baudrate` 只影响**内核** FIQ 台；U-Boot 另有 `CONFIG_BAUDRATE`，两边不一致会分段乱码。本板维持 **1500000**。

## boot 分区内容

`device/rockchip/.chips/rk3576/boot.its`：FIT = fdt + kernel + resource → 编成 `boot.img`。  
改内核 / DTS → 重编 kernel → 烧 `boot.img`。

## 相关

- 分区：[`partition.md`](partition.md)
- 编译：[`build.md`](build.md)
- 烧录：[`../杂项笔记/Linux烧录与网络排查.md`](../杂项笔记/Linux烧录与网络排查.md)
