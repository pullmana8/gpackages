#!/bin/bash

# This script runs as the gpackages user normally!

# Outside of a docker environment, it cannot call emerge --sync because that
# requires the 'portage' group, and opens up attacks to escalate from gpackages
# to portage-owned files.  However, in a Docker environment, the other files
# from Portage are NOT available unless --sync IS used.

function in_docker() {
	path=/proc/1/cgroups
	[[ -e ${path} ]] && grep -qa docker "${path}"
}

# Stuff that we have to do inside Docker:
if in_docker && [[ ${1} != "production" ]]; then
	emerge --sync
fi

# This is the copy of the tree used to run gpackages against.
if [[ ! -d /mnt/packages-tree/gentoo/ ]]; then
    cd /mnt/packages-tree || exit 1
    git clone https://anongit.gentoo.org/git/repo/gentoo.git
else
    cd /mnt/packages-tree/gentoo/ || exit 1
    git pull --rebase &>/dev/null
fi

/var/www/packages.gentoo.org/htdocs/bin/update-md5.sh
/var/www/packages.gentoo.org/htdocs/bin/update-use.sh

cd /var/www/packages.gentoo.org/htdocs || exit 1
bundle exec rake kkuleomi:update:all RAILS_ENV=${1:-development} &>/dev/null
