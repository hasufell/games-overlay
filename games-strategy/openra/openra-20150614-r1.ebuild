# Copyright 2015 Julian Ospald <hasufell@posteo.de>
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit eutils mono-env gnome2-utils fdo-mime vcs-snapshot

DESCRIPTION="A free RTS engine supporting games like Command & Conquer and Red Alert"
HOMEPAGE="http://www.openra.net/"
SRC_URI="https://github.com/OpenRA/OpenRA/archive/release-${PV}.tar.gz -> ${P}.tar.gz"

NG_SRC="https://nuget.org/api/v2/package"
# 3rd party deps
StyleCopPlus_MSBuild="${NG_SRC}/StyleCopPlus.MSBuild/4.7.49.5 -> StyleCopPlus_MSBuild-4.7.49.5.zip"
StyleCop_MSBuild="${NG_SRC}/StyleCop.MSBuild/4.7.49.0 -> StyleCop_MSBuild-4.7.49.0.zip"
SharpZipLib="${NG_SRC}/SharpZipLib/0.86.0 -> SharpZipLib-0.86.0.zip"
MaxMind_Db="${NG_SRC}/MaxMind.Db/1.0.0.0 -> MaxMind_Db-1.0.0.0.zip"
Newtonsoft_Json="${NG_SRC}/Newtonsoft.Json/6.0.5 -> Newtonsoft_Json-6.0.5.zip"
RestSharp="${NG_SRC}/RestSharp/105.0.1 -> RestSharp-105.0.1.zip"
MaxMind_GeoIP2="${NG_SRC}/MaxMind.GeoIP2/2.1.0 -> MaxMind_GeoIP2-2.1.0.zip"
SharpFont="${NG_SRC}/SharpFont/3.0.1 -> SharpFont-3.0.1.zip"
NUnit="${NG_SRC}/NUnit/2.6.4 -> NUnit-2.6.4.zip"
Mono_Nat="${NG_SRC}/Mono.Nat/1.2.21 -> Mono_Nat-1.2.21.zip"
FuzzyLogicLibrary="${NG_SRC}/FuzzyLogicLibrary/1.2.0 -> FuzzyLogicLibrary-1.2.0.zip"
SDL2CS="https://github.com/OpenRA/SDL2-CS/releases/download/20140407/SDL2-CS.dll -> SDL2-CS.dll.20140407"
Eluant="https://github.com/OpenRA/Eluant/releases/download/20140425/Eluant.dll -> Eluant.dll.20140425"
# unfortunately, this may randomly change
GEO_IP_DB="http://geolite.maxmind.com/download/geoip/database/GeoLite2-Country.mmdb.gz -> GeoLite2-Country-2015-10-18.mmdb.gz"

SRC_URI="${SRC_URI}
${StyleCopPlus_MSBuild}
${StyleCop_MSBuild}
${SharpZipLib}
${MaxMind_Db}
${Newtonsoft_Json}
${RestSharp}
${MaxMind_GeoIP2}
${SharpFont}
${NUnit}
${Mono_Nat}
${FuzzyLogicLibrary}
${SDL2CS}
${Eluant}
${GEO_IP_DB}
"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""
RESTRICT="mirror"

LUA_V=5.1.5
RDEPEND="dev-dotnet/libgdiplus
	~dev-lang/lua-${LUA_V}:0
	dev-lang/mono
	media-libs/freetype:2[X]
	media-libs/libsdl2[X,opengl,video]
	media-libs/openal
	virtual/jpeg:0
	virtual/opengl"
DEPEND="${RDEPEND}
	app-arch/unzip"

S=${WORKDIR}/OpenRA-release-${PV}

src_unpack() {
	unpack ${P}.tar.gz

	# this is pure crapshit, but it will successfully die
	# if upstream has added/changed files
	cd "${S}"/thirdparty || die
	sed -i \
		-e 's/^function get/function furz/' \
		-e 's|curl |: |' \
		fetch-thirdparty-deps.sh || die

	mkdir "${S}"/thirdparty/download || die
	get() {
		# don't add dies here
		local archive="${1/./_}"
		local version="${2}"
		mkdir -p "${S}"/thirdparty/download/${1}
		unzip -o -qq "${DISTDIR}"/${archive}-${version}.zip \
			-d "${S}"/thirdparty/download/${1}
	}
	export -f get
	./fetch-thirdparty-deps.sh || die
	unset get
	cd "${S}"/thirdparty/download || die
	cp "${DISTDIR}"/${SDL2CS##* } ./SDL2-CS.dll || die
	cp "${DISTDIR}"/${Eluant##* } ./Eluant.dll || die
	cp "${DISTDIR}"/${GEO_IP_DB##* } ./GeoLite2-Country.mmdb.gz || die
}

src_configure() { :; }

src_prepare() {
	# register game-version
	emake VERSION="${PV}" version

	sed \
		-e "s/@LIBLUA51@/liblua.so.${LUA_V}/" \
		"${S}"/thirdparty/Eluant.dll.config.in > Eluant.dll.config || die

	cd "${S}"/thirdparty/download || die
	cp *.dll *.dll.config GeoLite2-Country.mmdb.gz "${S}"/ || die
}

src_compile() {
	emake VERSION="${PV}" core tools
	emake VERSION="${PV}" docs
}

src_install() {
	emake \
		datadir="/usr/share" \
		bindir="/usr/bin" \
		libdir="/usr/libexec" \
		VERSION="${PV}" \
		DESTDIR="${D}" \
		install-all install-linux-scripts install-linux-mime install-linux-icons

	exeinto /usr/libexec/openra
	doexe Eluant.dll.config

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
}

pkg_postrm() {
	gnome2_icon_cache_update
	fdo-mime_desktop_database_update
	fdo-mime_mime_database_update
}
