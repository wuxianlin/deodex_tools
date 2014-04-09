@echo off
::
:: deodex tools for mt6592
:: Script created by wuxianlin
:: Version : 1.0
:: File    : deodex.bat
:: Usage   : 1. put app and framework folder into system folder(system\app\*.apk,*.odex;system\framework\*.jar,*.odex)
::           2. start by double click deodex.bat
title deodex tools
color 0a
echo.+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
echo.I                                                                             I
echo.I                           MT6592 deodex工具箱                               I
echo.I                                                    Made by  wuxianlin       I
echo.+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
echo.                                                         
if not exist system\app (
echo.错误：没有发现system\app目录
pause
exit )
if not exist system\framework (
echo.错误：没有发现system\framework目录
pause
exit )
if not exist tools (
echo.错误：工具箱不完整,tools目录不可删除
pause
exit )
echo.创建Android框架备份....
if exist system\temp_framework rd /q /s system\temp_framework
mkdir system\temp_framework
xcopy system\framework system\temp_framework /E/Q >nul
echo.
echo.Android框架备份完成
echo.
echo.开始合并framework目录...
for %%i in (baksmali.jar smali.jar 7z.exe 7z.dll) do copy tools\%%i system\framework\ >nul
for /r system\framework\ %%a in (*.odex) do call :deodex %%a jar
echo.合并framework目录完成
for %%i in (baksmali.jar smali.jar 7z.exe 7z.dll) do del /f system\framework\%%i 
echo.
echo.开始合并app目录...
for %%i in (baksmali.jar smali.jar 7z.exe 7z.dll) do copy tools\%%i system\app\ >nul
for /r system\app\ %%a in (*.odex) do call :deodex %%a apk
echo.合并app目录完成
for %%i in (baksmali.jar smali.jar 7z.exe 7z.dll) do del /f system\app\%%i 
echo. 
echo 删除Android框架备份....
rd /q /s system\temp_framework
echo.
echo. 
echo.任务全部结束！
pause
goto :eof
:deodex
if %2 equ jar (
cd system\framework
) else if %2 equ apk (
cd system\app
) else (
echo.错误
pause
exit
)
echo.---- 开始合并%~n1.%2 ----
echo.正在将 %~n1.odex 转化为 classes.dex ...
java -jar baksmali.jar -a 17 -T ../../tools/inline.txt -d ../temp_framework -x %1
java -jar smali.jar -a 17 out -o classes.dex
del %1 /Q
rd out /Q /S
echo.正在将 %~n1.%2 与 classes.dex 合并...
7z.exe a -tzip %~n1.%2 classes.dex>nul
del classes.dex /Q
cd ..\..\
echo.---- 合并%~n1.%2成功 ----
echo.
goto :eof