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
	dev-qt/qtcore:4
	dev-qt/qtgui:4
	>=media-fonts/dejavu-2.28
	media-fonts/wqy-zenhei
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
		>=dev-libs/gmp-5
		virtual/libffi
	)
"
RDEPEND="${CDEPEND}"
DEPEND="${CDEPEND}
	>=dev-lang/fpc-2.4
	server? (
		dev-haskell/binary
		dev-haskell/bytestring-show
		dev-haskell/dataenc
		dev-haskell/entropy
		dev-haskell/hslogger
		>=dev-haskell/mtl-2.0.1.0
		>=dev-haskell/network-2.3
		>=dev-haskell/parsec-3
		dev-haskell/random
		dev-haskell/sha
		dev-haskell/utf8-string
		dev-haskell/vector
		dev-haskell/zlib
		>=dev-lang/ghc-7.0
	)
"

S=${WORKDIR}/${PN}-src-${PV:0:6}

src_configure() {
	local mycmakeargs=(
		-DMINIMAL_FLAGS=ON
		-DDATA_INSTALL_DIR="/usr/share/${PN}"
		-Dtarget_library_install_dir="/usr/$(get_libdir)"
		$(cmake-utils_use !server NOSERVER)
		-DCMAKE_VERBOSE_MAKEFILE=TRUE
		-DLUA_SYSTEM=OFF
		-DPHYSFS_SYSTEM=OFF
		-DFONTS_DIRS="/usr/share/fonts/dejavu;/usr/share/fonts/wqy-zenhei"
	)
	cmake-utils_src_configure
}

src_compile() {
	cmake-utils_src_compile
}

src_install() {
	DOCS="ChangeLog.txt README" cmake-utils_src_install
	doicon misc/hedgewars.png
	make_desktop_entry ${PN} Hedgewars
	doman man/${PN}.6
}
