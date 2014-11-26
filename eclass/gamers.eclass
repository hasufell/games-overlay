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

# @ECLASS-VARIABLE: GAMES_PREFIX_OPT
# @INTERNAL
# @DESCRIPTION:
# Holds the games scores that will be preserved. Used by preserve_scores(),
# gamers_pkg_preinst() and gamers_pkg_postinst().
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
		chown ${R} gamers:gamers "${D}${f}" || die
		chmod ${R} g+w "${D}${f}" || die
		if [[ -d "${D}/${f}" ]]; then
			chmod g+s "${D}${f}" || die
			if [[ -n ${R} ]]; then
				find "${D}/${f}" -type d -exec chmod g+s '{}' +
			fi
		fi
	done
}

# @FUNCTION: preserve_scores
# @USAGE: <score-dirs>
# @DESCRIPTION:
# Preserve score files from the live filesystem.
preserve_scores() {
	local f
	for f in "${@}"; do
		[[ ${f} == ${D%+(/)}/* ]] && f=${f#${D%+(/)}}
		[[ ( -e ${D}/${f} || -L ${D}/${f} ) && ! -f ${D}/${f} ]] && continue
		GAME_SCORES+=( "${f}" )
	done
}

# @FUNCTION: gamers_pkg_preinst
# @DESCRIPTION:
# Prepares the games score files for copying in pkg_postinst,
# not optional if you ran preserve_scores() in src_install().
gamers_pkg_preinst() {
	local staging="${T}"/gamers.eclass-scores
	mkdir "${staging}"

	local f
	for f in "${GAME_SCORES[@]}"; do
		mkdir -p "${staging}/${f%/*}" || die
		mv {"${D}","${staging}"}/"${f}" || die
	done
}

# @FUNCTION: gamers_pkg_postinst
# @DESCRIPTION:
# Copies the games score files for,
# not optional if you ran preserve_scores() in src_install().
gamers_pkg_postinst() {
	local staging="${T}"/gamers.eclass-scores f
	for f in "${GAME_SCORES[@]}"; do
		# don't die in pkg_postinst
		[[ -f ${ROOT}/${f} ]] || cp -p {"${staging}","${ROOT}"}/"${f}"
	done

	ewarn "In order to play this game and access the variable data files,"
	ewarn "you have to be in the 'gamers' group."
	ewarn "Just run 'gpasswd -a <USER> gamers', then have <USER> re-login."
}


fi

