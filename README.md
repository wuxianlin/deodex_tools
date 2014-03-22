deodex tools on linux by wuxianlin
==================

工具说明：
------------------
1.本工具适用于在安装有Android SDK和Java SDK的linux环境下对一般的Android设备的/system/app和/system/framework下的*.odex合并到对应的apk或jar中

2.本脚本由[wuxianlin](http://weibo.com/wuxianlin000000)个人制作，其中有参考github上朋友开源的资料，有什么意见或建议欢迎联系[wuxianlinwxl@gmail.com](malito:wuxianlinwxl@gmail.com)

使用方法：
----------
1.连接手机，提取/system/app和/system/framework,也可以直接解压官方包得到app和framework

     adb device
     adb pull /system/app app
     adb pull /system/framework framework

2.使用脚本合并

     ./deodex.sh app_path framework_path [apilevel] [bootclasspath]

注意事项：
-------
1.[apilevel] [bootclasspath]为可选参数

     adb shell
     getprop ro.build.version.sdk (获取apilevel)
     echo $BOOTCLASSPATH (获取bootclasspath)

2.tools目录下的baksmali.jar和smali.jar可以自行更换最新版本

感谢：
-------
感谢smali开源项目
感谢github上众多朋友的开源代码
