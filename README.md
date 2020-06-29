# Cagebreak Archlinux Package

This repository provides a PKGBUILDs for [cagebreak](https://github.com/project-repo/cagebreak).

All releases on master are tagged corresponding to the cagebreak release and signed.

For every release we provide a tarball containing at least `.SRCINFO` and `PKGBUILD`
and a corresponing signature.

We also provide these PKGBUILDs in the [AUR](aur.archlinux.org).

## Cagebreak

This pkgbuild is provided for those who want a full build from source.

## Cagebreak-bin

This pkgbuild just extracts a precompiled binary and the man pages and therefore
requires no build dependencies (runtime dependencies are still required).

## Signing Keys

The following keys are valid:

  * A9C386EFBEB0819C5523E6AB2AD89C95DEA1AE85

Note that the key is signed by some signing keys of the cagebreak project.

## Release Automation

This is the minimally required commands for creating a release and generating
the PKGBUILDs for the [AUR](aur.archlinux.org).

  * [ ] git checkout development
  * [ ] git pull origin development
  * [ ] make version=release_tag release=pkgbuild_release gpgid=valid_gpg_id all
  * [ ] git commit
  * [ ] git checkout master
  * [ ] git merge --squash development
  * [ ] git tag -u valid_gpg_id release_tag HEAD
  * [ ] git tag -v release_tag
  * [ ] git push --tags origin master
  * [ ] upload artefacts
