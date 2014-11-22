#!/bin/bash
set -e
org=org
posts=_posts
log=run.log

#check & move
for x in $org $posts; do
	if ! [ -d $x ]; then
		echo "error dir ${x} not exist" && exit -1
	fi
done

echo "commit info" > $log 
for x in $org/*.html; do
	if ! [ -f $x ]; then continue; fi
	#check name
	nu=`echo $x | grep -P "(\d{4})-(\d{2})-(\d{2})-.*" | wc -l`
	if [ $nu -ne 1 ]; then
		echo "file name ${x} is illegal" && exit -1
	fi
	name=`basename $x`
	#check if in _posts, modify or new create
	if ! [ -f $posts/$name ]; then
		echo "add new file $x" >> $log
	else
		echo "modify file $x" >> $log 
	fi
	#correct img export
	sed -i "s:file\://::" $x
	#add jekyll header
	org_file=`echo $x | sed -e "s:html:org:"`
	title=`grep -i -P '#\+title' $org_file | awk '{print $2}'`
	echo "---" > $posts/$name
	echo "title: ${title}" >> $posts/$name
	echo "---" >> $posts/$name
	cat $x >> $posts/$name
	#rm tmp html file
	rm $x 
done	

#log info, emacs vc test
info=`cat $log`
echo $info
#git add && commit && push
git add org/*.org _posts/*
git commit -am "${info}" 
git push origin master
