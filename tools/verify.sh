#!/usr/bin/env bash
# Dino Hop! full check: import -> all headless tests -> Linux/Windows exports ->
# Android export attempt -> build/ output check. Exits non-zero on any failure.
# A missing Android SDK/Java is reported clearly but does not fail the run.
#
# Environment (optional):
#   GODOT                               Godot 4 binary (default: godot4 or godot on PATH)
#   GODOT_ANDROID_KEYSTORE_DEBUG_PATH   debug keystore (else a local one is made in build/)
#   GODOT_ANDROID_KEYSTORE_DEBUG_USER / _PASSWORD
#   DINO_TEMPLATES_URL                  override the export-template download URL
#   CAPTURE=1                           also re-render ciktilar/ekran/ (tools/capture.sh)
set -u
cd "$(dirname "$0")/.."
ROOT="$PWD"
step() { printf '\n== %s\n' "$*"; }
fail() { echo "VERIFY FAILED: $*"; exit 1; }

# 1) Godot binary
GODOT="${GODOT:-}"
if [ -z "$GODOT" ]; then
	for candidate in godot4 godot; do
		if command -v "$candidate" >/dev/null 2>&1; then GODOT="$(command -v "$candidate")"; break; fi
	done
fi
[ -n "$GODOT" ] || fail "Godot 4 not found (install godot4/godot or set GODOT=...)"
VERSION_FULL="$("$GODOT" --version 2>/dev/null | tail -n 1)"
case "$VERSION_FULL" in 4.*) ;; *) fail "Godot 4 required, found '$VERSION_FULL' at $GODOT" ;; esac
TEMPLATE_VERSION="$(echo "$VERSION_FULL" | sed -E 's/^([0-9]+\.[0-9]+(\.[0-9]+)?\.(stable|rc[0-9]*|beta[0-9]*|dev[0-9]*)).*/\1/')"
echo "godot: $GODOT ($VERSION_FULL, templates $TEMPLATE_VERSION)"
mkdir -p build/logs build/linux build/windows build/android
touch build/.gdignore

# 2) Export templates: user install, else a project-local cache (downloaded once).
USER_TEMPLATES="${XDG_DATA_HOME:-$HOME/.local/share}/godot/export_templates/$TEMPLATE_VERSION"
LOCAL_DATA="$ROOT/.cache/godot-data"
LOCAL_TEMPLATES="$LOCAL_DATA/godot/export_templates/$TEMPLATE_VERSION"
need=(linux_release.x86_64 windows_release_x86_64.exe)
have_templates() { for f in "${need[@]}"; do [ -f "$1/$f" ] || return 1; done; }
if have_templates "$USER_TEMPLATES"; then
	echo "templates: $USER_TEMPLATES"
else
	if ! have_templates "$LOCAL_TEMPLATES"; then
		step "Export templates missing -> downloading into .cache/ (one time)"
		TAG="$(echo "$TEMPLATE_VERSION" | sed -E 's/\.(stable|rc[0-9]*|beta[0-9]*|dev[0-9]*)$/-\1/')"
		URL="${DINO_TEMPLATES_URL:-https://github.com/godotengine/godot/releases/download/$TAG/Godot_v$TAG\_export_templates.tpz}"
		URL="${URL//\\_/_}"
		mkdir -p .cache/dl "$LOCAL_TEMPLATES"
		if [ ! -s .cache/dl/templates.tpz ]; then
			curl -fL --retry 3 -o .cache/dl/templates.tpz.part "$URL" && mv .cache/dl/templates.tpz.part .cache/dl/templates.tpz \
				|| fail "could not download export templates from $URL"
		fi
		unzip -o -j -q .cache/dl/templates.tpz templates/version.txt "templates/linux_*.x86_64" "templates/windows_*_x86_64*.exe" "templates/android_*.apk" -d "$LOCAL_TEMPLATES" \
			|| fail "could not unpack export templates"
	fi
	echo "templates: $LOCAL_TEMPLATES (project-local cache)"
	export XDG_DATA_HOME="$LOCAL_DATA"
fi

# 3) Import
step "Import (--import)"
timeout 600 "$GODOT" --headless --path . --import >build/logs/import.log 2>&1 || { tail -n 20 build/logs/import.log; fail "import failed"; }
if grep -E "SCRIPT ERROR|Parse Error|ERROR: Failed" build/logs/import.log; then fail "import reported errors (build/logs/import.log)"; fi
echo "import: ok"

# 4) Tests
step "Tests (tests/*_smoke.gd, tests/*_test.gd)"
bash tools/run_tests.sh "$GODOT" || fail "tests failed (logs in build/logs/)"

# Evidence: the rig checks behind the acceptance criterion (9 hero animations, two enemy rigs).
step "Animation evidence (build/logs/animation_test.log)"
ANIM_LOG=build/logs/animation_test.log
for anim in idle walk run jump fall land attack hurt die; do
	grep -q "ok: animation '$anim' exists" "$ANIM_LOG" || fail "Çağan animation '$anim' missing"
done
echo "  Çağan: idle walk run jump fall land attack hurt die (+ climb), cross-faded state machine"
grep -E "ok: (planted foot|every transition)" "$ANIM_LOG" | sed 's/^ *ok: /  /'
for rig in enemy_dino enemy_second; do
	# No [a-z] ranges here: under a Turkish locale they skip the dotted "i".
	anims="$(grep -o -E "ok: $rig animation '[^']+'" "$ANIM_LOG" | cut -d"'" -f2 | tr '\n' ' ')"
	[ -n "$anims" ] || fail "$rig rig not verified"
	echo "  $rig: $anims"
done

# Screenshots are rendered by tools/capture.sh (needs a display) and kept in git.
step "Screenshots (ciktilar/ekran/)"
for group in "oyun içi:0[1-4]-oyun-*.png" "Çağan animasyonları:cagan-[0-9]*.png" "düşmanlar:dusman-*.png" "mobil:05-mobil-*.png" "taslak A:06-taslak-a-*.png"; do
	count="$(ls ciktilar/ekran/${group#*:} 2>/dev/null | wc -l)"
	[ "$count" -gt 0 ] || fail "no screenshot for ${group%%:*} (run tools/capture.sh)"
	printf '  %-22s %s png\n' "${group%%:*}" "$count"
done

# 5) Desktop exports
export_preset() { # name, mode, output
	timeout 900 "$GODOT" --headless --path . "--export-$2" "$1" "$3" >"build/logs/export-${1// /_}.log" 2>&1
}
step "Export: Linux"
rm -f build/linux/dino-hop.x86_64 build/linux/dino-hop.pck
export_preset "Linux" release build/linux/dino-hop.x86_64 || { tail -n 15 build/logs/export-Linux.log; fail "Linux export failed"; }
step "Export: Windows Desktop"
rm -f build/windows/dino-hop.exe build/windows/dino-hop.pck
export_preset "Windows Desktop" release build/windows/dino-hop.exe || { tail -n 15 "build/logs/export-Windows_Desktop.log"; fail "Windows export failed"; }

# 6) Android (debug, arm64). Keystore path comes from the environment only.
step "Export: Android (debug, arm64)"
ANDROID_STATUS="skipped"
if [ -z "${GODOT_ANDROID_KEYSTORE_DEBUG_PATH:-}" ] && command -v keytool >/dev/null 2>&1; then
	KS="$ROOT/build/android/debug.keystore"
	if [ ! -f "$KS" ]; then
		keytool -genkeypair -v -keystore "$KS" -storepass android -alias androiddebugkey -keypass android \
			-keyalg RSA -keysize 2048 -validity 10000 -dname "CN=Android Debug,O=Android,C=US" >build/logs/keytool.log 2>&1
	fi
	export GODOT_ANDROID_KEYSTORE_DEBUG_PATH="$KS"
	export GODOT_ANDROID_KEYSTORE_DEBUG_USER="${GODOT_ANDROID_KEYSTORE_DEBUG_USER:-androiddebugkey}"
	export GODOT_ANDROID_KEYSTORE_DEBUG_PASSWORD="${GODOT_ANDROID_KEYSTORE_DEBUG_PASSWORD:-android}"
	echo "android keystore: generated local debug keystore (build/, not in git)"
fi
rm -f build/android/dino-hop.apk
if export_preset "Android" debug build/android/dino-hop.apk && [ -f build/android/dino-hop.apk ]; then
	ANDROID_STATUS="built"
	echo "android: build/android/dino-hop.apk"
else
	LOG="build/logs/export-Android.log"
	if grep -q -i -E "SDK|Java|template|şablon|adb|apksigner|build-tools|platform-tools|keystore" "$LOG"; then
		echo "ANDROID EXPORT SKIPPED - missing Android toolchain on this machine:"
		grep -i -E "SDK|Java|template|şablon|adb|apksigner|build-tools|platform-tools|keystore" "$LOG" | grep -v "^\s*at:" | sed 's/^/   /' | head -n 8
		echo "   Fix: install JDK 17 + Android SDK (platform-tools, build-tools) and set them in"
		echo "   Editor Settings > Export > Android, then run this script again."
	else
		tail -n 15 "$LOG"
		fail "Android export failed for a reason other than a missing SDK"
	fi
fi

# 7) Outputs
step "Build outputs"
for f in build/linux/dino-hop.x86_64 build/linux/dino-hop.pck build/windows/dino-hop.exe build/windows/dino-hop.pck; do
	[ -s "$f" ] || fail "missing $f"
	printf '  %-32s %s bytes\n' "$f" "$(stat -c %s "$f")"
done
[ "$ANDROID_STATUS" = "built" ] && printf '  %-32s %s bytes\n' build/android/dino-hop.apk "$(stat -c %s build/android/dino-hop.apk)"

if [ "${CAPTURE:-0}" = "1" ]; then
	step "Screenshots"
	bash tools/capture.sh || fail "screenshot capture failed"
fi
echo
echo "VERIFY OK (android: $ANDROID_STATUS)"
