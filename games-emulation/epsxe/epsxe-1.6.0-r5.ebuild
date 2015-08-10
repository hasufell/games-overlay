# Copyright 2014 Julian Ospald <hasufell@posteo.de>
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit fdo-mime gnome2-utils multilib

DESCRIPTION="ePSXe PlayStation Emulator"
HOMEPAGE="http://www.epsxe.com/"
SRC_URI="http://www.epsxe.com/files/epsxe${PV//.}lin.zip
	http://dev.gentoo.org/~hasufell/distfiles/${PN}.png"

LICENSE="freedist"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="opengl"
RESTRICT="strip"

DEPEND="app-arch/unzip"
RDEPEND="games-emulation/psemu-peopsspu
	opengl? ( games-emulation/psemu-gpupetexgl2
		games-emulation/psemu-gpupetemesagl )
	!opengl? ( games-emulation/psemu-peopssoftgpu )
	x11-libs/gtk+:1[abi_x86_32(-)]"

S=${WORKDIR}

src_install() {
	local dir="/opt/${PN}"
	dobin "${FILESDIR}"/epsxe
	sed -i \
		-e "s:GAMES_PREFIX_OPT:/opt:" \
		-e "s:GAMES_LIBDIR:/usr/$(get_libdir):" \
		"${D}"/usr/bin/epsxe \
		|| die
	exeinto "${dir}"
	doexe epsxe
	insinto "${dir}"
	doins keycodes.lst
	insinto /usr/$(get_libdir)/psemu/cheats
	doins cheats/*
	dodoc docs/*
	doicon -s 32 "${DISTDIR}"/${PN}.png
	domenu "${FILESDIR}"/epsxe.desktop
}

pkg_preinst() {
	gnome2_icon_savelist
}

pkg_postinst() {
	fdo-mime_desktop_database_update
	gnome2_icon_cache_update
	ewarn "                                                 "
	ewarn "You need at least plugins for sound and video and"
	ewarn "a BIOS file!                                     "
	ewarn "                                                 "
	ewarn "Plugins can also be added to ~/.epsxe/plugins 	"
	ewarn "manually.                                        "
	ewarn "                                                 "
}

pkg_postrm() {
	fdo-mime_desktop_database_update
	gnome2_icon_cache_update
}

