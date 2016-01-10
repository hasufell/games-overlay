# Copyright 2015 Julian Ospald <hasufell@posteo.de>
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit eutils

DESCRIPTION="A port of Jagged Alliance 2 to SDL"
HOMEPAGE="http://tron.homeunix.org/ja2/"
SRC_URI="http://dev.gentoo.org/~hasufell/distfiles/${P}.tar.xz
	http://tron.homeunix.org/ja2/editor.slf.gz"

LICENSE="SFI-SCLA"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="editor zlib"

RDEPEND="media-libs/libsdl[X,sound,video]
	zlib? ( sys-libs/zlib )"
DEPEND="${RDEPEND}"

LANGS="linguas_de +linguas_en linguas_fr linguas_it linguas_nl linguas_pl linguas_ru linguas_ru_gold"
IUSE="$IUSE $LANGS"
REQUIRED_USE="^^ ( ${LANGS//+/} )"

src_prepare() {
	epatch "${FILESDIR}"/${P}-makefile.patch

	sed \
		-e "s:/some/place/where/the/data/is:/usr/share/ja2:" \
		-i sgp/FileMan.cc || die

	sed \
		-e "s:@GAMES_DATADIR@:/usr/share/ja2/data:" \
		"${FILESDIR}"/ja2-convert.sh > "${T}"/ja2-convert || die
}

src_compile() {
	local myconf

	case ${LINGUAS} in
		de) myconf="LNG=GERMAN" ;;
		nl) myconf="LNG=DUTCH" ;;
		fr) myconf="LNG=FRENCH" ;;
		it) myconf="LNG=ITALIAN" ;;
		pl) myconf="LNG=POLISH" ;;
		ru) myconf="LNG=RUSSIAN" ;;
		ru_gold) myconf="LNG=RUSSIAN_GOLD" ;;
		en) myconf="LNG=ENGLISH" ;;
		*) die "wat" ;;
	esac
	elog "Chosen language is ${myconf#LNG=}"

	use editor && myconf+=" JA2EDITOR=yes JA2BETAVERSION=yes"
	use zlib && myconf+=" WITH_ZLIB=yes"

	emake ${myconf}
}

src_install() {
	dobin ja2 "${T}"/ja2-convert

	if use editor; then
		insinto /usr/share/ja2/data
		doins "${WORKDIR}"/editor.slf
	fi

	make_desktop_entry ja2 ${PN}
	doman ja2.6
}

pkg_postinst() {
	elog "You need ja2 in the chosen language, otherwise set it in package.use!"
	elog
	elog "You need to copy all files from the Data directory of"
	elog "Jagged Alliance 2 installation to"
	elog "/usr/share/ja2/data "
	elog "Make sure the filenames are lowercase. You may want to run the"
	elog "script":
	elog "/usr/bin/ja2-convert"
	elog "Alternatively, install games-strategy/ja2-stracciatella-data."
}

