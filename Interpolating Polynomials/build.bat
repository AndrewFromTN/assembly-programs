@echo off
cls

set EXE_NAME=interpolate_driver
del %EXE_NAME%.exe
del %EXE_NAME%.obj
del %EXE_NAME%.lst
del %EXE_NAME%.ilk
del %EXE_NAME%.pdb

set DRIVE_LETTER=%1:
set PATH=%DRIVE_LETTER%\Assembly\bin;c:\Windows
set INCLUDE=%DRIVE_LETTER%\Assembly\include
set LIB_DIRS=%DRIVE_LETTER%\Assembly\lib
set LIBS=sqrt.obj compare_floats.obj atofproc.obj ftoaproc.obj

ml -Zi -c -coff -Fl compute_bs.asm
ml -Zi -c -coff -Fl interpolate.asm
ml -Zi -c -coff -Fl interpolate_driver.asm
link /libpath:%LIB_DIRS% interpolate_driver.obj interpolate_sort.obj interpolate.obj compute_bs.obj %LIBS% io.obj kernel32.lib /debug /out:%EXE_NAME%.exe /subsystem:console /entry:start
%EXE_NAME% <points.txt
