# Copyright 2014 Julian Ospald <hasufell@posteo.de>
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5
inherit eutils toolchain-funcs

DESCRIPTION="A UCI chess engine"
HOMEPAGE="http://www.stockfishchess.com/"
SRC_URI="https://s3.amazonaws.com/stockfish/stockfish-dd-src.zip -> ${P}.zip"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="cpu_flags_x86_sse"

RDEPEND=""
DEPEND="app-arch/unzip"

S="${WORKDIR}/stockfish-dd-src/src"

src_prepare() {
	epatch "${FILESDIR}"/${P}-make.patch
}

src_compile() {
	emake CXX="$(tc-getCXX)" CXXFLAGS="${CXXFLAGS}" \
		arch=any os=any bits=$(usex amd64 "64" "32") \
		bsfq=no popcnt=no \
		prefetch=$(usex cpu_flags_x86_sse "yes" "no") sse=$(usex cpu_flags_x86_sse "yes" "no") \
		all
}

src_install() {
	dobin ${PN}
	dodoc ../Readme.md
}

pkg_postinst() {
	elog
	elog "Note: The opening book hasn't been installed. If you want it, just"
	elog "      download it from ${HOMEPAGE}."
	elog "      In most cases you take now your xboard compatible application,"
	elog "      (xboard, eboard, knights) and just play chess against computer"
	elog "      opponent. Have fun."
	elog
}

