#!/bin/bash
#INSTALL@ /usr/local/bin/website02

website=www
wd=$(pwd)
base=$(basename $wd)
htmldir=html

if [ -f meta.in ] ; then
	title=$(sed -n 's/^\.title *//p' meta.in | head)
elif [ -f destination ] ; then
	title=$(sed -n 's/^title=//p' destination | head)
else
	title=$(cat *.in|sed -n 's/^\.title *//p'|head)
fi
if [ "$title" = "" ] ; then
	title="$base"
fi

hellup(){
cat <<EOF

NAME:
    $0: website beautifier - gnu man style

SYNOPSIS:
    $0 [ -s source ] [ -t title ] [ -w website ]
    $0 -h

DESCRIPTION:

$0 converts a the html-parts in the source directory to
a website under the target directory. $0 is meant for 
simple websites, not for multi-level sites with multiple
directories.

A htmlpart is a piece of HTML code without the introductory
<html>, without the header part and without the introductory
<body>.

ARGUMENTS:

    -s Source directory where the HTML parts are (default: html)
    -w Target website directory (default: www)
    -t Title (default: as defined in meta.in or in the file
       destination or in the first .in file, or else the base-name
       of the current directory)

Note that all directories are relative to the current directory.

BUGS/FEATURES:
Absolute paths for source or target do not work.

AUTHOR:
ljm
EOF

}

while getopts "hswh:" opt ; do
	case "$opt" in
		(h) hellup ; exit 0 ;;
		(s) htmldir="$OPTARG" ;;
		(t) title="$OPTARG" ;;
		(w) website="$OPTARG" ;;
	esac
done

if [ ! -d "$htmldir" ] ; then
	echo "ERROR: no directory '$htmldir' which should contain html-parts"
	exit 9
fi

if [ ! -d $website ] ; then
	echo "Warning: no '$website' directory; so nothing is made"
	exit 0
fi

if [ -f meta.in ] ; then
	coverpng=`sed -n 's/^\.cover *//p' meta.in`
	if [ "$coverpng" = "" ] ; then
		coverpng=cover.png
	fi
	language=`sed -n 's/^\.lang *//p' meta.in`
	if [ "$language" = "" ] ; then
		language=en
	fi
fi
if [ -f "$coverpng" ] ; then
	convert -resize 400x400 "$coverpng" "$website/$coverpng"
fi

# I know parsing of ls is generally bad; dont spam me for it
files=($(ls $htmldir/*html | sort -n))
qfiles=$(ls $htmldir/*html|wc -l)

if [ -f $htmldir/index.html ] ; then 
	index="$htmldir/index.html"
	indexline="<a href=index.html>Index</a>"
elif [ -f $htmldir/index.htm ] ; then 
	index="$htmldir/index.htm"
	indexline="<a href=index.htm>Index</a>"
else
	index=none
fi
if [ -f $htmldir/header.html ] ; then 
	header="$htmldir/header.html"
elif [ -f $htmldir/header.htm ] ; then 
	header="$htmldir/header.htm"
else
	header=none
fi
if [ -f $htmldir/total.html ] ; then 
	total="$htmldir/total.html"
elif [ -f $htmldir/total.htm ] ; then 
	total="$htmldir/total.htm"
else
	total=none
fi
	

typeset -i i=0
typeset -i p=0
typeset -i n=1

while [ $i -lt $qfiles ] ; do
	p=$((i-1))
	n=$((i+1))

	if [ $i -ne 0 ] ; then
		pbase=$(basename ${files[$p]})
		ptitle=$(sed -n 's/.*<[hH][123].*>\(.*\)<.[Hh][123]>.*/\1/p' $htmldir/$pbase | head -1)
		pline[$i]="<a href=$pbase>Previous: $ptitle</a>"
	else
		pline[$i]=" "
	fi

	if [ $n -ne $qfiles ] ; then
		nbase=$(basename ${files[$n]})
		if [ "$nbase" = "total.html" ] ; then ntitle=''; nline[$i]=""; 
		elif [ "$nbase" = "index.html" ] ; then ntitle=''; nline[$i]=""; 
		elif [ "$nbase" = "header.html" ] ; then ntitle=''; nline[$i]=""; 
		elif [ "$nbase" = "meta.html" ] ; then ntitle=''; nline[$i]=""; 
		else
			ntitle=$(sed -n 's/.*<[hH][123].*>\(.*\)<.[Hh][123]>.*/\1/p' $htmldir/$nbase | head -1)
			nline[$i]="<a href=$nbase>Next: $ntitle</a>"
		fi
	else
		nline[$i]=" "
	fi

	echo "$basefile -- $i ------------- "
	echo "    previous: $ptitle ($pbase)"
	echo "    next    : $ntitle ($npbase)"
	i=$((i+1))
done


i=0
while [ $i -lt $qfiles ] ; do
	file=${files[$i]}
	basefile=$(basename "$file")
	if [ "$basefile" = "index.html"  ] ; then  cp "$htmldir/index.html"  $website ; break; fi
	if [ "$basefile" = "total.html"  ] ; then  cp "$htmldir/total.html"  $website ; break; fi
	if [ "$basefile" = "header.html" ] ; then  cp "$htmldir/header.html" $website ; break; fi
	cat > "$website/$basefile" <<EOF
<!DOCTYPE html>
<html lang="$language">
    <head>
		<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
		<title>$title</title>
EOF
	if [ -f stylesheet.css ] ; then
		cp stylesheet.css $website
		echo '        <link rel="stylesheet" href="stylesheet.css">' >> "$website/$basefile" 
	fi

	cat >> "$website/$basefile" <<EOF
    </head>
 	<body>
		<table style="width:100%">
			<tr>
				<td style="width:50%">
					<h1>$title</h1>
EOF
	if [ "$header" != "none" ] ; then
		cat "$header" >> "$website/$basefile"
	fi
	if [ "$coverpng" != "" ] ; then
		cat >> "$website/$basefile" <<EOF
				</td>
				<td>
					<img src=$coverpng alt=\"cover\">
EOF
	fi
	cat >> "$website/$basefile" <<EOF
				</td>
			</tr>
		</table>
		<hr>
		<table style="width:100%">
			<tr>
				<td style="width:33%">
					${pline[$i]}
				</td>
				<td style="width:33%">
					$indexline
				</td>
				<td>
					${nline[$i]}
				</td>
			</tr>
		</table>
		<hr>
					
EOF


	cat $htmldir/$basefile >> "$website/$basefile"
	cat >> "$website/$basefile" <<EOF
		<hr>
		<table style="width:100%">
			<tr>
				<td style="width:33%">
					${pline[$i]}
				</td>
				<td style="width:33%">
					$indexline
				</td>
				<td>
					${nline[$i]}
				</td>
			</tr>
		</table>
		<hr>
    </body>
</html>
EOF
	i=$((i+1))
done
