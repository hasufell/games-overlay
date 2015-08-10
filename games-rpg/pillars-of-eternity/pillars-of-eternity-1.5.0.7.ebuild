# Copyright 2015 Julian Ospald <hasufell@posteo.de>
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit eutils gnome2-utils multilib

DESCRIPTION="Pillars Of Eternity"
HOMEPAGE="http://www.gog.com/game/pillars_of_eternity_hero_edition"

BASE_SRC_URI="gog_pillars_of_eternity_${PV}.tar.gz"
DLC1_SRC_URI="gog_pillars_of_eternity_dlc1_1.0.0.1.tar.gz "
DLC2_SRC_URI="gog_pillars_of_eternity_dlc2_1.0.0.1.tar.gz "
DLC3_SRC_URI="gog_pillars_of_eternity_dlc3_1.0.0.1.tar.gz"
SRC_URI="${BASE_SRC_URI}
	dlc1? ( ${DLC1_SRC_URI} )
	dlc2? ( ${DLC2_SRC_URI} )
	dlc3? ( ${DLC3_SRC_URI} )"

LICENSE="all-rights-reserved"
SLOT="0"
KEYWORDS="~amd64"
IUSE="dlc1 dlc2 dlc3"
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
	use dlc1 && einfo "and \"${DLC1_SRC_URI}\""
	use dlc2 && einfo "and \"${DLC2_SRC_URI}\""
	use dlc3 && einfo "and \"${DLC3_SRC_URI}\""
	einfo "from:"
	einfo "  ${HOMEPAGE}"
	einfo "and move/link it to \"${DISTDIR}\""
	einfo
}

src_prepare() {
	# rm steam stuff
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

	insinto "${dir}"/game
	use dlc1 &&
		doins -r "${WORKDIR}/Pillars of Eternity Kickstarter Item DLC/content/PillarsOfEternity_Data"
	use dlc2 &&
		doins -r "${WORKDIR}/Pillars of Eternity Kickstarter Pet DLC/content/PillarsOfEternity_Data"
	use dlc3 &&
		doins -r "${WORKDIR}/Pillars of Eternity Preorder Item and Pet DLC/content/PillarsOfEternity_Data"
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

