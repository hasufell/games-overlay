# Copyright 2014 Julian Ospald <hasufell@posteo.de>
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit git-r3

MY_PN=${PN%-data}

DESCRIPTION="Data files for opendungeons"
HOMEPAGE="http://opendungeons.sourceforge.net"
EGIT_REPO_URI="https://github.com/OpenDungeons/OpenDungeons-media-source.git"

LICENSE="GPL-3 CC-BY-SA-3.0"
SLOT="0"
KEYWORDS=""
IUSE=""

src_install() {
	insinto /usr/share/OpenDungeons
	doins -r *
}

