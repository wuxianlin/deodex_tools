#!/bin/bash

APP=$1
FRAMWORK=$2
APILEVEL=$3
BOOTCLASSPATH=$4
BAKFRAMWORK=temp_framework

PRGDIR=`dirname "$0"`
TOOL_PATH=$PRGDIR/tools
SMALI=$TOOL_PATH/smali
BAKSMALI=$TOOL_PATH/baksmali

if [ -z "$APP" -o ! -d "$APP" -o -z "$FRAMWORK" -o ! -d "$FRAMWORK" ] 
then
	echo "请指定 app 和 framework 路径！"
	exit 0
fi

function deodex_file
{
        FILE=$1; TOFILE=${FILE%.*}.$2
        
        echo "将 $FILE 生成 smali 文件到 out 目录下"
        if [ -z "$APILEVEL" ]
        then
                $BAKSMALI -d $BAKFRAMWORK -c $BOOTCLASSPATH -x $FILE || exit -1
        else
                $BAKSMALI -a $APILEVEL -d $BAKFRAMWORK -c $BOOTCLASSPATH -x $FILE || exit -2
        fi
        
        echo "将 out 生成 classes.dex 文件 classes.dex"
        #dex=$out/classes.dex
        $SMALI out -o classes.dex || exit -3
        
        echo "将 classes.dex 添加到对应的 $TOFILE 中"
        jar uf $TOFILE classes.dex 
        
        echo "清理生成的 out 和 classes.dex"
        rm -r out classes.dex $FILE

        #echo "优化 ..."
        #zipalign 4 $TOFILE $TOFILE.aligned
        #mv $TOFILE.aligned $TOFILE
}

echo "清理残余文件 ..."
rm -rf classes.dex out $BAKFRAMWORK

echo "备份 Android 框架 ..."
echo " "
cp -r $FRAMWORK $BAKFRAMWORK

ls $FRAMWORK/core.odex > /dev/null
if [ $? -eq 0 ] 
then
	echo "---- 开始合并core.jar ----"
	deodex_file $FRAMEWORK/core.odex jar
	echo "---- 合并core.jar成功 ----"
	echo " "
fi

if [ -z "$BOOTCLASSPATH" ]
then
	for f in $FRAMEWORK/*.jar
	do
	    BOOTCLASSPATH=$BOOTCLASSPATH:$f
	done

	echo "BOOTCLASSPATH=$BOOTCLASSPATH"
fi

ls $FRAMWORK/*.odex > /dev/null
if [ $? -eq 0 ]
then
	echo "合并$FRAMWORK ..."
	echo " "
	for file in `ls $FRAMWORK/*.odex`
	do
		echo "---- 开始合并${file%.*}.jar ----"
	        deodex_file $file jar
		echo "---- 合并${file%.*}.jar成功 ----"
		echo " "
	done
fi

ls app/*.odex > /dev/null
if [ $? -eq 0 ]
then
	echo "合并$APP ..."
	echo " "
	for file in `ls $APP/*.odex`
	do
		echo "---- 开始合并${file%.*}.apk ----"
	        deodex_file $file apk
		echo "---- 合并${file%.*}.apk成功 ----"
		echo " "
	done
fi

echo "删除 Android 框架备份"
rm -rf $BAKFRAMWORK
