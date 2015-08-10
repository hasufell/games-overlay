# Copyright 2015 Julian Ospald <hasufell@posteo.de>, Heiko Schaefer <heiko@rangun.de>
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit qmake-utils eutils vcs-snapshot

MY_P=nmm-qt-client${PV}

DESCRIPTION="Client for games-server/netmaumau, the popular card game Mau Mau"
HOMEPAGE="http://sourceforge.net/projects/netmaumau"
SRC_URI="https://github.com/velnias75/NetMauMau-Qt-Client/archive/V${PV}.tar.gz -> ${P}-client.tar.gz"

LICENSE="LGPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="+espeak"

RDEPEND="
	dev-qt/qtcore:4[exceptions]
	dev-qt/qtgui:4[exceptions]
	dev-qt/qtsvg:4[exceptions]
	espeak? ( || ( app-accessibility/espeak[portaudio] app-accessibility/espeak[pulseaudio] ) )
	games-server/netmaumau:0/10[-dedicated]
"

DEPEND="
	${RDEPEND}
	virtual/pkgconfig
"

S=${WORKDIR}/${P}-client

src_configure() {
	if use espeak; then USE_ESPEAK='CONFIG+=espeak'; fi
	eqmake4 $USE_ESPEAK
	lrelease src/src.pro
}

src_install() {
	dobin src/nmm-qt-client
	doicon -s 256 src/nmm_qt_client.png
	domenu src/nmm_qt_client.desktop
	insinto /usr/share/nmm-qt-client
	doins src/*.qm
}
