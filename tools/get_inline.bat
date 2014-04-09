@echo off
::
:: deodex tools for mt6592
:: Script created by wuxianlin
:: Version : 1.0
:: File    : get_inline.bat
:: Usage   : 1. co
::           2. start by double click get_inline.bat
title deodex tools
color 0a
echo.+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
echo.I                                                                             I
echo.I                           MT6592 deodex工具箱                               I
echo.I                                                                             I
echo.+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
echo.
for /f %%i in ('dir /b *.txt') do ( ren %%i bak_%%i )
echo.启动adb调试
echo.
adb\adb kill-server
adb\adb start-server
echo.
echo.正在等待手机连接
adb\adb wait-for-device
echo.
echo.正在推送文件
adb\adb push deodexerant /data/local/tmp/
adb\adb shell chmod 755 /data/local/tmp/deodexerant
echo.
echo.正在提取inline.txt
adb\adb shell /data/local/tmp/deodexerant > inline.txt
echo.
echo.完成
pause
