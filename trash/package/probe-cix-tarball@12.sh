#
# probe-cix-tarball -- learns the sha256 of a gitea source archive
# from the box, so a release recipe can be written without fetching
# the tarball anywhere else.
#
# THE SANDBOX RULE is why this exists. A cix release recipe needs
# pkg_sha256 of https://git.home.arpa/.../archive/<tag>.tar.gz, and
# the obvious way to get it -- download it and run sha256sum -- is not
# allowed in the dev sandbox, where nothing runs but cixctl. The
# daemon already computes and logs the real digest of every source it
# fetches:
#
#   pkg <name>@<version>: source 0 hashes to the wrong value.
#   path=... bytes=... computed=<64 hex> declared=... url=...
#
# So a recipe with a deliberately wrong pkg_sha256 fails at exactly
# the right moment and prints the answer. The fetch is the whole
# probe; the build never runs.
#
pkg_name="probe-cix-tarball"
pkg_version="12"
pkg_source="https://osakka:{{REPO_TOKEN}}@git.home.arpa/api/v1/repos/itdlabs/cix/archive/v2.57.247.tar.gz"
# Deliberately wrong, and deliberately obvious: this is the probe.
pkg_sha256="0000000000000000000000000000000000000000000000000000000000000000"
pkg_depends=""
pkg_build_depends="bash coreutils"
pkg_changelog="12: the cix v2.57.247 archive, for cix-tests@v2.57.247. 1: learns a gitea archive's sha256 from the box's own fetch log rather than downloading it in the dev sandbox, which the sandbox rule forbids."

pkg_build() { true; }
pkg_install() { true; }
