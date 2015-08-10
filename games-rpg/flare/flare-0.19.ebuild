# Copyright 2014 Julian Ospald <hasufell@posteo.de>
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit cmake-utils gnome2-utils

DESCRIPTION="Free/Libre Action Roleplaying game"
HOMEPAGE="https://github.com/clintbellanger/flare-game"
SRC_URI="https://github.com/clintbellanger/flare-game/archive/v${PV}.tar.gz -> ${P}-game.tar.gz"

LICENSE="CC-BY-SA-3.0 GPL-2 GPL-3 OFL-1.1"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND="~games-engines/flare-${PV}"

S=${WORKDIR}/${PN}-game-${PV}

src_prepare() {
	sed -i \
		-e "/Exec/s#@FLARE_EXECUTABLE_PATH@#flare-game#" \
		distribution/flare.desktop.in || die
}

src_configure() {
	local mycmakeargs=(
		-DBINDIR=/usr/bin
		-DDATADIR=/usr/share/${PN}
	)
	cmake-utils_src_configure
}

src_compile() {
	cmake-utils_src_compile
}

src_install() {
	cmake-utils_src_install
	make_wrapper "flare-game" "flare --game=flare-game"
	make_desktop_entry "flare-game" "Flare (game)"
	dodoc README
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

