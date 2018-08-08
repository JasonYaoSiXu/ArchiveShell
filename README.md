IOS 自动打包并上传脚本(最好是能在执行脚本时将脚本看一遍，里面重要的部分都有注释)
1、autoPack.sh 运行时需要传一个配置文件路径如下:
    ./autoPack.sh  /xxx/xxx/xxx/xxx/xxx.txt
2、该配置文件中需要包含11个参数,11个参数分别为:
    1)工程路径
    2)xxx.plist文件路径
    3)账号信息配置文件路径
    4)AdHocExportOptionsPlist.plist Path
    5)AppStoreExportOptionsPlist.plist Path
    6)IPA存放目录文件夹
    7)archive名称
    8)adhoc export path
    9)appsotre export path
    10)TeamID
    11)scheme

3、autoPack.sh执行完成后会自动执行upload.sh， 也可以单独执行upload.sh脚本，需要传递两个参数如下：
    ./upload.sh   /xxx/xxx/xxx/xxx.ipa    xxx/xxx/xxx.txt
