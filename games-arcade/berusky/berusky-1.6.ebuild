# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5
inherit autotools eutils gnome2-utils

DATAFILE=${PN}-data-${PV}
DESCRIPTION="free logic game based on an ancient puzzle named Sokoban"
HOMEPAGE="http://anakreon.cz/?q=node/1"
SRC_URI="http://www.anakreon.cz/download/${P}.tar.gz
	http://www.anakreon.cz/download/${DATAFILE}.tar.gz
	http://dev.gentoo.org/~hasufell/distfiles/${PN}.png"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND="media-libs/libsdl[X,video]
	media-libs/sdl-image[png]
	x11-libs/gtk+:2"
DEPEND="${RDEPEND}
	virtual/pkgconfig"

src_prepare() {
	mv ../${DATAFILE}/{berusky.ini,GameData,Graphics,Levels} . || die
	sed -i \
		-e "/INI_FILE_GLOBAL/s:/var/games/berusky/:/usr/share/berusky/:" \
		src/defines.h \
		|| die
	eautoreconf
}

src_install() {
	default
	insinto /usr/share/${PN}
	doins -r berusky.ini GameData Graphics Levels
	doicon -s 32 "${DISTDIR}"/${PN}.png
	make_desktop_entry ${PN}
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
