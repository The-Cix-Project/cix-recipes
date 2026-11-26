# cix-recipes

The Cix catalogue: package and image recipes, which any Cix host may use.
A site's container deployments live in that site's own repository (cix
ADR-0396); `recipes/deployment/` here is empty by design.

Split out of the [cix](https://git.home.arpa/itdlabs/cix) repository on
2026-09-21 (cix#505), with history preserved.

## Layout

One file per recipe, flat, in one directory per kind:

```
recipes/package/zstd@1.5.7-5.cbs
recipes/package/bash@5.2.37-6.cbs
recipes/image/cix-builder@6.2.1.json
```

`<name>@<version>.<ext>`, where the extension is the format: `cbs` for a
package recipe in CPDL, `json` for an image recipe. There are no shell recipes (cix ADR-0329).

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
walks `recipes/`; the sources a host fetches from are set with
`cixctl pkg source` (cix ADR-0324).

Recipe versions are **immutable** (cix ADR-0107): a published version is
never edited, only superseded by a new one. That is why old revisions
stay here — an artifact in the cache is only explicable by the exact
recipe that produced it.

## Tests

`test/` holds the gates that assert things about recipe *content*, and
they moved here with the recipes they test. Tests of daemon behaviour
stayed in `cix`.

## Licence

The recipes and the tests in this repository are under the [MIT
licence](LICENSE). That covers the recipe files, not the software they build:
each package keeps its upstream licence, which its recipe records in its
`license` line, and `recipes/keys/` holds upstream projects' public signing
keys, published by their owners. The Cix name and marks, and what counts as an
official Cix catalogue, are governed separately by [TRADEMARK.md](TRADEMARK.md).
