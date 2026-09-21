#
# 2.8.0: hibr, and the manifest is trued up to what the image actually
# runs.
#
# HIBR is the point of this bump -- the owner's shell (Hackable
# In-process Bash Runtime, and حِبر, Arabic for ink), packaged as
# hibr 0.21-2. It installs /usr/bin/hibr plus four modules under
# /usr/lib/hibr. It is NOT set as anyone's login shell by this
# manifest: an image says what is installed, and which shell an
# account gets is an account-level decision.
#
# THE OTHER 26 LINES ARE THE DANGEROUS HALF OF THIS BUMP, and they
# are why it is not a one-line change.
#
# Measured against the running image before editing: 23 of the 31
# pinned packages named a version OLDER than the one installed, some
# by a lot -- zlib declared 1.3.2-2 against 1.3.2-14 installed,
# openssh 10.4p1-8 against 10.4p1-11, psmisc 23.7-1 against 23.7-8.
# A manifest is what a re-apply WRITES, which this file's own 2.2.0,
# 2.3.0 and 2.6.0 notes each learned separately, so applying the old
# pins to add one package would have DOWNGRADED twenty-three of them
# in the same operation. Adding hibr safely meant fixing that first.
#
# Three packages are newly DECLARED rather than re-pinned, because
# they were installed ad hoc and would have been removed by the very
# apply that adds hibr:
#
#   byobu 5.133-3      the terminal multiplexer wrapper actually used
#   fastfetch 2.68.1-4 the host summary printed on login
#   python 3.13.5-7    a real interpreter on a diagnosis box
#
# Nine more are installed and still NOT declared, deliberately:
# bzip2, diffutils, elfutils, gawk, libcap, libmnl, libxcrypt, sed
# and xz. Most are transitive (bzip2 via python, libmnl/elfutils/
# libcap via iproute2, libxcrypt via linux-pam), and this file's rule
# is that an image recipe declares what the image is FOR while apply
# resolves each package's own pkg_depends. sed, gawk and diffutils
# are the genuinely open case: 2.7.0 added grep and said in as many
# words that "the others are a separate decision rather than a reflex
# to add them all". That decision is still the owner's, so they stay
# undeclared here rather than being folded in by someone tidying.
#
# 2.7.0: git 2.55.0-8, and grep.
#
# 2.6.0 declared git:pinned:2.55.0-7, which cannot install at all --
# that revision links libz.so.1 while declaring zlib only as a BUILD
# dependency, so the elfcheck gate refuses it (#455). A manifest
# pinning a revision that cannot be installed is worse than one that
# omits the package: the omission is visible, the broken pin only
# surfaces on the next apply.
#
# grep is added because this image did not have it. A jump box whose
# whole purpose is interactive diagnosis shipped with coreutils and no
# grep, sed, gawk or findutils. grep is the one that was actually
# reached for; the others are a separate decision rather than a
# reflex to add them all.
#
# 2.6.0: declares the network tools the jump box is actually used for.
# Eight packages: iputils (ping), iproute2 (ip), net-tools (ifconfig),
# inetutils (telnet -- that recipe exists for exactly this client and
# builds nothing else), curl, wget, git, and ca-certificates.
#
# All eight were installed ad hoc first, which is the state this file
# has now had to correct three times (2.2.0 for htop, 2.3.0 for btop,
# and this one). The manifest is what a re-apply of this recipe
# writes, so a package that is installed but not declared survives
# only until the next apply.
#
# ca-certificates is not incidental to the other three network tools:
# curl, wget and git all verify public TLS against a CA bundle, and
# without one every HTTPS fetch from this box fails at verification
# rather than at the network. The platform's own /etc/ssl/certs/
# cix-ca-bundle.pem covers Cix's internal PKI only.
#
# Transitive dependencies are deliberately NOT listed here: iproute2
# pulls libmnl/elfutils/libcap, curl and wget pull openssl/zlib (both
# already declared for other reasons). An image recipe declares what
# the image is FOR, and apply resolves each package's own pkg_depends.
#
# 2.5.0: pin linux-pam 1.6.1-9, which declares the diffutils its
# configure has always reached for.
#
# 2.4.0: declares login (util-linux's login(1)) and moves linux-pam
# from 1.6.1-2 to 1.6.1-7 -- the bump is what made login buildable,
# every revision before -7 shipping a security/pam_misc.h that could
# not compile, so util-linux's configure concluded no PAM
# conversation function existed and refused to build login at all.
#
# jumpbox -- the image the `jump` container runs: an SSH entry point that
# authenticates against this platform's own LDAP live, rather than against
# copied-in files (ADR-0144/ADR-0145).
#
# 2.3.0: declares btop. 2.2.0: declares htop, and records the
# ADR-0108/ADR-0155 mechanism that makes an undeclared install
# evaporate: an image's version is a hash of its manifest, so
# installing without declaring leaves the hash unchanged,
# image_produce_new_version() dedups against the pre-existing
# directory, and the freshly built tree is discarded. Confirmed on
# 192.168.15.95: GET /v1/pkg/htop@jumpbox said installed with a real
# file list while `ls /usr/bin/htop` in the running container said no
# such file. 2.1.0: declares glibc, cixd refusing to start a
# container from an image whose manifest names no C library.
#
# See the cix-recipes README for what "version" means for an image
# recipe (ADR-0149, now cix ADR-0308's flat layout) versus an image's
# content-addressed build version (ADR-0108).
#
image_packages="bash:pinned:5.2.37-5 btop:pinned:1.4.7-1 byobu:pinned:5.133-3 ca-certificates:pinned:2026.09.03-1 coreutils:pinned:9.11-7 curl:pinned:8.21.0-5 dhcpcd:pinned:10.5.2-8 fastfetch:pinned:2.68.1-4 git:pinned:2.55.0-8 glibc:rolling:2.44 grep:pinned:3.11-7 hibr:pinned:0.21-2 htop:pinned:3.5.2-9 inetutils:pinned:2.5-4 iproute2:pinned:6.18.0-17 iputils:pinned:s20180629-4 libuuid:pinned:2.42.2-5 linux-pam:pinned:1.6.1-9 login:pinned:2.42.2-2 mtr:pinned:0.96-9 ncurses:pinned:6.6-10 net-tools:pinned:2.10-4 nss-pam-ldapd:pinned:0.9.13-6 openldap-client:pinned:2.6.14-5 openssh:pinned:10.4p1-11 openssl:pinned:3.0.20-5 perl:pinned:5.40.1-7 procps:pinned:4.0.6-9 psmisc:pinned:23.7-8 python:pinned:3.13.5-7 screen:pinned:5.0.2-7 tar:pinned:1.35-6 vim:pinned:9.1.1428-4 wget:pinned:1.25.0-2 zlib:pinned:1.3.2-14"
