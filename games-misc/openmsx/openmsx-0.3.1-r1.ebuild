# Copyright 1999-2010 Gentoo Foundation
# Copyright 2014 Julian Ospald <hasufell@posteo.de>
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5
PYTHON_COMPAT=( python2_7 )
inherit python-any-r1

DESCRIPTION="An ambiguously named music replacement set for OpenTTD"
HOMEPAGE="http://bundles.openttdcoop.org/openmsx/"
SRC_URI="http://bundles.openttdcoop.org/openmsx/releases/${PV}/${P}-source.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~arm ~ppc ~ppc64 ~x86"
IUSE=""

DEPEND="${PYTHON_DEPS}"

S=${WORKDIR}/${P}-source

src_compile() {
	emake bundle
}

src_install() {
	insinto /usr/share/openttd/gm/${P}
	doins ${P}/{*.mid,openmsx.obm}
	dodoc ${P}/{changelog.txt,readme.txt}
}

