# cix-recipes

Every recipe Cix builds from: packages, images and container deployments.

Split out of the [cix](https://git.home.arpa/itdlabs/cix) repository on
2026-09-21 (cix#505), with history preserved.

## Layout

One file per recipe, flat, in one directory per kind:

```
recipes/package/zstd@1.5.7-5.cbs
recipes/package/bash@5.2.37-6.cbs
recipes/image/cix-builder@1.4.0.sh
recipes/deployment/dns-1@1.2.0.json
```

`<name>@<version>.<ext>`, where the extension is the format: `cbs` for a
PBS recipe in CPDL, `sh` for a shell one (cix ADR-0305), `json` for a
container deployment definition.

It used to be `<name>/<version>/build.<ext>` — two directory levels
carrying two fields, under a leaf filename that was the same two
strings 1577 times over, so every editor tab, grep hit and diff header
said `build.cbs` and only the path said which recipe it was. Every one
of those directories held exactly one file, so they carried nothing the
filename could not.

`@` is the separator because it is already Cix's name/version separator
wherever it prints one (`glibc@2.44-14`, `kmod@cix-builder`), and
because no recipe name contains one.

## How a host gets these

`cixctl pkg sync`. The daemon fetches an archive of this repository and
walks `recipes/`; the repository it fetches is set with
`cixctl pkg repo-config set --url=`.

Recipe versions are **immutable** (cix ADR-0107): a published version is
never edited, only superseded by a new one. That is why old revisions
stay here — an artifact in the cache is only explicable by the exact
recipe that produced it.

## Tests

`test/` holds the gates that assert things about recipe *content*, and
they moved here with the recipes they test. Tests of daemon behaviour
stayed in `cix`.
