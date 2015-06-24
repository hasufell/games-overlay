# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit multilib

DESCRIPTION="P.E.Op.S Software GPU plugin"
HOMEPAGE="http://sourceforge.net/projects/peops/"
SRC_URI="mirror://sourceforge/peops/PeopsSoftGpu${PV//./}.zip"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND=""
RDEPEND="x11-libs/gtk+:1[abi_x86_32(-)]"

S="${WORKDIR}"/gpuPeopsSoft

src_install() {
	dodoc *.txt
	insinto /usr/$(get_libdir)/psemu/cfg
	doins gpuPeopsSoftX.cfg || die "doins failed"
	exeinto /usr/$(get_libdir)/psemu/plugins
	doexe libgpuPeops* || die "doexe failed"
	exeinto /usr/$(get_libdir)/psemu/cfg
	doexe cfgPeopsSoft || die "doexe failed"
}

