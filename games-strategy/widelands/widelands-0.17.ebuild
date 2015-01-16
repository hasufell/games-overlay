# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5
inherit eutils versionator toolchain-funcs flag-o-matic cmake-utils gnome2-utils

MY_PV=build$(get_version_component_range 2)
MY_P=${PN}-${MY_PV}-src
DESCRIPTION="A game similar to Settlers 2"
HOMEPAGE="http://www.widelands.org/"
SRC_URI="http://launchpad.net/widelands/${MY_PV}/build-$(get_version_component_range 2)/+download/${MY_P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~x86"
IUSE=""

RDEPEND="dev-lang/lua
	media-libs/libsdl[video]
	media-libs/sdl-image[jpeg,png]
	media-libs/sdl-mixer[vorbis]
	media-libs/sdl-gfx
	media-libs/sdl-net
	media-libs/libpng:0
	sys-libs/zlib
	media-libs/glew
	media-libs/sdl-ttf
	>=dev-libs/boost-1.37"
DEPEND="${RDEPEND}"

S=${WORKDIR}/${MY_P}

CMAKE_BUILD_TYPE=Release

src_prepare() {
	epatch \
		"${FILESDIR}"/${P}-cxxflags.patch \
		"${FILESDIR}"/${P}-gcc47.patch

	sed -i -e 's:__ppc__:__PPC__:' src/s2map.cc || die
	sed -i -e '74i#define OF(x) x' src/io/filesystem/{un,}zip.h || die
	sed -i -e '22i#define OF(x) x' src/io/filesystem/ioapi.h || die
	sed -i -e '/Boost_USE_STATIC_LIBS/s:ON:OFF:' CMakeLists.txt || die
}

src_configure() {
	local mycmakeargs=(
		'-DWL_VERSION_STANDARD=true'
		"-DWL_INSTALL_PREFIX=/usr"
		"-DWL_INSTALL_DATADIR=share/${PN}"
		"-DWL_INSTALL_LOCALEDIR=share/${PN}/locale"
		"-DWL_INSTALL_BINDIR=bin"
	)
	cmake-utils_src_configure
}

src_compile() {
	cmake-utils_src_compile
}

src_install() {
	cmake-utils_src_install
	newicon -s 128 pics/wl-ico-128.png ${PN}.png
	make_desktop_entry ${PN} Widelands
	dodoc ChangeLog CREDITS
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

