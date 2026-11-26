# recipes/deployment/

**Empty by design.** This catalogue holds packages and images: the platform, which any Cix host may use. A deployment is one site's container, with its addresses, networks and groups, so it lives in that site's own repository, which the site's box takes as a source ([ADR-0396](https://git.uk.home.arpa/itdlabs/cix/src/branch/master/docs/adr/0396-a-sites-deployments-live-in-the-sites-own-repository.md)).

The layout there is the same: `recipes/deployment/<name>@<version>.json`, whose content is a `POST /v1/containers` body applied by `POST /v1/deployments/{name}/apply`. Add the repository on the box with `cixctl pkg source add NAME --url=URL --kind=gitea --token=TOKEN [--write=on]`.

Deployments were removed from this repository's history on 2026-11-26, so commit ids from before that date no longer resolve here.
