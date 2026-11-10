# 分区表（KickPi K7 / RK3576）

> 板：KickPi K7 · RK3576  
> SDK：rk3576-linux-2026091008  
> 日期：2026-11-09

## 来源

```text
device/rockchip/.chips/rk3576/parameter.txt
output/firmware/parameter.txt    # 软链到上面
```

## 怎么读

`CMDLINE` 格式：`size@offset(name)`，单位 **512 字节扇区**。  
`-@offset(name:grow)` = 从该偏移吃到 eMMC 末尾。

本板：

```text
CMDLINE: mtdparts=:0x00002000@0x00004000(uboot),0x00002000@0x00006000(misc),0x00020000@0x00008000(boot),0x00040000@0x00028000(recovery),0x00010000@0x00068000(backup),-@0x00078000(rootfs:grow)
uuid:rootfs=614e0000-0000-4b53-8000-1d28000054a9
uuid:boot=7A3F0000-0000-446A-8000-702F00006273
```

| 分区 | offset | 约从 | size | 约大小 |
|------|--------|------|------|--------|
| （Loader，在 mtdparts 前） | — | 片头 | — | MiniLoaderAll.bin |
| uboot | `0x4000` | 8MB | `0x2000` | 4MB |
| misc | `0x6000` | 12MB | `0x2000` | 4MB |
| boot | `0x8000` | 16MB | `0x20000` | 64MB |
| recovery | `0x28000` | 80MB | `0x40000` | 128MB |
| backup | `0x68000` | 208MB | `0x10000` | 32MB |
| rootfs | `0x78000` | 240MB | grow | 剩余 |

## 与启动的扣合

`uuid:rootfs=614e0000-…` ↔ DTS `root=PARTUUID=614e0000-0000`。  
对不上会挂不上根或挂错分区。

## 分区 ↔ 镜像 ↔ 何时烧

| 角色 | 镜像（`output/firmware/`） | 场景 |
|------|---------------------------|------|
| Loader | `MiniLoaderAll.bin` | 分烧常先 `ul`；很少单独改 |
| uboot | `uboot.img` | 改 U-Boot → `di -u` |
| misc | `misc.img` | 恢复/OTA 相关 |
| boot | `boot.img` | 改内核/DTS → `di -b` |
| recovery | `recovery.img` | 改 recovery |
| backup | RESERVED | 日常少烧 |
| rootfs | `rootfs.img` → ubuntu | 改根文件系统 |
| 整包 | `update.img` | 首次 / 大改 / 救砖 → `uf` |

## oem / userdata

`firmware/` 里可有 `oem.img`、`userdata.img`；编译开了 extra partition（`/oem`、`/userdata`）。  
**当前这份 `parameter.txt` 明文没有这两项**——读主布局以 CMDLINE 为准；改分区大小放到阶段 C。

## 相关

- 启动：[`boot.md`](boot.md)
- 编译：[`build.md`](build.md)
- 烧录命令：[`../杂项笔记/Linux烧录与网络排查.md`](../杂项笔记/Linux烧录与网络排查.md)
