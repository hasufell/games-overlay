# Copyright 2014-2016 Julian Ospald <hasufell@posteo.de>
# Distributed under the terms of the GNU General Public License v2

EAPI=5

PYTHON_COMPAT=( python2_7 )
inherit cmake-utils eutils gnome2-utils python-any-r1 fdo-mime

MY_P=${PN}-release-${PV}-src

DESCRIPTION="A free multiplayer action game where you control clonks"
HOMEPAGE="http://openclonk.org/"
SRC_URI="http://www.openclonk.org/builds/release/${PV}/openclonk-${PV}-src.tar.bz2
	http://${PN}.org/homepage/icon.png -> ${PN}.png"

LICENSE="BSD ISC CLONK-trademark LGPL-2.1 POSTGRESQL"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="dedicated doc"

RDEPEND="
	dev-libs/glib:2
	dev-libs/tinyxml
	media-libs/libpng:0
	net-libs/libupnp
	sys-libs/readline:0
	sys-libs/zlib
	!dedicated? (
		media-libs/freealut
		media-libs/freetype:2
		media-libs/glew
		media-libs/libvorbis
		media-libs/openal
		virtual/jpeg:0
		virtual/opengl
		virtual/glu
		x11-libs/gdk-pixbuf
		x11-libs/gtk+:3
		x11-libs/libXrandr
		x11-libs/libX11
	)"
DEPEND="${RDEPEND}
	virtual/pkgconfig
	doc? (
		${PYTHON_DEPS}
		dev-libs/libxml2[python]
		sys-devel/gettext
	)"

PATCHES=(
	"${FILESDIR}"/${PN}-7.0-install.patch
)
S=${WORKDIR}/${P}-src

pkg_setup() {
	use doc && python-any-r1_pkg_setup
}

src_prepare() {
	rm -r thirdparty/tinyxml || die
	cmake-utils_src_prepare
}

src_configure() {
	local mycmakeargs=(
		-DWITH_AUTOMATIC_UPDATE=OFF
	)

	cmake-utils_src_configure
}

src_compile() {
	cmake-utils_src_compile $(usex dedicated "openclonk-server" "all") data

	if use doc ; then
		emake -C docs
	fi
}

src_install() {
	if use dedicated; then
		cd "${BUILD_DIR}" || die
		dobin openclonk-server
		insinto /usr/share/openclonk/
		doins \
			Graphics.ocg \
			Material.ocg \
			Music.ocg \
			Sound.ocg \
			System.ocg \
			Objects.ocd \
			Decoration.ocd \
			Arena.ocf \
			Parkour.ocf \
			Defense.ocf \
			Missions.ocf \
			Tutorials.ocf \
			Worlds.ocf
		cd "${S}" || die
	else
		cmake-utils_src_install
		mv "${ED%/}/usr/bin/openclonk" "${ED%/}/usr/bin/clonk" || die
		newbin "${FILESDIR}"/${PN}-wrapper-script.sh ${PN}
		doicon -s 64 "${DISTDIR}"/${PN}.png
		make_desktop_entry ${PN}
	fi
	use doc && dohtml -r docs/online/*
}

pkg_preinst() {
	gnome2_icon_savelist
}

pkg_postinst() {
	gnome2_icon_cache_update
	fdo-mime_desktop_database_update
}

pkg_postrm() {
	gnome2_icon_cache_update
	fdo-mime_desktop_database_update
}
