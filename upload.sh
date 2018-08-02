altoolPath="/Applications/Xcode.app/Contents/Applications/Application Loader.app/Contents/Frameworks/ITunesSoftwareService.framework/Versions/A/Support/altool"
echo "*****检测中*****"
"${altoolPath}" --validate-app -f xxxx -u xxxx -p xxxx -t ios --output-format xml
echo "*****上传中*****"
"${altoolPath}" --upload-app -f xxxx -u xxxx -p xxxx -t ios --output-format xml
