# Copyright 2014 Julian Ospald <hasufell@posteo.de>
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit qmake-utils

MY_P=nmm-qt-client${PV}

DESCRIPTION="Client for games-server/netmaumau, the popular card game Mau Mau"
HOMEPAGE="http://sourceforge.net/projects/netmaumau"
SRC_URI="mirror://sourceforge/netmaumau/${MY_P}.tar.gz"

LICENSE="LGPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND="
	dev-qt/qtcore:4
	dev-qt/qtgui:4
	dev-qt/qtsvg:4
	>=games-server/netmaumau-0.3"

DEPEND="${RDEPEND}"

S=${WORKDIR}/${MY_P}

src_prepare() {
    epatch "${FILESDIR}/netmaumau-0.3.patch"
}

src_configure() {
	eqmake4
	lrelease src.pro
}

src_install() {
	dobin nmm-qt-client
	insinto /usr/share/icons/hicolor/256x256/apps
	doins nmm_qt_client.png
	insinto /usr/share/applications
	doins nmm_qt_client.desktop
	insinto /usr/share/nmm-qt-client
	doins *.qm
}

