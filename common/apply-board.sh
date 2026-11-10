#!/bin/bash
# 把 boards/<board>/ 注入到 SDK（轻量 BSP → 厂商树）
set -euo pipefail

BSP_DIR="$(cd "$(dirname "$0")/.." && pwd)"
BOARD="${1:?usage: apply-board.sh <board>}"
BOARD_DIR="$BSP_DIR/boards/$BOARD"

[ -d "$BOARD_DIR" ] || { echo "no board: $BOARD_DIR"; exit 1; }
# shellcheck source=/dev/null
source "$BOARD_DIR/board.conf"

SDK_DIR="${SDK_DIR:-$SDK_DIR_DEFAULT}"
CHIP_DIR="$SDK_DIR/device/rockchip/.chips/rk3576"
DTS_DIR="$SDK_DIR/kernel-6.1/arch/arm64/boot/dts/rockchip"
MAKEFILE="$DTS_DIR/Makefile"

[ -d "$SDK_DIR" ] || { echo "SDK missing: $SDK_DIR"; exit 1; }

echo "[apply] board=$BOARD → SDK=$SDK_DIR"

# 1) defconfig
install -m 0644 \
	"$BOARD_DIR/defconfig/$SDK_DEFCONFIG" \
	"$CHIP_DIR/$SDK_DEFCONFIG"

# 2) dts
install -m 0644 \
	"$BOARD_DIR/dts/${KERNEL_DTS}.dts" \
	"$DTS_DIR/${KERNEL_DTS}.dts"

# 3) Makefile 注册 dtb（幂等）
DTB_LINE="dtb-\$(CONFIG_ARCH_ROCKCHIP) += ${KERNEL_DTS}.dtb"
if ! grep -qF "${KERNEL_DTS}.dtb" "$MAKEFILE"; then
	# 插在 kickpi-k7 行后，没有则追加到文件中 rk3576 段附近
	if grep -q 'rk3576-kickpi-k7-linux.dtb' "$MAKEFILE"; then
		sed -i "/rk3576-kickpi-k7-linux.dtb/a\\${DTB_LINE}" "$MAKEFILE"
	else
		echo "$DTB_LINE" >> "$MAKEFILE"
	fi
	echo "[apply] Makefile += ${KERNEL_DTS}.dtb"
else
	echo "[apply] Makefile already has ${KERNEL_DTS}.dtb"
fi

# 4) 可选：kernel/uboot patches（有才打）
if [ -d "$BOARD_DIR/patches" ] && compgen -G "$BOARD_DIR/patches/*.patch" > /dev/null; then
	echo "[apply] patches: TODO wire quilt/git-am when needed"
fi

echo "[apply] ok: $SDK_DEFCONFIG + ${KERNEL_DTS}.dts"
