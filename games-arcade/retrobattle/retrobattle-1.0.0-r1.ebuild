# Copyright 2014 Julian Ospald <hasufell@posteo.de>
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5
inherit eutils

MY_P="${PN}-src-${PV}"
DESCRIPTION="A NES-like platform arcade game"
HOMEPAGE="http://remar.se/andreas/retrobattle/"
SRC_URI="http://remar.se/andreas/retrobattle/files/${MY_P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""
# test is incomplete
RESTRICT="test"

RDEPEND="media-libs/libsdl[X,sound,video]
	media-libs/sdl-mixer[wav]"
DEPEND="${RDEPEND}"

S=${WORKDIR}/${MY_P}/src

src_prepare() {
	epatch "${FILESDIR}"/${P}-{build,sound}.patch
}

src_install() {
	insinto /usr/share/${PN}
	doins -r "${WORKDIR}"/${MY_P}/data || die

	# wrapper to pass datadir location
	newbin "${WORKDIR}"/${MY_P}/${PN} ${PN}.bin || die
	make_wrapper ${PN} "${PN}.bin \"/usr/share/${PN}\""

	make_desktop_entry ${PN}
	dodoc "${WORKDIR}"/${MY_P}/{manual.txt,README}
}

