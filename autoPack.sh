#自动打包导出脚本，仅适用于XCode9,且工程后缀名为xcodeproj(非cocopods项目)

echo `date +%Y%m%d_%H%M%S`
exit

xcodebuild clean

xcodebuild -project mipci.xcodeproj \
-scheme mipci \
-configuration Release \
ONLY_ACTIVE_ARCH=NO \
CODE_SIGN_IDENTITY="iPhone Developer" \
CODE_SIGN_STYLE="Automatic" \
PROVISIONING_STYLE="Automatic" \
DEVELOPMENT_TEAM="VN4Q3CLHVC" \
-archivePath ~/Desktop/XCodeB/a.xcarchive \
archive

xcodebuild -exportArchive -archivePath  ~/Desktop/XCodeB/a.xcarchive \
-exportOptionsPlist ./AdHocExportOptionsPlist.plist \
-exportPath ~/Desktop/XCodeB/${appName}_Adhoc



xcodebuild -exportArchive -archivePath  ~/Desktop/XCodeB/a.xcarchive \
-exportOptionsPlist ./AdHocExportOptionsPlist.plist \
-exportPath ~/Desktop/XCodeB/${appName}_Release
