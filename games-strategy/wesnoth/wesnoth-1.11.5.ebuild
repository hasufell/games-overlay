# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5
inherit cmake-utils eutils multilib toolchain-funcs flag-o-matic user

DESCRIPTION="Battle for Wesnoth - A fantasy turn-based strategy game"
HOMEPAGE="http://www.wesnoth.org/"
SRC_URI="mirror://sourceforge/wesnoth/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~ppc64 ~x86 ~x86-fbsd"
IUSE="dbus dedicated doc nls server tools"

RDEPEND=">=media-libs/libsdl-1.2.7[joystick,video,X]
	media-libs/sdl-net
	media-libs/libvorbis
	!dedicated? (
		>=media-libs/sdl-ttf-2.0.8
		>=media-libs/sdl-mixer-1.2[vorbis]
		>=media-libs/sdl-image-1.2[jpeg,png]
		dbus? ( sys-apps/dbus )
		sys-libs/zlib
		x11-libs/pango
		dev-lang/lua
		media-libs/fontconfig
		tools? (
			media-libs/libpng:0
			sys-libs/zlib
		)
	)
	>=dev-libs/boost-1.36
	virtual/libintl"
DEPEND="${RDEPEND}
	virtual/pkgconfig
	sys-devel/gettext"

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

	export BOOST_INCLUDEDIR="/usr/include/boost"
	export BOOST_LIBRARYDIR="/usr/$(get_libdir)"

	# bug #472994
	mv icons/wesnoth-icon-Mac.png icons/wesnoth-icon.png || die
	mv icons/map-editor-icon-Mac.png icons/wesnoth_editor-icon.png || die
}

src_configure() {
	filter-flags -ftracer -fomit-frame-pointer
	if [[ $(gcc-major-version) -eq 3 ]] ; then
		filter-flags -fstack-protector
		append-flags -fno-stack-protector
	fi
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
		$(cmake-utils_use_enable !dedicated GAME)
		$(cmake-utils_use_enable !dedicated ENABLE_DESKTOP_ENTRY)
		$(cmake-utils_use_enable nls NLS)
		$(cmake-utils_use_enable dbus NOTIFICATIONS)
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
	DOCS="README changelog players_changelog" cmake-utils_src_install
	if use dedicated || use server; then
		newinitd "${FILESDIR}"/wesnothd.rc wesnothd || die
	fi
}

