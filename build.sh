OUTPUT=thecareerofpeter.p8

GIT=`git log --pretty=format:'%h' -n 1 $1`
GIT_COUNT=`git log --pretty=format:'' $1 | wc -l`

cat src/data.header > ${OUTPUT}
echo "git = \"$GIT\"" >> ${OUTPUT}
echo "git_count = \"$GIT_COUNT\"" >> ${OUTPUT}

echo "assets={}" >> ${OUTPUT}
for file in src/assets/* ; do
	echo -n "assets[\"$(basename $file)\"] = " >> ${OUTPUT}
	cat $file >> ${OUTPUT}
done

cat src/data.lua src/data.gfx src/data.gff src/data.map src/data.sfx src/data.music >> ${OUTPUT}
