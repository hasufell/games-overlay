# Copyright 2015 Julian Ospald <hasufell@posteo.de>
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI="5"

CDROM_OPTIONAL="yes"
inherit cdrom check-reqs

GOG_FILE="setup_jagged_alliance2_2.0.0.12.exe"
DESCRIPTION="A port of Jagged Alliance 2 to SDL (data files)"
HOMEPAGE="http://tron.homeunix.org/ja2/"
SRC_URI="gog? ( ${GOG_FILE} )"

LICENSE="SIR-TECH gog? ( GOG-EULA )"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="gog"
REQUIRED_USE="^^ ( cdinstall gog )"
RESTRICT="mirror bindist gog? ( fetch )"

RDEPEND="
	cdinstall? ( games-strategy/ja2-stracciatella )
	gog? ( games-strategy/ja2-stracciatella[linguas_en] )
"
DEPEND="
	cdinstall? ( app-arch/unshield )
	gog? ( app-arch/innoextract )
"

S=${WORKDIR}

CHECKREQS_DISK_BUILD="3G"
CHECKREQS_DISK_USR="1G"

pkg_nofetch() {
	einfo "Please download ${GOG_FILE} from your GOG.com account"
	einfo "and put it into ${DISTDIR}."
}

src_unpack() {
	if use cdinstall ; then
		export CDROM_NAME="INSTALL_CD"

		cdrom_get_cds INSTALL/data1.cab

		# this makes some serious overhead
		unshield x "${CDROM_ROOT}"/INSTALL/data1.cab || die "unpacking failed"
	elif use gog ; then
		innoextract --lowercase \
			"${DISTDIR}"/${A} || die
	fi
}

src_prepare() {
	if use cdinstall ; then
		cd "${S}"/Ja2_Files/Data || die
		local lower i

		# convert to lowercase
		find . \( -iname "*.jsd" -o -iname "*.wav" -o -iname "*.sti" -o -iname "*.slf" \) \
			-exec sh -c 'echo "${1}"
		lower="`echo "${1}" | tr [:upper:] [:lower:]`"
		[ -d `dirname "${lower}"` ] || mkdir `dirname ${lower}`
		[ "${1}" = "${lower}" ] || mv "${1}" "${lower}"' - {} \;

		# remove possible leftover
		rm -r ./TILECACHE ./STSOUNDS
	fi
}

src_install() {
	insinto /usr/share/ja2/data

	if use cdinstall ; then
		doins -r "${S}"/Ja2_Files/Data/*
	elif use gog ; then
		doins -r "${S}"/app/data/*
	fi
}

