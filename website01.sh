#!/bin/bash
#INSTALL@ /usr/local/bin/website01
debug=yes

if [ -d web ] ; then
        website=web
else
        website=www
fi
wd=$(pwd)
base=$(basename $wd)
if [ -d htm ] ; then
        htmldir=htm
else
        htmldir=html
fi


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
    $0: website beautifier - leftbar style

SYNOPSIS:
    $0 [ -s source ] [ -t title ] [ -w website ]

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
    -h Print this helptext
    -d [yes|no] Set debug output

Note that all directories are relative to the current directory.

BUGS/FEATURES:
Absolute paths for source or target do not work.

AUTHOR:
ljm

EOF
}

while getopts "hdswh:" opt ; do
	case "$opt" in
		(d) debug="$OPTARG" ;;
		(h) hellup ; exit 0 ;;
		(s) htmldir="$OPTARG" ;;
		(t) title="$OPTARG" ;;
		(w) website="$OPTARG" ;;
	esac
done

if [ "$debug" = "yes" ] ; then
	echo "Title:     $title"
	echo "Htmldir:   $htmldir"
	echo "Website:   $website"
fi

if [ ! -d "$htmldir" ] ; then
	echo "ERROR: no directory '$htmldir' which should contain html-parts"
	exit 9
fi

if [ ! -d $website ] ; then
	echo "Warning: no '$website' directory; so nothing is made"
	exit 0
fi

mkwebindex > $website/header.html

if [ -f meta.in ] ; then
	coverpng=`sed -n 's/^\.cover *//p' meta.in`
	if [ "$coverpng" = "" ] ; then
		coverpng=cover.png
	fi
	language=`sed -n 's/^\.lang *//p' meta.in`
	if [ "$language" = "" ] ; then
		language=en
	fi
else
	coverpng=cover.png
	language=en
fi

if [ "$debug" = "yes" ] ; then
	echo "Cover:     $coverpng"
	echo "Language:  $language"
fi

if [ -d block ] ; then
	if [ -L "$website/block" ] ; then
		echo "Block link exists."
	else
		ln -s $(realpath block) "$website/block"
		echo "Block link made."
	fi
fi

if [ ! -f "$coverpng" ] ; then
	convert -size 400x400 canvas:white "$coverpng"
fi

cp cover.png $website

cat > $website/website.css <<EOF
title-header{
    margin-top: 0;
    text-align: center;
}

.container{
    margin-left: 15%;
    padding-top: 2%;
    position: relative;
    display: inline-block;
    vertical-align: top;
    height: 100%;
    min-height: 100%;
    width: 100%;
    max-width: 100%;
}

/* Projects page */

.project-row{
  margin-bottom: 1%;
}

.project-box{
  background-color: #142F54;
  color: #FFFFFF;
  border: 1px solid;
  margin:5px;
  min-height: 150px;
  max-height: 150px;
  min-width: 325px;
  overflow: hidden;
}

.project-box:hover {
  background-color: #051A38;
  -webkit-transition: all .2s ease;
  -moz-transition: all .2s ease;
  -o-transition: all .2s ease;
  -ms-transition: all .2s ease;
  transition: all .2s ease;
}

.project-box h2{
  text-align: center;
}

/* End projects */

/* social media logos */

#social-media-icons{
  margin-top: 0;
  padding-top: 0;
  padding: 0;
  padding-bottom: 2px;
}

#social-media-icons img{
  margin-top: 0;
  text-align: left;
  height: 34px;
  width: auto;
}

.brand p{
  line-height: 200%;
  margin-bottom: 0;
}

/* end social media logos */

.article{
    margin-left: 1%;
    margin-right: 1%;
    width: 97%;
}

.article img{
  height: auto;
  max-width: 100%;
}

.brand h1{
  font-weight: 900;
  font-size: 22px;
}

.nav-side-menu .brand img{
  margin-top: 25px;
  height: 125px;
  width: 125px;

}

.nav-side-menu li a{
  width: 100%;
  display: block;
}

/* Sidenav credit to Tom Michew https://medium.com/wdstack/bootstrap-sidebar-examples-e363021395ff */
.nav-side-menu {
  overflow: auto;
  font-family: verdana;
  font-size: 12px;
  font-weight: 200;
  background-color: #142F54;
  position: fixed;
  top: 0px;
  width: 300px;
  /* Personal tweak - disabled height 100 and added to min-width to properly scale menu on smaller screens */
  /* height: 100%;  */
  color: #e1ffff;
}
.nav-side-menu .brand {
  background-color: #051A38;
  line-height: 50px;
  display: block;
  text-align: center;
  font-size: 14px;
}
.nav-side-menu .toggle-btn {
  display: none;
}
.nav-side-menu ul,
.nav-side-menu li {
  list-style: none;
  padding: 0px;
  margin: 0px;
  line-height: 35px;
  cursor: pointer;
  /*    
    .collapsed{
       .arrow:before{
                 font-family: FontAwesome;
                 content: "\f053";
                 display: inline-block;
                 padding-left:10px;
                 padding-right: 10px;
                 vertical-align: middle;
                 float:right;
            }
     }
*/
}
.nav-side-menu ul :not(collapsed) .arrow:before,
.nav-side-menu li :not(collapsed) .arrow:before {
  font-family: FontAwesome;
  content: "\f078";
  display: inline-block;
  padding-left: 10px;
  padding-right: 10px;
  vertical-align: middle;
  float: right;
}

.nav-side-menu ul .active,
.nav-side-menu li .active {
  border-left: 3px solid #d19b3d;
  background-color: #758AA8;
}
.nav-side-menu ul .sub-menu li.active,
.nav-side-menu li .sub-menu li.active {
  color: #d19b3d;
}
.nav-side-menu ul .sub-menu li.active a,
.nav-side-menu li .sub-menu li.active a {
  color: #d19b3d;
}
.nav-side-menu ul .sub-menu li,
.nav-side-menu li .sub-menu li {
  background-color: #181c20;
  border: none;
  line-height: 28px;
  border-bottom: 1px solid #23282e;
  margin-left: 0px;
}
.nav-side-menu ul .sub-menu li:hover,
.nav-side-menu li .sub-menu li:hover {
  background-color: #020203;
}
.nav-side-menu ul .sub-menu li:before,
.nav-side-menu li .sub-menu li:before {
  font-family: FontAwesome;
  content: "\f105";
  display: inline-block;
  padding-left: 10px;
  padding-right: 10px;
  vertical-align: middle;
}
.nav-side-menu li {
  padding-left: 20px; /* Personal tweak - add padding in case no icons are used */
}
.nav-side-menu li a {
  text-decoration: none;
  color: #e1ffff;
}
.nav-side-menu li a i {
  padding-left: 10px;
  width: 20px;
  padding-right: 20px;
}
.nav-side-menu li:hover {
  border-left: 3px solid #d19b3d;
  background-color: #051A38;
  -webkit-transition: all .5s ease;
  -moz-transition: all .5s ease;
  -o-transition: all .5s ease;
  -ms-transition: all .5s ease;
  transition: all .5s ease;
}
@media (max-width: 767px) {
  .brand p{
    line-height: 50px;
  }
  .brand h1{
    font-size: 14px;
    margin: 0px;
    line-height: 50px;
  }
  .nav-side-menu .brand img {
    display: none;
  }
  .nav-side-menu {
    position: relative;
    width: 100%;
    margin-bottom: 10px;
  }
  .nav-side-menu .toggle-btn {
    display: block;
    cursor: pointer;
    position: absolute;
    right: 10px;
    top: 10px;
    z-index: 10 !important;
    padding: 3px;
    background-color: #ffffff;
    color: #000;
    width: 40px;
    text-align: center;
  }
  .brand {
    text-align: left !important;
    font-size: 22px;
    padding-left: 20px;
    line-height: 50px !important;
  }
}
@media (min-width: 767px) {
  .nav-side-menu {
    height: 100%;
  }
  .nav-side-menu .menu-list .menu-content {
    display: block;
  }
  #main {
  	width:calc(100% - 300px);
  	float: right;
  }
}

body {
  margin: 0px;
  padding: 0px;
}

/* End sidenav */
EOF

for file in $htmldir/*.htm* ; do
	basefile=$(basename "$file")
	stem=${basefile%.ht*}
	if [ "$stem" = "header" ] ; then 
		continue
	fi
	cat > "$website/$stem.html" <<EOF
<!DOCTYPE html>
<html lang="$language">
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
        <title>$title</title>
        <link rel="stylesheet" href="website.css">
EOF
	if [ -f stylesheet.css ] ; then
		cp stylesheet.css $website
		echo '        <link rel="stylesheet" href="stylesheet.css">' >> "$website/$stem.html" 
	fi

	cat >> "$website/$stem.html" <<EOF
    </head>
    <body>
        <div class="nav-side-menu">
                <div class="brand">
                    <img src=$coverpng alt="cover">
                    <h1>$title</h1>
                </div>
                <div class="menu-list">
EOF

	if [ -f $htmldir/header.html ] ; then
		cp $htmldir/header.html  "$website"
	elif [ -f $htmldir/header.htm ] ; then
		cp $htmldir/header.htm  "$website/header.html"
	else
		touch "$website/header.html"
	fi
	cat $website/header.html >> "$website/$stem.html"
	cat >> "$website/$stem.html" <<EOF
                </div>
            </div>
            <div class="container" id="main">
                <div class="row">
                    <div class="col-md-12">
                        <div class="article">
EOF
	cat $file >> "$website/$stem.html"
	cat >> "$website/$stem.html" <<EOF
                        </div>
                    </div>
                </div>
            </div>
    </body>
</html>
EOF
done
