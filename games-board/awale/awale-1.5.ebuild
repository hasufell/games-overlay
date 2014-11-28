# Copyright 2014 Julian Ospald <hasufell@posteo.de>
# Distributed under the terms of the GNU General Public License v2
# $Header: $

# do not use autotools related stuff in stable ebuilds
# unless you like random breakage: 469796, 469798, 424041

EAPI=5
inherit eutils gnome2-utils # STABLE ARCH
# inherit autotools eutils gnome2-utils # UNSTABLE ARCH

DESCRIPTION="Free Awale - The game of all Africa"
HOMEPAGE="http://www.nongnu.org/awale/"
SRC_URI="mirror://nongnu/awale/${P}.tar.gz"
SRC_URI="${SRC_URI} http://dev.gentoo.org/~hasufell/distfiles/${P}-no-autoreconf2.patch.xz" # STABLE ARCH

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="tk"

RDEPEND="tk? ( dev-lang/tcl dev-lang/tk )"

src_prepare() {
	epatch "${FILESDIR}"/${P}-build.patch
	epatch "${DISTDIR}"/${P}-no-autoreconf2.patch.xz # STABLE ARCH

	mv src/xawale.tcl src/xawale.tcl.in || die
#	mv configure.in configure.ac || die # UNSTABLE ARCH
#	eautoreconf # UNSTABLE ARCH
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

