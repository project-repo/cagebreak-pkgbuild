.PHONY: PKGBUILDs PKGBUILD-cagebreak PKGBUILD-cagebreak-bin signatures

all: signatures

signatures: release_$(version).tar.gz.sig

release_$(version).tar.gz: PKGBUILDs output upstream
	mkdir upstream/cagebreak-pkgbuild
	mkdir upstream/cagebreak-pkgbuild/cagebreak
	mkdir upstream/cagebreak-pkgbuild/cagebreak-bin
	cp cagebreak/PKGBUILD upstream/cagebreak-pkgbuild/cagebreak
	cp cagebreak/.SRCINFO upstream/cagebreak-pkgbuild/cagebreak
	cp cagebreak-bin/PKGBUILD upstream/cagebreak-pkgbuild/cagebreak-bin
	cp cagebreak-bin/.SRCINFO upstream/cagebreak-pkgbuild/cagebreak-bin
	export SOURCE_DATE_EPOCH=$$(git -C upstream/cagebreak-git log -1 --pretty=%ct) ; cd upstream ; tar --sort=name --mtime= --owner=0 --group=0 --numeric-owner -czf ../output/release_$(version).tar.gz cagebreak-pkgbuild

release_$(version).tar.gz.sig: release_$(version).tar.gz
	gpg --detach-sig -u $(gpgid) output/release_$(version).tar.gz

PKGBUILDs: PKGBUILD-cagebreak PKGBUILD-cagebreak-bin

PKGBUILD-cagebreak: cagebreak/PKGBUILD cagebreak/.SRCINFO

PKGBUILD-cagebreak-bin: cagebreak-bin/PKGBUILD cagebreak-bin/.SRCINFO

cagebreak/PKGBUILD: upstream
	cd cagebreak ; sed -i "s/pkgver=.*/pkgver=$(version)/g" PKGBUILD
	cd cagebreak ; sed -i "s/pkgrel=.*/pkgrel=$(release)/g" PKGBUILD
	hash=$$(sha512sum upstream/release_$(version).tar.gz | cut -d " " -f1) ; cd cagebreak ; sed -i "s/sha512sums=.*/sha512sums=\(\'$$hash\'\)/g" PKGBUILD

cagebreak/.SRCINFO: cagebreak/PKGBUILD
	cd cagebreak ; makepkg --printsrcinfo > .SRCINFO

cagebreak-bin/PKGBUILD: upstream
	cd cagebreak-bin ; sed -i "s/pkgver=.*/pkgver=$(version)/g" PKGBUILD
	cd cagebreak-bin ; sed -i "s/pkgrel=.*/pkgrel=$(release)/g" PKGBUILD
	hash=$$(sha512sum upstream/release-artefacts_$(version).tar.gz | cut -d " " -f1) ; cd cagebreak-bin ; sed -i "s/sha512sums=.*/sha512sums=\(\'$$hash\'\)/g" PKGBUILD

cagebreak-bin/.SRCINFO: cagebreak-bin/PKGBUILD
	cd cagebreak-bin ; makepkg --printsrcinfo > .SRCINFO

output:
	mkdir -p output

upstream:
# Download and verify sources (and verify tag)
## Prepare directories
	mkdir -p upstream
	rm -rf upstream/*
## Download source
	wget "https://github.com/project-repo/cagebreak/releases/download/$(version)/release_$(version).tar.gz"
	mv "release_$(version).tar.gz" upstream
	wget "https://github.com/project-repo/cagebreak/releases/download/$(version)/release_$(version).tar.gz.sig"
	mv "release_$(version).tar.gz.sig" upstream
	gpg --verify "upstream/release_$(version).tar.gz.sig" "upstream/release_$(version).tar.gz"
## Download artefacts
	wget "https://github.com/project-repo/cagebreak/releases/download/$(version)/release_$(version).tar.gz"
	mv "release_$(version).tar.gz" upstream
	wget "https://github.com/project-repo/cagebreak/releases/download/$(version)/release_$(version).tar.gz.sig"
	mv "release_$(version).tar.gz.sig" upstream
	gpg --verify "upstream/release_$(version).tar.gz.sig" "upstream/release_$(version).tar.gz"
## Verify tag
	git clone --depth=1 https://github.com/project-repo/cagebreak upstream/cagebreak-git
	git -C upstream/cagebreak-git tag -v $(version)

check: all
# Perform sanity checks on output
## Check version continuity
	[[ $$(vercmp $(version) $$(git tag | tail -1)) -eq 1 ]]
	grep -Fxq "pkgver=$(version)" cagebreak/PKGBUILD
	grep -Fxq "pkgrel=$(release)" cagebreak/PKGBUILD
	[[ cagebreak/.SRCINFO -nt cagebreak/PKGBUILD ]]
	grep -Fqx "	pkgver = $(version)" cagebreak/.SRCINFO
	grep -Fqx "	pkgrel = $(release)" cagebreak/.SRCINFO
	grep -Fxq "pkgver=$(version)" cagebreak-bin/PKGBUILD
	grep -Fxq "pkgrel=$(release)" cagebreak-bin/PKGBUILD
	[[ cagebreak-bin/.SRCINFO -nt cagebreak-bin/PKGBUILD ]]
	grep -Fqx "	pkgver = $(version)" cagebreak-bin/.SRCINFO
	grep -Fqx "	pkgrel = $(release)" cagebreak-bin/.SRCINFO
	gpg --verify output/release_$(version).tar.gz.sig output/release_$(version).tar.gz
	gpg --verify output/release_$(version).tar.gz.sig output/release_$(version).tar.gz 2>&1 >/dev/null | grep -Fxq "gpg:                using RSA key $(gpgid)"
	gpg --verify output/release_$(version).tar.gz.sig output/release_$(version).tar.gz 2>&1 >/dev/null | grep -Fxq "gpg: Good signature from \"project-repo <archlinux-aur@project-repo.co>\" [ultimate]"
	[[ $$(tar --list -f output/release_$(version).tar.gz | wc -l) = "7" ]]
	[[ $$(tar --list -f output/release_$(version).tar.gz | head -1) = "cagebreak-pkgbuild/" ]]
	[[ $$(tar --list -f output/release_$(version).tar.gz | head -2 | tail -1) = "cagebreak-pkgbuild/cagebreak/" ]]
	[[ $$(tar --list -f output/release_$(version).tar.gz | head -3 | tail -1) = "cagebreak-pkgbuild/cagebreak/.SRCINFO" ]]
	[[ $$(tar --list -f output/release_$(version).tar.gz | head -4 | tail -1) = "cagebreak-pkgbuild/cagebreak/PKGBUILD" ]]
	[[ $$(tar --list -f output/release_$(version).tar.gz | head -5 | tail -1) = "cagebreak-pkgbuild/cagebreak-bin/" ]]
	[[ $$(tar --list -f output/release_$(version).tar.gz | head -6 | tail -1) = "cagebreak-pkgbuild/cagebreak-bin/.SRCINFO" ]]
	[[ $$(tar --list -f output/release_$(version).tar.gz | head -7 | tail -1) = "cagebreak-pkgbuild/cagebreak-bin/PKGBUILD" ]]
	[[ $$(tar -xOf output/release_$(version).tar.gz cagebreak-pkgbuild/cagebreak/PKGBUILD | sha512sum) = $$(cat cagebreak/PKGBUILD | sha512sum) ]]
	[[ $$(tar -xOf output/release_$(version).tar.gz cagebreak-pkgbuild/cagebreak/.SRCINFO | sha512sum) = $$(cat cagebreak/.SRCINFO | sha512sum) ]]
	[[ $$(tar -xOf output/release_$(version).tar.gz cagebreak-pkgbuild/cagebreak-bin/PKGBUILD | sha512sum) = $$(cat cagebreak-bin/PKGBUILD | sha512sum) ]]
	[[ $$(tar -xOf output/release_$(version).tar.gz cagebreak-pkgbuild/cagebreak-bin/.SRCINFO | sha512sum) = $$(cat cagebreak-bin/.SRCINFO | sha512sum) ]]

clean:
	rm -rf upstream
	rm -rf output

