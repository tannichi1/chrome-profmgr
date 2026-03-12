#!/bin/sh -x

top=`dirname $0`
ver=`date "+%Y%m%d"`
echo "top=${top}"
echo "ver=${ver}"


cp -p $top/src/chrome-profmgr.ps1 $top/dist/chrome-profmgr.ps1
cp -p $top/src/chrome-profmgr_MakeShotcut-Hidden.vbs $top/dist/chrome-profmgr_MakeShotcut-Hidden.vbs
cp -p $top/src/chrome-profmgr_MakeShotcut-Hidden.vbs $top/dist/chrome-profmgr_MakeShotcut.vbs
cp -p $top/src/chrome-profmgr_MakeShotcut-Hidden.vbs $top/dist/chrome-profmgr_MakeShotcut-Hidden-v7.vbs

(
	cd $top/dist;
	zipver="./chrome-profmgr_${ver}-"
	seq=1
	while [ -f "${zipver}${seq}.zip" ] ; do
		seq=`expr $seq + 1`
	done
	zipfile="${zipver}${seq}.zip"
	echo "zipfile=${zipfile}"

	zip -9 "${zipfile}" chrome-profmgr.ps1 \
		chrome-profmgr_MakeShotcut.vbs \
		chrome-profmgr_MakeShotcut-Hidden.vbs	\
		chrome-profmgr_MakeShotcut-Hidden-v7.vbs
)
