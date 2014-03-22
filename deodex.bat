@echo off
::
:: deodex tools for Android rom
:: Script created by wuxianlin
:: Version : 1.0
:: File    : deodex.bat
:: Usage   : 1. put app and framework folder into system folder(system\app\*.apk,*.odex;system\framework\*.jar,*.odex)
::           2. deodex.bat [apilevel] [bootclasspath]
title deodex tools
color 0a
set apilevel=%1
set bootclasspatch=%2

set home=%cd%
set app=%home%\system\app
set framework=%home%\system\framework
set temp_framework=%home%\system\temp_framework

setlocal EnableDelayedExpansion
if "%2"=="" for /r %framework% %%a in (*.jar) do set bootclasspatch=!bootclasspatch!:%%~nxa
if "%bootclasspatch:~0,1%"==":" set bootclasspatch=%bootclasspatch:~1%
endlocal

echo.
echo.创建Android框架备份....
if exist %temp_framework% rd /q /s %temp_framework%
mkdir %temp_framework%
xcopy %framework% %temp_framework% /E/Q >nul
echo.
echo.Android框架备份完成
echo.
echo.开始合并framework目录...
for %%i in (baksmali.jar smali.jar 7z.exe 7z.dll) do copy tools\%%i %framework% >nul
for /r %framework% %%a in (*.odex) do call :deodex %%a jar
echo.合并framework目录完成
for %%i in (baksmali.jar smali.jar 7z.exe 7z.dll) do del /f %framework%\%%i 
echo.
echo.开始合并app目录...
for %%i in (baksmali.jar smali.jar 7z.exe 7z.dll) do copy tools\%%i %app% >nul
for /r %app% %%a in (*.odex) do call :deodex %%a apk
echo.合并app目录完成
for %%i in (baksmali.jar smali.jar 7z.exe 7z.dll) do del /f %app%\%%i 
echo. 
echo 删除Android框架备份....
rd /q /s %temp_framework%
echo.
echo. 
echo.deodex完成！
pause
goto :eof
:deodex
if %2 equ jar (
cd %framework%
) else if %2 equ apk (
cd %app%
) else (
echo.错误
pause
exit
)
echo.---- 开始合并%~n1.%2 ----
echo.正在将 %~n1.odex 转化为 classes.dex ...
if "%apilevel%"=="" (
java -jar baksmali.jar -d %temp_framework% -c %bootclasspatch% -x %1
java -jar smali.jar out -o classes.dex
) else (
java -jar baksmali.jar -a %apilevel% -d %temp_framework% -x %1
java -jar smali.jar -a %apilevel% out -o classes.dex
)
del %1 /Q
rd out /Q /S
echo.正在将 %~n1.%2 与 classes.dex 合并...
7z.exe a -tzip %~n1.%2 classes.dex>nul
del classes.dex /Q
cd ..\..\
echo.---- 合并%~n1.%2成功 ----
echo.
goto :eof