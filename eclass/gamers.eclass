# Copyright 2009 David Leverton <dleverton@exherbo.org>
# Copyright 2014 Julian Ospald <hasufell@posteo.de>
# Distributed under the terms of the GNU General Public License v2

# @ECLASS: gamers
# @MAINTAINER:
# Julian Ospald <hasufell@posteo.de>
# @BLURB: Handling games that install variable data/bones/score files.
# @DESCRIPTION:
# This eclass is only for games that install saves, bones or score files
# into /var/lib/games or subdirectories.
#
# It sets up necessary permissions for the user/group 'gamers' on those
# files via gamers_prep_vardata(), which is security relevant.
#
# It also allows to preserve those files across (re-)installations via
# gamers_preserve_vardata().
#
# If you are unsure what files specifically need to be fixed or preserved,
# you can just do the following at the END of src_install():
# @CODE
#   gamers_prep_vardata -R
#   gamers_preserve_vardata -R
# @CODE
# which fixes all related permissions in /var/lib/games and subdirs and
# preserves all files inside those dirs. Then make sure pkg_setup() and
# pkg_preinst() are not overwritten (or call gamers_pkg_* functions manually)!
#
# Don't use this for games that don't need it. For server parts you should
# instead create package-specific user/group and set appropriate permissions.

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
# Creates the gamers user and group used in gamers_prep_vardata().
gamers_pkg_setup() {
	enewgroup gamers 40
	enewuser gamers 40 -1 -1 gamers
}

# @FUNCTION: gamers_prep_vardata
# @USAGE: [-R|-r] [<dirs|files>]
# @DESCRIPTION:
# Fixes permissions of var games data, such as bones files.
# Default directory is "/var/lib/games" if no dirs are given.
# This may be security relevant and is mandatory if the ebuild installs
# into "/var/lib/games".
# Also mind that this must be called after the files are installed to ${D},
# so usually at the end of src_install().
# @CODE
#   options:
#     -R, -r
#       recursively fix permissions
#
#   example1: gamers_prep_vardata /var/lib/games/${PN}
#   results in: fixes permissions of the file/dir /var/lib/games/${PN} only
#
#   example2: gamers_prep_vardata -r
#   results in: fixes all permissions of /var/lib/games recursively
# @CODE
gamers_prep_vardata() {
	local recursive=false
	if [[ ${1} == "-R" || ${1} == "-r" ]]; then
		recursive=true
		shift
	fi
	einfo "fixing permissions of:"

	local f
	for f in "${@:-/var/lib/games}"; do
		[[ -e "${D}${f}" ]] || die "${D}${f} does not exist"

		einfo "  ${f}"

		fowners $(${recursive} && echo "-R") gamers:gamers "${f}"
		fperms $(${recursive} && echo "-R") g+w "${f}"

		# set gid on directories
		if [[ -d "${D}${f}" ]]; then
			fperms g+s "${f}" || die
			if ${recursive} ; then
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
# Preserve variable game data files such as scores
# from the live filesystem.
# This must be called after the files are installed to ${D},
# so usually at the end of src_install().
# Also make sure gamers_pkg_preinst() is executed.
# @CODE
#   options:
#     -R, -r
#       recursively preserve files
#
#   example1: gamers_preserve_vardata /var/lib/games/${PN}/scores
#   results in: only preserve /var/lib/games/${PN}/scores which is a regular
#               file
#
#   example2: gamers_preserve_vardata -R
#   results in: preserve all related files from /var/lib/games and subdirs
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

