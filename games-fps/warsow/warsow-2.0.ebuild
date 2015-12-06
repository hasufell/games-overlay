# Copyright 2015 Julian Ospald <hasufell@posteo.de>
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5
inherit eutils cmake-utils gnome2-utils flag-o-matic toolchain-funcs

DATA_PV=${PV/./}
ENGINE_PV=${PV/./}
ENGINE_P=${PN}_${ENGINE_PV}_sdk

DESCRIPTION="Multiplayer FPS based on the QFusion engine (evolved from Quake 2)"
HOMEPAGE="http://www.warsow.net/"
SRC_URI="http://mirror.null.one/${ENGINE_P}.tar.gz
	http://mirror.null.one/warsow_${DATA_PV}_unified.tar.gz
	mirror://gentoo/warsow.png"

# ZLIB: bundled angelscript
LICENSE="GPL-2 ZLIB warsow"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND="
	media-libs/freetype
	media-libs/libogg
	media-libs/libpng:0
	media-libs/libsdl2[X,opengl,video]
	media-libs/libtheora
	media-libs/libvorbis
	media-libs/openal
	net-misc/curl
	sys-libs/zlib
	virtual/jpeg:0
	virtual/opengl
"
DEPEND="${RDEPEND}"

S=${WORKDIR}/source/source

src_prepare() {
	if [[ $(tc-getCC) =~ clang ]]; then
		einfo "disabling -ffast-math due to clang bug"
		einfo "http://llvm.org/bugs/show_bug.cgi?id=13745"
		append-cflags -fno-fast-math
		append-cxxflags -fno-fast-math
	fi

	cmake-utils_src_prepare
}

src_install() {
	dobin_wrapper() {
		local f

		for f in $@ ; do
			cat <<-EOF > "${T}/${f}" || die
			#!/bin/sh

			basepath="/usr/share/${PN}"

			cd "\${basepath}"

			exec "/usr/libexec/${PN}/${f}" \
				+set fs_basepath \${basepath} \
				+set fs_usehomedir 1 "\$@"
			EOF

			dobin "${T}/${f}"
		done
	}
	insinto /usr/share/${PN}
	doins -r "${WORKDIR}"/${PN}_${DATA_PV}/basewsw

	cd build || die

	exeinto /usr/libexec/${PN}/
	doexe */*.so
	newexe ${PN}.* ${PN}
	newexe wsw_server.* ${PN}-ded
	newexe wswtv_server.* ${PN}-tv
	dobin_wrapper ${PN} ${PN}-ded ${PN}-tv

	local so
	dodir /usr/share/${PN}/libs
	for so in basewsw/*.so libs/*.so ; do
		dosym /usr/libexec/${PN}/${so##*/} \
			/usr/share/${PN}/${so}
	done

	doicon -s 48 "${DISTDIR}"/${PN}.png
	make_desktop_entry ${PN} Warsow
}

pkg_preinst() {
	gnome2_icon_savelist
}

pkg_postinst() {
	gnome2_icon_cache_update
}

pkg_postrm() {
	gnome2_icon_cache_update
}

