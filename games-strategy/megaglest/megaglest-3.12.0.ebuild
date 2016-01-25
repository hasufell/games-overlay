# Copyright 2014-2016 Julian Ospald <hasufell@posteo.de>
# Distributed under the terms of the GNU General Public License v2
# $Id$

# google-breakpad
# TODO: fribidi, libvorbis static

EAPI=5
VIRTUALX_REQUIRED="manual"
inherit eutils flag-o-matic cmake-utils virtualx wxwidgets gnome2-utils

DESCRIPTION="Cross-platform 3D realtime strategy game"
HOMEPAGE="http://www.megaglest.org/"
SRC_URI="https://github.com/MegaGlest/megaglest-source/releases/download/${PV}/megaglest-source-${PV}.tar.xz"

LICENSE="GPL-3 BitstreamVera"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="cpu_flags_x86_sse cpu_flags_x86_sse2 cpu_flags_x86_sse3 +editor +fontconfig fribidi +ftgl +irc libressl static +streflop +tools +unicode wxuniversal +model-viewer videos +xml"

RDEPEND="
	>=dev-lang/lua-5.1:0
	fontconfig? ( media-libs/fontconfig )
	media-libs/freetype
	media-libs/libsdl2[X,haptic,sound,joystick,opengl,video]
	media-libs/libvorbis
	media-libs/openal
	sys-libs/zlib
	virtual/opengl
	virtual/glu
	x11-libs/libX11
	editor? ( x11-libs/wxGTK:2.8[X,opengl] )
	fribidi? ( dev-libs/fribidi )
	!libressl? ( dev-libs/openssl:0 )
	libressl? ( dev-libs/libressl )
	model-viewer? ( x11-libs/wxGTK:2.8[X] )
	!static? (
		dev-libs/xerces-c[icu]
		ftgl? ( media-libs/ftgl )
		media-libs/glew
		media-libs/libpng:0
		irc? ( net-libs/libircclient )
		>=net-libs/miniupnpc-1.8
		net-misc/curl
		virtual/jpeg:0
		)
	videos? ( media-video/vlc )
	xml? ( dev-libs/xerces-c )"
DEPEND="${RDEPEND}
	virtual/pkgconfig
	editor? ( ${VIRTUALX_DEPEND} )
	model-viewer? ( ${VIRTUALX_DEPEND} )
	static? (
		dev-libs/icu[static-libs]
		dev-libs/xerces-c[icu,static-libs]
		ftgl? ( media-libs/ftgl[static-libs] )
		media-libs/glew[static-libs]
		media-libs/libpng:0[static-libs]
		irc? ( net-libs/libircclient[static-libs] )
		net-libs/miniupnpc[static-libs]
		net-misc/curl[static-libs]
		virtual/jpeg:0[static-libs]
	)"
PDEPEND="~games-strategy/${PN}-data-${PV}"

src_prepare() {
	if use editor || use model-viewer ; then
		WX_GTK_VER="2.8"
		need-wxwidgets unicode
	fi

	epatch "${FILESDIR}"/${PN}-3.11.1-cmake.patch
}

src_configure() {
	if use cpu_flags_x86_sse3; then
		SSE=3
	elif use cpu_flags_x86_sse2; then
		SSE=2
	elif use cpu_flags_x86_sse; then
		SSE=1
	else
		SSE=0
	fi

	local mycmakeargs=(
		-DBUILD_MEGAGLEST_MAP_EDITOR="$(usex editor)"
		-DBUILD_MEGAGLEST_MODEL_IMPORT_EXPORT_TOOLS="$(usex tools)"
		-DBUILD_MEGAGLEST_MODEL_VIEWER="$(usex model-viewer)"
		-DCUSTOM_DATA_INSTALL_PATH="/usr/share/${PN}/"
		-DFORCE_MAX_SSE_LEVEL="${SSE}"
		-DWANT_GIT_STAMP=OFF
		-DWANT_STATIC_LIBS="$(usex static)"
		-DWANT_USE_FTGL="$(usex ftgl)"
		-DWANT_USE_FontConfig="$(usex ftgl)"
		-DWANT_USE_FriBiDi="$(usex fribidi)"
		-DWANT_USE_GoogleBreakpad=OFF
		-DWANT_USE_Ircclient="$(usex irc)"
		-DWANT_USE_STREFLOP="$(usex streflop)"
		-DWANT_USE_VLC="$(usex videos)"
		-DWANT_USE_XercesC="$(usex xml)"
		-DwxWidgets_USE_STATIC="$(usex static)"
		-DwxWidgets_USE_UNICODE="$(usex unicode)"
		-DwxWidgets_USE_UNIVERSAL="$(usex wxuniversal)"
	)

	# support CMAKE_BUILD_TYPE=Gentoo
	append-cppflags '-DCUSTOM_DATA_INSTALL_PATH=\\\"'/usr/share/${PN}/'\\\"'

	cmake-utils_src_configure
}

src_compile() {
	if use editor || use model-viewer; then
		# work around parallel make issues - bug #561380
		MAKEOPTS="-j1 ${MAKEOPTS}" \
			VIRTUALX_COMMAND="cmake-utils_src_compile" virtualmake
	else
		cmake-utils_src_compile
	fi
}

src_install() {
	if [[ ${CMAKE_MAKEFILE_GENERATOR} != emake ]] ; then
		cmake-utils_src_install
	else
		# rebuilds some targets randomly without fast option
		emake -C "${BUILD_DIR}" DESTDIR="${D}" "$@" install/fast
	fi

	dodoc docs/{AUTHORS.source_code,CHANGELOG,README}.txt

	use editor &&
		make_desktop_entry ${PN}_editor "MegaGlest Map Editor"
	use model-viewer &&
		make_desktop_entry ${PN}_g3dviewer "MegaGlest Model Viewer"
}

pkg_preinst() {
	gnome2_icon_savelist
}

pkg_postinst() {
	einfo
	elog 'Note about Configuration:'
	elog 'DO NOT directly edit glest.ini and glestkeys.ini but rather glestuser.ini'
	elog 'and glestuserkeys.ini in ~/.megaglest/ and create your user over-ride'
	elog 'values in these files.'
	elog
	elog 'If you have an older graphics card which only supports OpenGL 1.2, and the'
	elog 'game crashes when you try to play, try starting with "megaglest --disable-vbo"'
	elog 'Some graphics cards may require setting Max Lights to 1.'
	einfo

	gnome2_icon_cache_update
}

pkg_postrm() {
	gnome2_icon_cache_update
}

