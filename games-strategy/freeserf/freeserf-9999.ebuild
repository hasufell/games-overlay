# Copyright 2014 Julian Ospald <hasufell@posteo.de>
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit autotools git-2

DESCRIPTION="Settlers 1 (Serf city) clone"
HOMEPAGE="http://jonls.dk/freeserf/"
EGIT_REPO_URI="https://github.com/freeserf/freeserf.git"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS=""
IUSE="+mixer"

RDEPEND="media-libs/libsdl2[X,sound,video]
	mixer? ( media-libs/sdl2-mixer[timidity] )"
DEPEND="${RDEPEND}
	mixer? ( virtual/pkgconfig )"

DOCS=( README.md )

src_prepare() {
	eautoreconf
}

src_configure() {
	econf \
		$(use_enable mixer sdl2-mixer)
}

pkg_postinst() {
	elog "Instructions on how to install the data files can be found at"
	elog "/usr/share/doc/${PF}/README.md"
}
