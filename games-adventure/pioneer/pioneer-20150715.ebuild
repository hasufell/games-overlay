# Copyright 2015 Julian Ospald <hasufell@posteo.de>
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit eutils autotools gnome2-utils

DESCRIPTION="Space adventure game set in the Milky Way galaxy at the turn of the 31st century"
HOMEPAGE="http://pioneerspacesim.net/"
SRC_URI="https://github.com/pioneerspacesim/pioneer/archive/${PV}.tar.gz -> ${P}.tar.gz"

# see AUTHORS.txt
LICENSE="GPL-3 CC-BY-SA-3.0 MIT public-domain ZLIB SIL-1.1 DejaVu-license Apache-2.0 NASA-Spitzer-Space-Telescope"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND="
	dev-libs/libsigc++:2
	media-libs/assimp
	media-libs/freetype:2
	media-libs/libpng:0
	media-libs/libsdl2[joystick,opengl,sound,video]
	media-libs/libvorbis
	media-libs/sdl2-image[png]
	"
DEPEND="${RDEPEND}
	virtual/pkgconfig"

src_prepare() {
	epatch "${FILESDIR}"/${P}-QA.patch
	eautoreconf
}

src_configure() {
	PIONEER_DATA_DIR="/usr/share/${PN}" \
		econf
}

src_compile() {
	emake V=1
}

src_install() {
	default
	newicon -s 256 application-icon/pngs/pioneer-256x256.png ${PN}.png
	make_desktop_entry pioneer Pioneer
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
