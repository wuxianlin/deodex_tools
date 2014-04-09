deodex tools for mt6592
===========

说明
----------------

此处开源wuxianlin全部关于mt6592 deodex的工具


使用方法介绍
----------------
1.获取你要合并的ROM的/system/app和/system/framework目录，复制到工具箱/system目录下

2.双击deoedx.bat即可开始合并，合并完成后替换原来ROM的app和framework目录刷机测试

3.若正常开机则deodex完成

合并过程中报错或者合并后不能开机
--------------------------------
方案一：将tools/备用smali下的两个jar换到tools下

方案二：连接手机，运行get_inline.bat获取你的ROM的inline.txt

方案三：联系我 [wuxianlinwxl@gmail.com](mailto:wuxianlinwxl@gmail.com)


感谢
--------
感谢smali开源项目 [google code](https://code.google.com/p/smali/)     [github](https://github.com/JesusFreke/smali)

