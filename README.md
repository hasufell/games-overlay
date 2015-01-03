### Purpose and scope

Games ebuilds, nothing else. No libraries.

### Contributing

* no games.eclass usage
* proper Copyright header (not just Gentoo Foundation, unless you want to give them copyright)
* license should be GPL-2
* all commits MUST be gpg-signed
* always provide a metadata.xml with contact information

### Adding the overlay

With paludis: see [Paludis repository configuration](http://paludis.exherbo.org/configuration/repositories/index.html)

With layman:
```layman -f -o https://raw.github.com/hasufell/games-overlay/master/repository.xml -a games-overlay``` or ```layman -a games-overlay```

### Signature verification

All commits on the first parent (at least) are signed by me.
You can verify the repository via:
```
[ -z "$(git show -q --pretty="format:%G?" $(git rev-list --first-parent master) | grep -v G)" ] && echo "verification success" || echo "verification failure"
```

If the verification failed, you can examine which commits did
via
```
git show -q --pretty="format:%h %an %G?" $(git rev-list --first-parent master) | grep '.* [NBU]$'
```

### Compatibility with gentoo tree

As this overlay does not use games.eclass it does voluntarily conflict
with the gentoo tree. There are a few cases that can cause trouble, e.g.
when a data-package of game foo is installed from gentoo tree, but the
engine of foo is installed from this overlay.

Normally this does not happen, because overlays have naturally a higher
priority than the tree.

To improve compatibility, you can add the following to bashrc in paludis or
make.conf in portage:
```
GAMES_PREFIX=/usr
GAMES_PREFIX_OPT=/opt
GAMES_DATADIR=/usr/share
GAMES_DATADIR_BASE=/usr/share
GAMES_SYSCONFDIR=/etc
GAMES_STATEDIR=/var/lib
GAMES_LOGDIR=/var/log
GAMES_BINDIR=${GAMES_PREFIX}/bin
GAMES_GROUP=users
```

If you hit trouble with some packages you can simply force reinstallation
of all installed gentoo-packages that are also provided by this repository.
For paludis do:
```
cave resolve -z -1 -x $(eix --only-names --installed-from-overlay gentoo --in-overlay games-overlay)
```

For portage do:
```
emerge -av1 $(eix --only-names --installed-from-overlay gentoo --in-overlay games-overlay)
```
