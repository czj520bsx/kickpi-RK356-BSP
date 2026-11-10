#!/bin/bash
# 轻量 BSP 入口：./build.sh k7 [all|kernel|uboot|recovery|apply|lunch]
set -euo pipefail

BSP_DIR="$(cd "$(dirname "$0")" && pwd)"
BOARD_ALIAS="${1:-}"
TARGET="${2:-all}"

usage() {
	cat <<EOF
usage: $0 <board> [target]

boards:  k7 | k7_rk3576
targets: apply | lunch | all | kernel | uboot | recovery | firmware

例:
  $0 k7 apply     # 只注入 SDK，不编译
  $0 k7 lunch     # 注入 + 切 defconfig
  $0 k7 all       # 注入 + 全量编译
  $0 k7 kernel    # 注入 + 只编内核
EOF
	exit 1
}

[ -n "$BOARD_ALIAS" ] || usage

case "$BOARD_ALIAS" in
	k7|k7_rk3576|k7_rk3576_czj) BOARD=k7_rk3576 ;;
	*) echo "unknown board: $BOARD_ALIAS"; usage ;;
esac

BOARD_DIR="$BSP_DIR/boards/$BOARD"
# shellcheck source=/dev/null
source "$BOARD_DIR/board.conf"
SDK_DIR="${SDK_DIR:-$SDK_DIR_DEFAULT}"
STAMP="$(date +%Y%m%d-%H%M%S)"
LOG_DIR="$BOARD_DIR/changelog"
mkdir -p "$LOG_DIR"

# 始终先注入（源在 bsp，不在 SDK）
"$BSP_DIR/common/apply-board.sh" "$BOARD"

cd "$SDK_DIR"

case "$TARGET" in
	apply)
		echo "[build] apply only"
		exit 0
		;;
	lunch|defconfig)
		./build.sh "$SDK_DEFCONFIG"
		;;
	kernel|uboot|recovery|all|firmware|updateimg)
		./build.sh "$SDK_DEFCONFIG"
		./build.sh "$TARGET"
		;;
	*)
		usage
		;;
esac

{
	echo "## $STAMP  $BOARD  v$VERSION  target=$TARGET"
	echo "- bsp: $BSP_DIR"
	echo "- sdk: $SDK_DIR"
	echo "- defconfig: $SDK_DEFCONFIG"
	echo "- dts: $KERNEL_DTS"
	if [ -e "$SDK_DIR/output/firmware/update.img" ]; then
		echo "- update.img: $(readlink -f "$SDK_DIR/output/firmware/update.img" 2>/dev/null || true)"
		ls -lh "$SDK_DIR/output/firmware/update.img" 2>/dev/null | awk '{print "- size:", $5}'
	fi
	echo
} | tee -a "$LOG_DIR/CHANGELOG.md"

echo "[build] done → $LOG_DIR/CHANGELOG.md"
