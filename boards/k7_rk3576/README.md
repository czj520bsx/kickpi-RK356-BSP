# 板级包：k7_rk3576（CZJ）

轻量 BSP：**源文件只在本目录**；厂商 SDK 仅作编译池，由 `bsp/build.sh` 注入后再编。

## 目录

```text
k7_rk3576/
├── board.conf          # 板名 / 版本 / SDK 路径
├── defconfig/          # 注入 → device/rockchip/.chips/rk3576/
├── dts/                # 注入 → kernel-6.1/.../dts/rockchip/
├── patches/            # 预留：内核/U-Boot 补丁
├── overlay/            # 预留：rootfs 覆盖
├── changelog/          # 编译记录
└── README.md
```

## 用法

```bash
cd /home/li/rk3576/bsp
./build.sh k7 apply      # 只注入
./build.sh k7 lunch      # 注入 + 切配置
./build.sh k7 kernel     # 注入 + 编内核
./build.sh k7 all        # 注入 + 全量
```

`SDK_DIR=其它路径 ./build.sh k7 all` 可换 SDK。

## 烧录 / 验证

整包：`SDK/output/firmware/update.img`  
命令见 `../../杂项笔记/Linux烧录与网络排查.md`。

```bash
hostname
cat /proc/device-tree/model   # RK3576 K7 CZJ Board
```

## 现状

- 硬件仍 `#include` 官方 `rk3576-kickpi-k7.dtsi`
- hostname 在 defconfig：`k7-czj`（需编过 rootfs 才进镜像）
