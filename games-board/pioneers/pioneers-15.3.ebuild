# Copyright 1999-2014 Gentoo Foundation
# Copyright 2014 Julian Ospald <hasufell@posteo.de>
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5
inherit autotools eutils

DESCRIPTION="A clone of the popular board game The Settlers of Catan"
HOMEPAGE="http://pio.sourceforge.net/"
SRC_URI="mirror://sourceforge/pio/${P}.tar.gz"

LICENSE="GPL-2 CC-BY-SA-4.0"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~x86"
IUSE="dedicated help nls"

# dev-util/gob only for autoreconf
RDEPEND=">=dev-libs/glib-2.26:2
	!dedicated?	(
		>=x11-libs/gtk+-3.4:3
		>=x11-libs/libnotify-0.7.4
		help? (
			>=app-text/scrollkeeper-0.3.8
			>=gnome-base/libgnome-2.10
		)
	)
	nls? ( virtual/libintl )"
DEPEND="${RDEPEND}
	dev-util/gob:2
	virtual/pkgconfig
	nls? ( sys-devel/gettext )"

src_prepare() {
	epatch "${FILESDIR}"/${P}-build.patch
	eautoreconf
}

src_configure() {
	econf \
		$(use_enable nls) \
		--enable-minimal-flags \
		$(use_enable help) \
		$(use_with !dedicated gtk)
}

