# Copyright 2014 Julian Ospald <hasufell@posteo.de>
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5
inherit toolchain-funcs

DESCRIPTION="A wad composer for Doom, Heretic, Hexen and Strife"
HOMEPAGE="http://www.teaser.fr/~amajorel/deutex/"
SRC_URI="https://github.com/chungy/deutex/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-2+ LGPL-2+ HPND"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~x86"
IUSE=""

RDEPEND=""
DEPEND=""

src_configure() {
	./configure \
		--cc "$(tc-getCC)" \
		--cflags "${CFLAGS}" \
		--ldflags "${LDFLAGS}" \
		--prefix "/usr"
}

src_install() {
	dobin deusf deutex
	doman deutex.6
	dodoc CHANGES README TODO
}
