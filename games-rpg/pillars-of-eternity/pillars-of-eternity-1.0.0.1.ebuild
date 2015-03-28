# Copyright 2015 Julian Ospald <hasufell@posteo.de>
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit eutils gnome2-utils multilib

DESCRIPTION="Pillars Of Eternity"
HOMEPAGE="http://www.gog.com/game/pillars_of_eternity_hero_edition"

BASE_SRC_URI="gog_pillars_of_eternity_${PV}.tar.gz"
DLC3_SRC_URI="gog_pillars_of_eternity_dlc3_${PV}.tar.gz"
SRC_URI="${BASE_SRC_URI} dlc3? ( ${DLC3_SRC_URI} )"

LICENSE="all-rights-reserved"
SLOT="0"
KEYWORDS="~amd64"
IUSE="dlc3"
RESTRICT="fetch bindist"

RDEPEND="
	dev-libs/atk
	media-libs/fontconfig
	media-libs/freetype:2
	x11-libs/cairo
	x11-libs/gdk-pixbuf:2
	x11-libs/gtk+:2
	x11-libs/pango
	virtual/opengl
"

S="${WORKDIR}/Pillars of Eternity"

pkg_nofetch() {
	einfo
	einfo "Please buy & download \"${BASE_SRC_URI}\""
	if use dlc3 ; then
		einfo "and \"${DLC3_SRC_URI}\""
	fi
	einfo "from:"
	einfo "  ${HOMEPAGE}"
	einfo "and move/link it to \"${DISTDIR}\""
	einfo
}

src_prepare() {
	# rm steam stuff
	rm game/{libsteam_api.so,steam_api.dll,steam_appid.txt,SteamworksNative.dll} || die
	rm game/PillarsOfEternity_Data/Plugins/x86_64/{libCSteamworks,libsteam_api}.so || die
}

src_install() {
	local dir=/opt/${PN}

	newicon -s 512 game/PillarsOfEternity.png ${PN}.png
	make_wrapper ${PN} "./PillarsOfEternity" "${dir}/game"
	make_desktop_entry ${PN} "Pillars Of Eternity"

	dodoc game/Docs/{pe-game-manual.pdf,readme.txt}

	dodir "${dir}"
	mv "${S}/game" "${D}${dir}/" || die
	fperms +x "${dir}"/game/PillarsOfEternity

	if use dlc3 ; then
		insinto "${dir}"/game
		doins -r "${WORKDIR}/Pillars of Eternity Preorder Item and Pet DLC/content/PillarsOfEternity_Data"
	fi
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

