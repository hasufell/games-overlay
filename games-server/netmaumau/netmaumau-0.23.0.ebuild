# Copyright 2015 Julian Ospald <hasufell@posteo.de>, Heiko Schaefer <heiko@rangun.de>
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit autotools bash-completion-r1 flag-o-matic eutils vcs-snapshot

DESCRIPTION="Server for the popular card game Mau Mau"
HOMEPAGE="http://sourceforge.net/projects/netmaumau"
SRC_URI="https://github.com/velnias75/NetMauMau/archive/V${PV}.tar.gz -> ${P}-server.tar.gz"

LICENSE="LGPL-3"
SLOT="0/13"
KEYWORDS="~amd64 ~x86"
IUSE="branding console-client dedicated doc static-libs"

# use Lua slot 5.1 if working
RDEPEND="
	dev-db/sqlite:3
	<dev-lang/lua-5.2
	>=dev-libs/popt-1.10
	>=sci-libs/gsl-1.9
	sys-apps/file
"

DEPEND="${RDEPEND}
	dev-util/xxdi
	doc? ( >=app-doc/doxygen-1.8.0[dot] )
	sys-apps/help2man
	virtual/pkgconfig
"

S=${WORKDIR}/${P}-server

src_prepare() {
	eautoreconf
}

src_configure() {
	append-cppflags -DNDEBUG

	econf \
		$(use_enable !dedicated client) \
		--enable-xinetd \
		--with-bashcompletiondir="$(get_bashcompdir)" \
		$(usex dedicated "--disable-console-client" "$(use_enable console-client)") \
		$(use_enable doc apidoc) \
		--docdir=/usr/share/doc/${PF} \
		--localstatedir=/var/lib/games/ \
		$(use_enable static-libs static) \
		"$(use_enable branding ai-name 'Gentoo Hero')" \
		$(use_enable branding ai-image "${FILESDIR}"/gblend.png)
}

src_install() {
	default
	prune_libtool_files
	keepdir /var/lib/games/netmaumau
	fowners nobody:nogroup /var/lib/games/netmaumau
}

pkg_postinst() {

	# if there is a running nmm-server started by xinetd
	# than it get stopped, so the next connection attempt
	# will use the newly installed instance
	if [ -n "`pgrep -f "nmm-server"`" ]; then
                if [ -n "`pgrep -f "inetd"`" ]; then
			elog "Detected a NetMauMau server started from (x)inetd."
                        elog "Stopping nmm-server to spawn the newly installed instance at next request …"
                        killall nmm-server 2> /dev/null
                fi
        fi

	if ! use dedicated ; then
		elog "This is only the server part, you might want to install"
		elog "the client too:"
		elog "  games-board/netmaumau"
		elog
	fi
	elog "This server also installs a xinetd service. You need"
	elog "  sys-apps/xinetd"
	elog "if you want to get the server started on demand."
}
