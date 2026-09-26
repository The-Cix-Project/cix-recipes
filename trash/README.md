# trash/

Shell recipes that nothing reads any more, kept until the owner is
sure they are not needed and then deleted. Moved here 2026-09-25 on
the owner's instruction.

**Nothing in this directory is live.** It sits outside `recipes/`, so
cixd's recipe sync never sees it: the sync walks
`<extract>/recipes/package` (`daemon/src/pkg.c`, `recipes_root`).
Recipes already published to a host are immutable server-side and are
unaffected by a file moving here.

1538 files moved; 1545 shell recipe files existed. The count grew
after the original move: `openssh@10.4p1-13.cbs` (superseded by -14
for canonical declaration order, cix-build-system#245) and
`kernel@6.18.40-24.sh`.

## What did NOT move, and what holds each one

Nine files stayed under `recipes/package/`. Each is read by something
that runs today, measured 2026-09-25 rather than assumed:

| File | Held by |
|---|---|
| `bash@5.2.37-2.sh` | ADR-0209 test floor — `recipe_artifact_sha()` reads the artifact approval |
| `coreutils@9.11-3.sh` | same |
| `tcc@0.9.27-7.sh` | same |
| `linux-headers@6.18.40-4.sh` | same |
| `zlib@1.3.2-11.sh` | same |
| `flex@2.6.4-2.sh` | same |
| `binutils@2.42-10.sh` | same |
| `xz@5.8.3-8.sh` | same |

The eight floor entries are pinned by `floor_packages[]` in
`test/test_image_fixture.c` and gate every release since cix#485. They
stop being held when that table moves to versions whose recipes are
CPDL — which is an ordinary pin bump, not a conversion.

## The cbs bootstrap root moved too

`cbs@v0.1.25-1.sh` was held back for one afternoon on the belief that
it was the from-nothing root. It is not, and ADR-0309 point 5 already
said so: `mkbootroot` stages `/usr/bin/cbs` into every control-plane
root from cix-hosttools, and ADR-0307 clause 6 makes it REQUIRED --
assembly refuses a root without it. So every Cix host boots with a
CPDL engine before any package is installed, and building cbs from
source is an ordinary upgrade using the engine the host already runs.
cbs has built itself in CPDL for 27 revisions (`v0.1.25-2` through
`v0.1.56-1`). Nothing in either repository reads the shell file.

The seed is the previous Cix root -- Cix-built, not external, so the
Build Provenance Mandate holds. Same shape as tcc building tcc.
Confirmed by the owner 2026-09-25.

## 2026-09-26: eight held, not nine

`kernel@6.18.40-24.sh` moved here. It was held by
`test/test_kernelrecipe.c`, which tested `daemon/src/kernelrecipe.c`
— a pure text transform over `pkg_version=` / `pkg_source=` /
`pkg_sha256=`. Both were deleted with ADR-0309 clause 3: the
transform could no longer parse the kernel's own recipe, which has
been CPDL since `7.2.3-17`, nothing in the daemon ever called it, and
its test was in no gate. (`test_srcresolve.c` still names the string
`"6.18.40-24"`, but as a hardcoded version in an array — it does not
read this file. Checked before moving it.)

**The eight that remain are all ADR-0209 test-floor artifact
approvals**, read by `recipe_artifact_sha()`, and they are the
subject of cix#529. They will leave when the floor seeds from
`.cixpkg` artifacts instead of `tar.gz`.

**This directory is still not deleted, deliberately.** Deleting it
gives an operator nothing, and the No Stop-Gaps maxim's point about
janitorial work applies to removals as much as to additions. Every
file here is in git history regardless, and the versions they
describe are immutable server-side.
