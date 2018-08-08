#自动打包导出脚本，仅适用于XCode9,且工程后缀名为xcodeproj(非cocopods项目)
#$1 配置文件路径。配置文件中都包含:
#1. 工程路径
#2. xxx.plist文件路径
#3. 账号信息配置文件路径
#4. AdHocExportOptionsPlist.plist Path
#5. AppStoreExportOptionsPlist.plist Path
#6. IPA存放目录文件夹
#7. archivePath
#8. adhoc export path
#9. appsotre export path
#10. TeamID
#11. scheme
#***注意顺序这11个信息的顺序***

numberOfLines=$(sed -n '$=' $1) #获取行数
if [ $numberOfLines -ne 11 ]; then
    echo "*****缺乏导出必要信息*****"
    exit
fi

date=`date +%Y%m%d_%H%M%S`
projectPath=`sed -n 1p $1` #工程路径 带后缀的xxx/xxx.xcodeproj
plistPath=`sed -n 2p $1`
accountInfoFilePath=`sed -n 3p $1`
adhocExportPlistPath=`sed -n 4p $1`
appStoreExportPlistPath=`sed -n 5p $1`
dirPath=`sed -n 6p $1`
archivePath=`sed -n 7p $1`   #带后缀的xxx/xxx.xcarchive
adhocExportPath=`sed -n 8p $1`
appStoreExportPath=`sed -n 9p $1`
teamID=`sed -n 10p $1`
scheme=`sed -n 11p $1`
flagStr="SUCCEEDED"


#获取版本号 $1 = /xx/xx/xx/xx/xxx.plist
lineNumber=`grep -n "CFBundleVersion" $plistPath | cut -d  ":"  -f  1`
lineNumber=$[lineNumber+1]
versionStr=`sed -n ${lineNumber}p $plistPath`

startStr="<string>"
startLen=${#startStr}
startIndex=${versionStr/${startStr}*/}

endStr="</string>"
endLen=${#endStr}
endIndex=${versionStr/${endStr}*/}

startIndex=$[${#startIndex}+${startLen}]
endIndex=${#endIndex}

if [ $startIndex -gt ${#versionStr} ] ||  [ $endIndex  -gt ${#versionStr} ]; then
    versionStr="1.1.1.1010101010"
else
    versionStr=${versionStr:${startIndex}:$[endIndex-startIndex]}
fi

#为每个新的工程创建单独的文件夹存放ipa包
if [ ! -d $dirPath ]; then
mkdir $dirPath
fi

echo "*****正在清理缓存*****"
xcodebuild clean -project $projectPath -configuration Release -alltargets  >  ./clean.txt

opreationResult=`cat ./clean.txt | grep $flagStr`
if [[ "$opreationResult" != "" ]]; then
    echo "${opreationResult}"
else
    echo "清理失败"
    exit
fi

echo "*****正在打包*****"
xcodebuild -project $projectPath \
-scheme $scheme \
-configuration Release \
ONLY_ACTIVE_ARCH=NO \
CODE_SIGN_IDENTITY="iPhone Developer" \
CODE_SIGN_STYLE="Automatic" \
PROVISIONING_STYLE="Automatic" \
DEVELOPMENT_TEAM=$teamID \
-archivePath "${dirPath}/${versionStr}_${archivePath}" \
archive  >  ./archive.txt

opreationResult=`cat ./archive.txt | grep $flagStr`
if [[ "$opreationResult" != "" ]]; then
    echo "${opreationResult}"
else
    echo "打包失败"
    exit
fi

echo "*****正在导出Adhoc包*****"
xcodebuild -exportArchive -archivePath  "${dirPath}/${versionStr}_${archivePath}" \
-exportOptionsPlist $adhocExportPlistPath \
-exportPath "${adhocExportPath}_${versionStr}" >  ./exportAdhoc.txt

opreationResult=`cat ./exportAdhoc.txt | grep $flagStr`
if [[ "$opreationResult" != "" ]]; then
    echo "${opreationResult}"
else
    echo "导出Adhoc失败"
    exit
fi


echo "*****正在导出Release包*****"
xcodebuild -exportArchive -archivePath  "${dirPath}/${versionStr}_${archivePath}" \
-exportOptionsPlist $appStoreExportPlistPath \
-exportPath "${appStoreExportPath}_${versionStr}" >  ./exportRelease.txt

opreationResult=`cat ./exportRelease.txt | grep $flagStr`
if [[ "$opreationResult" != "" ]]; then
    echo "${opreationResult}"
else
    echo "导出Release失败"
    exit
fi


releaseIpaPath="${appStoreExportPath}_${versionStr}/${scheme}.ipa"
if [ ! -f "$releaseIpaPath" ];  then
    echo "********************"
    echo "**                **"
    echo "**     打包失败     **"
    echo "**                **"
    echo "********************"
    exit
fi

./upload.sh $releaseIpaPath  $accountInfoFilePath
