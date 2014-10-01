@echo off
::
:: deodex tools for Android rom
:: Script created by wuxianlin
:: Version : 1.1
:: File    : deodex.bat
:: Usage   : 1. put app , priv-app(if exist) and framework folder into system folder(system\app\*.apk,*.odex;system\priv-app\*.apk,*.odex;system\framework\*.jar,*.odex)
::           2. deodex.bat [apilevel] [bootclasspath]
title deodex tools
color 0a
setlocal EnableDelayedExpansion
echo.+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
echo.I                                                                             I
echo.I                            Android  deodex工具箱                            I
echo.I                                                    Made by  wuxianlin       I
echo.+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
echo.       
set apilevel=%1
set bootclasspatch=%2

set home=%cd%
set system=%home%\system
set app=%system%\app
set priv-app=%system%\priv-app
set framework=%system%\framework
set temp_framework=%system%\temp_framework
set tools=%home%\tools

if not exist %framework% (
echo.错误：没有发现system\framework目录
pause
exit )
if not exist %tools% (
echo.错误：工具箱不完整,tools目录不可删除
pause
exit )

if "%1"=="" echo.apilevel未手动赋值 && call :getapilevel
echo.apilevel=%apilevel%

if "%2"=="" echo.bootclasspatch未手动赋值 && call :getbootclasspatch
echo.bootclasspatch=%bootclasspatch%

echo.
echo.创建Android框架备份....
echo.
if exist %temp_framework% rd /q /s %temp_framework%
mkdir %temp_framework%
xcopy %framework% %temp_framework% /E/Q >nul
echo.Android框架备份完成
echo.

for %%i in (%framework% %app% %priv-app%) do call :defolder %%i

echo 删除Android框架备份....
echo.
rd /q /s %temp_framework%
echo.deodex完成！
echo.
pause
goto :eof

:defolder
if not exist %1 (
echo.未发现%~n1目录
echo.
goto :eof
)
echo.开始合并%~n1目录...
for %%i in (baksmali.jar smali.jar 7z.exe 7z.dll) do copy tools\%%i %1 >nul
cd %1
if "%~n1"=="framework" (
for /r %1 %%a in (*.odex) do call :deodex %%a jar
) else (
for /r %1 %%a in (*.odex) do call :deodex %%a apk
)
cd %home%
echo.合并%~n1目录完成
echo.
for %%i in (baksmali.jar smali.jar 7z.exe 7z.dll) do del /f %1\%%i 
goto :eof

:deodex
echo.---- 开始合并%~n1.%2 ----
call :checkdex %~n1.%2
if %errorlevel%==1 echo.无需合并%~n1.%2 &&echo.---- 合并%~n1.%2成功 ---- && echo. && del /q/f %1 && goto :eof
echo.正在将 %~n1.odex 转化为 classes.dex ...
if "%apilevel%"=="" (
java -jar baksmali.jar -T %tools%/inline.txt -d %temp_framework% -c %bootclasspatch% -x %1
java -jar smali.jar out -o classes.dex
) else (
java -jar baksmali.jar -a %apilevel% -T %tools%/inline.txt -d %temp_framework% -x %1
java -jar smali.jar -a %apilevel% out -o classes.dex
)
del %1 /Q
rd out /Q /S
echo.正在将 %~n1.%2 与 classes.dex 合并...
7z.exe a -tzip %~n1.%2 classes.dex>nul
del classes.dex /Q
echo.---- 合并%~n1.%2成功 ----
echo.
goto :eof

:checkdex
::7z.exe l %1 > %system%\test
%tools%\aapt.exe l %1 > %system%\test
findstr "classes.dex" "%system%\test">nul && echo.%1已经存在classes.dex && set retVal=1 || set retVal=0
del /q/f %system%\test
exit /b %retVal%

:getapilevel
if not exist %framework%\framework-res.apk echo.不存在framework-res.apk && goto :eof
%tools%\aapt.exe d badging %framework%\framework-res.apk > %system%\systeminfo.txt
echo.尝试自动获取apilevel
for /f "tokens=1,2 delims='" %%a in (%system%\systeminfo.txt) do (if "%%a"=="targetSdkVersion:" set apilevel=%%b)
if not %apilevel%=="" del /q/f %system%\systeminfo.txt && goto :eof
echo.重新自动获取apilevel
for /f "tokens=1,2 delims='" %%a in (%system%\systeminfo.txt) do (if "%%a"=="sdkVersion:" set apilevel=%%b)
if not %apilevel%=="" del /q/f %system%\systeminfo.txt && goto :eof
echo.重新自动获取apilevel
for /f "tokens=3,4 delims='" %%a in (%system%\systeminfo.txt) do (if "%%a"==" versionCode=" set apilevel=%%b)
::echo.apilevel=%apilevel%
del /q/f %system%\systeminfo.txt && goto :eof

:getbootclasspatch
echo.尝试自动获取bootclasspatch
for /r %framework% %%a in (*.jar) do set bootclasspatch=!bootclasspatch!:%%~nxa
if "%bootclasspatch:~0,1%"==":" set bootclasspatch=%bootclasspatch:~1%
::echo.bootclasspatch=%bootclasspatch%
goto :eof

endlocal
