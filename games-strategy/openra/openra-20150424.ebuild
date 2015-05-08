# Copyright 2014 Julian Ospald <hasufell@posteo.de>
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit eutils mono-env gnome2-utils fdo-mime vcs-snapshot

DESCRIPTION="A free RTS engine supporting games like Command & Conquer and Red Alert"
HOMEPAGE="http://open-ra.org/"
SRC_URI="https://dev.gentoo.org/~hasufell/distfiles/${P}.tar.xz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="tools"

LUA_V=5.1.5
DEPEND="dev-dotnet/libgdiplus
	~dev-lang/lua-${LUA_V}:0
	dev-lang/mono
	media-libs/freetype:2
	media-libs/libsdl2[opengl,video]
	media-libs/openal
	virtual/jpeg
	virtual/opengl"
RDEPEND="${DEPEND}"

src_unpack() {
	vcs-snapshot_src_unpack
}

src_configure() { :; }

src_prepare() {
	# register game-version
	sed \
		-e "/Version/s/{DEV_VERSION}/release-${PV}/" \
		-i mods/{ra,cnc,d2k}/mod.yaml || die
	sed \
		-e "s/@LIBLUA51@/liblua.so.${LUA_V}/" \
		thirdparty/Eluant.dll.config.in > Eluant.dll.config || die
}

src_compile() {
	emake $(usex tools "all" "")
	emake docs
}

src_install() {
	emake \
		datadir="/usr/share" \
		bindir="/usr/bin" \
		libdir="/usr/libexec" \
		DESTDIR="${D}" \
		$(usex tools "install-all" "install") install-linux-scripts install-linux-mime

	exeinto /usr/libexec/openra
	doexe Eluant.dll.config

	# icons
	insinto /usr/share/icons/
	doins -r packaging/linux/hicolor

	# desktop entries
	make_desktop_entry "${PN} Game.Mods=cnc" "OpenRA CNC" ${PN}
	make_desktop_entry "${PN} Game.Mods=ra" "OpenRA RA" ${PN}
	make_desktop_entry "${PN} Game.Mods=d2k" "OpenRA Dune2k" ${PN}
	make_desktop_entry "${PN}-editor" "OpenRA Map Editor" ${PN}

	dodoc "${FILESDIR}"/README.gentoo README.md CONTRIBUTING.md AUTHORS \
		DOCUMENTATION.md Lua-API.md
}

pkg_postinst() {
	gnome2_icon_cache_update
	fdo-mime_desktop_database_update
	fdo-mime_mime_database_update

	elog "optional dependencies:"
	elog "  media-gfx/nvidia-cg-toolkit (fallback renderer if OpenGL fails)"
}

pkg_postrm() {
	gnome2_icon_cache_update
	fdo-mime_desktop_database_update
	fdo-mime_mime_database_update
}
