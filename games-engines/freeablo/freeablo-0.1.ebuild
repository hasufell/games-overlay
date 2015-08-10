# Copyright 2014 Julian Ospald <hasufell@posteo.de>
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit cmake-utils

DESCRIPTION="Modern reimplementation of the Diablo 1 game engine"
HOMEPAGE="https://github.com/wheybags/freeablo"
SRC_URI="https://github.com/wheybags/freeablo/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND="app-arch/bzip2
	>=dev-games/stormlib-9.00
	>=dev-libs/boost-1.53.0[threads]
	media-libs/libsdl2
	sys-libs/zlib"
DEPEND="${RDEPEND}"

src_prepare() {
	sed -i \
		-e '/extern\/StormLib\/src/d' \
		-e '/add_subdirectory (extern)/d' \
		CMakeLists.txt || die

	sed -i \
		-e 's/StormLib/storm/' \
		CMakeLists.txt components/CMakeLists.txt || die
}

src_install() {
	dobin "${CMAKE_BUILD_DIR}"/freeablo
	make_desktop_entry freeablo freeablo
	dodoc readme.md
}

