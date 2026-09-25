# trash/

Shell recipes that nothing reads any more, kept until the owner is
sure they are not needed and then deleted. Moved here 2026-09-25 on
the owner's instruction.

**Nothing in this directory is live.** It sits outside `recipes/`, so
cixd's recipe sync never sees it: the sync walks
`<extract>/recipes/package` (`daemon/src/pkg.c`, `recipes_root`).
Recipes already published to a host are immutable server-side and are
unaffected by a file moving here.

1535 files moved; 1545 shell recipe files existed.

## What did NOT move, and what holds each one

Ten files stayed under `recipes/package/`. Each is read by something
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
| `kernel@6.18.40-24.sh` | `test/test_kernelrecipe.c` — the real-recipe fixture for `kernelrecipe.c`, which generates shell kernel revisions and retires with the shell path |
| `cbs@v0.1.25-1.sh` | the from-nothing bootstrap root: cixd has no CPDL executor, so building cbs from source needs a cbs (cix#516, ADR-0309 point 5) |

The eight floor entries are pinned by `floor_packages[]` in
`test/test_image_fixture.c` and gate every release since cix#485. They
stop being held when that table moves to versions whose recipes are
CPDL — which is an ordinary pin bump, not a conversion.
