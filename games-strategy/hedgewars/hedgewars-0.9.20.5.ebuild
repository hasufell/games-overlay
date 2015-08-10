# Copyright 2014 Julian Ospald <hasufell@posteo.de>
# Copyright 2014 <zimous@matfyz.cz>
# Distributed under the terms of the GNU General Public License v2
# $Id$

# TODO: when physfs-2.1.0 hits the tree, set
# -DPHYSFS_SYSTEM=ON

EAPI=5
CMAKE_BUILD_TYPE=Release
inherit cmake-utils eutils multilib

MY_P=${PN}-src-${PV}
DESCRIPTION="A turn-based strategy, artillery, action and comedy game"
HOMEPAGE="http://hedgewars.org/"
SRC_URI="http://download.gna.org/hedgewars/${MY_P}.tar.bz2"

LICENSE="GPL-2 Apache-2.0 FDL-1.3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="server"
QA_FLAGS_IGNORED=/usr/bin/hwengine
QA_PRESTRIPPED=/usr/bin/hwengine

CDEPEND="
	dev-lang/lua
	dev-qt/qtcore:4
	dev-qt/qtgui:4
	media-libs/freeglut
	media-libs/libpng:0
	media-libs/libsdl[sound,opengl,video]
	media-libs/sdl-image[png]
	media-libs/sdl-mixer[vorbis]
	media-libs/sdl-net
	media-libs/sdl-ttf
	sys-libs/zlib
	virtual/ffmpeg
	server? (
		dev-haskell/binary
		dev-haskell/bytestring-show
		dev-haskell/dataenc
		dev-haskell/deepseq
		dev-haskell/hslogger
		>=dev-haskell/mtl-2.0.1.0
		>=dev-haskell/network-2.3
		>=dev-haskell/parsec-3
		dev-haskell/utf8-string
		dev-haskell/vector
		dev-haskell/random
		>=dev-libs/gmp-5:=
		virtual/libffi:=
	)
"
DEPEND="${CDEPEND}
	>=dev-lang/fpc-2.4
	>=dev-lang/ghc-7.0:=
"
RDEPEND="${CDEPEND}
	media-fonts/wqy-zenhei
	>=media-fonts/dejavu-2.28
"

S=${WORKDIR}/${PN}-src-${PV:0:6}

src_prepare() {
	# see http://code.google.com/p/hedgewars/issues/detail?id=798
	epatch "${FILESDIR}"/${P}-ghc-7.8.patch

	epatch "${FILESDIR}"/${P}-cmake3.patch
}

src_configure() {
	local mycmakeargs=(
		-DMINIMAL_FLAGS=ON
		-DCMAKE_INSTALL_PREFIX=/usr/bin
		-DDATA_INSTALL_DIR="/usr/share/${PN}"
		-Dtarget_binary_install_dir=/usr/bin
		-Dtarget_library_install_dir="/usr/$(get_libdir)"
		$(cmake-utils_use !server NOSERVER)
		-DCMAKE_VERBOSE_MAKEFILE=TRUE
		-DPHYSFS_SYSTEM=OFF
	)
	cmake-utils_src_configure
}

src_compile() {
	cmake-utils_src_compile
}

src_install() {
	DOCS="ChangeLog.txt README" cmake-utils_src_install
	rm -f "${D%/}"/usr/share/hedgewars/Data/Fonts/{DejaVuSans-Bold.ttf,wqy-zenhei.ttc}
	dosym /usr/share/fonts/dejavu/DejaVuSans-Bold.ttf \
		/usr/share/${PN}/Data/Fonts/DejaVuSans-Bold.ttf
	dosym /usr/share/fonts/wqy-zenhei/wqy-zenhei.ttc \
		/usr/share/${PN}/Data/Fonts/wqy-zenhei.ttc
	doicon misc/hedgewars.png
	make_desktop_entry ${PN} Hedgewars
	doman man/${PN}.6
}
