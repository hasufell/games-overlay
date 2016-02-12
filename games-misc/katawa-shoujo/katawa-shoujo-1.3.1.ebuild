# Copyright 2015-2016 Julian Ospald <hasufell@posteo.de>
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

inherit eutils gnome2-utils

DESCRIPTION="Bishoujo-style visual novel set in the fictional Yamaku High School for disabled children"
HOMEPAGE="http://katawa-shoujo.com/"
SRC_URI="http://dl.katawa-shoujo.com/gold_${PV}/%5B4ls%5D_katawa_shoujo_${PV}-%5Blinux-x86%5D%5B18161880%5D.tar.bz2 -> ${P}.tar.bz2
	http://dev.gentoo.org/~hasufell/distfiles/katawa-shoujo-48.png
	http://dev.gentoo.org/~hasufell/distfiles/katawa-shoujo-256.png"

LICENSE="CC-BY-NC-ND-3.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="system-renpy"

DEPEND="!system-renpy? ( dev-util/patchelf )"

# make system-renpy optional due to #459742 :(
RDEPEND="system-renpy? ( games-engines/renpy )
	!system-renpy? (
		>=sys-libs/zlib-1.2.8-r1
	)" #495270

S="${WORKDIR}/Katawa Shoujo-${PV}-linux"

src_install() {
	local libdir notlibdir
	if use x86 ; then
		libdir="lib/linux-i686"
		notlibdir="lib/linux-x86_64"
	else
		libdir="lib/linux-x86_64"
		notlibdir="lib/linux-i686"
	fi

	if use system-renpy ; then
		insinto /usr/share/${PN}
		doins -r game/.
		make_wrapper ${PN} "renpy '/usr/share/${PN}'"
	else
		insinto /opt/${PN}
		rm -r "${notlibdir}" || die
		doins -r game lib localizations renpy "Katawa Shoujo.py" \
			"Katawa Shoujo.sh"
		make_wrapper ${PN} "./Katawa\ Shoujo.sh" "/opt/${PN}"
		fperms +x "/opt/${PN}/${libdir}/python" \
			"/opt/${PN}/${libdir}/pythonw" \
			"/opt/${PN}/${libdir}/Katawa Shoujo" \
			"/opt/${PN}/Katawa Shoujo.sh" \
			"/opt/${PN}/Katawa Shoujo.py"
	fi

	local i
	for i in 48 256; do
		newicon -s ${i} "${DISTDIR}"/${PN}-${i}.png ${PN}.png
	done

	make_desktop_entry ${PN} "Katawa Shoujo"

	newdoc "Game Manual.pdf" manual.pdf
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
