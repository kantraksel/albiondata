; This file is part of Albion Data Client
; Copyright (c) 2017    The Albion Data Project
;
; See the LICENSE file in the root folder (MIT).
;
;-----------------------------------------------
;Include section

!include "MUI2.nsh"
!include "FileFunc.nsh"
!include "LogicLib.nsh"
!include "WinCore.nsh"

;--------------------------------
;General
CRCCheck on   ;make sure this isn't corrupted

;Name and file
Name "${PACKAGE_NAME}"
OutFile "${OUTFILE}"

;Default installation folder
;Don't set a default $InstDir so we can detect /D= and InstallDirRegKey
InstallDir ""
;Get installation folder from registry if available
InstallDirRegKey HKCU "Software\${PACKAGE_NAME}" ""
;Request application privileges for Windows Vista
RequestExecutionLevel admin

;--------------------------------
;Versioninfo

VIProductVersion "${PACKAGE_VERSION}.0"
VIAddVersionKey "CompanyName"	"Kantraksel"
VIAddVersionKey "FileDescription"	"${PACKAGE_NAME} Installer"
VIAddVersionKey "FileVersion"		"${PACKAGE_VERSION}"
VIAddVersionKey "InternalName"	"${PACKAGE_NAME}"
VIAddVersionKey "LegalCopyright"	"Copyright (c) 2022 Kantraksel"
VIAddVersionKey "OriginalFilename"	"${PACKAGE}-${PACKAGE_VERSION}-installer.exe"
VIAddVersionKey "ProductName"	"${PACKAGE_NAME}"
VIAddVersionKey "ProductVersion"	"${PACKAGE_VERSION}"

;--------------------------------

;Interface Settings
!define MUI_ICON "${TOP_SRCDIR}\icon\albiondata-client.ico"
!define MUI_UNICON "${TOP_SRCDIR}\icon\albiondata-client.ico"

;--------------------------------
;Variables
Var STARTMENU_FOLDER

;--------------------------------
;Start Menu Folder Page Configuration (for MUI_PAGE_STARTMENU)
!define MUI_STARTMENUPAGE_REGISTRY_ROOT "HKCU"
!define MUI_STARTMENUPAGE_REGISTRY_KEY "Software\${PACKAGE_NAME}"
!define MUI_STARTMENUPAGE_REGISTRY_VALUENAME "Start Menu Folder"

;--------------------------------
; These indented statements modify settings for MUI_PAGE_FINISH
; !define MUI_FINISHPAGE_NOAUTOCLOSE
; !define MUI_UNFINISHPAGE_NOAUTOCLOSE

;--------------------------------
;Pages

!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_LICENSE "${TOP_SRCDIR}\LICENSE"
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_STARTMENU "Application" $STARTMENU_FOLDER
!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_PAGE_FINISH

!insertmacro MUI_UNPAGE_WELCOME
!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES
!insertmacro MUI_UNPAGE_FINISH

;--------------------------------
;Languages

  !insertmacro MUI_LANGUAGE "English" # first language is the default language
;  !insertmacro MUI_LANGUAGE "Dutch"
;  !insertmacro MUI_LANGUAGE "German"
;  !insertmacro MUI_LANGUAGE "Russian"

;--------------------------------
;Reserve Files

  ;These files should be inserted before other files in the data block
  ;Keep these lines before any File command
  ;Only for solid compression (by default, solid compression is enabled for BZIP2 and LZMA)

!insertmacro MUI_RESERVEFILE_LANGDLL


Function .onInit
  SetShellVarContext Current
  ${If} $InstDir == "" ; No /D= nor InstallDirRegKey?
    GetKnownFolderPath $InstDir ${FOLDERID_UserProgramFiles} ; This folder only exists on Win7+
    StrCmp $InstDir "" 0 +2 
    StrCpy $InstDir "$LocalAppData\Programs" ; Fallback directory
    StrCpy $InstDir "$InstDir\$(^Name)"
  ${EndIf}

  !insertmacro MUI_LANGDLL_DISPLAY

FunctionEnd


;--------------------------------
;Installer Sections

Section $(TEXT_SecBase) SecBase
  SectionIn RO
  SetOutPath "$INSTDIR"
  SetShellVarContext all

  ;ADD YOUR OWN FILES HERE...

  ; Main executable
  File "${TOP_SRCDIR}\${PACKAGE_EXE}"

  ; Npcap driver
  File "${TOP_SRCDIR}\npcap.exe"
  PUSH "npcap.exe"

  File "${TOP_SRCDIR}\LICENSE"
  Push "LICENSE"
  Push "License.txt"
  Call unix2dos

  ;Store installation folder
  WriteRegStr HKCU "Software\${PACKAGE_NAME}" "" $INSTDIR

  ; Write the Windows-uninstall keys
  WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PACKAGE_NAME}" "DisplayName" "${PACKAGE_NAME}"
  WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PACKAGE_NAME}" "DisplayVersion" "${PACKAGE_VERSION}"
  WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PACKAGE_NAME}" "DisplayIcon" "$INSTDIR\${PACKAGE}.exe,0"
  WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PACKAGE_NAME}" "Publisher" "Kantraksel"
  WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PACKAGE_NAME}" "InstallLocation" "$INSTDIR"
  WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PACKAGE_NAME}" "UninstallString" "$INSTDIR\uninstall.exe"
  WriteRegDWORD HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PACKAGE_NAME}" "NoModify" 1
  WriteRegDWORD HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PACKAGE_NAME}" "NoRepair" 1

  ;Create uninstaller
  WriteUninstaller "$INSTDIR\uninstall.exe"

  !insertmacro MUI_STARTMENU_WRITE_BEGIN Application
    SetOutPath "$INSTDIR"
    ;Create shortcuts
    CreateDirectory "$SMPROGRAMS\$STARTMENU_FOLDER"
    CreateShortCut "$SMPROGRAMS\$STARTMENU_FOLDER\Uninstall.lnk" "$INSTDIR\uninstall.exe"
    CreateShortCut "$SMPROGRAMS\$STARTMENU_FOLDER\${PACKAGE_NAME}.lnk" "$INSTDIR\${PACKAGE_EXE}"
  !insertmacro MUI_STARTMENU_WRITE_END

  SetOutPath "$INSTDIR"
  CreateShortCut "$DESKTOP\${PACKAGE_NAME}.lnk" "$INSTDIR\${PACKAGE_EXE}"

; Create Task to run the Client as Admin on Logon
  WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Run" "${PACKAGE_NAME}" '"$InstDir\${PACKAGE}.exe"'

SectionEnd

Section $(TEXT_SecWinPcap) SecWinPcap
  SetOutPath "$INSTDIR"
  File "${TOP_SRCDIR}\npcap.exe"
  ExecWait '"$INSTDIR\npcap.exe"'
SectionEnd


;--------------------------------
; unix2dos
Function unix2dos
    ; strips all CRs and then converts all LFs into CRLFs
    ; (this is roughly equivalent to "cat file | dos2unix | unix2dos")
    ; beware that this function destroys $0 $1 $2
	;
    ; usage:
    ;    Push "infile"
    ;    Push "outfile"
    ;    Call unix2dos
    ClearErrors
    Pop $2
    FileOpen $1 $2 w			;$1 = file output (opened for writing)
    Pop $2
    FileOpen $0 $2 r			;$0 = file input (opened for reading)
    Push $2						;save name for deleting
    IfErrors unix2dos_done

unix2dos_loop:
    FileReadByte $0 $2			; read a byte (stored in $2)
    IfErrors unix2dos_done		; EOL
    StrCmp $2 13 unix2dos_loop	; skip CR
    StrCmp $2 10 unix2dos_cr unix2dos_write	; if LF write an extra CR

unix2dos_cr:
    FileWriteByte $1 13

unix2dos_write:
    FileWriteByte $1 $2			; write byte
    Goto unix2dos_loop			; read next byte

unix2dos_done:
    FileClose $0				; close files
    FileClose $1
    Pop $0
    Delete $0					; delete original

FunctionEnd

;--------------------------------
;Descriptions

LangString TEXT_SecBase ${LANG_ENGLISH} "Core files"
LangString DESC_SecBase ${LANG_ENGLISH} "The core files required to run ${PACKAGE_NAME}."

LangString TEXT_SecWinPcap ${LANG_ENGLISH} "NPCAP"
LangString DESC_SecWinPcap ${LANG_ENGLISH} "NPCAP Driver"


;--------------------------------
;Uninstaller Section

Section "Uninstall"

  ; Main executable
  Delete "$INSTDIR\${PACKAGE_EXE}"

  ; NPCAP driver
  Delete "$INSTDIR\npcap.exe"
  Delete "$INSTDIR\LICENSE.txt"
  Delete "$INSTDIR\uninstall.exe"
  RmDir "$INSTDIR"

  ; Startmenu
  !insertmacro MUI_STARTMENU_GETFOLDER Application $STARTMENU_FOLDER

  Delete "$SMPROGRAMS\$STARTMENU_FOLDER\Uninstall.lnk"
  Delete "$SMPROGRAMS\$STARTMENU_FOLDER\${PACKAGE_NAME}.lnk"

  ;Delete empty start menu parent diretories
  RmDir "$SMPROGRAMS\$STARTMENU_FOLDER"

  ; Registry
  DeleteRegKey HKCU "Software\${PACKAGE_NAME}"

  ; Unregister with Windows' uninstall system
  DeleteRegKey HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PACKAGE_NAME}"

  ; Task
  DeleteRegValue HKCU "Software\Microsoft\Windows\CurrentVersion\Run" "${PACKAGE_NAME}"

SectionEnd


;--------------------------------
;Uninstaller Functions

Function un.onInit

  !insertmacro MUI_UNGETLANGUAGE

FunctionEnd
