# Copyright 1999-2012 Gentoo Foundation
# Copyright 2014 Julian Ospald <hasufell@posteo.de>
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit eutils

if [[ ${PV} == 9999* ]]; then
	inherit autotools mercurial
	EHG_REPO_URI="https://bitbucket.org/rude/${PN}"
	SRC_URI=""
	KEYWORDS=""
else
	SRC_URI="https://bitbucket.org/rude/${PN}/downloads/${P}-linux-src.tar.gz"
	KEYWORDS="~amd64 ~arm ~ppc ~x86"
fi

DESCRIPTION="A framework for 2D games in Lua"
HOMEPAGE="http://love2d.org/"

LICENSE="ZLIB"
SLOT="0.8"
IUSE=""

RDEPEND="dev-games/physfs
	dev-lang/lua[deprecated]
	media-libs/devil[mng,png,tiff]
	media-libs/freetype
	media-libs/libmodplug
	media-libs/libsdl[joystick,opengl]
	media-libs/libvorbis
	media-libs/openal
	media-sound/mpg123
	virtual/opengl"
DEPEND="${RDEPEND}"

DOCS=( "readme.md" "changes.txt" )

src_prepare() {
	epatch "${FILESDIR}"/${PN}-0.8.0-freetype.patch
	if [[ ${PV} == 9999* ]]; then
		sh platform/unix/gen-makefile || die
		mkdir platform/unix/m4 || die
		eautoreconf
	fi
}

src_install() {
	if [[ "${SLOT}" != "0" ]]; then
		newbin src/${PN} ${PN}-${SLOT}
		dodoc ${DOCS[@]}
	else
		default
	fi
}

