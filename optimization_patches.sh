#!/bin/sh

export SOURCE_PATH=/home/awaysu/aosp/
export PATCH_TOP_PATH=/home/awaysu/aosp/patch

#======================================================================================
export PWD_PATH=`pwd`
export NEWPATCH_PATH=$PWD_PATH"/do_copy_folder/"
export NEWPATCH_CREATE_FOLDER=$NEWPATCH_PATH"/NEW_PATCHES/"
export OLDPATCH_CREATE_FOLDER=$NEWPATCH_PATH"/OLD_PATCHES/"
export RUN_SH="./.run.sh"

function init()
{
	rm -Rf $NEWPATCH_PATH
	mkdir -p $NEWPATCH_CREATE_FOLDER $OLDPATCH_CREATE_FOLDER
}

function copy_patch_folder()
{
	cp -a $PATCH_TOP_PATH/* $OLDPATCH_CREATE_FOLDER

	for FILE_LIST in `find $PATCH_TOP_PATH -name "*.patch" | sort`
	do
	   echo "-------------------------------------------"
		echo "Copy file from => "$FILE_LIST
		PATCH_FILE=`cat $FILE_LIST | grep "diff " | cut -d" " -f 3`

		for NEW_FILE_LIST in $PATCH_FILE
		do
			NEW_FILE=$SOURCE_PATH/$NEW_FILE_LIST
			echo SOURCE_NEW_FILE=`echo $NEW_FILE | sed -r "s/\/a\//\//g; s/\/source\//\//g"`
			SOURCE_NEW_FILE=`echo $NEW_FILE | sed -r "s/\/a\//\//g; s/\/source\//\//g"`
			DEST_NEW_FILE=$NEWPATCH_PATH/$NEW_FILE_LIST
			DIR_NAME=`dirname $DEST_NEW_FILE`
			#echo "-------------------------------------------"

			if [ ! -d $DIR_NAME ]; then
				echo "  mkdir -p "$DIR_NAME
				mkdir -p $DIR_NAME
			fi
			echo "cp ["$SOURCE_NEW_FILE"] ["$DEST_NEW_FILE"]"
			cp $SOURCE_NEW_FILE $DEST_NEW_FILE -a
		done
	done
	
	
	NEWPATCH_PATH_A=${NEWPATCH_PATH}"/a/*"
	NEWPATCH_PATH_S=${NEWPATCH_PATH}"/source/"

	echo cp -a $NEWPATCH_PATH_A $NEWPATCH_PATH_S
	cp -a $NEWPATCH_PATH_A $NEWPATCH_PATH_S
	rm -Rf $NEWPATCH_PATH/a
	
	echo "================================================================="
}

function create_patch_script()
{
	LAST_B_PATH=""
	echo "" > $RUN_SH
	
	for FILE_LIST in `find $PATCH_TOP_PATH -name "*.patch" | sort`
	do
		NOW_PATCH_FILE="$FILE_LIST"
		CMD="patch -p1 < $NOW_PATCH_FILE"
		
		BASE_NAME=$(basename "$NOW_PATCH_FILE" .patch)
		NEWPATCH_SOURCE="$NEWPATCH_PATH/source/"
		NEWPATCH_PATH_A="$NEWPATCH_PATH/$BASE_NAME/a"
		NEWPATCH_PATH_B="$NEWPATCH_PATH/$BASE_NAME/b"
		
		echo "echo =====================================================================================" >> $RUN_SH
		#echo "echo [$BASE_NAME] : " >> $RUN_SH

		echo mkdir -p $NEWPATCH_PATH_A $NEWPATCH_PATH_B >> $RUN_SH
		
		if [ "$LAST_B_PATH" == "" ]; then
			echo cp -a $NEWPATCH_SOURCE/* $NEWPATCH_PATH_A >> $RUN_SH
			echo cp -a $NEWPATCH_SOURCE/* $NEWPATCH_PATH_B >> $RUN_SH
		else	
			echo cp -a $LAST_B_PATH/* $NEWPATCH_PATH_A >> $RUN_SH
			echo cp -a $LAST_B_PATH/* $NEWPATCH_PATH_B >> $RUN_SH
		fi

		echo cd $NEWPATCH_PATH_B >> $RUN_SH
		echo $CMD >> $RUN_SH
		
		echo "find $NEWPATCH_PATH_B -type f -name "*.orig" -exec rm -f {} +" >> $RUN_SH
		echo "find $NEWPATCH_PATH_B -type f -name "*.rej" -exec rm -f {} +" >> $RUN_SH
		echo "cd .." >> $RUN_SH
		echo "echo \"Create new patch => \"$NEWPATCH_CREATE_FOLDER/$BASE_NAME.patch" >> $RUN_SH
		echo "diff -Naur a b > $NEWPATCH_CREATE_FOLDER/$BASE_NAME.patch" >> $RUN_SH
		
		LAST_B_PATH=$NEWPATCH_PATH_B
	done	
	chmod 777 $RUN_SH
}

function run_script()
{
	sh $RUN_SH
	echo "echo =====================================================================================" >> $RUN_SH
	ls $NEWPATCH_CREATE_FOLDER -al
	echo 
	echo "Old patch path => $OLDPATCH_CREATE_FOLDER"
	echo "New patch path => $NEWPATCH_CREATE_FOLDER"
	echo 
	rm -Rf $RUN_SH
}

init
copy_patch_folder
create_patch_script
run_script
