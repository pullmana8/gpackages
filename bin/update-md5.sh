#!/bin/bash

mkdir -p /var/cache/pgo-egencache

cd /mnt/packages-tree/gentoo/ || exit 1
egencache -j 6 --cache-dir /var/cache/pgo-egencache --repo gentoo --repositories-configuration '[gentoo]
location = /mnt/packages-tree/gentoo' --update
