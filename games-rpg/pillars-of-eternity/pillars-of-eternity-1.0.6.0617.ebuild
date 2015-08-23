# Copyright 2015 Julian Ospald <hasufell@posteo.de>
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit eutils gnome2-utils multilib unpacker

DESCRIPTION="Pillars Of Eternity"
HOMEPAGE="http://www.gog.com/game/pillars_of_eternity_hero_edition"

BASE_SRC_URI="gog_pillars_of_eternity_2.5.0.8.sh"
DLC3_SRC_URI="gog_pillars_of_eternity_preorder_item_and_pet_dlc_2.0.0.2.sh"
SRC_URI="${BASE_SRC_URI}
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

S="${WORKDIR}/data/noarch"

unpack_mojo_makeself_crap() {
	local _name=${1}
	local _offset=${2}
	dd \
		ibs="${_offset}" \
		skip=1 \
		if="${DISTDIR}/${_name}" \
		of="${T}"/${_name}.zip || die
	unpack_zip "${T}"/${_name}.zip
}

pkg_nofetch() {
	einfo
	einfo "Please buy & download \"${BASE_SRC_URI}\""
	use dlc3 && einfo "and \"${DLC3_SRC_URI}\""
	einfo "from:"
	einfo "  ${HOMEPAGE}"
	einfo "and move/link it to \"${DISTDIR}\""
	einfo
}

src_unpack() {
	einfo "unpacking dlc3 data..."
	use dlc3 && unpack_mojo_makeself_crap \
		"${DLC3_SRC_URI}" \
		"$(head -n 519 "${DISTDIR}/${DLC3_SRC_URI}" | wc -c | tr -d ' ')"

	einfo "unpacking base data..."
	unpack_mojo_makeself_crap \
		"${BASE_SRC_URI}" \
		"$(head -n 519 "${DISTDIR}/${BASE_SRC_URI}" | wc -c | tr -d ' ')"
}

src_install() {
	local dir=/opt/${PN}

	newicon -s 512 game/PillarsOfEternity.png ${PN}.png
	make_wrapper ${PN} "./PillarsOfEternity" "${dir}/game"
	make_desktop_entry ${PN} "Pillars Of Eternity"

	dodoc game/Docs/{pe-game-manual.pdf,readme.txt}

	dodir "${dir}"
	rm "${S}"/game/PillarsOfEternity_Data/Plugins/x86_64/libCSteamworks.so \
		"${S}"/game/PillarsOfEternity_Data/Plugins/x86_64/libsteam_api.so || die
	mv "${S}/game" "${D}${dir}/" || die
	fperms +x "${dir}"/game/PillarsOfEternity

	insinto "${dir}"/game
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

