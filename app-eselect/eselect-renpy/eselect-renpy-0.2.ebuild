# Copyright 2014 Julian Ospald <hasufell@posteo.de>
# Distributed under the terms of the GNU General Public License v2

EAPI=6

DESCRIPTION="Manages renpy symlink"
HOMEPAGE="https://www.gentoo.org/proj/en/eselect/"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"

RDEPEND="app-eselect/eselect-lib-bin-symlink"

S=${WORKDIR}

pkg_setup() { :; }

src_prepare() {
	sed \
		-e "s#@GAMES_BINDIR@#/usr/bin#" \
		"${FILESDIR}"/renpy.eselect-${PV} > "${WORKDIR}"/renpy.eselect || die
}

src_install() {
	insinto /usr/share/eselect/modules
	doins renpy.eselect
}
