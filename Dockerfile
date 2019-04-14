# IMPORTANT (antonette)
# I created a Docker image for the first part of the image
# TODO: create Docker image for ES
FROM pyrrhus/gpkg

# Needed for changelogs.
RUN git clone https://anongit.gentoo.org/git/repo/gentoo.git /mnt/packages-tree/gentoo/

# Copy code into place.
COPY ./ /var/www/packages.gentoo.org/htdocs/
WORKDIR /var/www/packages.gentoo.org/htdocs/
RUN bundler install

# Git clones here.
RUN cp /var/www/packages.gentoo.org/htdocs/config/secrets.yml.dist /var/www/packages.gentoo.org/htdocs/config/secrets.yml
RUN sed -i 's/set_me/ENV["SECRET_KEY_BASE"]/'g /var/www/packages.gentoo.org/htdocs/config/secrets.yml

# Precompile our assets.
RUN rake assets:precompile
CMD ["bundler", "exec", "thin", "start"]
