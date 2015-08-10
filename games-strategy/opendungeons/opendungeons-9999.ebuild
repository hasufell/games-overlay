# Copyright 2014 Julian Ospald <hasufell@posteo.de>
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit cmake-utils eutils git-r3

MY_PN=OpenDungeons

DESCRIPTION="An open source, real time strategy game based on the Dungeon Keeper series"
HOMEPAGE="http://opendungeons.sourceforge.net"
EGIT_REPO_URI="https://github.com/OpenDungeons/OpenDungeons.git"
EGIT_BRANCH="development"

LICENSE="GPL-3 CC-BY-SA-3.0"
SLOT="0"
KEYWORDS=""
IUSE=""

RDEPEND=">=dev-games/cegui-0.7.0[ogre,opengl]
	>=dev-games/ogre-1.7.0[cg,freeimage,ois,opengl]
	dev-games/ois
	dev-libs/boost
	games-strategy/opendungeons-data
	media-libs/freetype:2
	media-libs/glew
	>=media-libs/libsfml-2
	media-libs/libsndfile
	media-libs/openal
	virtual/jpeg
	virtual/opengl"
DEPEND="${RDEPEND}
	virtual/pkgconfig"

CMAKE_IN_SOURCE_BUILD=1

src_configure() {
	local mycmakeargs=(
		-DOD_DATA_PATH=/usr/share/${MY_PN}
		-DOD_BIN_PATH=/usr/bin/
		-DOD_SHARE_PATH=/usr/share
		)

	cmake-utils_src_configure
}

src_install() {
	cmake-utils_src_install
	doicon "${FILESDIR}"/${PN}.svg
	make_desktop_entry ${MY_PN} ${PN} ${PN}
}

