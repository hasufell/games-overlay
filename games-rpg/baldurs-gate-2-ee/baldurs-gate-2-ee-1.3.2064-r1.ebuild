# Copyright 2015 Julian Ospald <hasufell@posteo.de>
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit eutils gnome2-utils multilib unpacker

DESCRIPTION="Baldur's Gate 2: Enhanced Edition"
HOMEPAGE="http://www.gog.com/game/baldurs_gate_2_enhanced_edition"
SRC_URI="gog_baldur_s_gate_2_enhanced_edition_2.0.0.3.sh"

LICENSE="all-rights-reserved"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="bundled-libs"
RESTRICT="fetch bindist"

RDEPEND="
	!bundled-libs? (
		>=dev-libs/expat-2.1.0-r3[abi_x86_32(-)]
		>=dev-libs/json-c-0.11-r1[abi_x86_32(-)]
		>=dev-libs/openssl-1.0.1j[abi_x86_32(-)]
		>=media-libs/openal-1.15.1-r2[abi_x86_32(-)]
		>=x11-libs/libX11-1.6.2[abi_x86_32(-)]
	)
	virtual/opengl
"
DEPEND="app-arch/unzip"

S="${WORKDIR}/data/noarch"

pkg_nofetch() {
	einfo
	einfo "Please buy & download \"${SRC_URI}\" from:"
	einfo "  ${HOMEPAGE}"
	einfo "and move/link it to \"${DISTDIR}\""
	einfo
}

src_unpack() {
	einfo "unpacking data..."
	unpack_zip "${DISTDIR}/${SRC_URI}"
}

src_install() {
	local dir=/opt/${PN}
	local f

	insinto "${dir}"
	doins -r game
	fperms +x "${dir}"/game/BaldursGateII

	dodir "${dir}/lib"
	if use bundled-libs ; then
		pushd "${S}"/lib >/dev/null || die
		exeinto "${dir}/lib"
		for f in * ; do
			if [[ -L ${f} ]] ; then
				dosym "$(readlink ${f})" "${dir}"/lib/${f}
			else
				doexe ${f}
			fi
		done
		unset f
		popd >/dev/null || die
	else
		dosym /usr/$(get_abi_LIBDIR x86)/libjson-c.so "${dir}"/lib/libjson.so.0
	fi

	newicon -s 256 support/icon.png ${PN}.png
	make_wrapper ${PN} "./BaldursGateII" "${dir}/game" "${dir}/lib"
	make_desktop_entry ${PN} "Baldurs Gate 2 Enhanced Edition"

	dodoc -r docs/BGManual2.pdf
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

