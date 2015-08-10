# Copyright 1999-2012 Gentoo Foundation
# Copyright 2014 Julian Ospald <hasufell@posteo.de>
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5
inherit eutils multiprocessing toolchain-funcs

DESCRIPTION="city/country simulation game for X and opengl"
HOMEPAGE="http://lincity-ng.berlios.de/"
SRC_URI="mirror://berlios/${PN}/${P}.tar.bz2"

LICENSE="GPL-2 BitstreamVera"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~sparc ~x86"
IUSE=""

RDEPEND="
	dev-games/physfs
	dev-libs/libxml2
	media-libs/libsdl[sound,joystick,opengl,video]
	media-libs/sdl-mixer[vorbis]
	media-libs/sdl-image[png]
	media-libs/sdl-ttf
	media-libs/sdl-gfx
	sys-libs/zlib
	virtual/opengl
"
DEPEND="${RDEPEND}
	dev-util/ftjam
	virtual/pkgconfig
"

src_compile() {
	jam -q -dx -j $(makeopts_jobs) || die "jam failed"
}

src_install() {
	jam -sDESTDIR="${D}" \
		 -sappdocdir="/usr/share/doc/${PF}" \
		 -sapplicationsdir="/usr/share/applications" \
		 -spixmapsdir="/usr/share/pixmaps" \
		 install \
		 || die "jam install failed"
	rm -f "${D}"/usr/share/doc/${PF}/COPYING*
	prepalldocs
}
