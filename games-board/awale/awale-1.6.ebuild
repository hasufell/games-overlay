# Copyright 2014 Julian Ospald <hasufell@posteo.de>
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5
WANT_AUTOMAKE=1.13
inherit autotools eutils gnome2-utils

DESCRIPTION="Free Awale - The game of all Africa"
HOMEPAGE="http://www.nongnu.org/awale/"
SRC_URI="mirror://nongnu/awale/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="tk"

RDEPEND="tk? ( dev-lang/tcl dev-lang/tk )"

src_prepare() {
	epatch "${FILESDIR}"/${P}-build.patch

	mv src/xawale.tcl src/xawale.tcl.in || die
	mv configure.in configure.ac || die
	eautoreconf
}

src_configure() {
	econf \
		$(use_enable tk)
}

src_install() {
	emake -j1 DESTDIR="${D}" install
	dodoc AUTHORS ChangeLog NEWS README THANKS
	use tk && fperms +x /usr/share/${PN}/xawale.tcl
}

pkg_preinst() {
	use tk && gnome2_icon_savelist
}

pkg_postinst() {
	use tk && gnome2_icon_cache_update
}

pkg_postrm() {
	use tk && gnome2_icon_cache_update
}

