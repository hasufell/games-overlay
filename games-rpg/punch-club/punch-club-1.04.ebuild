# Copyright 2016 Julian Ospald <hasufell@posteo.de>
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit eutils gnome2-utils unpacker

DESCRIPTION="Punch Club is a boxing tycoon management game with multiple branching story lines"
HOMEPAGE="https://www.gog.com/game/punch_club"
SRC_URI="gog_punch_club_2.0.0.1.sh"

LICENSE="all-rights-reserved GOG-EULA"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""
RESTRICT="fetch mirror bindist"

RDEPEND="
	dev-libs/glib:2
	x11-libs/gdk-pixbuf:2
	x11-libs/gtk+:2
	x11-libs/libX11
	x11-libs/libXcursor
	virtual/glu
	virtual/opengl
"
DEPEND="app-arch/unzip"

S="${WORKDIR}/data/noarch"

pkg_nofetch() {
	einfo
	einfo "Please buy & download \"${SRC_URI}\""
	einfo "from:"
	einfo "  ${HOMEPAGE}"
	einfo "and move/link it to \"${DISTDIR}\""
	einfo
}

src_unpack() {
	unpack_zip "${DISTDIR}/${SRC_URI}"
}

src_install() {
	local dir=/opt/${PN}
	local arch=$(usex amd64 "x86_64" "x86")
	local noarch=$(usex amd64 "x86" "x86_64")

	newicon -s 128 "game/Punch Club_Data/Resources/UnityPlayer.png" ${PN}.png
	make_wrapper ${PN} "\"./Punch Club.${arch}\"" "${dir}/game"
	make_desktop_entry ${PN} "Punch Club"

	rm "${S}/game/Punch Club_Data/Plugins/${arch}/libsteam_api.so" \
		"${S}/game/Punch Club_Data/Plugins/${arch}/libCSteamworks.so" || die
	rm -r "${S}/game/Punch Club_Data/Plugins/${noarch}" || die
	rm "${S}/game/Punch Club.${noarch}" || die
	insinto "${dir}"
	doins -r "${S}/game"
	fperms +x "${dir}/game/Punch Club.${arch}"
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
