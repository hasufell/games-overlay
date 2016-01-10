# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

# cmake-utils.eclass hackery breaks the build
CMAKE_BUILD_TYPE=Release

inherit cmake-utils multilib toolchain-funcs flag-o-matic user

DESCRIPTION="Battle for Wesnoth - A fantasy turn-based strategy game"
HOMEPAGE="http://www.wesnoth.org/
	https://github.com/wesnoth/wesnoth"
SRC_URI="https://github.com/wesnoth/wesnoth/archive/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~ppc64 ~x86 ~x86-fbsd"
IUSE="dbus dedicated doc fribidi nls server tools"

RDEPEND="
	>=dev-libs/boost-1.36
	>=media-libs/libsdl-1.2.7[joystick,video,X]
	media-libs/sdl-net
	virtual/libintl
	!dedicated? (
		dev-lang/lua
		dev-libs/glib:2
		media-libs/fontconfig
		media-libs/libpng:0
		>=media-libs/sdl-ttf-2.0.8
		>=media-libs/sdl-mixer-1.2[vorbis]
		>=media-libs/sdl-image-1.2[jpeg,png]
		media-libs/libvorbis
		sys-libs/readline:0
		sys-libs/zlib
		x11-libs/cairo
		x11-libs/libX11
		x11-libs/pango
		dbus? ( sys-apps/dbus )
		fribidi? ( dev-libs/fribidi )
		tools? (
			media-libs/libpng:0
			sys-libs/zlib
		)
	)
"
DEPEND="${RDEPEND}
	sys-devel/gettext
	virtual/pkgconfig
"

pkg_setup() {
	enewgroup ${PN}
	enewuser ${PN} -1 /bin/bash -1 ${PN}
}

src_prepare() {
	if ! use doc ; then
		sed -i \
			-e '/manual/d' \
			doc/CMakeLists.txt || die
	fi
}

src_configure() {
	filter-flags -ftracer -fomit-frame-pointer

	if use dedicated || use server ; then
		mycmakeargs=(
			"-DENABLE_CAMPAIGN_SERVER=TRUE"
			"-DENABLE_SERVER=TRUE"
			"-DSERVER_UID=${PN}"
			"-DSERVER_GID=${PN}"
			"-DFIFO_DIR=/run/wesnothd"
			)
	else
		mycmakeargs=(
			"-DENABLE_CAMPAIGN_SERVER=FALSE"
			"-DENABLE_SERVER=FALSE"
			)
	fi
	mycmakeargs+=(
		-DCMAKE_CXX_FLAGS_RELEASE=""
		-DCMAKE_C_FLAGS_RELEASE=""
		$(cmake-utils_use_enable !dedicated GAME)
		$(cmake-utils_use_enable !dedicated ENABLE_DESKTOP_ENTRY)
		$(cmake-utils_use_enable nls NLS)
		$(cmake-utils_use_enable dbus NOTIFICATIONS)
		$(cmake-utils_use_enable fribidi FRIBIDI)
		$(cmake-utils_use_enable tools TOOLS)
		"-DCMAKE_VERBOSE_MAKEFILE=TRUE"
		"-DENABLE_FRIBIDI=FALSE"
		"-DENABLE_STRICT_COMPILATION=FALSE"
		"-DCMAKE_INSTALL_PREFIX=/usr"
		"-DDATAROOTDIR=/usr/share/"
		"-DBINDIR=/usr/bin"
		"-DICONDIR=/usr/share/pixmaps"
		"-DDESKTOPDIR=/usr/share/applications"
		"-DMANDIR=/usr/share/man"
		"-DDOCDIR=/usr/share/doc/${PF}"
		)
	cmake-utils_src_configure
}

src_compile() {
	cmake-utils_src_compile
}

src_install() {
	DOCS="README.md changelog players_changelog" cmake-utils_src_install
	if use dedicated || use server; then
		newinitd "${FILESDIR}"/wesnothd.rc wesnothd
	fi
}

