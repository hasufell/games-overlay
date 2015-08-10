# Copyright 2014 Julian Ospald <hasufell@posteo.de>
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

CABAL_FEATURES="bin"
inherit haskell-cabal

MY_PN=MazesOfMonad
MY_P=${MY_PN}-${PV}

DESCRIPTION="Console-based roguelike Role Playing Game similar to nethack"
HOMEPAGE="https://github.com/JPMoresmau/MazesOfMonad
	http://hackage.haskell.org/package/MazesOfMonad"
SRC_URI="mirror://hackage/packages/archive/${MY_PN}/${PV}/${MY_P}.tar.gz"

LICENSE="BSD-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND=">=dev-libs/gmp-5:0=
	virtual/libffi:="
DEPEND="${RDEPEND}
	>=dev-lang/ghc-7.4.1
	>=dev-haskell/cabal-1.6
	dev-haskell/hunit
	dev-haskell/mtl
	dev-haskell/random
	dev-haskell/regex-posix"

S=${WORKDIR}/${MY_P}

