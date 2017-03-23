# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6
inherit user cmake-utils

DESCRIPTION="Battle for Wesnoth - A fantasy turn-based strategy game"
HOMEPAGE="http://www.wesnoth.org
	https://github.com/wesnoth/wesnoth"
SRC_URI="https://github.com/${PN}/${PN}/archive/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86 ~x86-fbsd"
IUSE="dbus dedicated doc fribidi nls openmp server tools"

RDEPEND="
	>=dev-libs/boost-1.48:=[nls,threads]
	>=media-libs/libsdl-1.2.7:0[joystick,video,X]
	media-libs/sdl-net
	virtual/libintl
	!dedicated? (
		dev-lang/lua:0
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
	)"
DEPEND="${RDEPEND}
	sys-devel/gettext
	virtual/pkgconfig"

pkg_setup() {
	if use openmp; then
		tc-has-openmp || die "Please switch to an openmp compatible compiler"
	fi

	enewgroup ${PN}
	enewuser ${PN} -1 /bin/bash -1 ${PN}
}

src_prepare() {
	cmake-utils_src_prepare

	if ! use doc ; then
		sed -i \
			-e '/manual/d' \
			doc/CMakeLists.txt || die
	fi

	# respect LINGUAS (bug #483316)
	if [[ ${LINGUAS+set} ]] ; then
		local langs
		for lang in $(cat po/LINGUAS)
		do
			has $lang $LINGUAS && langs+="$lang "
		done
		echo "$langs" > po/LINGUAS || die
	fi
}

src_configure() {
	filter-flags -ftracer -fomit-frame-pointer
	if [[ $(gcc-major-version) -eq 3 ]] ; then
		filter-flags -fstack-protector
		append-flags -fno-stack-protector
	fi

	# Work around eclass
	append-flags -UNDEBUG

	if use dedicated || use server ; then
		mycmakeargs=(
			-DENABLE_CAMPAIGN_SERVER="ON"
			-DENABLE_SERVER="ON"
			-DSERVER_UID="${PN}"
			-DSERVER_GID="${PN}"
			-DFIFO_DIR="/run/wesnothd"
			)
	else
		mycmakeargs=(
			-DENABLE_CAMPAIGN_SERVER="OFF"
			-DENABLE_SERVER="OFF"
			)
	fi
	mycmakeargs+=(
		-Wno-dev
		-DENABLE_GAME="$(usex !dedicated)"
		-DENABLE_DESKTOP_ENTRY="$(usex !dedicated)"
		-DENABLE_NLS="$(usex !nls)"
		-DENABLE_NOTIFICATIONS="$(usex dbus)"
		-DENABLE_FRIBIDI="$(usex fribidi)"
		-DENABLE_TOOLS="$(usex tools)"
		-DENABLE_OMP="$(usex openmp)"
		-DENABLE_STRICT_COMPILATION="OFF"
		-DCMAKE_INSTALL_PREFIX="/usr"
		-DDATAROOTDIR="/usr/share"
		-DBINDIR="/usr/bin"
		-DICONDIR="/usr/share/pixmaps"
		-DDESKTOPDIR="/usr/share/applications"
		-DMANDIR="/usr/share/man"
		-DDOCDIR="/usr/share/doc/${PF}"
		)
	cmake-utils_src_configure
}

src_install() {
	DOCS="README.md changelog players_changelog" cmake-utils_src_install
	if use dedicated || use server; then
		keepdir "/run/wesnothd"
		newinitd "${FILESDIR}"/wesnothd.rc wesnothd
	fi
}
