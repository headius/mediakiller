This is a very simple converter from MediaWiki to other formats (only
markdown is supported currently).

Dependencies: mediacloth (gem)

Usage:

As an API:

MediaKiller.new(:markdown).convert(some_mediawiki_text)

At the command line:

mediakiller markdown some_mediawiki_file