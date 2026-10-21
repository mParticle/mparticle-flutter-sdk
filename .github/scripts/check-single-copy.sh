#!/bin/bash
# Counts the Mach-O images in an .app that define each class and expects exactly 1 each. Exits non-zero
# when an SDK is linked twice, for example from both CocoaPods and Swift Package Manager.
# Usage: .github/scripts/check-single-copy.sh path/to/Runner.app
set -u
APP="${1}"
bins=("${APP}/$(basename "${APP}" .app)" "${APP}/$(basename "${APP}" .app).debug.dylib")
while IFS= read -r fw; do
	bins+=("${fw}/$(basename "${fw}" .framework)")
done < <(find "${APP}/Frameworks" -maxdepth 1 -name '*.framework' 2>/dev/null || true)

status=0
for cls in MParticle RoktEmbeddedView MPKitRokt; do
	hits=()
	for b in "${bins[@]}"; do
		[[ -f ${b} ]] || continue
		if nm -U "${b}" 2>/dev/null | grep -qE "_OBJC_CLASS_\\\$_${cls}\$"; then hits+=("$(basename "${b}")"); fi
	done
	echo "${cls}: ${#hits[@]} [${hits[*]-}]"
	[[ ${#hits[@]} -eq 1 ]] || status=1
done
exit "${status}"
