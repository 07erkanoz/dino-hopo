#!/usr/bin/env bash
# Renders the acceptance screenshots into ciktilar/ekran/ (tests/capture_screens.gd).
# Needs a GPU-backed display: uses xvfb-run when available, otherwise a private
# headless KWin Wayland session, otherwise an existing $DISPLAY.
set -u
cd "$(dirname "$0")/.."
GODOT="${GODOT:-$(command -v godot4 || command -v godot)}"
mkdir -p ciktilar/ekran build/logs
LOG=build/logs/capture.log
# Screens first, then one Skeleton2D contact sheet per rig.
run() {
	"$@" --path . --script tests/capture_screens.gd >"$LOG" 2>&1 || return 1
	for rig in cagan dino ptero; do
		"$@" --path . --script tests/capture_rig_sheet.gd -- "$rig" "res://ciktilar/ekran/rig-$rig.png" >>"$LOG" 2>&1 || return 1
	done
}
if command -v xvfb-run >/dev/null 2>&1; then
	echo "capture: xvfb-run"
	run xvfb-run -a -s "-screen 0 1920x1080x24" "$GODOT" --rendering-driver opengl3
	code=$?
elif command -v kwin_wayland >/dev/null 2>&1; then
	echo "capture: headless kwin_wayland (xvfb-run not installed)"
	SOCKET="dinohop-capture-$$"
	kwin_wayland --virtual --socket "$SOCKET" --width 1920 --height 1080 --no-lockscreen --no-global-shortcuts >build/logs/kwin.log 2>&1 &
	KWIN=$!
	for i in $(seq 1 50); do [ -S "${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/$SOCKET" ] && break; sleep 0.1; done
	WAYLAND_DISPLAY="$SOCKET" run "$GODOT" --display-driver wayland --rendering-driver opengl3
	code=$?
	kill "$KWIN" 2>/dev/null
	wait "$KWIN" 2>/dev/null
elif [ -n "${DISPLAY:-}" ]; then
	echo "capture: DISPLAY=$DISPLAY"
	run "$GODOT" --rendering-driver opengl3
	code=$?
else
	echo "capture: no display available (install xvfb-run)"
	exit 2
fi
grep -E "^(SAVED|PASS)" "$LOG"
[ $code -eq 0 ] && ! grep -q "SCRIPT ERROR" "$LOG"
