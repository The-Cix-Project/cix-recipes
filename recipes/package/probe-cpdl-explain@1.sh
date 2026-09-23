#
# probe-cpdl-explain -- which published CPDL recipe does the current
# engine refuse?
#
# On 2026-09-23 the daemon's engine-change sweep (cbs 0.1.34 -> 0.1.52,
# and again -> 0.1.53) reported "re-derived 229 identities, 1 failed"
# without naming the recipe. This runs exactly what the sweep runs,
# `cbs explain --json`, over every .cbs in the corpus, and prints each
# one the engine rejects with its diagnostic. It exits 1 on purpose so
# the answer stays in the retained build log (`pkg build-logs`); the
# build is the whole probe.
#
pkg_name="probe-cpdl-explain"
pkg_version="1"
pkg_source="https://osakka:{{REPO_TOKEN}}@git.home.arpa/api/v1/repos/itdlabs/cix-recipes/archive/982a387f0e322738fa5a8d6b9a115a76857a4907.tar.gz"
pkg_sha256="3abae63080b80c4f497af09a3b415bfd74bbb186f1a81855d42eead91f522766"
pkg_depends=""
pkg_build_depends="bash coreutils cbs"
pkg_changelog="1: runs cbs explain --json over every published .cbs to name the recipe the engine-change sweep failed on."

pkg_build() {
	cbs --version
	total=0
	bad=0
	for f in */recipes/package/*.cbs; do
		total=$((total + 1))
		if ! cbs explain --json "$f" > /dev/null 2> /run/explain.err; then
			bad=$((bad + 1))
			echo "REJECTED: $f"
			cat /run/explain.err
		fi
	done
	echo "explained $total, rejected $bad"
	exit 1
}
pkg_install() { true; }
