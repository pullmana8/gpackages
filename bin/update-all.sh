if [[ ! -d /mnt/packages-tree/gentoo/ ]]; then
    cd /mnt/packages-tree || exit 1
    git clone https://anongit.gentoo.org/git/repo/gentoo.git
else
    cd /mnt/packages-tree/gentoo/ || exit 1
    git pull --rebase &>/dev/null
fi

/var/www/packages.gentoo.org/update-md5.sh
/var/www/packages.gentoo.org/update-use.sh

cd /var/www/packages.gentoo.org/htdocs || exit 1
bundle exec rake kkuleomi:update:all RAILS_ENV=production &>/dev/null
