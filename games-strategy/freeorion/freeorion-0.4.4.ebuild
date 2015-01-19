# Copyright 1999-2014 Gentoo Foundation
# Copyright 2015 Julian Ospald <hasufell@posteo.de>
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

PYTHON_COMPAT=( python2_7 )
inherit cmake-utils toolchain-funcs gnome2-utils python-single-r1

SVNREV="7760" # update on version bump!

DESCRIPTION="A free turn-based space empire and galactic conquest game"
HOMEPAGE="http://www.freeorion.org"
SRC_URI="http://dev.gentoo.org/~hasufell/distfiles/${P}.tar.xz"

LICENSE="GPL-2 LGPL-2.1 CC-BY-SA-3.0"
SLOT="0"
KEYWORDS="~amd64"
IUSE="cg"
REQUIRED_USE="${PYTHON_REQUIRED_USE}"

# Needs it's own version of GG(dev-games/gigi) which it ships.
# The split version dev-games/gigi is not used anymore as of 0.4.3
RDEPEND="${PYTHON_DEPS}
	!dev-games/gigi
	dev-games/ogre[cg?,ois,opengl]
	dev-games/ois
	>=dev-libs/boost-1.47[python,${PYTHON_USEDEP}]
	media-libs/freetype:2
	media-libs/libogg
	media-libs/libpng:0
	media-libs/libsdl[X,opengl,video]
	media-libs/libvorbis
	media-libs/openal
	media-libs/tiff:0
	sci-physics/bullet
	sys-libs/zlib
	virtual/glu
	virtual/jpeg
	virtual/opengl"
DEPEND="${RDEPEND}
	virtual/pkgconfig"

CMAKE_USE_DIR="${S}"

src_prepare() {
	# set OGRE plugin-dir
	sed \
		-e "s:PluginFolder=.*$:PluginFolder=$($(tc-getPKG_CONFIG) --variable=plugindir OGRE):" \
		-i "${CMAKE_USE_DIR}"/ogre_plugins.cfg.in || die

	if use cg ; then
		# add cg ogre plugin to config
		echo "Plugin=Plugin_CgProgramManager" \
			>> "${CMAKE_USE_DIR}"/ogre_plugins.cfg || die
	fi

	# parse subdir sets -O3
	sed -e "s:-O3::" -i parse/CMakeLists.txt

	# set revision for display in game!
	sed -i -e 's/???/'${SVNREV}'/' CMakeLists.txt
}

src_configure() {
	local mycmakeargs=(
		-DRELEASE_COMPILE_FLAGS=""
		-DCMAKE_SKIP_RPATH=ON
		)

	cmake-utils_src_configure
}

src_install() {
	# data files
	rm -f "${CMAKE_USE_DIR}"/default/COPYING
	insinto /usr/share/${PN}
	doins -r "${CMAKE_USE_DIR}"/default

	# bin
	dobin "${CMAKE_BUILD_DIR}"/${PN}{ca,d}
	newbin "${CMAKE_BUILD_DIR}"/${PN} ${PN}.bin
	make_wrapper ${PN} \
		"/usr/bin/${PN}.bin --resource-dir /usr/share/${PN}/default" \
		/usr/share/${PN}

	# lib
	dolib "${CMAKE_BUILD_DIR}"/libfreeorion{common,parse}.so
	dolib "${CMAKE_BUILD_DIR}"/libGiGi*.so

	# config
	insinto /etc/${PN}
	doins "${CMAKE_BUILD_DIR}"/ogre_plugins.cfg
	doins "${CMAKE_USE_DIR}"/OISInput.cfg
	# game uses relative paths
	dosym /etc/${PN}/ogre_plugins.cfg \
		/usr/share/${PN}/ogre_plugins.cfg
	dosym /etc/${PN}/OISInput.cfg \
		/usr/share/${PN}/OISInput.cfg

	# other
	dodoc "${CMAKE_USE_DIR}"/changelog.txt
	newicon -s 256 "${CMAKE_USE_DIR}"/default/data/art/icons/FO_Icon_256x256.png \
		${PN}.png
	make_desktop_entry ${PN}

	python_optimize "${ED%/}/usr/share/${PN}/default"
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
