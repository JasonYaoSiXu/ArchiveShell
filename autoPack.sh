#自动打包导出脚本，仅适用于XCode9,且工程后缀名为xcodeproj(非cocopods项目)
#$1 配置文件路径。配置文件中都包含:1、工程路径    2、TeamID   3、archivePath    4、AdHocExportOptionsPlist.plist Path  5、adhoc export path  6、AppStoreExportOptionsPlist.plist Path    7、appsotre export path   8、scheme   9、账号信息配置文件路径 ***注意顺序这9个信息的顺序***

numberOfLines=$(sed -n '$=' $1) #获取行数
if [ $numberOfLines -ne 9 ]; then
    echo "*****缺乏导出必要信息*****"
    exit
fi

date=`date +%Y%m%d_%H%M%S`
projectPath=`sed -n 1p $1` #工程路径 带后缀的xxx/xxx.xcodeproj
teamID=`sed -n 2p $1`
archivePath=`sed -n 3p $1`   #带后缀的xxx/xxx.xcarchive
adhocExportPlistPath=`sed -n 4p $1`
adhocExportPath=`sed -n 5p $1`
appStoreExportPlistPath=`sed -n 6p $1`
appStoreExportPath=`sed -n 7p $1`
scheme=`sed -n 8p $1`
accountInfoFilePath=`sed -n 9p $1`
flagStr="SUCCEEDED"

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
-archivePath $archivePath \
archive  >  ./archive.txt

opreationResult=`cat ./archive.txt | grep $flagStr`
if [[ "$opreationResult" != "" ]]; then
    echo "${opreationResult}"
else
    echo "打包失败"
    exit
fi

echo "*****正在导出Adhoc包*****"
xcodebuild -exportArchive -archivePath  $archivePath \
-exportOptionsPlist $adhocExportPlistPath \
-exportPath "${adhocExportPath}" >  ./exportAdhoc.txt

opreationResult=`cat ./exportAdhoc.txt | grep $flagStr`
if [[ "$opreationResult" != "" ]]; then
    echo "${opreationResult}"
else
    echo "导出Adhoc失败"
    exit
fi


echo "*****正在导出Release包*****"
xcodebuild -exportArchive -archivePath  $archivePath \
-exportOptionsPlist $appStoreExportPlistPath \
-exportPath "${appStoreExportPath}" >  ./exportRelease.txt

opreationResult=`cat ./exportRelease.txt | grep $flagStr`
if [[ "$opreationResult" != "" ]]; then
    echo "${opreationResult}"
else
    echo "导出Release失败"
    exit
fi


releaseIpaPath="${appStoreExportPath}/${scheme}.ipa"
if [ ! -f "$releaseIpaPath" ];  then
    echo "********************"
    echo "**                **"
    echo "**     打包失败     **"
    echo "**                **"
    echo "********************"
    exit
fi

./upload.sh $releaseIpaPath  $accountInfoFilePath
