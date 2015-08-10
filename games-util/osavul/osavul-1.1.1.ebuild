# Copyright 2014 Julian Ospald <hasufell@posteo.de>
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit eutils qt4-r2 toolchain-funcs vcs-snapshot

DESCRIPTION="Unvanquished server browser"
HOMEPAGE="https://github.com/Unvanquished/Osavul"
SRC_URI="https://github.com/Unvanquished/Osavul/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

COMMON_DEPEND="
	dev-qt/qtcore:4
	dev-qt/qtgui:4
	dev-qt/qtxmlpatterns:4"
RDEPEND="${COMMON_DEPEND}
	games-fps/unvanquished"
DEPEND="${COMMON_DEPEND}"

pkg_pretend() {
	if [[ ${MERGE_TYPE} != binary ]]; then
		if [[ $(gcc-major-version) == 4 && $(gcc-minor-version) -lt 6 || $(gcc-major-version) -lt 4 ]] ; then
			eerror "You need at least sys-devel/gcc-4.6.0"
			die "You need at least sys-devel/gcc-4.6.0"
		fi
	fi
}

src_configure() {
	qt4-r2_src_configure
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

