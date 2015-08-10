# Copyright 2014 Julian Ospald <hasufell@posteo.de>
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit cmake-utils eutils subversion

DESCRIPTION="A cross-platform reimplementation of engine for the classic Bullfrog game, Syndicate"
HOMEPAGE="http://freesynd.sourceforge.net/"
ESVN_REPO_URI="svn://svn.code.sf.net/p/freesynd/code/freesynd/trunk"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS=""
IUSE=""

RDEPEND="media-libs/libogg
	media-libs/libpng:0
	media-libs/libsdl[X,sound,video]
	media-libs/libvorbis
	media-libs/sdl-mixer[mp3,vorbis]
	media-libs/sdl-image[png]"
DEPEND="${RDEPEND}"

CMAKE_IN_SOURCE_BUILD=1

src_install() {
	dobin src/${PN} || die
	insinto /usr/share/${PN}
	doins -r data || die
	newicon icon/sword.png ${PN}.png || die
	make_desktop_entry ${PN} ${PN} ${PN}
	dodoc NEWS README INSTALL AUTHORS || die
}

pkg_postinst() {
	elog "You have to set \"data_dir = /my/path/to/synd-data\""
	elog "in \"~/.${PN}/${PN}.ini\"."
}
