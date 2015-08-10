# Copyright 2014 Julian Ospald <hasufell@posteo.de>
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit cmake-utils eutils

DESCRIPTION="A realtime strategy game engine"
HOMEPAGE="http://stratagus.sourceforge.net/"
SRC_URI="http://launchpad.net/stratagus/trunk/${PV}/+download/stratagus_${PV}.orig.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="bzip2 debug doc mikmod mng theora vorbis"

RDEPEND="dev-db/sqlite:3
	>=dev-lang/lua-5
	dev-lua/toluapp
	media-libs/libpng:0
	virtual/opengl
	x11-libs/libX11
	media-libs/libsdl[sound,opengl,video]
	sys-libs/zlib
	bzip2? ( app-arch/bzip2 )
	mikmod? ( media-libs/libmikmod )
	mng? ( media-libs/libmng )
	vorbis? (
		media-libs/libogg
		media-libs/libvorbis
		theora? ( media-libs/libtheora )
	)"
DEPEND="${RDEPEND}
	doc? ( app-doc/doxygen )
	virtual/pkgconfig"

REQUIRED_USE="theora? ( vorbis )"

S=${WORKDIR}/${PN}_${PV}.orig

src_prepare() {
	epatch "${FILESDIR}"/${P}-{debug,doc}.patch
}

src_configure() {
	# there are in-source switches
	use debug && CMAKE_BUILD_TYPE=Debug

	local mycmakeargs=(
		-DGAMEDIR=/usr/bin
		-DBINDIR=/usr/bin
		-DSBINDIR=/usr/bin
		-DDOCDIR="/usr/share/doc/${PF}"
		$(cmake-utils_use_with bzip2 BZIP2)
		$(cmake-utils_use_enable doc DOC)
		$(cmake-utils_use_with mikmod MIKMOD)
		$(cmake-utils_use_with mng MNG)
		$(cmake-utils_use_with vorbis OGGVORBIS)
		$(cmake-utils_use_with theora THEORA)
		-DENABLE_DEV=ON
	)

	cmake-utils_src_configure
}

