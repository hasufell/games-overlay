# Copyright 2014 Julian Ospald <hasufell@posteo.de>
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5
inherit cmake-utils git-r3 gnome2-utils user

DESCRIPTION="An InfiniMiner/Minecraft inspired game"
HOMEPAGE="http://minetest.net/"
EGIT_REPO_URI="git://github.com/minetest/${PN}.git"

LICENSE="LGPL-2.1+ CC-BY-SA-3.0"
SLOT="0"
KEYWORDS=""
IUSE="+curl dedicated doc leveldb luajit nls redis +server +sound spatial +truetype"

RDEPEND="dev-db/sqlite:3
	sys-libs/zlib
	curl? ( net-misc/curl )
	!dedicated? (
		app-arch/bzip2
		>=dev-games/irrlicht-1.8-r2
		dev-libs/gmp:0
		media-libs/libpng:0
		virtual/jpeg
		virtual/opengl
		x11-libs/libX11
		x11-libs/libXxf86vm
		sound? (
			media-libs/libogg
			media-libs/libvorbis
			media-libs/openal
		)
		truetype? ( media-libs/freetype:2 )
	)
	leveldb? ( dev-libs/leveldb )
	luajit? ( dev-lang/luajit:2 )
	nls? ( virtual/libintl )
	redis? ( dev-libs/hiredis )
	spatial? ( sci-libs/libspatialindex )"
DEPEND="${RDEPEND}
	>=dev-games/irrlicht-1.8-r2
	doc? ( app-doc/doxygen media-gfx/graphviz )
	nls? ( sys-devel/gettext )"

pkg_setup() {
	if use server || use dedicated ; then
		enewgroup ${PN}
		enewuser ${PN} -1 -1 /var/lib/${PN} ${PN}
	fi
}

src_prepare() {
	# correct gettext behavior
	if [[ -n "${LINGUAS+x}" ]] ; then
		for i in $(cd po ; echo *) ; do
			if ! has ${i} ${LINGUAS} ; then
				rm -r po/${i} || die
			fi
		done
	fi

	# jthread is modified
	# json is modified

	# set paths
	sed \
		-e "s#@BINDIR@#/usr/bin#g" \
		-e "s#@GROUP@#${PN}#g" \
		"${FILESDIR}"/minetestserver.confd > "${T}"/minetestserver.confd || die
}

src_configure() {
	local mycmakeargs=(
		$(usex dedicated "-DBUILD_SERVER=ON -DBUILD_CLIENT=OFF" "$(cmake-utils_use_build server SERVER) -DBUILD_CLIENT=ON")
		-DCUSTOM_BINDIR="/usr/bin"
		-DCUSTOM_DOCDIR="/usr/share/doc/${PF}"
		-DCUSTOM_LOCALEDIR="/usr/share/locale"
		-DCUSTOM_SHAREDIR="/usr/share/${PN}"
		$(cmake-utils_use_enable curl CURL)
		$(cmake-utils_use_enable truetype FREETYPE)
		$(cmake-utils_use_enable nls GETTEXT)
		-DENABLE_GLES=0
		$(cmake-utils_use_enable leveldb LEVELDB)
		$(cmake-utils_use_enable redis REDIS)
		-DENABLE_SPATIAL=$(usex spatial)
		$(cmake-utils_use_enable sound SOUND)
		$(cmake-utils_use !luajit DISABLE_LUAJIT)
		-DRUN_IN_PLACE=0
		$(use dedicated && {
			echo "-DIRRLICHT_SOURCE_DIR=/the/irrlicht/source"
			echo "-DIRRLICHT_INCLUDE_DIR=/usr/include/irrlicht"
		})
	)

	cmake-utils_src_configure
}

src_compile() {
	cmake-utils_src_compile

	if use doc ; then
		cmake-utils_src_compile doc
	fi
}

src_install() {
	cmake-utils_src_install

	if use server || use dedicated ; then
		newinitd "${FILESDIR}"/minetestserver.initd minetest-server
		newconfd "${T}"/minetestserver.confd minetest-server
	fi

	if use doc ; then
		cd "${CMAKE_BUILD_DIR}"/doc || die
		dodoc -r html
	fi
}

pkg_preinst() {
	gnome2_icon_savelist
}

pkg_postinst() {
	gnome2_icon_cache_update

	if ! use dedicated ; then
		elog
		elog "optional dependencies:"
		elog "	games-action/minetest_game (official mod)"
		elog
	fi

	if use server || use dedicated ; then
		elog
		elog "Configure your server via /etc/conf.d/minetest-server"
		elog "The user \"minetest\" is created with /var/lib/${PN} homedir."
		elog "Default logfile is ~/minetest-server.log"
		elog
	fi
}

pkg_postrm() {
	gnome2_icon_cache_update
}
