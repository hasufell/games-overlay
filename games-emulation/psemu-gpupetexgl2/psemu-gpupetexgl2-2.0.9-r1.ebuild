# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit multilib

DESCRIPTION="PSEmu XGL2 GPU"
HOMEPAGE="http://www.pbernert.com/"
SRC_URI="http://www.pbernert.com/gpupetexgl${PV//.}.tar.gz
	http://www.pbernert.com/petegpucfg_V2-9_V1-77_V1-18.tar.gz
	http://www.pbernert.com/pete_ogl2_shader_scale2x.zip
	http://www.pbernert.com/pete_ogl2_shader_simpleblur.zip"

LICENSE="freedist"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""
RESTRICT="strip"

DEPEND="app-arch/unzip"
RDEPEND="virtual/opengl
	x11-libs/gtk+:1[abi_x86_32(-)]"

S="${WORKDIR}"

src_install() {
	exeinto /usr/$(get_libdir)/psemu/plugins
	doexe lib* || die "doexe failed"
	exeinto /usr/$(get_libdir)/psemu/cfg
	doexe cfg/cfgPeteXGL2 || die "doexe failed"
	insinto /usr/$(get_libdir)/psemu/cfg
	doins gpuPeteXGL2.cfg || die "doins failed"
	# now do our shader files!
	insinto /usr/$(get_libdir)/psemu/shaders
	doins *.fp *.vp *.slf *.slv || die "doins failed"
	dodoc *.txt
}

