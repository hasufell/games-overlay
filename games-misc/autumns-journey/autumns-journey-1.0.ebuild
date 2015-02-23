# Copyright 2015 Julian Ospald <hasufell@posteo.de>
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit eutils gnome2-utils

DESCRIPTION="Autumn's Journey is the story of an aspiring knight and her two dragon friends."
HOMEPAGE="http://autumn.ishtera.net/index.html"
SRC_URI="autumnsjourney-${PV}-linux.tar.bz2"

LICENSE="MIT"
SLOT="0"
KEYWORDS="-* ~amd64 ~x86"
IUSE="+system-renpy"
RESTRICT="fetch mirror"

RDEPEND="system-renpy? ( games-engines/renpy:6.17 )
	!system-renpy? (
		virtual/glu
		x11-libs/libX11
		x11-libs/libXext
		x11-libs/libXi
		x11-libs/libXmu
	)"

S=${WORKDIR}/autumnsjourney-${PV}-linux

pkg_nofetch() {
	einfo
	einfo "Please download \"${SRC_URI}\" from:"
	einfo "  ${HOMEPAGE}"
	einfo "and move/link it to \"${DISTDIR}\""
	einfo
}

src_install() {
	if use system-renpy ; then
		insinto "/usr/share/${PN}"
		doins -r game/.
		make_wrapper ${PN} "renpy-6.17 '/usr/share/${PN}'"
	else
		insinto /opt/${PN}
		rm -r lib/linux-$(usex amd64 "i686" "x86_64") || die
		doins -r game lib renpy autumnsjourney.py autumnsjourney.sh
		make_wrapper ${PN} "./autumnsjourney.sh" "/opt/${PN}"
		fperms +x \
			"/opt/${PN}"/lib/linux-$(usex amd64 "x86_64" "i686")/{python,pythonw,zsync,zsyncmake,autumnsjourney} \
			"/opt/${PN}/autumnsjourney.sh" \
			"/opt/${PN}/autumnsjourney.py"
	fi

	make_desktop_entry ${PN} "Autumn's Journey"

	dohtml README.html
}

pkg_preinst() {
	gnome2_icon_savelist
}

pkg_postinst() {
	elog "Savegames from system-renpy and the bundled version are incompatible"

	if use system-renpy; then
		ewarn "system-renpy is unstable and not supported upstream"
	fi

	gnome2_icon_cache_update
}

pkg_postrm() {
	gnome2_icon_cache_update
}
