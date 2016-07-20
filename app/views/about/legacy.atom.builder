atom_feed(id: atom_id(@feed_type, 'feed')) do |feed|
  feed.title @feed_title
  feed.updated Time.now

  feed.entry('', id: atom_id(@feed_type, 'deprecated'), url: about_feeds_url) do |entry|
    entry.title 'This feed is deprecated'
    entry.content <<END_CONTENT.strip
This is a legacy feed from the previous version of packages.gentoo.org

With our recent site relaunch, the feed setup has changed as well.
To continue receiving updates about Gentoo packages, please visit the Feeds section of our new packages website at:

  https://packages.gentoo.org/about/feeds

Thank you for your interest in our packages site.
END_CONTENT
  end
end
