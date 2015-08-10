# Copyright 2014 Julian Ospald <hasufell@posteo.de>
# Distributed under the terms of the GNU General Public License v2
# $Id$

# TODO/FIXME:
# lunatic broken
# lunatic? ( >=dev-lang/luajit-2.0.0_beta10:2 )
# $(usex lunatic "LUNATIC=1" "LUNATIC=0")
#
# extras? ( games-fps/${PN}-extras )
#
# clang does not build

EAPI=5

inherit eutils gnome2-utils subversion

MY_PV=${PV%.*}
MY_BUILD=${PV#*.}

# extensions
MY_HRP=5.2
MY_SC55=3.0
MY_OPL=2.0
MY_XXX=1.33

DESCRIPTION="Port of Duke Nukem 3D for SDL"
HOMEPAGE="http://www.eduke32.com/ http://hrp.duke4.net/"
SRC_URI="http://dev.gentoo.org/~hasufell/distfiles/eduke32-icons.tar
	textures? (	http://www.duke4.org/files/nightfright/duke3d_hrp.zip -> duke3d_hrp_${MY_HRP}.zip )
	sc55-musicpack? ( http://www.duke4.org/files/nightfright/music/duke3d_mus.zip -> duke3d_mus_${MY_SC55}.zip )
	opl-musicpack? ( http://www.duke4.org/files/nightfright/music/duke3d_musopl.zip -> duke3d_musopl_${MY_OPL}.zip )
	offensive? ( http://www.duke4.org/files/nightfright/duke3d_xxx.zip -> duke3d_xxx_${MY_XXX}.zip )"
ESVN_REPO_URI="http://svn.eduke32.com/eduke32/polymer/eduke32"

LICENSE="GPL-2 BUILDLIC textures? ( hrp_art )"
SLOT="0"
KEYWORDS=""
IUSE="debug gtk offensive +opengl opl-musicpack +png samples sc55-musicpack +server textures tools +vpx"
REQUIRED_USE="vpx? ( opengl )
	textures? ( opengl )
	offensive? ( textures )
	?? ( opl-musicpack sc55-musicpack )"

RDEPEND="media-libs/flac
	media-libs/libogg
	media-libs/libsdl[X,joystick,opengl?,video]
	media-libs/libvorbis
	media-libs/sdl-mixer[timidity]
	sys-libs/zlib
	gtk? ( x11-libs/gtk+:2 )
	opengl? (
		virtual/glu
		virtual/opengl
		vpx? ( media-libs/libvpx )
	)
	png? ( media-libs/libpng:0=
		sys-libs/zlib )
	"
DEPEND="${RDEPEND}
	app-arch/unzip
	x86? ( dev-lang/nasm )"

src_unpack() {
	unpack eduke32-icons.tar
	subversion_src_unpack

	if use textures; then
		unzip -q "${DISTDIR}"/duke3d_hrp_${MY_HRP}.zip "hrp_readme.txt" \
			|| die "unzip hrp readme"
		if use offensive; then
			unzip -q "${DISTDIR}"/duke3d_xxx_${MY_XXX}.zip "xxx_readme.txt" \
				|| die "unzip xxx readme"
		fi
	fi
	if use opl-musicpack; then
		unzip -q "${DISTDIR}"/duke3d_musopl_${MY_OPL}.zip "readme.txt" \
			|| die "unzip musopl readme"
		mv readme.txt musopl_readme.txt || die "mv musopl_readme"
	elif use sc55-musicpack; then
		unzip -q "${DISTDIR}"/duke3d_mus_${MY_SC55}.zip "music_readme.txt" \
			|| die "unzip mus readme"
	fi
}

src_prepare() {
	subversion_src_prepare

	sed -i \
		-e "s;/usr/local/share/games/${PN};/usr/share/duke3d;" \
		source/common.c || die "sed common.c path update failed"
	sed -i \
		-e "/OSD_SetLogFile/s;mapster32.log;~/.mapster32.log;" \
		source/astub.c || die "sed astub.c path update failed"
	sed -i \
		-e "/OSD_SetLogFile/s;${PN}.log;~/.${PN}.log;" \
		source/game.c || die "sed game.c path update failed"
}

src_compile() {
	local MY_OPTS=(
		AS=$(type -P nasm)
		ARCH=
		SYSARCH=
		LTO=0
		PRETTY_OUTPUT=0
		RELEASE=1
		LUNATIC=0
		STRIP=touch
		LINKED_GTK=1
		CPLUSPLUS=0
		SDL_TARGET=1
		F_JUMP_TABLES=""
		$(usex gtk "WITHOUT_GTK=0" "WITHOUT_GTK=1")
		$(usex debug "DEBUGANYWAY=1" "DEBUGANYWAY=0")
		$(usex x86 "NOASM=0" "NOASM=1")
		$(usex server "NETCODE=1" "NETCODE=0")
		$(usex opengl "USE_OPENGL=1 POLYMER=1" "USE_OPENGL=0 POLYMER=0")
		$(usex png "USE_LIBPNG=1" "USE_LIBPNG=0")
		$(usex opengl "$(usex vpx "USE_LIBVPX=1" "USE_LIBVPX=0")" "USE_LIBVPX=0")
	)

	emake ${MY_OPTS[@]}

	if use tools; then
		emake -C build ${MY_OPTS[@]}
	fi
}

src_install() {
	local ARGS

	newbin ${PN} ${PN}.bin
	dobin mapster32

	if use tools; then
		dobin build/{arttool,bsuite,cacheinfo,generateicon,givedepth,kextract,kgroup,kmd2tool,md2tool,mkpalette,transpal,unpackssi,wad2art,wad2map}
		dodoc build/doc/*.txt
	fi

	insinto "/usr/share/${PN}"
	# Install optional components
	if use textures; then
		newins "${DISTDIR}"/duke3d_hrp_${MY_HRP}.zip duke3d_hrp.zip
		dodoc "${WORKDIR}"/hrp_readme.txt
		ARGS+=" -g duke3d_hrp.zip"

		if use offensive; then
			newins "${DISTDIR}"/duke3d_xxx_${MY_XXX}.zip duke3d_xxx.zip
			dodoc "${WORKDIR}"/xxx_readme.txt
			ARGS+=" -g duke3d_xxx.zip"
		fi
	fi

	if use opl-musicpack; then
		newins "${DISTDIR}"/duke3d_musopl_${MY_OPL}.zip duke3d_musopl.zip
		dodoc "${WORKDIR}"/musopl_readme.txt
		ARGS+=" -g duke3d_musopl.zip"
	elif use sc55-musicpack; then
		newins "${DISTDIR}"/duke3d_mus_${MY_SC55}.zip duke3d_mus.zip
		dodoc "${WORKDIR}"/music_readme.txt
		ARGS+=" -g duke3d_mus.zip"
	fi

	# Install game data
	doins package/sdk/{SEHELP.HLP,STHELP.HLP,m32help.hlp,names.h,tiles.cfg}
	use samples && doins -r package/samples

	local i
	for i in 16 32 128 256 ; do
		newicon -s ${i} "${WORKDIR}"/${PN}_${i}x${i}x32.png ${PN}.png
		newicon -s ${i} "${WORKDIR}"/mapster32_${i}x${i}x32.png mapster32.png
	done

	make_wrapper "${PN}" "/usr/bin/${PN}.bin ${ARGS}"
	make_desktop_entry ${PN} EDuke32 ${PN}
	make_desktop_entry mapster32 Mapster32 mapster32

	dodoc build/buildlic.txt

	keepdir "/var/log/eduke32"
}

pkg_preinst() {
	subversion_pkg_preinst
	gnome2_icon_savelist
}

pkg_postinst() {
	gnome2_icon_cache_update

	einfo
	elog "${PN} reads data files from /usr/share/duke3d"
	elog "make sure the game files are there (either copied or linked)."
	einfo
	elog "Logs are written to ~/.eduke32.log and ~/.mapster32.log"
}

pkg_postrm() {
	gnome2_icon_cache_update
}
