# Copyright 2014-2016 Julian Ospald <hasufell@posteo.de>
# Distributed under the terms of the GNU General Public License v2

EAPI=5

CABAL_FEATURES="bin lib profile haddock hoogle hscolour test-suite"
inherit haskell-cabal

DESCRIPTION="A monadic take on a 2,500-year-old board game - GTK+ UI"
HOMEPAGE="http://khumba.net/projects/goatee"
SRC_URI="mirror://hackage/packages/archive/${PN}/${PV}/${P}.tar.gz"

LICENSE="AGPL-3"
SLOT="0/${PV}"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND=">=dev-games/goatee-0.3:=[profile?]
	>=dev-haskell/cairo-0.13:=[profile?]
	>=dev-haskell/gtk-0.13:2=[profile?]
	>=dev-haskell/mtl-2.1:=[profile?]
	>=dev-haskell/parsec-3.1:=[profile?]
	>=dev-libs/gmp-5:=
	virtual/libffi:=
"
DEPEND="${RDEPEND}
	>=dev-lang/ghc-7.4.1:=
	>=dev-haskell/cabal-1.8
	test? ( >=dev-haskell/hunit-1.2 )
"
