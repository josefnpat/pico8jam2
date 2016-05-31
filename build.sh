#!/bin/sh
GIT=`git log --pretty=format:'%h' -n 1 $1`
GIT_COUNT=`git log --pretty=format:'' $1 | wc -l`
OUTPUT=thecareerofpeter-v${GIT_COUNT}.p8

cat src/data.header > ${OUTPUT}
echo "git = \"$GIT\"" >> ${OUTPUT}
echo "git_count = \"$GIT_COUNT\"" >> ${OUTPUT}

#echo "rooms={}" >> ${OUTPUT}
#for file in src/assets/rooms/* ; do
#	echo -n "rooms[\"$(basename $file)\"] = " >> ${OUTPUT}
#	cat $file >> ${OUTPUT}
#done

echo "people={}" >> ${OUTPUT}
for file in src/assets/people/* ; do
	echo -n "people[\"$(basename $file)\"] = " >> ${OUTPUT}
	cat $file >> ${OUTPUT}
done

cat src/data.lua src/data.gfx src/data.gff src/data.map src/data.sfx src/data.music >> ${OUTPUT}
