# Copyright 2014 Julian Ospald <hasufell@posteo.de>
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5
inherit autotools eutils gnome2-utils

DESCRIPTION="puzzle game similar to Oxyd"
HOMEPAGE="http://www.nongnu.org/enigma/"
SRC_URI="mirror://sourceforge/enigma-game/${P}.tar.gz"

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="nls"

COMMON_DEPS="media-libs/sdl-ttf
	media-libs/libsdl[video]
	media-libs/sdl-mixer
	media-libs/sdl-image[jpeg,png]
	media-libs/libpng:0=
	sys-libs/zlib
	net-misc/curl
	|| ( >=dev-libs/xerces-c-3[icu] >=dev-libs/xerces-c-3[-icu,-iconv] )
	net-libs/enet
	media-fonts/dejavu
	nls? ( virtual/libintl )"
DEPEND="${COMMON_DEPS}
	sys-devel/gettext"
RDEPEND="${COMMON_DEPS}
	x11-misc/xdg-utils"

src_prepare() {
	epatch "${FILESDIR}"/0003-Respect-CXXFLAGS.patch \
		"${FILESDIR}"/0004-Don-t-build-documentation.patch \
		"${FILESDIR}"/0005-Fix-localedir-destination.patch
	cp /usr/share/gettext/config.rpath .
	sed -i \
		-e "s:DOCDIR:\"/usr/share/doc/${P}/html\":" \
		src/main.cc || die
	eautoreconf
}

src_configure() {
	econf \
		$(use_enable nls) \
		--with-system-enet
}

src_install() {
	emake DESTDIR="${D}" install
	dosym \
		/usr/share/fonts/dejavu/DejaVuSansCondensed.ttf \
		/usr/share/${PN}/fonts/DejaVuSansCondensed.ttf
	dodoc ACKNOWLEDGEMENTS AUTHORS CHANGES README doc/HACKING
	dohtml -r doc/*
	doman doc/enigma.6
}

pkg_preinst() {
	gnome2_icon_savelist
}

pkg_postinst() {
	gnome2_icon_cache_update
}

pkg_postrm() {
	gnome2_icon_cache_update
}

