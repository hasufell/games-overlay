# Copyright 2014 Julian Ospald <hasufell@posteo.de>
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit cmake-utils eutils

MY_PN=opensnc
MY_P=${MY_PN}-src-${PV}

DESCRIPTION="A free open-source game based on the Sonic the Hedgehog universe"
HOMEPAGE="http://opensnc.sourceforge.net/"
SRC_URI="mirror://sourceforge/opensnc/Open%20Sonic/${PV}/${MY_P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND="media-libs/allegro:0[X,jpeg,png,vorbis]
	media-libs/libogg
	media-libs/libpng:0
	media-libs/libvorbis
	sys-libs/zlib
	virtual/jpeg"
DEPEND="${RDEPEND}"

S=${WORKDIR}/${MY_P}

src_prepare() {
	epatch "${FILESDIR}"/${PF}-cmake.patch
}

src_configure() {
	local mycmakeargs=(
		-DGAME_INSTALL_DIR=/usr/share/${PN}
		-DGAME_FINAL_DIR="/usr/bin"
		-DGAME_LIBDIR="/usr/libexec/${PN}"
	)

	cmake-utils_src_configure
}

src_compile() {
	cmake-utils_src_compile
}

src_install() {
	cmake-utils_src_install
	for i in "${D}"/usr/share/${PN}/* ; do
		dosym "${i#${D}}" "/usr/libexec/${PN}/${i#${D}/usr/share/${PN}/}"
	done
}

