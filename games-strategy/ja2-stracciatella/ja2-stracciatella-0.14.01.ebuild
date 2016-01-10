# Copyright 2015 Julian Ospald <hasufell@posteo.de>
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit eutils vcs-snapshot

DESCRIPTION="A port of Jagged Alliance 2 to SDL"
HOMEPAGE="https://bitbucket.org/gennady/ja2-stracciatella http://tron.homeunix.org/ja2/"
SRC_URI="https://bitbucket.org/gennady/ja2-stracciatella/get/v${PV}.tar.gz -> ${P}.tar.gz
	editor? ( http://tron.homeunix.org/ja2/editor.slf.gz )"

LICENSE="SFI-SCLA"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="editor"

RDEPEND="media-libs/libsdl[X,sound,video]"
DEPEND="${RDEPEND}"

src_prepare() {
	epatch "${FILESDIR}"/${P}-makefile.patch

	sed \
		-e "s:@GAMES_DATADIR@:/usr/share/ja2/data:" \
		"${FILESDIR}"/ja2-convert.sh > "${T}"/ja2-convert || die
}

src_configure() {
	./configure --prefix=/usr
}

src_compile() {
	local myconf=""

	emake Q="" ${myconf}
}

src_install() {
	emake \
		BINARY_DIR="${ED%/}/usr/bin" \
		MANPAGE_DIR="${ED%/}/usr/share/man/man6" \
		FULL_PATH_EXTRA_DATA_DIR="${ED%/}/usr/share/ja2" \
		install

	if use editor; then
		insinto /usr/share/ja2/data
		doins "${WORKDIR}"/editor.slf
	fi

	make_desktop_entry ja2 ${PN}
}

pkg_postinst() {
	elog "You need to copy all files from the Data directory of"
	elog "Jagged Alliance 2 installation to"
	elog "/usr/share/ja2/data "
	elog "Make sure the filenames are lowercase. You may want to run the"
	elog "script"
	elog "/usr/bin/ja2-convert"
	elog "Alternatively, install games-strategy/ja2-stracciatella-data."
}

