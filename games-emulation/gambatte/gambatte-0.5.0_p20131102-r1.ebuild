# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

PYTHON_COMPAT=( python2_7 )

inherit eutils qt4-r2 toolchain-funcs python-any-r1

DESCRIPTION="An accuracy-focused Gameboy / Gameboy Color emulator"
HOMEPAGE="http://sourceforge.net/projects/gambatte"
SRC_URI="http://dev.gentoo.org/~hasufell/distfiles/${P}.tar.xz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="qt4 +sdl test"

SDL_DEP="media-libs/libsdl[X,sound,joystick,video]"
RDEPEND="
	sys-libs/zlib
	qt4? (
		dev-qt/qtcore:4
		dev-qt/qtgui:4
		dev-qt/qtopengl:4
		media-libs/alsa-lib
		x11-libs/libX11
		x11-libs/libXext
		x11-libs/libXrandr
		x11-libs/libXv
	)
	sdl? ( ${SDL_DEP} )
	!qt4? ( !sdl? ( ${SDL_DEP} ) )"
DEPEND="${RDEPEND}
	app-arch/xz-utils
	virtual/pkgconfig
	test? ( ${PYTHON_DEPS} )"

src_prepare() {
	if use sdl ; then
		WANT_SDL=true
	elif use !sdl && use !qt4 ; then
		ewarn "both sdl and qt4 clients disabled... enabling sdl client!"
		WANT_SDL=true
	else
		WANT_SDL=false
	fi

	epatch -p0 "${FILESDIR}"/${P}-makefile.patch \
		"${FILESDIR}"/${P}-clang.patch
	# Fix zlib/minizip build error
	sed -i \
		-e '1i#define OF(x) x' \
		libgambatte/src/file/unzip/{unzip,ioapi}.h \
		|| die "sed iompi.h failed"
}

src_compile() {
	# build core library
	emake \
		CC="$(tc-getCC)" \
		CXX="$(tc-getCXX)" \
		AR="$(tc-getAR)" \
		RANLIB="$(tc-getRANLIB)" \
		PKG_CONFIG="$(tc-getPKG_CONFIG)" \
		libgambatte/libgambatte.a

	# build sdl frontend
	if ${WANT_SDL}; then
		emake \
			CC="$(tc-getCC)" \
			CXX="$(tc-getCXX)" \
			AR="$(tc-getAR)" \
			RANLIB="$(tc-getRANLIB)" \
			PKG_CONFIG="$(tc-getPKG_CONFIG)"
	fi

	# build qt frontend
	if use qt4; then
		cd "${S}"/gambatte_qt || die
		eqmake4 ${PN}_qt.pro
		emake
	fi
}

src_test() {
	emake PYTHON="${EPYTHON}" test
}

src_install() {
	${WANT_SDL} && dobin gambatte_sdl/gambatte_sdl
	use qt4 && dobin gambatte_qt/bin/gambatte_qt

	nonfatal dodoc README changelog
}

