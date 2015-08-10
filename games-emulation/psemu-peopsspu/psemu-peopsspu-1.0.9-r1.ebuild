# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit eutils multilib toolchain-funcs

DESCRIPTION="P.E.Op.S Sound Emulation (SPU) PSEmu Plugin"
HOMEPAGE="http://sourceforge.net/projects/peops/"
SRC_URI="mirror://sourceforge/peops/PeopsSpu${PV//./}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="alsa oss"
REQUIRED_USE="|| ( alsa oss )"

DEPEND="alsa? ( media-libs/alsa-lib[abi_x86_32(-)] )
	x11-libs/gtk+:1[abi_x86_32(-)]"
RDEPEND="${DEPEND}"

QA_PREBUILT="${GAMES_PREFIX}/lib32/psemu/cfg/cfgPeopsOSS
	${GAMES_PREFIX}/lib64/psemu/cfg/cfgPeopsOSS"

S="${WORKDIR}"/src

src_compile() {
	tc-export CC
	epatch "${FILESDIR}"/makefile.patch

	if use amd64 ; then
		sed -i -e "s:-L/usr/lib:-L/usr/lib32:" Makefile
	fi

	if use oss ; then
		emake USEALSA=FALSE || die "oss build failed"
	fi
	if use alsa ; then
		# clean doesn't remove oss-build
		emake clean || die
		emake USEALSA=TRUE || die "alsa build failed"
	fi
}

src_install() {
	# install plugins
	exeinto /usr/$(get_libdir)/psemu/plugins
	if use alsa ; then
		doexe libspuPeopsALSA* || die
	fi
	if use oss ; then
		doexe libspuPeopsOSS* || die
	fi

	# install precompiled gui config-utility
	# due to problematic build system
	exeinto /usr/$(get_libdir)/psemu/cfg
	doexe "${WORKDIR}"/cfgPeopsOSS

	# install cfg
	insinto /usr/$(get_libdir)/psemu/cfg
	doins "${WORKDIR}"/spuPeopsOSS.cfg || die

	dodoc "${WORKDIR}"/*.txt || die
}

