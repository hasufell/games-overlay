### Purpose and scope

Games ebuilds, nothing else. No libraries.

### Contributing

* no games.eclass usage
* proper Copyright header (not Gentoo Foundation)
* license should be GPL-2
* all commits MUST be gpg-signed
* always provide a metadata.xml with contact information

### Adding the overlay

With paludis: see [Paludis repository configuration](http://paludis.exherbo.org/configuration/repositories/index.html)

With layman:
```layman -f -o https://raw.github.com/hasufell/games-overlay/master/repository.xml -a games-overlay``` or ```layman -a games-overlay```

