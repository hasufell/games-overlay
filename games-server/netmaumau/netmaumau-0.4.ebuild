# Copyright 2014 Julian Ospald <hasufell@posteo.de>
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit flag-o-matic autotools-utils eutils libtool

DESCRIPTION="Server for the popular card game Mau Mau"
HOMEPAGE="http://sourceforge.net/projects/netmaumau"
SRC_URI="mirror://sourceforge/netmaumau/${P}.tar.xz"

LICENSE="LGPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="-static-libs client -doc"

RDEPEND=">=dev-libs/popt-1.10
	doc? ( >=app-doc/doxygen-1.8.0 )"
DEPEND="${RDEPEND}
	virtual/pkgconfig"

src_prepare() {
    elibtoolize
}

src_configure() {
    append-cppflags -DNDEBUG
    local myeconfargs=(
        $(use_enable client)
        $(use_enable doc apidoc)
        --enable-ai-name="Gentoo Hero"
	--docdir=/usr/share/doc/${PF}
    )
    autotools-utils_src_configure
}

src_compile() {
    autotools-utils_src_compile
}

src_install() {
    autotools-utils_src_install
}

pkg_postinst() {
	elog "This is only the server part, you might want to install"
	elog "the client too:"
	elog "  games-board/netmaumau"
	elog "For a server only install remove the USE-flag 'client'"
}
