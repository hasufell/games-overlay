# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5
inherit base eutils java-pkg-2 java-ant-2

DESCRIPTION="An open source clone of the game Colonization"
HOMEPAGE="http://www.freecol.org/"
SRC_URI="mirror://sourceforge/${PN}/${P}-src.zip"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

CDEPEND="
	dev-java/commons-cli:1
	dev-java/cortado
	dev-java/jsr173
	>=dev-java/miglayout-4.0
	dev-java/wstx:3.2
"
DEPEND="${CDEPEND}
	app-arch/unzip
	>=virtual/jdk-1.5
"
RDEPEND="${CDEPEND}
	>=virtual/jre-1.5
"

S=${WORKDIR}/${PN}

PATCHES=( "${FILESDIR}"/${P}-gentoo.patch )

java_prepare() {
	cd jars || die
	rm jsr173_1.0_api.jar \
		wstx-lgpl-4.0pr1.jar \
		commons-cli-1.1.jar \
		miglayout-4.0-swing.jar \
		cortado-0.6.0.jar \
		jogg-0.0.7.jar \
		jorbis-0.0.15.jar || die
}

src_prepare() {
	base_src_prepare
	java-pkg-2_src_prepare
}

src_configure() {
	java-ant-2_src_configure
}

src_compile() {
	EANT_BUILD_TARGET=package
	EANT_EXTRA_ARGS="
		-Dstax.jar=$(java-pkg_getjars jsr173)
		-Dwoodstox.jar=$(java-pkg_getjars wstx-3.2)
		-Dcli.jar=$(java-pkg_getjars commons-cli-1)
		-Dmiglayout.jar=$(java-pkg_getjars miglayout)
		-Dcortado.jar=$(java-pkg_getjars cortado)
	"
	java-pkg-2_src_compile
}

src_install() {
	java-pkg_jarinto /usr/share/${PN}/jars
	java-pkg_dojar jars/vorbisspi1.0.3.jar
	java-pkg_dojar jars/tritonus_share.jar
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

