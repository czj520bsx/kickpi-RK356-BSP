# build.sh 流水线（KickPi K7 / RK3576）

> 板：KickPi K7 · RK3576  
> SDK：rk3576-linux-2026091008  
> 日期：2026-11-09

## 入口

```bash
cd /home/li/rk3576/rk3576-linux-2026091008
./build.sh lunch          # 选板级 defconfig
./build.sh uboot          # / loader
./build.sh kernel
./build.sh recovery
./build.sh all            # 全量 → update.img
```

根目录 `build.sh`：选配置 + 调 hook；真正干活在：

`device/rockchip/common/scripts/mk-*.sh`

## 本板 defconfig

`device/rockchip/.chips/rk3576/rockchip_rk3576_kickpi_k7_ubuntu_defconfig`

```text
RK_ROOTFS_SYSTEM_UBUNTU=y
RK_UBOOT_SPL=y
RK_KERNEL_DTS_NAME="rk3576-kickpi-k7-linux"
RK_USE_FIT_IMG=y
RK_ROOTFS_SYSTEM=ubuntu
```

生效全集：`output/final.env`（例：`RK_UBOOT_CFG=rk3576`，`RK_KERNEL_CFG=rockchip_linux_defconfig`，`RK_PARAMETER=parameter.txt`）。

## `all` 顺序（`mk-all.sh`）

```text
mk-misc.sh      → misc.img
mk-loader.sh    → MiniLoaderAll.bin, uboot.img
mk-kernel.sh    → boot.img（+ DTB，FIT）
mk-rootfs.sh    → rootfs.img（Ubuntu → ubuntu-rootfs.img）
mk-recovery.sh  → recovery.img
mk-firmware.sh  → 汇总软链到 output/firmware/
mk-updateimg.sh → 按 parameter 打 update.img
```

| 脚本 | 作用 |
|------|------|
| `mk-firmware.sh` | `parameter.txt` 链进 firmware；补齐 Loader；列打包文件 |
| `mk-updateimg.sh` | `package-file`：bootloader / 各分区 `.img` → `update.img` |

## 产物落点（`output/firmware/`）

| 文件 | 来自 |
|------|------|
| `MiniLoaderAll.bin` | u-boot 编出的 spl loader |
| `uboot.img` | u-boot |
| `boot.img` | kernel-6.1 |
| `rootfs.img` | ubuntu/ubuntu-rootfs.img |
| `recovery.img` | recovery |
| `parameter.txt` | `.chips/rk3576/parameter.txt` |
| `update.img` | 整包（可有带板名软链） |

## 增量

| 改动 | 编 | 烧 |
|------|----|----|
| 内核 / DTS | `./build.sh kernel` | `di -b boot.img` |
| U-Boot | `./build.sh uboot` | `di -u uboot.img` |
| 首次 / 大改 | `./build.sh all` | `uf update.img` |

## 已知坑

| 问题 | 处理 |
|------|------|
| recovery `android-adbd` 下载截断 / hash 不对 | 重打包进 `buildroot/dl/` 并改 hash 后重编 recovery |

## 相关

- 启动：[`boot.md`](boot.md)
- 分区：[`partition.md`](partition.md)
- 方案：[`../方案/K7-RK3576-BSP-AI方案.md`](../方案/K7-RK3576-BSP-AI方案.md)
