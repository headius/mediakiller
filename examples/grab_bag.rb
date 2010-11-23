require 'mediakiller'

wikitext = <<WIKI
==header1==
===header2===
* list
* list2

# foo
# foo2

This is a link: [[asdf]]
This is one inline [[qwer|Qwerty]] in a sentence.

This text is '''bold'''.
This text is ''italic''.
WIKI

puts MediaKiller.new(:markdown).convert(wikitext)