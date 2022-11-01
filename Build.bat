call "C:\BDS\Studio\22.0\bin\rsvars.bat"
msbuild.exe "Source\MyShellExtensions.dproj" /target:Clean;Build /p:Platform=Win64 /p:config=release
msbuild.exe "Source\MyShellExtensions32.dproj" /target:Clean;Build /p:Platform=Win32 /p:config=release

:END
pause
