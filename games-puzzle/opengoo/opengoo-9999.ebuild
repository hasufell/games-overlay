# Copyright 2014 Julian Ospald <hasufell@posteo.de>
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit eutils gnome2-utils qmake-utils git-2

DESCRIPTION="Free clone of World Of Goo"
HOMEPAGE="http://mandarancio.github.io/OpenGOO/"
SRC_URI=""
EGIT_REPO_URI="https://github.com/Mandarancio/OpenGOO.git"

LICENSE="GPL-3+"
SLOT="0"
KEYWORDS=""
IUSE=""

RDEPEND="
	dev-qt/qtcore:5
	dev-qt/qtgui:5
	dev-qt/qtopengl:5
	dev-qt/qtwidgets:5
	dev-qt/qtxml:5"
DEPEND=""

src_prepare() {
	eqmake5 ${PN}.pro
}

src_install() {
	insinto /usr/share/${PN}
	doins -r Artworks properties res resources
	dobin OpenGOO
	make_wrapper ${PN} OpenGOO /usr/share/${PN}

	newicon -s scalable Artworks/black-goo.v1.0.svg ${PN}.svg
	make_desktop_entry ${PN}

	einstalldocs
}

pkg_preinst() {
	gnome2_icon_savelist
}

pkg_postinst() {
	gnome2_icon_cache_update
}

pkg_postrm() {
	gnome2_icon_cache_update
}

