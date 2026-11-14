#!/usr/bin/env bash
# Runs every tests/*_smoke.gd and tests/*_test.gd headless; logs go to build/logs/.
# Usage: bash tools/run_tests.sh [godot-binary] [filter]
set -u
cd "$(dirname "$0")/.."
GODOT="${1:-${GODOT:-$(command -v godot4 || command -v godot)}}"
FILTER="${2:-}"
mkdir -p build/logs
failed=0
count=0
for test in tests/*_smoke.gd tests/*_test.gd; do
	[ -f "$test" ] || continue
	case "$test" in *"$FILTER"*) ;; *) continue ;; esac
	name="$(basename "$test" .gd)"
	log="build/logs/$name.log"
	count=$((count + 1))
	timeout 180 "$GODOT" --headless --path . --script "$test" >"$log" 2>&1
	code=$?
	# A script error that does not reach quit() would otherwise hang or exit 0.
	if [ $code -eq 0 ] && grep -q -E "SCRIPT ERROR|Parse Error" "$log"; then code=99; fi
	if [ $code -eq 0 ]; then
		echo "PASS  $name  $(grep -E '^PASS' "$log" | tail -n 1 | cut -c1-110)"
	else
		echo "FAIL  $name  (exit $code, log: $log)"
		grep -E "ERROR|FAIL" "$log" | grep -v "resources still in use" | head -n 5 | sed 's/^/      /'
		failed=$((failed + 1))
	fi
done
echo "tests: $count run, $failed failed"
[ $failed -eq 0 ] && [ $count -gt 0 ]
