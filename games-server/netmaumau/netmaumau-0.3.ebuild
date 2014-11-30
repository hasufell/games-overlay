# Copyright 2014 Julian Ospald <hasufell@posteo.de>
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

DESCRIPTION="Server for the popular card game Mau Mau"
HOMEPAGE="http://sourceforge.net/projects/netmaumau"
SRC_URI="mirror://sourceforge/netmaumau/${P}.tar.xz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND="dev-libs/popt"
DEPEND="${RDEPEND}
	virtual/pkgconfig"

src_configure() {
	econf \
		--docdir=/usr/share/doc/${PF}
}

pkg_postinst() {
	elog "This is only the server part, you might want to install"
	elog "the client too:"
	elog "  games-board/netmaumau"
}

