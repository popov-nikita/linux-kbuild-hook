#!/bin/sh

set -e

usage() {
	printf 'USAGE: %s <linux root> [<Makefile.inc path>]\n' "$0" 1>&2
	exit 1
}

if test "$#" -lt "1"; then
	usage
fi

if ! test -d "$1" -a -w "$1"; then
	printf 'Couldn'\''t access %s\n' "$1" 1>&2
	usage
fi

check_linux_root() {
	local dirname="$1"

	test -f "${dirname}/kernel/cpu.c" -a          \
	     -f "${dirname}/scripts/Kbuild.include"
}

if ! check_linux_root "$1"; then
	printf 'Not a linux root dir - %s\n' "$1" 1>&2
	usage
fi

linux_root="$1"
kbuild_inc_file="${linux_root}/scripts/Kbuild.include"

if test "$#" -ge "2"; then
	mk_file_inc="$2"
else
	mk_file_inc="$(dirname "$0")/Makefile.inc"
fi
if ! test -f "${mk_file_inc}"; then
	printf 'File %s doesn'\''t exist\n' "${mk_file_inc}" 1>&2
	usage
fi

printf 'Copying file %s -> %s\n' "${kbuild_inc_file}" "${kbuild_inc_file}.orig"
cp "${kbuild_inc_file}" "${kbuild_inc_file}.orig"

printf 'Fixing file %s\n' "${kbuild_inc_file}"
sed -i -e 's/^\([[:blank:]]*\)if_changed_rule/\1___tmp_if_changed_rule/g' "${kbuild_inc_file}"
sed -i -e 's/^\([[:blank:]]*\)if_changed_dep/\1___tmp_if_changed_dep/g' "${kbuild_inc_file}"
sed -i -e 's/^\([[:blank:]]*\)if_changed/\1___tmp_if_changed/g' "${kbuild_inc_file}"
echo "include $(realpath "${mk_file_inc}")" >> "${kbuild_inc_file}"

printf 'Done!\n'

exit 0
