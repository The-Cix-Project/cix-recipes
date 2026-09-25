#
# probe-gcc-limits -- is gcc's include-fixed/syslimits.h still a copy
# of limits.h in the CURRENT build sandbox, and does that still stop
# glibc's own <limits.h> being reached?
#
# elfutils@0.192-12 writes the correct chaining wrapper into
# .../include-fixed/syslimits.h before it configures, because this
# sandbox's gcc install shipped that file as a byte-for-byte copy of
# limits.h instead of the short #include_next wrapper a complete
# fixincludes/mkheaders run generates. That was root-caused by
# probe-gcc-headers v3..v6 during the 0.192-5 era and has not been
# re-measured since gcc moved to 16.2.0.
#
# It matters beyond elfutils: if it is still true, EVERY gcc-built
# package in this catalog compiles with glibc's limits.h unreachable
# through <limits.h>, and the recipe that noticed is simply the one
# that happened to need PATH_MAX.
#
# The C program is the real test. With a correct syslimits.h,
# <limits.h> chains to /usr/include/limits.h and PATH_MAX is 4096 and
# MB_LEN_MAX is 16. With a copy of limits.h in its place the chain is
# broken, PATH_MAX is undefined and MB_LEN_MAX falls back to 1.
#
# EXPECTED RESULT: the install FAILS, deliberately. Version 1
# exited 0 and its output was lost -- a successful build's stdout is
# not retained in the log store, only a failing one's is captured.
# So this ends in exit 1 and the verdict is in the failure output.
#
# Source moved to github on 2026-09-22 because version 2 could not
# fetch at all: "Could not resolve host: mirrors.kernel.org", twice,
# an hour after that exact URL fetched successfully. git.home.arpa
# resolved and fetched in the same window, so the box resolves LAN
# names and not that external one -- which this probe now also
# measures, incidentally, by using a different external host. A probe needs a real,
# checksum-verified fetch to reach pkg_build() at all, and reusing one
# just proven to fetch keeps this probe about the one thing it asks.
#
pkg_name="probe-gcc-limits"
pkg_version="3"
pkg_source="https://github.com/thom311/libnl/releases/download/libnl3_11_0/libnl-3.11.0.tar.gz"
pkg_sha256="2a56e1edefa3e68a7c00879496736fdbf62fc94ed3232c0baba127ecfa76874d"
pkg_depends=""
pkg_build_depends="bash coreutils gcc binutils linux-headers diffutils"
pkg_changelog="3: source moves to github because mirrors.kernel.org stopped resolving from the box. 2: ends in a deliberate exit 1, because version 1 exited 0 and its output was never retained -- only a failing build's stdout is captured. 1: re-measures whether gcc's include-fixed/syslimits.h is still a copy of limits.h, which elfutils@0.192-12 works around by rewriting that file -- a write CPDL cannot make, since it is outside the confined build roots. Not re-measured since gcc moved to 16.2.0."

pkg_build() {
	v=$(/usr/bin/gcc -dumpversion)
	echo "=== gcc ==="
	echo "version: $v"
	d="/usr/lib/gcc/x86_64-pc-linux-gnu/$v/include-fixed"
	echo "include-fixed: $d"
	ls "$d" 2>&1 | head -8

	gl="/usr/lib/gcc/x86_64-pc-linux-gnu/$v/include/limits.h"
	sl="$d/syslimits.h"
	echo "=== the two files ==="
	for f in "$gl" "$sl"; do
		if [ -e "$f" ]; then
			echo "  $(wc -c < "$f") bytes  $(sha256sum "$f" | cut -c1-16)  $f"
		else
			echo "  ABSENT  $f"
		fi
	done
	echo "=== syslimits.h, first 12 lines ==="
	head -12 "$sl" 2>&1 || true
	echo "=== are they identical? ==="
	if [ -e "$gl" ] && [ -e "$sl" ] && cmp -s "$gl" "$sl"; then
		echo "  IDENTICAL -- syslimits.h is a copy of limits.h (the defect)"
	else
		echo "  different -- syslimits.h is not a copy of limits.h"
	fi

	cat > limits_probe.c <<'EOF'
#include <limits.h>
#include <stdio.h>
int main(void)
{
#ifdef PATH_MAX
	printf("PATH_MAX=%d\n", (int)PATH_MAX);
#else
	printf("PATH_MAX=UNDEFINED\n");
#endif
	printf("MB_LEN_MAX=%d\n", (int)MB_LEN_MAX);
	return 0;
}
EOF
	echo "=== compiling the limits probe with /usr/bin/gcc ==="
	/usr/bin/gcc -o limits_probe limits_probe.c || {
		echo "  the probe did not compile" >&2
		exit 1
	}
	echo "=== verdict ==="
	./limits_probe
	echo "  correct chain: PATH_MAX=4096 MB_LEN_MAX=16"
	echo "  broken chain:  PATH_MAX=UNDEFINED MB_LEN_MAX=1"
	echo "probe-gcc-limits: deliberate failure so this output is kept" >&2
	exit 1
}

pkg_install() {
	mkdir -p "$PKG_DESTDIR/usr/share/probe-gcc-limits"
	./limits_probe > "$PKG_DESTDIR/usr/share/probe-gcc-limits/RESULT"
}
