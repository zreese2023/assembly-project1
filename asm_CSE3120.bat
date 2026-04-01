@ECHO OFF
rem File: asm_CSE3120.bat
rem Author: Marius Silaghi, 2023
SET IRVINE=C:\Users\msilaghi\Downloads\Irvine\Irvine
SET FILEBASE=%~n1
echo Handling Source: %FILEBASE%
setlocal

rem You may use quotes for the whole parameter
set "PATH=C:\Program Files (x86);...;%PATH%"

rem Or you should use quotes only for special
rem characters. Avoid final undesired spaces...
set PATH=C:\Program Files\Microsoft Visual Studio\18\Community\VC\Tools\MSVC\14.44.35207\bin\HostX86\x86;C:\Program Files (x86)\Windows Kits\10\bin\10.0.26100.0\x86;C:\Program Files\Microsoft Visual Studio\18\Community\Common7\tools;C:\Program Files\Microsoft Visual Studio\18\Community\Common7\ide;C:\Program Files (x86)\HTML Help Workshop;;C:\Program Files\Microsoft Visual Studio\18\Community\MSBuild\Current\Bin;


set LIB=C:\Users\zacha\OneDrive\FIT\Spring 2026\Assembly\Irvine;C:\Program Files\Microsoft Visual Studio\18\Community\VC\Tools\MSVC\14.44.35207\lib\x86;;C:\Program Files\Microsoft Visual Studio\18\Community\VC\Tools\MSVC\14.44.35207\atlmfc\lib\x86;;C:\Program Files\Microsoft Visual Studio\18\Community\VC\Auxiliary\VS\lib\x86;;C:\Program Files\Windows Kits\10\lib\10.0.26100.0\ucrt\x86;;;C:\Program Files\Microsoft Visual Studio\18\Community\VC\Auxiliary\VS\UnitTest\lib;C:\Program Files (x86)\Windows Kits\10\lib\10.0.26100.0\um\x86;lib\um\x86;



set LIBPATH=C:\Program Files\Microsoft Visual Studio\18\Community\VC\Tools\MSVC\14.44.35207\atlmfc\lib\x86;;C:\Program Files\Microsoft Visual Studio\18\Community\VC\Tools\MSVC\14.44.35207\lib\x86;



set INCLUDE=C:\Users\zacha\OneDrive\FIT\Spring 2026\Assembly\Irvine;C:\Program Files\Microsoft Visual Studio\18\Community\VC\Tools\MSVC\14.44.35207\include;;C:\Program Files\Microsoft Visual Studio\18\Community\VC\Tools\MSVC\14.44.35207\atlmfc\include;;C:\Program Files\Microsoft Visual Studio\18\Community\VC\Auxiliary\VS\include;;C:\Program Files\Windows Kits\10\Include\10.0.26100.0\ucrt;;;C:\Program Files\Microsoft Visual Studio\18\Community\VC\Auxiliary\VS\UnitTest\include;C:\Program Files (x86)\Windows Kits\10\Include\10.0.26100.0\um;C:\Program Files (x86)\Windows Kits\10\Include\10.0.26100.0\shared;C:\Program Files (x86)\Windows Kits\10\Include\10.0.26100.0\winrt;C:\Program Files (x86)\Windows Kits\10\Include\10.0.26100.0\cppwinrt;Include\um;


rem EXTERNAL_INCLUDE=C:\Program Files\Microsoft Visual Studio\18\Community\VC\Tools\MSVC\14.44.35207\include;;C:\Program Files\Microsoft Visual Studio\18\Community\VC\Tools\MSVC\14.44.35207\atlmfc\include;;C:\Program Files\Microsoft Visual Studio\18\Community\VC\Auxiliary\VS\include;;C:\Program Files\Windows Kits\10\Include\10.0.26100.0\ucrt;;;C:\Program Files\Microsoft Visual Studio\18\Community\VC\Auxiliary\VS\UnitTest\include;C:\Program Files (x86)\Windows Kits\10\Include\10.0.26100.0\um;C:\Program Files (x86)\Windows Kits\10\Include\10.0.26100.0\shared;C:\Program Files (x86)\Windows Kits\10\Include\10.0.26100.0\winrt;C:\Program Files (x86)\Windows Kits\10\Include\10.0.26100.0\cppwinrt;Include\um;


rem ml.exe /c /nologo /Sg /Zi /Fo"%FILEBASE%.obj"\
rem /Fl"%FILEBASE%.lst" /I "%IRVINE%" /W3 \
rem /errorReport:prompt /Ta%FILEBASE%.asm

FOR %%F IN (%*) DO (
echo Handling %%~nF
ml.exe /c /nologo /Sg /Zi /Fo"%%~nF.obj" /Fl"%%~nF.lst" /I "%IRVINE%" /W3 /errorReport:prompt /Ta%%~nF.asm
)

link.exe /ERRORREPORT:PROMPT /OUT:"%FILEBASE%.exe" /NOLOGO /LIBPATH:%IRVINE% user32.lib irvine32.lib kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /MANIFEST /MANIFESTUAC:"level='asInvoker' uiAccess='false'" /manifest:embed /SUBSYSTEM:CONSOLE /TLBID:1 /DYNAMICBASE:NO /MACHINE:X86 /SAFESEH:NO %FILEBASE%.obj

endlocal

