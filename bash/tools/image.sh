
function convert2jpg() { for i in $*; do convert $i `echo $i | sed -e 's/\(.*\)\..*/\1.jpg/g'`; done; }
function convert2png() { for i in $*; do convert $i `echo $i | sed -e 's/\(.*\)\..*/\1.png/g'`; done; }
# Usage: <width>
function convertscalejpg() { 
  for i in `ls *.jpg -1`; do echo $i ; convert -scale $1 $i `echo $i | sed -e 's/\(.*\).jpg/\1.sized.jpg/g'`; done
}
