# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5
inherit eutils java-pkg-2 java-ant-2

DESCRIPTION="An open source clone of the game Colonization"
HOMEPAGE="http://www.freecol.org/"
SRC_URI="mirror://sourceforge/${PN}/${P}-src.zip"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="
	app-arch/unzip
	>=virtual/jdk-1.7
"
RDEPEND="
	>=virtual/jre-1.7
"

JAVA_ANT_ENCODING="iso8859-1"

S=${WORKDIR}/${PN}

src_prepare() {
	java-pkg-2_src_prepare
}

src_configure() {
	java-ant-2_src_configure
}

src_compile() {
	EANT_BUILD_TARGET=package
	java-pkg-2_src_compile
}

src_install() {
	java-pkg_jarinto /usr/share/${PN}/jars
	java-pkg_dojar jars/*.jar
	java-pkg_jarinto /usr/share/${PN}
	java-pkg_dojar FreeCol.jar
	java-pkg_dolauncher ${PN} \
		-into /usr \
		--pwd /usr/share/${PN} \
		--jar FreeCol.jar \
		--java_args -Xmx512M
	insinto /usr/share/${PN}
	doins -r data schema splash.jpg
	doicon ${PN}.xpm
	make_desktop_entry ${PN} FreeCol
	dodoc README
}

