@ECHO OFF

pushd "%~dp0\.."

REM // make sure we can write to the file sonic3k.bin
REM // also make a backup to sonic3k.prev.bin
IF NOT EXIST sonic3k.bin goto LABLNOCOPY
IF EXIST sonic3k.prev.bin del sonic3k.prev.bin
IF EXIST sonic3k.prev.bin goto LABLNOCOPY
move /Y sonic3k.bin sonic3k.prev.bin
IF EXIST sonic3k.bin goto LABLERROR2

:LABLNOCOPY
REM // delete some intermediate assembler output just in case
IF EXIST sonic3k.p del sonic3k.p
IF EXIST sonic3k.p goto LABLERROR1

REM // clear the output window
REM cls

REM // run the assembler
REM // -xx shows the most detailed error output
REM // -q makes AS shut up
REM // -A gives us a small speedup
set AS_MSGPATH=AS\Win32
set USEANSI=n

REM // allow the user to choose to output error messages to file by supplying the -logerrors parameter
"AMPS/Includer.exe" AS AMPS AMPS/.Data
IF "%1"=="-logerrors" ( "AS\Win32\asw.exe" -xx -q -c -D Sonic3_Complete=1 -E -A -L sonic3k.asm ) ELSE "AS\Win32\asw.exe" -xx -q -c -D Sonic3_Complete=1 -A -L sonic3k.asm

REM // if there were errors, a log file is produced
IF "%1"=="-logerrors" ( IF EXIST sonic3k.log goto LABLERROR3 )

REM // combine the assembler output into a rom
IF EXIST sonic3k.p "AS\Win32\s2p2bin" sonic3k.p sonic3k.bin sonic3k.h
"ErrorDebugger/ConvSym.exe" sonic3k.lst sonic3k.bin -input as_lst -a

REM // done -- pause if we seem to have failed, then exit
IF NOT EXIST sonic3k.p goto LABLPAUSE
IF EXIST sonic3k.bin goto LABLEXIT

:LABLPAUSE
pause
goto LABLEXIT

:LABLERROR1
echo Failed to build because write access to sonic3k.p was denied.
pause
goto LABLEXIT

:LABLERROR2
echo Failed to build because write access to sonic3k.bin was denied.
pause
goto LABLEXIT

:LABLERROR3
REM // display a noticeable message
echo.
echo ***************************************************************************
echo *                                                                         *
echo *   There were build errors/warnings. See sonic3k.log for more details.   *
echo *                                                                         *
echo ***************************************************************************
echo.
pause

:LABLEXIT
del AMPS\.Data
popd
exit /b
