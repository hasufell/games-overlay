# Copyright 2014 Julian Ospald <hasufell@posteo.de>
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit eutils cmake-utils gnome2-utils

DESCRIPTION="Warcraft II for the Stratagus game engine"
HOMEPAGE="http://wargus.sourceforge.net/"
SRC_URI="http://launchpad.net/${PN}/trunk/${PV}/+download/${PN}_${PV}.orig.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND="~games-engines/stratagus-${PV}[theora]
	media-libs/freetype
	media-libs/libpng:0
	sys-libs/zlib
	x11-libs/gtk+:2
	x11-libs/libX11"
DEPEND="${RDEPEND}
	virtual/pkgconfig"
PDEPEND="games-strategy/wargus-data"

S=${WORKDIR}/${PN}_${PV}.orig

src_configure() {
	local mycmakeargs=(
		-DGAMEDIR=/usr/bin
		-DBINDIR=/usr/bin
		-DSTRATAGUS=/usr/bin/stratagus
		-DSHAREDIR=/usr/share/stratagus/${PN}
		-DICONDIR=/usr/share/icons/hicolor/64x64/apps
	)

	cmake-utils_src_configure
}

pkg_preinst() {
	gnome2_icon_savelist
}

pkg_postinst() {
	elog "Enabling OpenGL in-game seems to cause segfaults/crashes."
	gnome2_icon_cache_update
}

pkg_postrm() {
	gnome2_icon_cache_update
}

