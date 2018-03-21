# Copyright 2017 Julian Ospald <hasufell@posteo.de>
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

inherit flag-o-matic qmake-utils

DESCRIPTION="Unvanquished server browser"
HOMEPAGE="https://github.com/Unvanquished/Osavul"
SRC_URI="https://github.com/Unvanquished/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"

S="${WORKDIR}/${P//os/Os}"

CDEPEND="dev-qt/qtcore:4
	dev-qt/qtgui:4
	dev-qt/qtxmlpatterns:4"
RDEPEND="${CDEPEND}
	games-fps/unvanquished"
DEPEND="${CDEPEND}"

PATCHES=(
	"${FILESDIR}"/${PN}-stdcpp.patch
)

pkg_pretend() {
	if [[ ${MERGE_TYPE} != binary ]]; then
		if ! test-flag-CXX -std=c++0x; then
			die "You need at least GCC 4.7.x or Clang >= 3.0 for C++11-specific compiler flags"
		fi
	fi
}

src_configure() {
	eqmake4
}

src_install() {
	dobin ${PN}
	make_desktop_entry ${PN} ${PN} unvanquished

	# translations
	insinto /usr/share/qt4/translations
	for i in ${LANGS} ; do
		use linguas_${i} && doins ${PN}_${i}.qm
	done
}
