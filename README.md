# kickpi-RK356-BSP

轻量板级包（当前平台：**KickPi K7 / RK3576**；GitHub 仓名沿用 `kickpi-RK356-BSP`）。

厂商 SDK 负责编；**本仓库负责板级归属与交付脚本**。  
远程：https://github.com/czj520bsx/kickpi-RK356-BSP.git

```text
bsp/
├── build.sh                 # ./build.sh k7 [apply|lunch|all|kernel|…]
├── common/apply-board.sh    # 把 boards/<板>/ 注入 SDK
├── boards/k7_rk3576/        # 当前板级（defconfig + dts + …）
├── docs/                    # 启动/分区/编译理解
├── 杂项笔记/                 # 烧录等操作备忘
├── 方案/
└── notes/raw/
```

## 快速开始

```bash
cd /home/li/rk3576/bsp
./build.sh k7 apply
./build.sh k7 all
```

默认 SDK：`/home/li/rk3576/rk3576-linux-2026091008`（见 `boards/k7_rk3576/board.conf`）。

## 和笔记的关系

| 东西 | 放哪 |
|------|------|
| 板级 defconfig / DTS / 补丁 / 一键编译 | **本包 `boards/` + `build.sh`** |
| 原理笔记 | `docs/` |
| 命令备忘 | `杂项笔记/` |
