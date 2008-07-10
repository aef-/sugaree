#!/bin/sed -f
# tex2htm.sed
#  Converts Textile to HTML.
#  
#  For a textile reference visit:
#	http://hobix.com/textile
#  WARNING: Not everything has been implemented
#	the same, please read the README for more
#	info.
#
# Part of the sugaree package.
#
# By C.Dotty (c.dotty@catch-colt.com)
#  http://dev.catch-colt.com/sugaree
################################################

#		CODE/PRE (Unformated)
#  Use a beautifier if you want pretty code. I'm just a parsa!
	:noformat
	/<code>\(.*\)/ {
		N
		/<\/code>$/ {
			s/</\&#60;/g
			s/>/\&#62;/g
			s/^&#60;code&#62;\(.*\)&#60;\/code&#62;/<code>\1<\/code>/
			b
		}
		bnoformat
	}

#		BLOCKS
	:block
	#-----------------tags-----------------------#block alignment-----#attribute modifers------------------
	/^\(\(h[1-6]\)\|\(bq\)\|\(p\)\|\(fn[0-9]\+\)\)\(\(<>\)\?\|[><=]\?\)\(\({.\+}\)\|\((.\+)\)\|\(\[.\+\]\)\)*\. .*/ {
		N
		# RULES: No blocks within blocks or inlines.
			s/^h\([1-6]\)\(\(<>\)\?\|[><=]\?\)\(\(\({.\+}\)\|\((.\+)\)\|\(\[.\+\]\)\)*\)\. \(\(.*\)\|\(\n\)\)*\n\(^$\)/<h\1\2\4>\9<\/h\1>\n/
			s/^bq\(\(<>\)\?\|[><=]\?\)\(\(\({.\+}\)\|\((.\+)\)\|\(\[.\+\]\)\)*\)\. \(.*\|\n\)\n\(^$\)/<blockquote><p\1\3>\8<\/p><\/blockquote>\n/
			s/^p\(\(<>\)\?\|[><=]\?\)\(\(\({.\+}\)\|\((.\+)\)\|\(\[.\+\]\)\)*\)\. \(.*\|\n\)\n\(^$\)/<p\1\3>\8<\/p>\n/
			s/^fn\([0-9]\+\)\(\(<>\)\?\|[><=]\?\)\(\(\({.\+}\)\|\((.\+)\)\|\(\[.\+\]\)\)*\)\. \(.*\|\n\)\n\(^$\)/<p\2 id="\1"\4><sup>\1<\/sup>\9<\/p>\n/
			/^\(<blockquote>\)\?<\(\(h[1-6]\)\|\(p\)\)\(\(<>\)\|[><=]\)[^>]*>/ {	
				s/^\(<blockquote>\)\?<\([^<=>]\+\)=\([^<=>]*\)>/\1<\2 style="text-align:center;"\3>/
				s/^\(<blockquote>\)\?<\([^<>]\+\)<>\([^<>]*\)>/\1<\2 style="text-align:justify;"\3>/
				s/^\(<blockquote>\)\?<\([^<>]\+\)<\([^<>]*\)>/\1<\2 style="text-align:left;"\3>/
				s/^\(<blockquote>\)\?<\([^<>]\+\)>\([^<>]*\)>/\1<\2 style="text-align:right;"\3>/	
			}
			bblock
	}

#		LISTS

	:lists
	/^\* [^ ]/ {
		N
		/\n$/ {
			s/^/<ul>\n\n/
			s/\n\*\([*]*\) \([^\n]*\)/<li>\1 \2 <\/li>\n/g
			s/\n$/<\/ul>/
			:srlistsret
			/<li>\*/ {		
				bsrlists
			}

			blinebreaks
		}
		blists
	}
#	Subroutine of lists that handles descendants
	btables
	:srlists
	s/\(<\/li>\|<ul>\)\n<li>\*/<ul>\n<li>!/
	s/<ul>\n<li>!\(.*\)<li>\* \([^\n]*\)<\/li>/<ul>\n<li>\1<li> \2<\/li><\/ul><\/li>/
	
#	End one item hierarchy
	/<li>!/ {
		s/<li>! \([^\n]*\) <\/li>/<li> \1 <\/li><\/ul><\/li>/
	}

	s/<li>!/<li>/g
	s/<li>\*/<li>/g
	bsrlistsret

#		TABLES

	:tables
	/^|/ {
		N
		/\n$/ {
			s/^|/<table><tr><td>/
			s/|\n$/<\/td><\/tr><\/table>/
			s/|\n|/<\/td><\/tr>\n<tr><td>/g
			s/|/<\/td><td>/g
			blinebreaks
		}
		btables
	}

#		PARAGRAPHS (loitering text)
	:paragraphs
	/^\(\(<\(\(h[1-6]\)\|\(blockquote\)\|p\|code\|pre\|table\).*>\)\|\(^$\)\)/! {
		N
		s/\(\(.*\|\n\)*\)\n\(^$\)/<p>\1<\/p>\n/
		bparagraphs
	}

#		LINE BREAKS
	:linebreaks	
	s/\([^>]\)\n/\1<br\/>\n/g

#		EXTRA
#  Footnote
	s/\([A-Za-z0-9]\)\[\([0-9]\+\)\]/\1<a href="#fn\2"><sup>\2<\/sup><\/a>/g
#  Image Links
	s/!\(\({.\+}\)\|\((.\+)\)\|\(\[.\+\]\)\)*\([^ ]\+.*\)\((\(\+*\))\)\?!:\([^ ]\+\)/<a href="\8"><img src="\5" alt="\7" title="\7"\1\/><\/a>/g
#  Images
	s/!\(\({.\+}\)\|\((.\+)\)\|\(\[.\+\]\)\)*\([^ ]\+.*\)\((\(.\+\))\)\?!/<img src="\5" alt="\7" title="\7"\1\/>/g
#  Hypertext Links
	s/"\([^\n ]\+[^"]*\)":\([A-Za-z:#/-]\+\)/<a href="\2">\1<\/a>/g

#  Code Far too many conflicts for this to be pragmatically used.
#	s/@\(\({.\+}\)\|\((.\+)\)\|\(\[.\+\]\)\)*\([^\n]*\)@/<code\1>\5<\/code>/g
	

#		INLINE ELEMENTS
	
#  italics
	s/__\(\({.\+}\)\|\((.\+)\)\|\(\[.\+\]\)\)*\([^\n]*\)__/<i\1>\5<\/i>/g

#  bold
	s/\*\*\(\({.\+}\)\|\((.\+)\)\|\(\[.\+\]\)\)*\([^\n]*\)\*\*/<b\1>\5<\/b>/g

#  emphasis
	s/_\(\({.\+}\)\|\((.\+)\)\|\(\[.\+\]\)\)*\([^\n]*\)_/<em\1>\5<\/em>/g

#  strength (muscles)
	s/\*\(\({.\+}\)\|\((.\+)\)\|\(\[.\+\]\)\)*\([^\n]*\)\*/<strong\1>\5<\/strong>/g

#  citations
	s/??\(\({.\+}\)\|\((.\+)\)\|\(\[.\+\]\)\)*\([^\n]*\)??/<cite\1>\5<\/cite>/g

#  delete
	s/-\(\({.\+}\)\|\((.\+)\)\|\(\[.\+\]\)\)*\([^\n]*\)-/<del\1>\5<\/del>/g

#  insert
	s/+\(\({.\+}\)\|\((.\+)\)\|\(\[.\+\]\)\)*\([^\n]*\)+/<ins\1>\5<\/ins>/g

#  superscript
	s/\^\(\({.\+}\)\|\((.\+)\)\|\(\[.\+\]\)\)*\([^\n]*\)^/<sup\1>\5<\/sup>/g

#  subscript
	s/~\(\({.\+}\)\|\((.\+)\)\|\(\[.\+\]\)\)*\([^\n]*\)~/<sub\1>\5<\/sub>/g

#  span
	s/%\(\({.\+}\)\|\((.\+)\)\|\(\[.\+\]\)\)*\([^\n]*\)%/<span\1>\5<\/span>/g

#  acronym
	s/\([A-Z]\+\)(\(.*\))/<acronym title="\2">\1<\/acronym>/g

#		ATTRIBUTES
:attributes
	/<[^ ].*\(\((.\+)\)\|\({.\+}\)\|\(\[.\+\]\)\)\?.*>/{
#>< constraints are done for multiline text in blocks where a word may appear like an attribute.
		s/<\([^><]*\)(#\([^><]\+\))\([^><]*\)>/<\1 id="\2"\3>/g
		s/<\([^><]*\)(\([^><]\+\))\([^><]*\)>/<\1 class="\2"\3>/g
		s/<\([^><]*\){\([^><]\+\)}\([^><]*\)>/<\1 style="\2"\3>/g
		s/<\([^><]*\)\[\([^><]\+\)\]\([^><]*\)>/<\1 lang="\2"\3>/g
	}
