# Copyright 2014-2016 Julian Ospald <hasufell@posteo.de>
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5
inherit cmake-utils

DESCRIPTION="Data files for the cross-platform 3D realtime strategy game MegaGlest"
HOMEPAGE="http://www.megaglest.org/"
SRC_URI="https://github.com/MegaGlest/megaglest-data/archive/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="CC-BY-SA-3.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="doc"

RDEPEND="~games-strategy/megaglest-${PV}"

DOCS=( docs/AUTHORS.data.txt docs/CHANGELOG.txt docs/README.txt )

src_configure() {
	local mycmakeargs=(
		-DMEGAGLEST_BIN_INSTALL_PATH=/usr/bin
		-DMEGAGLEST_DATA_INSTALL_PATH=/usr/share/megaglest
		-DMEGAGLEST_ICON_INSTALL_PATH=/usr/share/pixmaps
	)
	cmake-utils_src_configure
}

src_compile() {
	cmake-utils_src_compile
}

src_install() {
	use doc && HTML_DOCS="docs/glest_factions/"

	cmake-utils_src_install
}

