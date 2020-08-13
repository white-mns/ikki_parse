#!/bin/bash

CURENT=`pwd`	#実行ディレクトリの保存
cd `dirname $0`	#解析コードのあるディレクトリで作業をする

#------------------------------------------------------------------
# 更新回数、再更新番号の定義確認、設定

RESULT_NO=$1
GENERATE_NO=$2

if [ -z "$RESULT_NO" ]; then
    exit
fi

if [ -z "$2" ]; then
    GENERATE_NO=0
fi

ZIP_NAME=${RESULT_NO}

#------------------------------------------------------------------
# 圧縮結果ファイルを展開
if [ -f ./data/orig/result${ZIP_NAME}.zip ]; then

    echo "open archive..."
    
    cd ./data/orig

    rm  -rf r
    rm  -rf result
    rm  -rf result${RESULT_NO}
    rm  -rf result${ZIP_NAME}

    unzip -q result${ZIP_NAME}.zip
    if [ -d r ]; then
        mv r  result${ZIP_NAME}
    #elif [ -d result${RESULT_NO} ]; then
    #    mv result${RESULT_NO}  result${ZIP_NAME}
    fi
    
    cp -r  result${ZIP_NAME} ../utf/result${ZIP_NAME}
    echo "rm orig..."
    rm  -rf result${ZIP_NAME}

    cd ../utf/result${ZIP_NAME}/
    nkf -w --overwrite k/*.html
    nkf -w --overwrite br/*.html
    
    cd ../../../
fi

perl ./GetData.pl      $RESULT_NO $GENERATE_NO
perl ./UploadParent.pl $RESULT_NO $GENERATE_NO

# UTFファイルを圧縮
if [ -d ./data/utf/result${ZIP_NAME} ]; then
    
    cd ./data/utf/

    echo "utf zip..."
	zip -qr ./result${ZIP_NAME}.zip ./result${ZIP_NAME}
    echo "rm utf..."
    rm  -rf result${ZIP_NAME}
        
    cd ../../

fi

cd $CURENT  #元のディレクトリに戻る

