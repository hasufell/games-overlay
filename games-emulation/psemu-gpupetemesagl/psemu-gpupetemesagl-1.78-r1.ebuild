# Copyright 2014 Julian Ospald <hasufell@posteo.de>
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit multilib

DESCRIPTION="PSEmu MesaGL GPU"
HOMEPAGE="http://www.pbernert.com/"
SRC_URI="http://www.pbernert.com/gpupeopsmesagl${PV//./}.tar.gz"
LICENSE="freedist"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""
RESTRICT="strip"

RDEPEND="virtual/opengl
	x11-libs/gtk+:1[abi_x86_32(-)]"

S="${WORKDIR}"/peops_psx_mesagl_gpu

src_install() {
	exeinto /usr/$(get_libdir)/psemu/plugins
	doexe lib* || die "doexe failed"
	exeinto /usr/$(get_libdir)/psemu/cfg
	doexe cfgPeopsMesaGL || die "doexe failed"
	insinto /usr/$(get_libdir)/psemu/cfg
	doins gpuPeopsMesaGL.cfg || die "doins failed"
	dodoc readme.txt version.txt
}

