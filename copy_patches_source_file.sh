#!/bin/sh

# 這個script主要拷貝patch會用到的檔案
# The script primarily copies the files required by the patch.
# By Awaysu 2024

export SOURCE_PATH=/home/awaysu/aosp/gtv/
export PATCH_TOP_PATH=/home/awaysu/aosp/patch/

#======================================================================================

export PWD_PATH=`pwd`
export NEWPATCH_PATH=$PWD_PATH"/do_copy_folder/"

rm -Rf $NEWPATCH_PATH

for FILE_LIST in `find $PATCH_TOP_PATH -name "*.patch" | sort`
do
    echo "================================================================="
    echo "!!! => "$FILE_LIST
    PATCH_FILE=`cat $FILE_LIST | grep "diff " | cut -d" " -f 3`

    for NEW_FILE_LIST in $PATCH_FILE
    do
        NEW_FILE=$SOURCE_PATH$NEW_FILE_LIST
        # 合并两个替换操作
        SOURCE_NEW_FILE=`echo $NEW_FILE | sed -r "s/\/a\//\//g; s/\/source\//\//g"`
        DEST_NEW_FILE=$NEWPATCH_PATH$NEW_FILE_LIST
        DIR_NAME=`dirname $DEST_NEW_FILE`
        echo "-------------------------------------------"

        if [ ! -d $DIR_NAME ]; then
            echo "  mkdir -p "$DIR_NAME
            mkdir -p $DIR_NAME
        fi
        echo "cp ["$SOURCE_NEW_FILE"] ["$DEST_NEW_FILE"]"
        cp $SOURCE_NEW_FILE $DEST_NEW_FILE -a
    done
done

cp -a $PATCH_TOP_PATH $NEWPATCH_PATH"/a"
