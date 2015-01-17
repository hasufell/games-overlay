# Copyright 2015 Julian Ospald <hasufell@posteo.de>, Heiko Schaefer <heiko@rangun.de>
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit autotools flag-o-matic eutils libtool vcs-snapshot

DESCRIPTION="Server for the popular card game Mau Mau"
HOMEPAGE="http://sourceforge.net/projects/netmaumau"
SRC_URI="https://github.com/velnias75/NetMauMau/archive/V${PV}.tar.gz -> ${P}-server.tar.gz"

LICENSE="LGPL-3"
SLOT="0/0"
KEYWORDS="~amd64 ~x86"
IUSE="doc static-libs -cli-client -xinetd"

RDEPEND="
	>=dev-libs/popt-1.10
	>=sci-libs/gsl-1.9
	sys-apps/file
	dev-db/sqlite:3
	xinetd? ( sys-apps/xinetd )
"
DEPEND="${RDEPEND}
	app-editors/vim-core
	sys-apps/help2man
	virtual/pkgconfig
	doc? ( >=app-doc/doxygen-1.8.0 )
"

S=${WORKDIR}/${P}-server

src_prepare() {
	eautoreconf
}

src_configure() {
	append-cppflags -DNDEBUG

	econf \
		--enable-client \
		$(use_enable xinetd) \
		$(use_enable cli-client) \
		$(use_enable doc apidoc) \
		--enable-ai-name="Gentoo Hero" \
		--docdir=/usr/share/doc/${PF} \
		--localstatedir=/var/lib/games/ \
		$(use_enable static-libs static)
}

src_install() {
	default
	rm -f "${D}"/usr/share/netmaumau/ai_img*.png
	prune_libtool_files
	keepdir "${ROOT}"/var/lib/games/netmaumau
	fowners nobody:nogroup "${ROOT}"/var/lib/games/netmaumau
}

pkg_postinst() {

	cd "${ROOT}"/usr/share/netmaumau

	if [ ! -e ai_img1.png ]; then \
		ln -s QS.PNG ai_img1.png ; \
	fi
	if [ ! -e ai_img2.png ]; then \
		ln -s KC.PNG ai_img2.png ; \
        fi
	if [ ! -e ai_img3.png ]; then \
		ln -s QC.PNG ai_img3.png ; \
	fi

	elog "This is only the server part, you might want to install"
	elog "the client too:"
	elog "  games-board/netmaumau"
}
