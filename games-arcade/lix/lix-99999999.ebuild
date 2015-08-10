# Copyright 2014 Julian Ospald <hasufell@posteo.de>
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit eutils git-2

DESCRIPTION="Action-puzzle game, single- and networked multiplayer, inspired by Lemmings"
HOMEPAGE="http://asdfasdf.ethz.ch/~simon/index.php"
EGIT_REPO_URI="https://github.com/SimonN/Lix.git"
SRC_URI="http://dev.gentoo.org/~hasufell/distfiles/${PN}.png"

LICENSE="CC0-1.0"
SLOT="0"
KEYWORDS=""
IUSE=""

RDEPEND="media-libs/allegro:0
	media-libs/libpng:0
	net-libs/enet:1.3
	sys-libs/zlib"
DEPEND="virtual/pkgconfig"

src_compile() {
	emake \
		STRIP=touch \
		V=1
}

src_install() {
	local f

	insinto /usr/share/${PN}
	doins -r images/ data/ doc/ levels/

	insinto /usr/share/${PN}/replays
	doins -r replays/*
	dosym /usr/share/${PN}/replays /usr/share/${PN}/replays

	for f in ${PN} ${PN}d ; do
		newbin bin/${f} ${f}-bin
		make_wrapper ${f} ${f}-bin /usr/share/${PN}
	done
	make_desktop_entry ${PN}

	doicon "${DISTDIR}"/${PN}.png
}

