# Copyright 2014 Julian Ospald <hasufell@posteo.de>
# Distributed under the terms of the GNU General Public License v2
# $Id$

# do not use autotools related stuff in stable ebuilds
# unless you like random breakage: 469796, 469798, 424041

EAPI=5
inherit eutils gnome2-utils # STABLE ARCH
#inherit autotools eutils gnome2-utils # UNSTABLE ARCH

DESCRIPTION="Updated clone of Westood Studios' Dune2"
HOMEPAGE="http://dunelegacy.sourceforge.net"
SRC_URI="mirror://sourceforge/${PN}/${P}-src.tar.bz2"
SRC_URI="${SRC_URI} http://dev.gentoo.org/~hasufell/distfiles/${P}-no-autoreconf.patch.xz" # STABLE ARCH

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="+alsa pulseaudio"

RDEPEND="media-libs/libsdl[X,alsa?,sound,pulseaudio?,video]
	media-libs/sdl-mixer[midi,mp3,vorbis]"
DEPEND="${RDEPEND}
	virtual/pkgconfig"

# exits on start without libsdl[alsa] or libsdl[pulseaudio]
REQUIRED_USE="|| ( alsa pulseaudio )"

src_prepare() {
	epatch "${DISTDIR}"/${P}-no-autoreconf.patch.xz # STABLE ARCH
#	epatch "${FILESDIR}"/${P}-build.patch # UNSTABLE ARCH
#	eautoreconf # UNSTABLE ARCH
}

src_install() {
	default

	doicon -s scalable ${PN}.svg
	doicon -s 48 ${PN}.png
	make_desktop_entry ${PN} "Dune Legacy"
}

pkg_preinst() {
	gnome2_icon_savelist
}

pkg_postinst() {
	gnome2_icon_cache_update

	elog "You will need to copy all Dune 2 PAK files to one of these"
	elog "directories:"
	elog "  /usr/share/${PN}"
	elog "  ~/.config/${PN}/data"
	elog
	elog "At least the following files are needed:"
	elog " - ATRE.PAK"
	elog " - DUNE.PAK"
	elog " - ENGLISH.PAK"
	elog " - FINALE.PAK"
	elog " - HARK.PAK"
	elog " - INTRO.PAK"
	elog " - INTROVOC.PAK"
	elog " - MENTAT.PAK"
	elog " - MERC.PAK"
	elog " - ORDOS.PAK"
	elog " - SCENARIO.PAK"
	elog " - SOUND.PAK"
	elog " - VOC.PAK"
	elog
	elog "For playing in german or french you need additionally"
	elog "GERMAN.PAK or FRENCH.PAK."
}

pkg_postrm() {
	gnome2_icon_cache_update
}

