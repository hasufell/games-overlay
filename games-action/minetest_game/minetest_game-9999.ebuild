# Copyright 2014 Julian Ospald <hasufell@posteo.de>
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5
inherit git-2

DESCRIPTION="The main game for the Minetest game engine"
HOMEPAGE="http://github.com/minetest/minetest_game"
EGIT_REPO_URI="git://github.com/minetest/${PN}.git"

LICENSE="GPL-2 CC-BY-SA-3.0"
SLOT="0"
KEYWORDS=""
IUSE=""

RDEPEND="~games-action/minetest-${PV}"

src_unpack() {
	git-2_src_unpack
}

src_install() {
	insinto /usr/share/minetest/games/${PN}
	doins -r mods menu
	doins game.conf minetest.conf

	dodoc README.txt game_api.txt
}
