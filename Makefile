.PHONY: PKGBUILDs PKGBUILD-cagebreak PKGBUILD-cagebreak-bin upstream signatures

all: output/manifest signatures

output/manifest: release_bin_$(version).tar.gz release_$(version).tar.gz
	touch output/manifest
	echo "version=$(version)" >> output/manifest
	sha512sum output/release_$(version).tar.gz >> output/manifest
	sha512sum output/release_bin_$(version).tar.gz >> output/manifest

signatures: release_bin_$(version).tar.gz.sig release_$(version).tar.gz.sig

release_$(version).tar.gz: PKGBUILDs output upstream
	mkdir upstream/cagebreak-pkgbuild
	mkdir upstream/cagebreak-pkgbuild/cagebreak
	mkdir upstream/cagebreak-pkgbuild/cagebreak-bin
	cp cagebreak/PKGBUILD upstream/cagebreak-pkgbuild/cagebreak
	cp cagebreak/.SRCINFO upstream/cagebreak-pkgbuild/cagebreak
	cp cagebreak-bin/PKGBUILD upstream/cagebreak-pkgbuild/cagebreak-bin
	cp cagebreak-bin/.SRCINFO upstream/cagebreak-pkgbuild/cagebreak-bin
	export SOURCE_DATE_EPOCH=$$(git -C upstream/cagebreak-git log -1 --pretty=%ct) ; cd upstream ; tar --sort=name --mtime= --owner=0 --group=0 --numeric-owner -czf ../output/release_$(version).tar.gz cagebreak-pkgbuild

release_bin_$(version).tar.gz: output upstream
	mkdir upstream/cagebreak-bin
	cp upstream/cagebreak/build/cagebreak upstream/cagebreak-bin
	cp upstream/cagebreak/build/cagebreak.1 upstream/cagebreak-bin
	cp upstream/cagebreak/build/cagebreak-config.5 upstream/cagebreak-bin
	cp upstream/cagebreak/LICENSE upstream/cagebreak-bin
	export SOURCE_DATE_EPOCH=$$(git -C upstream/cagebreak-git log -1 --pretty=%ct) ; cd upstream ; tar --sort=name --mtime= --owner=0 --group=0 --numeric-owner -czf ../output/release_bin_$(version).tar.gz cagebreak-bin

PKGBUILDs: PKGBUILD-cagebreak PKGBUILD-cagebreak-bin

PKGBUILD-cagebreak: cagebreak/PKGBUILD cagebreak/.SRCINFO

PKGBUILD-cagebreak-bin: cagebreak-bin/PKGBUILD cagebreak-bin/.SRCINFO

cagebreak/PKGBUILD: upstream
	cd cagebreak ; sed -i "s/pkgver=.*/pkgver=$(version)/g" PKGBUILD
	cd cagebreak ; sed -i "s/pkgrel=.*/pkgrel=$(release)/g" PKGBUILD
	hash=$$(sha512sum upstream/release_$(version).tar.gz | cut -d " " -f1) ; cd cagebreak ; sed -i "s/sha512sums=.*/sha512sums=\(\'$$hash\'\)/g" PKGBUILD

cagebreak/.SRCINFO: cagebreak/PKGBUILD
	cd cagebreak ; makepkg --printsrcinfo > .SRCINFO

cagebreak-bin/PKGBUILD: release_bin_$(version).tar.gz
	cd cagebreak-bin ; sed -i "s/pkgver=.*/pkgver=$(version)/g" PKGBUILD
	cd cagebreak-bin ; sed -i "s/pkgrel=.*/pkgrel=$(release)/g" PKGBUILD
	hash=$$(sha512sum output/release_bin_$(version).tar.gz | cut -d " " -f1) ; cd cagebreak-bin ; sed -i "s/sha512sums=.*/sha512sums=\(\'$$hash\'\)/g" PKGBUILD

cagebreak-bin/.SRCINFO: cagebreak-bin/PKGBUILD
	cd cagebreak-bin ; makepkg --printsrcinfo > .SRCINFO

release_$(version).tar.gz.sig: release_$(version).tar.gz
	gpg --detach-sig -u $(gpgid) output/release_$(version).tar.gz

release_bin_$(version).tar.gz.sig: release_bin_$(version).tar.gz
	gpg --detach-sig -u $(gpgid) output/release_bin_$(version).tar.gz

output:
	mkdir output

upstream:
	mkdir upstream
	wget "https://github.com/project-repo/cagebreak/releases/download/$(version)/release_$(version).tar.gz"
	mv "release_$(version).tar.gz" upstream
	wget "https://github.com/project-repo/cagebreak/releases/download/$(version)/release_$(version).tar.gz.sig"
	mv "release_$(version).tar.gz.sig" upstream
	gpg --verify "upstream/release_$(version).tar.gz.sig" "upstream/release_$(version).tar.gz"
	cd upstream ; tar -xf release_$(version).tar.gz
	cd upstream/cagebreak ; meson build -Dxwayland=true --buildtype=release
	ninja -C upstream/cagebreak/build
	gpg --verify upstream/cagebreak/signatures/cagebreak.sig upstream/cagebreak/build/cagebreak
	git clone --depth=1 https://github.com/project-repo/cagebreak upstream/cagebreak-git
	git -C upstream/cagebreak-git tag -v $(version)

clean:
	rm -rf upstream
	rm -rf output

