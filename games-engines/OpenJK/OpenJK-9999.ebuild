# Copyright 2015 Julian Ospald <hasufell@posteo.de>
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit multilib eutils cmake-utils git-r3

DESCRIPTION="Open Source Jedi Academy and Jedi Outcast games engine"
HOMEPAGE="https://github.com/JACoders/OpenJK"
SRC_URI=""
EGIT_REPO_URI="git@github.com:JACoders/OpenJK.git
	https://github.com/JACoders/OpenJK.git"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="-* ~amd64 ~x86"
IUSE="dedicated"

RDEPEND="
	sys-libs/zlib
	!dedicated? (
		media-libs/libpng:0
		media-libs/libsdl2[opengl,video]
		virtual/jpeg:62
		virtual/opengl
	)
"
DEPEND="${RDEPEND}"

src_prepare() {
	# gentoos zlib is terrible
	sed -i \
		-e '1i#define OF(x) x' \
		lib/minizip/* || die "sed failed"

	# respect our build type, needs hax
	sed -i \
		-e 's/COMPILE_DEFINITIONS_RELEASE/COMPILE_DEFINITIONS/g' \
		code/CMakeLists.txt \
		code/game/CMakeLists.txt \
		code/rd-vanilla/CMakeLists.txt \
		codeJK2/game/CMakeLists.txt \
		codemp/CMakeLists.txt \
		codemp/cgame/CMakeLists.txt \
		codemp/game/CMakeLists.txt \
		codemp/rd-vanilla/CMakeLists.txt \
		codemp/ui/CMakeLists.txt \
		|| die "sed failed"
}

src_configure() {
	local mycmakeargs=(
		-DCMAKE_INSTALL_PREFIX=/usr/$(get_libdir)
		$(cmake-utils_use !dedicated BuildMPEngine)
		$(cmake-utils_use !dedicated BuildMPRdVanilla)
		$(cmake-utils_use !dedicated BuildSPEngine)
		$(cmake-utils_use !dedicated BuildSPGame)
		$(cmake-utils_use !dedicated BuildSPRdVanilla)
	)
	cmake-utils_src_configure
}

src_install() {
	local myext=$(usex amd64 "x86_64" "i386")
	local mylibdir=$(get_libdir)

	cmake-utils_src_install

	if use !dedicated ; then
		make_wrapper jka ./openjk.${myext} /usr/${mylibdir}/JediAcademy/ \
			"/usr/${mylibdir}/JediAcademy/base:/usr/${mylibdir}/JediAcademy/OpenJK"
		make_wrapper jka_sp ./openjk_sp.${myext} /usr/${mylibdir}/JediAcademy/ \
			"/usr/${mylibdir}/JediAcademy/base:/usr/${mylibdir}/JediAcademy/OpenJK"
		make_desktop_entry jka "Jedi Academy Multi Player"
		make_desktop_entry jka_sp "Jedi Academy Single Player"
	fi
	make_wrapper jka_ded ./openjkded.${myext} /usr/${mylibdir}/JediAcademy/ \
		"/usr/${mylibdir}/JediAcademy/base:/usr/${mylibdir}/JediAcademy/OpenJK"
}

pkg_postinst() {
	elog "You need to copy GameData/base/*.{pk3,cfg} from either your"
	elog "installation media or your hard drive to"
	elog "~/.local/share/openjk/base before running the game."
}
