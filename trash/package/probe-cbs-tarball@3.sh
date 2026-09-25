#
# probe-cbs-tarball -- learns the sha256 of the cix-build-system
# v0.1.53 gitea archive from the box, for cbs@v0.1.53-1.
#
# Same technique as probe-cix-tarball@1, which explains it: the
# sandbox may not download the tarball, and the daemon logs the real
# digest of any source whose declared pkg_sha256 is wrong. The fetch
# is the whole probe; the build never runs, and nothing is installed.
#
pkg_name="probe-cbs-tarball"
pkg_version="3"
pkg_source="https://osakka:{{REPO_TOKEN}}@git.home.arpa/api/v1/repos/itdlabs/cix-build-system/archive/v0.1.53.tar.gz"
# Deliberately wrong, and deliberately obvious: this is the probe.
pkg_sha256="0000000000000000000000000000000000000000000000000000000000000000"
pkg_depends=""
pkg_build_depends="bash coreutils"
pkg_changelog="3: the v0.1.53 archive, for cbs@v0.1.53-1. 2: the v0.1.52 archive, for cbs@v0.1.52-1. 1: learns the cix-build-system v0.1.50 archive's sha256 from the box's own fetch log, for cbs@v0.1.50-1."

pkg_build() { true; }
pkg_install() { true; }
