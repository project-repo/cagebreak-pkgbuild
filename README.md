# Cagebreak Archlinux Package

This repository provides PKGBUILDs for [cagebreak](https://github.com/project-repo/cagebreak).

All releases on master are tagged corresponding to the cagebreak release and signed.

For every release we provide a tarball containing at least `.SRCINFO` and `PKGBUILD`
and a corresponing signature.

We also provide these PKGBUILDs in the [AUR](aur.archlinux.org).

## Cagebreak

This pkgbuild is provided for those who want a full build from source.

## Cagebreak-bin

This pkgbuild simply extracts a precompiled binary and the man pages and therefore
requires no build dependencies (runtime dependencies are still required).

## cagebreak-arm

This aarch64 pkgbuild is not officially supported and not in the AUR.

## Signing Keys

The following keys are valid:

  * A9C386EFBEB0819C5523E6AB2AD89C95DEA1AE85
  * FC9B267D2C4AE25E139BADF5B093C3C73E9053A1
  * 7857F021E8808412DD6C2F8849B3AD1FFEA4AE42

Note that the keys are signed by at least one signing key of the cagebreak project.

## Release Automation

These are the minimally required commands for creating a release and generating
the PKGBUILDs for the [AUR](aur.archlinux.org).

  * [ ] `git checkout development`
  * [ ] `git pull origin development`
  * [ ] `make clean`
  * [ ] `make version=release_tag release=pkgbuild_release gpgid=valid_gpg_id check`
  * [ ] `git commit`
  * [ ] `git push origin development`
  * [ ] `git checkout master`
  * [ ] `git merge --squash development`
  * [ ] `git commit` and insert "Release version"
  * [ ] `git tag -u valid_gpg_id release_tag HEAD`
  * [ ] `git tag -v release_tag`
  * [ ] `git push --tags origin master`
  * [ ] `git checkout development`
  * [ ] `git merge master`
  * [ ] `git push --tags origin development`
  * [ ] upload artefacts
  * [ ] `make clean`
