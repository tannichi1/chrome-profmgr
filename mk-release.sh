#!/bin/sh -x

top=`dirname $0`
ver=`date "+%Y%m%d"`
echo "top=${top}"
echo "ver=${ver}"


cp -p $top/src/chrome-profmgr.ps1 $top/dist/chrome-profmgr.ps1.src
cp -p $top/src/chrome-profmgr_MakeShotcut.vbs $top/dist/chrome-profmgr_MakeShotcut.vbs.src
cp -p $top/src/pre-inst.bat $top/dist/pre-inst.bat


(
	cd $top/dist;
	zipver="./chrome-profmgr_${ver}-"
	seq=1
	while [ -f "${zipver}${seq}.zip" ] ; do
		seq=`expr $seq + 1`
	done
	zipfile="${zipver}${seq}.zip"
	echo "zipfile=${zipfile}"

	zip -9 "${zipfile}" chrome-profmgr.ps1.src \
		chrome-profmgr_MakeShotcut.vbs.src \
		pre-inst.bat
)
