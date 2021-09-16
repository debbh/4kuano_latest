# iterate over list of .axyz files, and concatenate together with HEADER 
# and FOOTER into a NWCHEM input deck
for i
do
 NW=${i##*/} #do you like my basename?
 NW=${NW%.*}.nw
 echo $NW
 
 cat HEADER > $NW
 cat $i >> $NW
 cat FOOTER >> $NW
done

