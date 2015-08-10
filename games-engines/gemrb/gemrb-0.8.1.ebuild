# Copyright 1999-2014 Gentoo Foundation
# Copyright 2014 Julian Ospald <hasufell@posteo.de>
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5
WANT_CMAKE=always
PYTHON_COMPAT=( python2_7 )
inherit eutils cmake-utils gnome2-utils multilib python-single-r1

DESCRIPTION="Reimplementation of the Infinity engine"
HOMEPAGE="http://gemrb.sourceforge.net/"
SRC_URI="mirror://sourceforge/gemrb/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND="${PYTHON_DEPS}
	media-libs/freetype
	media-libs/libpng:0
	>=media-libs/libsdl-1.2[video]
	media-libs/libvorbis
	media-libs/openal
	media-libs/sdl-mixer
	sys-libs/zlib
"
DEPEND=${RDEPEND}

src_prepare() {
	sed -i \
		-e '/COPYING/d' \
		CMakeLists.txt || die
}

src_configure() {
	mycmakeargs=(
		-DCMAKE_INSTALL_PREFIX=/usr
		-DBIN_DIR=/usr/bin
		-DDATA_DIR=/usr/share/gemrb
		-DSYSCONF_DIR=/etc/gemrb
		-DLIB_DIR=/usr/$(get_libdir)/${PN}
		-DMAN_DIR=/usr/share/man/man6
		-DICON_DIR=/usr/share/pixmaps
		-DMENU_DIR=/usr/share/applications
		-DDOC_DIR="/usr/share/doc/${PF}"
		-DSVG_DIR=/usr/share/icons/hicolor/scalable/apps
		)
	cmake-utils_src_configure
}

src_compile() {
	cmake-utils_src_compile
}

src_install() {
	cmake-utils_src_install
	dodoc README NEWS AUTHORS
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

