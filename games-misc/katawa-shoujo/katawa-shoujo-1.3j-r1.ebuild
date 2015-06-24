# Copyright 2015 Julian Ospald <hasufell@posteo.de>
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit eutils gnome2-utils

DESCRIPTION="Bishoujo-style visual novel set in the fictional Yamaku High School for disabled children"
HOMEPAGE="http://katawa-shoujo.com/"
SRC_URI="http://dl.katawa-shoujo.com/gold_1.2/%5b4ls%5d_katawa_shoujo_1.2-%5blinux-x86%5d%5b8F3BA490%5d.tar.bz2 -> ${P}.tar.bz2
	http://dev.gentoo.org/~hasufell/distfiles/katawa-shoujo-48.png
	http://dev.gentoo.org/~hasufell/distfiles/katawa-shoujo-256.png"

LICENSE="CC-BY-NC-ND-3.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="doc system-renpy"

DEPEND="!system-renpy? ( dev-util/patchelf )"

# make system-renpy optional due to #459742 :(
RDEPEND="system-renpy? ( games-engines/renpy )
	!system-renpy? (
		(
			>=sys-libs/zlib-1.2.8-r1[abi_x86_32(-)]
		)
	)" #495270

QA_PREBUILT="/opt/${PN}/lib/*"

S="${WORKDIR}/Katawa Shoujo-linux-x86"

src_prepare() {
	if use !system-renpy ; then
		# Set RPATH for preserve-libs handling (bug #528086).
		local x
		while read -r x ; do
			# Use \x7fELF header to separate ELF executables and libraries
			[[ $(od -t x1 -N 4 "${x}") == *"7f 45 4c 46"* ]] || continue
			patchelf --set-rpath \
				"${EPREFIX}/opt/${PN}/lib/linux-x86/lib" \
				"${x}" || die "patchelf failed on ${x}"
		done < <(find . -type f)
	fi
}

src_install() {
	if use system-renpy ; then
		insinto /usr/share/${PN}
		doins -r game/.
		make_wrapper ${PN} "renpy '/usr/share/${PN}'"
	else
		insinto /opt/${PN}
		rm "lib/linux-x86/lib/python2.5/pygame/mixer.so" || die # bug #528086
		doins -r common game lib renpy "Katawa Shoujo.py" "Katawa Shoujo.sh"
		make_wrapper ${PN} "./Katawa\ Shoujo.sh" "/opt/${PN}"
		fperms +x "/opt/${PN}"/lib/{python,linux-x86/python.real} \
			"/opt/${PN}/Katawa Shoujo.sh" \
			"/opt/${PN}/Katawa Shoujo.py"
	fi

	local i
	for i in 48 256; do
		newicon -s ${i} "${DISTDIR}"/${PN}-${i}.png ${PN}.png
	done

	make_desktop_entry ${PN} "Katawa Shoujo"

	if use doc ; then
		newdoc "Game Manual.pdf" manual.pdf
	fi
}

pkg_preinst() {
	gnome2_icon_savelist
}

pkg_postinst() {
	elog "Savegames from system-renpy and the bundled version are incompatible"

	if use system-renpy; then
		ewarn "system-renpy is unstable and not supported upstream"
	fi

	gnome2_icon_cache_update
}

pkg_postrm() {
	gnome2_icon_cache_update
}
