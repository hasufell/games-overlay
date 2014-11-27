# Copyright 2009 David Leverton <dleverton@exherbo.org>
# Copyright 2014 Julian Ospald <hasufell@posteo.de>
# Distributed under the terms of the GNU General Public License v2

# @ECLASS: gamers
# @MAINTAINER:
# Julian Ospald <hasufell@posteo.de>
# @BLURB: Handling games that install variable data/bones/score files.
# @DESCRIPTION:
# This eclass is only for games that install saves, bones or score files
# into /var/lib/games or similar directories. It sets up necessary permissions
# for the user/group 'gamers' on those files which may be security relevant.
#
# Don't use this for games that don't need it.

if [[ -z ${_GAMERS_ECLASS} ]]; then
_GAMERS_ECLASS=1

inherit user

EXPORT_FUNCTIONS pkg_setup pkg_preinst pkg_postinst

# @ECLASS-VARIABLE: GAME_SCORES
# @INTERNAL
# @DESCRIPTION:
# Holds the games files that will be preserved. Used by
# gamers_preserve_vardata(), gamers_pkg_preinst() and gamers_pkg_postinst().
GAME_SCORES=()

# @FUNCTION: gamers_pkg_setup
# @DESCRIPTION:
# Creates the gamers user and group used in dovarlibgames().
gamers_pkg_setup() {
	enewgroup gamers 40
	enewuser gamers 40 -1 -1 gamers
}

# @FUNCTION: dovarlibgames
# @USAGE: [-R] [<var-dirs>]
# @DESCRIPTION:
# Fixes permissions of var games data, such as bones files.
# This may be security relevant.
dovarlibgames() {
	local R=
	if [[ ${1} == -R ]]; then
		R=-R
		shift
	fi

	local f
	for f in "${@-/var/lib/games}"; do
		[[ ${f} == ${D%+(/)}/* ]] && f=${f#${D%+(/)}}
		[[ -e "${D}/${f}" ]] || dodir "${f}"
		fowners ${R} gamers:gamers "${f}" || die
		fperms ${R} g+w "${f}" || die
		if [[ -d "${D}/${f}" ]]; then
			fperms g+s "${f}" || die
			if [[ -n ${R} ]]; then
				pushd "${D}" > /dev/null
				find "${f}" -type d -exec fperms g+s '{}' +
				popd > /dev/null
			fi
		fi
	done
}

# @FUNCTION: gamers_preserve_vardata
# @USAGE: [-R|-r] [<dirs|files>]
# @DESCRIPTION:
# Preserve variable game data files or directories such as scores
# from the live filesystem.
# Make sure gamers_pkg_preinst() is executed.
# This must be called after the files are installed to ${D},
# so usually at the end of src_install().
# @CODE
#  options:
#  -R, -r
#    recursively preserve files
#
# example1: gamers_preserve_vardata /var/lib/games/${PN}/scores
# results in: only preserve /var/lib/games/${PN}/scores which is a regular
#             file
#
# example2: gamers_preserve_vardata -R
# results in: preserve all related files from /var/lib/games and subdirs
# @CODE
gamers_preserve_vardata() {
	local recursive=false
	if [[ ${1} == "-R" || ${1} == "-r" ]]; then
		recursive=true
		shift
	fi

	local f p
	for f in "${@:-/var/lib/games}"; do
		if [[ -f ${D}${f} ]] ; then
			GAME_SCORES+=( "${f}" )
		elif [[ -d ${D}${f} && ${recursive} ]] ; then
			# also preserve all files from subdirs as well
			while read p ; do
				[[ -f ${D}${f%/}/${p} ]] && GAME_SCORES+=( "${f%/}/${p}" )
			done < <(find "${D}${f}" -printf '%P\n' 2>/dev/null)
		fi
	done

	einfo "preserving files:"
	for f in ${GAME_SCORES[@]} ; do
		einfo "  ${f}"
	done
}

# @FUNCTION: gamers_pkg_preinst
# @DESCRIPTION:
# Synchronizes the files from GAME_SCORES with the live filesystem, so
# we don't overwrite e.g. score files.
# This does have no effect if gamers_preserve_vardata() is not used,
# but is mandatory if it is used.
gamers_pkg_preinst() {
	local f
	for f in "${GAME_SCORES[@]}"; do
		if [[ -e ${ROOT}${f} ]] ; then
			cp -p \
				"${ROOT}${f}" \
				"${D}${f}" \
				|| die "cp failed"
		fi
	done
}

# @FUNCTION: gamers_pkg_postinst
# @DESCRIPTION:
# Prints a warning to add the current user to the 'gamers' group.
# Not mandatory.
gamers_pkg_postinst() {
	ewarn "In order to play this game and access the variable data files,"
	ewarn "you have to be in the 'gamers' group."
	ewarn "Just run 'gpasswd -a <USER> gamers', then have <USER> re-login."
}


fi

