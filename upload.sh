#自动检测并上传包，检测和测试结果需要单独加
#$1为脚本运行的一些必须信息   1.开发者账号     2.账号密码   ***注意顺序这2个信息的顺序***

numberOfLines=$(sed -n '$=' $2) #获取行数
if [ $numberOfLines -ne 2 ]; then
    echo "*****缺乏导出必要信息*****"
    exit
fi

ipaPath=$1
account=`sed -n 1p $2`
password=`sed -n 2p $2`
flagStr="success-message"

altoolPath="/Applications/Xcode.app/Contents/Applications/Application Loader.app/Contents/Frameworks/ITunesSoftwareService.framework/Versions/A/Support/altool"

echo "*****检测中*****"
"${altoolPath}" --validate-app -f $ipaPath -u $account -p $password -t ios --output-format xml  > ./check.txt

opreationResult=`cat ./check.txt | grep $flagStr`
if [[ "$opreationResult" != "" ]]; then
    echo "检测成功!"
else
    echo "检测失败"
    exit
fi

echo "*****上传中*****"
"${altoolPath}" --upload-app -f $ipaPath -u $account -p $password -t ios --output-format xml    > ./upload.txt

opreationResult=`cat ./upload.txt | grep $flagStr`
if [[ "$opreationResult" != "" ]]; then
    echo "上传成功!"
else
    echo "上传失败"
    exit
fi
