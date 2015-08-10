# Copyright 2014 Julian Ospald <hasufell@posteo.de>
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit multilib

DESCRIPTION="PSEmu plugin to use the keyboard as a gamepad"
HOMEPAGE="http://www.pcsx.net/"
SRC_URI="http://linuzappz.pcsx.net/downloads/padXwin-${PV}.tgz"

LICENSE="freedist"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""
RESTRICT="strip"

RDEPEND="x11-libs/gtk+:1[abi_x86_32(-)]"

S="${WORKDIR}"

src_install() {
	dodoc ReadMe.txt
	cd bin
	exeinto /usr/$(get_libdir)/psemu/plugins
	doexe libpadXwin-* || die "doexe failed"
	exeinto /usr/$(get_libdir)/psemu/cfg
	doexe cfgPadXwin || die "doexe failed"
}

