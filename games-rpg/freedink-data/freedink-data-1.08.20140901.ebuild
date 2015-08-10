# Copyright 2014 Julian Ospald <hasufell@posteo.de>
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

DESCRIPTION="Freedink game data"
HOMEPAGE="http://www.freedink.org/"
SRC_URI="mirror://gnu/freedink/${P}.tar.gz"

LICENSE="ZLIB
	CC-BY-SA-3.0
	CC-BY-3.0
	FreeArt
	GPL-2
	GPL-3
	OAL-1.0.1
	WTFPL-2
	public-domain"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

src_install() {
	emake DESTDIR="${D}" DATADIR="/usr/share" install
	dodoc README.txt README-REPLACEMENTS.txt
}

