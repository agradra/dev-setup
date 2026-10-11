@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion


set "CONFIG_DIR_NAME=.setup"
set "REPO_DIR_NAME=dev-setup"
set "ARCHIVE_DIR_NAME=_Archive"
set "TEMP_DIR_NAME=_Temp"
set "RESOURCE_DIR_NAME=icons"
set "CONFIG_ICON_NAME=setup.ico"
set "DEV_ICON_NAME=dev.ico"
:: =================================================================

:: ANSI 색상
for /f %%a in ('echo prompt $E^| cmd') do set "ESC=%%a"
set "RST=%ESC%[0m"
set "BOLD=%ESC%[1m"
set "DIM=%ESC%[90m"
set "RED=%ESC%[91m"
set "GRN=%ESC%[92m"
set "YLW=%ESC%[93m"
set "BLU=%ESC%[94m"
set "CYN=%ESC%[96m"

:: 결과 카운터
set /a CNT_CREATED=0, CNT_EXIST=0, CNT_ICON=0, CNT_SKIP=0, CNT_FAIL=0, CNT_ARCH=0, CNT_ARCH_EXIST=0
set "SYS_RESULT_SETUP=%DIM%건너뜀%RST%"
set "SYS_RESULT_DEV=%DIM%건너뜀%RST%"

echo.
echo %CYN%============================================================%RST%
echo %CYN%%RST%  %BOLD%폴더 아이콘 자동 설정 도구%RST%                              %CYN%%RST%
echo %CYN%============================================================%RST%
echo.

for %%I in ("%~dp0.") do set "CUR_DIR=%%~nxI"

:: 깃허브 레포 이름 -> .setup 자동 변경
set "NEED_RENAME=0"
if /i "!CUR_DIR!"=="%REPO_DIR_NAME%" set "NEED_RENAME=1"
if /i "!CUR_DIR!"=="%REPO_DIR_NAME%-main" set "NEED_RENAME=1"
if /i "!CUR_DIR!"=="%REPO_DIR_NAME%-master" set "NEED_RENAME=1"
if !NEED_RENAME! equ 1 (
    pushd "%~dp0.."
    set "PDIR=!CD!"
    popd
    echo %YLW%  [INFO]%RST%   폴더 이름 '!CUR_DIR!' 을^(를^) '%CONFIG_DIR_NAME%' 으로 변경합니다.
    if exist "!PDIR!\%CONFIG_DIR_NAME%\" (
        echo %RED%  [FAIL]%RST%   이미 '%CONFIG_DIR_NAME%' 폴더가 존재하여 이름을 변경할 수 없습니다.
        echo.
        pause
        exit /b
    )
    :: 종료 후 변경 및 재실행하는 임시 스크립트 사용
    set "HELPER=%TEMP%\setup_rename_%RANDOM%.bat"
    > "!HELPER!" echo @echo off
    >> "!HELPER!" echo timeout /t 2 ^>nul
    >> "!HELPER!" echo ren "!PDIR!\!CUR_DIR!" "%CONFIG_DIR_NAME%"
    >> "!HELPER!" echo start "" /d "!PDIR!\%CONFIG_DIR_NAME%" cmd /c RUN.bat
    start "" /d "!PDIR!" cmd /c "!HELPER!"
    echo %DIM%         이름 변경 후 자동으로 다시 실행됩니다.%RST%
    exit /b
)
if /i not "!CUR_DIR!"=="%CONFIG_DIR_NAME%" (
    echo %RED%  [FAIL]%RST%   스크립트가 '%CONFIG_DIR_NAME%' 폴더 안에 있지 않습니다.
    echo %DIM%         현재 위치: !CUR_DIR!%RST%
    echo.
    pause
    exit /b
)

:: 리소스 폴더 존재 여부 확인
if not exist "%~dp0%RESOURCE_DIR_NAME%\" (
    echo %RED%  [FAIL]%RST%   '%CONFIG_DIR_NAME%' 폴더 내에 '%RESOURCE_DIR_NAME%' 폴더가 없습니다.
    echo.
    pause
    exit /b
)

:: .ico 파일 유무 확인
set "ICO_COUNT=0"
for %%I in ("%~dp0%RESOURCE_DIR_NAME%\*.ico") do set /a ICO_COUNT+=1
if !ICO_COUNT! equ 0 (
    echo %RED%  [FAIL]%RST%   '%RESOURCE_DIR_NAME%' 폴더 안에 .ico 파일이 없습니다.
    echo.
    pause
    exit /b
)

:: 부모 폴더 경로 설정
pushd "%~dp0.."
set "PARENT_DIR=%CD%"
popd

echo %DIM%  대상 경로 : !PARENT_DIR!%RST%
echo %DIM%  발견된 아이콘 : !ICO_COUNT!개%RST%
echo.


echo %BLU%%BOLD%[1/3] 기본 폴더 아이콘%RST%
echo %DIM%------------------------------------------------------------%RST%

:: .setup 아이콘 설정
if exist "%~dp0%CONFIG_ICON_NAME%" (
    set "CONFIG_INI=%~dp0desktop.ini"

    if exist "!CONFIG_INI!" attrib -h -s "!CONFIG_INI!"

    > "!CONFIG_INI!" echo [.ShellClassInfo]
    >> "!CONFIG_INI!" echo IconResource=%CONFIG_ICON_NAME%,0

    attrib +h +s "!CONFIG_INI!"
    attrib +r "%~dp0."
    echo   %GRN%[ OK ]%RST%   %CONFIG_DIR_NAME% %DIM%-^> %CONFIG_ICON_NAME%%RST%
    set "SYS_RESULT_SETUP=%GRN%적용됨%RST%"
    set /a CNT_ICON+=1
) else (
    echo   %YLW%[SKIP]%RST%  %CONFIG_ICON_NAME% 파일 없음 %DIM%[%CONFIG_DIR_NAME%]%RST%
    set /a CNT_SKIP+=1
)

:: DEV 아이콘 설정
if exist "%~dp0%DEV_ICON_NAME%" (
    set "PARENT_INI=!PARENT_DIR!\desktop.ini"

    if exist "!PARENT_INI!" attrib -h -s "!PARENT_INI!"

    > "!PARENT_INI!" echo [.ShellClassInfo]
    >> "!PARENT_INI!" echo IconResource=%CONFIG_DIR_NAME%\%DEV_ICON_NAME%,0

    attrib +h +s "!PARENT_INI!"
    attrib +r "!PARENT_DIR!"
    echo   %GRN%[ OK ]%RST%   DEV %DIM%-^> %DEV_ICON_NAME%%RST%
    set "SYS_RESULT_DEV=%GRN%적용됨%RST%"
    set /a CNT_ICON+=1
) else (
    echo   %YLW%[SKIP]%RST%  %DEV_ICON_NAME% 파일 없음 %DIM%[DEV]%RST%
    set /a CNT_SKIP+=1
)
echo.


echo %BLU%%BOLD%[2/3] 폴더 생성 및 아이콘 적용%RST%
echo %DIM%------------------------------------------------------------%RST%

:: .ico 파일 기반 폴더/아이콘 세팅
for %%I in ("%~dp0%RESOURCE_DIR_NAME%\*.ico") do (
    set "FOLDER_NAME=%%~nI"
    set "TARGET_FOLDER=!PARENT_DIR!\!FOLDER_NAME!"
    set "STATE=%DIM%기존%RST%"

    if not exist "!TARGET_FOLDER!\" (
        md "!TARGET_FOLDER!"
        set "STATE=%GRN%신규%RST%"
        set /a CNT_CREATED+=1
    ) else (
        set /a CNT_EXIST+=1
    )

    set "INI_FILE=!TARGET_FOLDER!\desktop.ini"

    :: 기존 desktop.ini 덮어쓰기
    if exist "!INI_FILE!" attrib -h -s "!INI_FILE!"

    > "!INI_FILE!" echo [.ShellClassInfo]
    >> "!INI_FILE!" echo IconResource=..\%CONFIG_DIR_NAME%\%RESOURCE_DIR_NAME%\%%~nxI,0

    attrib +h +s "!INI_FILE!"
    attrib +r "!TARGET_FOLDER!"
    set /a CNT_ICON+=1
    echo   %GRN%[ OK ]%RST% !STATE!  %BOLD%!FOLDER_NAME!%RST% %DIM%-^> %%~nxI%RST%
)
echo.


echo %BLU%%BOLD%[3/3] 아이콘 캐시 갱신%RST%
echo %DIM%------------------------------------------------------------%RST%
ie4uinit.exe -show
echo   %GRN%[ OK ]%RST%   탐색기 아이콘 캐시를 새로고침했습니다.
timeout /t 2 >nul
echo.

:: 종합 결과
echo %CYN%============================================================%RST%
echo %CYN%%RST%  %BOLD%실행 결과 요약%RST%                                         %CYN%%RST%
echo %CYN%------------------------------------------------------------%RST%
echo %CYN%%RST%   %BOLD%.setup 폴더 아이콘%RST%   : !SYS_RESULT_SETUP!
echo %CYN%%RST%   %BOLD%DEV 폴더 아이콘%RST%      : !SYS_RESULT_DEV!
echo %CYN%%RST%   %BOLD%새로 생성된 폴더%RST%     : %GRN%!CNT_CREATED!개%RST%
echo %CYN%%RST%   %BOLD%이미 존재한 폴더%RST%     : %YLW%!CNT_EXIST!개%RST%
echo %CYN%%RST%   %BOLD%아카이브 신규 생성%RST%   : %GRN%!CNT_ARCH!개%RST%
echo %CYN%%RST%   %BOLD%아카이브 기존 폴더%RST%   : %YLW%!CNT_ARCH_EXIST!개%RST%
echo %CYN%%RST%   %BOLD%아이콘 적용 합계%RST%     : %GRN%!CNT_ICON!개%RST%
echo %CYN%%RST%   %BOLD%건너뜀%RST%               : %DIM%!CNT_SKIP!개%RST%
echo %CYN%============================================================%RST%
echo.
echo   %GRN%%BOLD%모든 작업이 정상적으로 완료되었습니다^^!%RST%
echo.
pause