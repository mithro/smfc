# smfc, packaged for Debian (welland)

This is [mithro/apt-repo-action](https://github.com/mithro/apt-repo-action)'s
**Set A** layout (`docs/packaging.md`): a GitHub fork of
[petersulyok/smfc](https://github.com/petersulyok/smfc) with

- `upstream`: an unmodified copy of upstream's `main`, only ever
  fast-forwarded;
- `packaging` (the default branch): `upstream` plus our changes, `debian/`,
  `packaging/` and `.github/workflows/deb.yml` + `sync-upstream.yml`.

Nothing here is sent upstream without Tim's explicit approval.

## What is built

Upstream's **git `main`**: the current release (6.4.2 at the time of
writing) plus whatever has landed since, so a fix upstream merges reaches
us at the next weekly sync instead of the next release. The package is the
same `smfc` upstream publishes from
[petersulyok/smfc-deb](https://github.com/petersulyok/smfc-deb); this build
exists so the welland hosts take it from the same proxied, signed, per-suite
apt layout as every other package of ours, and so our own changes (see
below) ship as a package rather than a patched install.

## Where `debian/` comes from

Debian does not package smfc. `debian/` is **upstream's own**, kept in
place and changed as little as possible:

- `Maintainer:` is ours; upstream's is kept as `XSBC-Original-Maintainer:`;
- `Vcs-Browser:` / `Vcs-Git:` point here (`-b packaging`).

The package name stays `smfc`, and the version sorts above upstream's
release packages (see Version), so this build replaces one installed from
upstream's repository on upgrade. Upstream's `debian/changelog` is kept; the
build's entry goes on top of it.

## Our changes to upstream's code

Each is a commit on `packaging` with an `Upstream:` trailer saying where it
stands upstream. See `git log upstream..packaging -- ':!debian' ':!packaging' ':!.github'`.
None yet.

## Version

The shared `scripts/deb-version.py` (Set A):

    <release>[+git<N>.g<sha7>]-0+welland<M>[~deb<R>][~pr<P>]

`<release>` is upstream's nearest `vX.Y.Z` tag on `upstream`, `N` the
upstream commits since it (left out at the tag itself), `sha7` the upstream
commit built, and `M` the commits on `packaging` that aren't on `upstream`.
For example `6.4.2+git2.g199db31-0+welland3~deb13`: above upstream's own
`6.4.2`, below a `6.4.3`.

## Updating to a new upstream

`Sync upstream` (`.github/workflows/sync-upstream.yml`) runs weekly: it
fast-forwards `upstream`, pushes upstream's new tags, and opens the pull
request "Merge upstream <describe>" into `packaging`. Merge it with a merge
commit, never a rebase. By hand:

```sh
git fetch --tags https://github.com/petersulyok/smfc.git main
git push origin FETCH_HEAD:refs/heads/upstream --tags
git checkout -b sync/upstream origin/packaging
git merge --no-ff origin/upstream
```

## Install

```sh
sudo install -d -m0755 /etc/apt/keyrings
curl -fsSL https://mith.ro/smfc/smfc.gpg | sudo tee /etc/apt/keyrings/smfc.gpg > /dev/null
echo "deb [signed-by=/etc/apt/keyrings/smfc.gpg] https://mith.ro/smfc/trixie/ ./" \
  | sudo tee /etc/apt/sources.list.d/smfc.list
sudo apt update
```

Put your suite in place of `trixie`: `trixie`, `forky` or `sid`.

The repository's signing key fingerprint is
`2A2B C38D 0B82 1CBE ACE1  5A31 A19D 0911 3836 5A2F`.

On the welland hosts the repository is reached through the site apt-proxy
instead (`https://apt-proxy.welland.mithis.com/smfc/<suite>/`), which
mithro/welland-ansible-rpi's `apt_sources` role writes.
