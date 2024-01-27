.PHONY: PKGBUILDs PKGBUILD-cagebreak PKGBUILD-cagebreak-bin PKGBUILD-cagebreak-arm PKGBUILD-cagebreak-redundancy PKGBUILD-cagebreak-bin-redundancy signatures

all: signatures

signatures: release_$(version).tar.gz.sig

release_$(version).tar.gz: PKGBUILDs output upstream
	mkdir upstream/cagebreak-pkgbuild
	mkdir upstream/cagebreak-pkgbuild/cagebreak
	mkdir upstream/cagebreak-pkgbuild/cagebreak-bin
	mkdir upstream/cagebreak-pkgbuild/cagebreak-redundancy
	mkdir upstream/cagebreak-pkgbuild/cagebreak-bin-redundancy
	cp cagebreak/PKGBUILD upstream/cagebreak-pkgbuild/cagebreak
	cp cagebreak/.SRCINFO upstream/cagebreak-pkgbuild/cagebreak
	cp cagebreak-bin/PKGBUILD upstream/cagebreak-pkgbuild/cagebreak-bin
	cp cagebreak-bin/.SRCINFO upstream/cagebreak-pkgbuild/cagebreak-bin
	cp cagebreak-redundancy/PKGBUILD upstream/cagebreak-pkgbuild/cagebreak-redundancy
	cp cagebreak-redundancy/.SRCINFO upstream/cagebreak-pkgbuild/cagebreak-redundancy
	cp cagebreak-bin-redundancy/PKGBUILD upstream/cagebreak-pkgbuild/cagebreak-bin-redundancy
	cp cagebreak-bin-redundancy/.SRCINFO upstream/cagebreak-pkgbuild/cagebreak-bin-redundancy
	export SOURCE_DATE_EPOCH=$$(git -C upstream/cagebreak-git log -1 --pretty=%ct) ; cd upstream ; tar --sort=name --mtime= --owner=0 --group=0 --numeric-owner -czf ../output/release_$(version).tar.gz cagebreak-pkgbuild

release_$(version).tar.gz.sig: release_$(version).tar.gz
	gpg --detach-sig -u $(gpgid) output/release_$(version).tar.gz

PKGBUILDs: PKGBUILD-cagebreak PKGBUILD-cagebreak-bin PKGBUILD-cagebreak-arm PKGBUILD-cagebreak-redundancy PKGBUILD-cagebreak-bin-redundancy

PKGBUILD-cagebreak: cagebreak/PKGBUILD cagebreak/.SRCINFO

PKGBUILD-cagebreak-bin: cagebreak-bin/PKGBUILD cagebreak-bin/.SRCINFO

PKGBUILD-cagebreak-arm: cagebreak-arm/PKGBUILD cagebreak-arm/.SRCINFO

PKGBUILD-cagebreak-redundancy: cagebreak-redundancy/PKGBUILD cagebreak-redundancy/.SRCINFO

PKGBUILD-cagebreak-bin-redundancy: cagebreak-bin-redundancy/PKGBUILD cagebreak-bin-redundancy/.SRCINFO

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

cagebreak-arm/PKGBUILD: upstream
	cd cagebreak-arm ; sed -i "s/pkgver=.*/pkgver=$(version)/g" PKGBUILD
	cd cagebreak-arm ; sed -i "s/pkgrel=.*/pkgrel=$(release)/g" PKGBUILD
	hash=$$(sha512sum upstream/release_$(version).tar.gz | cut -d " " -f1) ; cd cagebreak-arm ; sed -i "s/sha512sums=.*/sha512sums=\(\'$$hash\'\)/g" PKGBUILD

cagebreak-arm/.SRCINFO: cagebreak-arm/PKGBUILD
	cd cagebreak-arm ; makepkg --printsrcinfo > .SRCINFO

cagebreak-redundancy/PKGBUILD: upstream
	cd cagebreak-redundancy ; sed -i "s/pkgver=.*/pkgver=$(version)/g" PKGBUILD
	cd cagebreak-redundancy ; sed -i "s/pkgrel=.*/pkgrel=$(release)/g" PKGBUILD
	hash=$$(sha512sum upstream/release_$(version).tar.gz | cut -d " " -f1) ; cd cagebreak-redundancy ; sed -i "s/sha512sums=.*/sha512sums=\(\'$$hash\'\)/g" PKGBUILD

cagebreak-bin-redundancy/PKGBUILD: upstream
	cd cagebreak-bin-redundancy ; sed -i "s/pkgver=.*/pkgver=$(version)/g" PKGBUILD
	cd cagebreak-bin-redundancy ; sed -i "s/pkgrel=.*/pkgrel=$(release)/g" PKGBUILD
	hash=$$(sha512sum upstream/release-artefacts_$(version).tar.gz | cut -d " " -f1) ; cd cagebreak-bin-redundancy ; sed -i "s/sha512sums=.*/sha512sums=\(\'$$hash\'\)/g" PKGBUILD

cagebreak-redundancy/.SRCINFO: cagebreak-redundancy/PKGBUILD
	cd cagebreak-redundancy ; makepkg --printsrcinfo > .SRCINFO

cagebreak-bin-redundancy/.SRCINFO: cagebreak-bin-redundancy/PKGBUILD
	cd cagebreak-bin-redundancy ; makepkg --printsrcinfo > .SRCINFO

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
	wget "https://github.com/project-repo/cagebreak/releases/download/$(version)/release-artefacts_$(version).tar.gz"
	mv "release-artefacts_$(version).tar.gz" upstream
	wget "https://github.com/project-repo/cagebreak/releases/download/$(version)/release-artefacts_$(version).tar.gz.sig"
	mv "release-artefacts_$(version).tar.gz.sig" upstream
	gpg --verify "upstream/release-artefacts_$(version).tar.gz.sig" "upstream/release-artefacts_$(version).tar.gz"
## Verify tag
	git clone --depth=1 https://github.com/project-repo/cagebreak upstream/cagebreak-git
	git -C upstream/cagebreak-git tag -v $(version)

check: all
# Perform sanity checks on output
## Check version continuity
	[[ $$(vercmp $(version) $$(git tag | tail -1)) -eq 1 ]]
	grep -Fxq "pkgver=$(version)" cagebreak/PKGBUILD
	grep -Fxq "pkgrel=$(release)" cagebreak/PKGBUILD
	grep -Fxq "pkgver=$(version)" cagebreak-redundancy/PKGBUILD
	grep -Fxq "pkgrel=$(release)" cagebreak-redundancy/PKGBUILD
	[[ cagebreak/.SRCINFO -nt cagebreak/PKGBUILD ]]
	[[ cagebreak-redundancy/.SRCINFO -nt cagebreak-redundancy/PKGBUILD ]]
	grep -Fqx "	pkgver = $(version)" cagebreak/.SRCINFO
	grep -Fqx "	pkgrel = $(release)" cagebreak/.SRCINFO
	grep -Fqx "	pkgver = $(version)" cagebreak-redundancy/.SRCINFO
	grep -Fqx "	pkgrel = $(release)" cagebreak-redundancy/.SRCINFO
	grep -Fxq "pkgver=$(version)" cagebreak-bin/PKGBUILD
	grep -Fxq "pkgrel=$(release)" cagebreak-bin/PKGBUILD
	grep -Fxq "pkgver=$(version)" cagebreak-bin-redundancy/PKGBUILD
	grep -Fxq "pkgrel=$(release)" cagebreak-bin-redundancy/PKGBUILD
	[[ cagebreak-bin/.SRCINFO -nt cagebreak-bin/PKGBUILD ]]
	[[ cagebreak-bin-redundancy/.SRCINFO -nt cagebreak-bin-redundancy/PKGBUILD ]]
	grep -Fqx "	pkgver = $(version)" cagebreak-bin/.SRCINFO
	grep -Fqx "	pkgrel = $(release)" cagebreak-bin/.SRCINFO
	gpg --verify output/release_$(version).tar.gz.sig output/release_$(version).tar.gz
	gpg --verify output/release_$(version).tar.gz.sig output/release_$(version).tar.gz 2>&1 >/dev/null | grep -Fxq "gpg:                using RSA key $(gpgid)"
	gpg --verify output/release_$(version).tar.gz.sig output/release_$(version).tar.gz 2>&1 >/dev/null | grep -Fxq "gpg: Good signature from \"project-repo <archlinux-aur@project-repo.co>\" [ultimate]"
	[[ $$(tar --list -f output/release_$(version).tar.gz | wc -l) = "13" ]]
	[[ $$(tar -xOf output/release_$(version).tar.gz cagebreak-pkgbuild/cagebreak/PKGBUILD | sha512sum) = $$(cat cagebreak/PKGBUILD | sha512sum) ]]
	[[ $$(tar -xOf output/release_$(version).tar.gz cagebreak-pkgbuild/cagebreak/.SRCINFO | sha512sum) = $$(cat cagebreak/.SRCINFO | sha512sum) ]]
	[[ $$(tar -xOf output/release_$(version).tar.gz cagebreak-pkgbuild/cagebreak-redundancy/PKGBUILD | sha512sum) = $$(cat cagebreak-redundancy/PKGBUILD | sha512sum) ]]
	[[ $$(tar -xOf output/release_$(version).tar.gz cagebreak-pkgbuild/cagebreak-redundancy/.SRCINFO | sha512sum) = $$(cat cagebreak-redundancy/.SRCINFO | sha512sum) ]]
	[[ $$(tar -xOf output/release_$(version).tar.gz cagebreak-pkgbuild/cagebreak-bin/PKGBUILD | sha512sum) = $$(cat cagebreak-bin/PKGBUILD | sha512sum) ]]
	[[ $$(tar -xOf output/release_$(version).tar.gz cagebreak-pkgbuild/cagebreak-bin/.SRCINFO | sha512sum) = $$(cat cagebreak-bin/.SRCINFO | sha512sum) ]]
	[[ $$(tar -xOf output/release_$(version).tar.gz cagebreak-pkgbuild/cagebreak-bin-redundancy/PKGBUILD | sha512sum) = $$(cat cagebreak-bin-redundancy/PKGBUILD | sha512sum) ]]
	[[ $$(tar -xOf output/release_$(version).tar.gz cagebreak-pkgbuild/cagebreak-bin-redundancy/.SRCINFO | sha512sum) = $$(cat cagebreak-bin-redundancy/.SRCINFO | sha512sum) ]]

clean:
	rm -rf upstream
	rm -rf output

