#!Nsis Installer Command Script

#
# Copyright (c) 2009, Shao Miller (shao.miller@yrdsb.edu.on.ca)
# Copyright (c) 2009, Cyrill Gorcunov (gorcunov@gmail.com)
# All rights reserved.
#
# The script requires NSIS v2.45 (or any later)
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#     * Redistributions of source code must retain the above copyright
#       notice, this list of conditions and the following disclaimer.
#     * Redistributions in binary form must reproduce the above copyright
#       notice, this list of conditions and the following disclaimer in the
#       documentation and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
# ''AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
# TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
# PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL <copyright holder> BE LIABLE FOR
# ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

!include "version.nsh"
!define PRODUCT_NAME "Netwide Assembler"
!define PRODUCT_SHORT_NAME "nasm"
!define PACKAGE_NAME "${PRODUCT_NAME} ${VERSION}"
!define PACKAGE_SHORT_NAME "${PRODUCT_SHORT_NAME}-${VERSION}"

SetCompressor lzma

!define MULTIUSER_EXECUTIONLEVEL Highest
!define MULTIUSER_MUI
!define MULTIUSER_INSTALLMODE_COMMANDLINE
!define MULTIUSER_INSTALLMODE_INSTDIR "${PRODUCT_SHORT_NAME}"
!include MultiUser.nsh

!insertmacro MULTIUSER_PAGE_INSTALLMODE
!insertmacro MULTIUSER_INSTALLMODEPAGE_INTERFACE

;--------------------------------
;General

;Name and file
Name "${PACKAGE_NAME}"
OutFile "${PACKAGE_SHORT_NAME}-installer.exe"

;Get installation folder from registry if available
InstallDirRegKey HKCU "Software\${PRODUCT_SHORT_NAME}" ""

;Request application privileges for Windows Vista
RequestExecutionLevel user

;--------------------------------
;Variables

Var StartMenuFolder
Var CmdFailed

;--------------------------------
;Interface Settings
Caption "${PACKAGE_SHORT_NAME} installation"
Icon "nsis/nasm.ico"
UninstallIcon "nsis/nasm-un.ico"

!define MUI_ABORTWARNING

;--------------------------------
;Pages

!insertmacro MUI_PAGE_COMPONENTS
!insertmacro MUI_PAGE_DIRECTORY

;Start Menu Folder Page Configuration
!define MUI_STARTMENUPAGE_REGISTRY_ROOT "HKCU"
!define MUI_STARTMENUPAGE_REGISTRY_KEY "Software\${PRODUCT_SHORT_NAME}"
!define MUI_STARTMENUPAGE_REGISTRY_VALUENAME "${PRODUCT_SHORT_NAME}"

!insertmacro MUI_PAGE_STARTMENU Application $StartMenuFolder

!insertmacro MUI_PAGE_INSTFILES

!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES

;--------------------------------
;Installer Sections

!insertmacro MUI_LANGUAGE English

Section "NASM" SecNasm
    Sectionin RO
    SetOutPath "$INSTDIR"
    File "LICENSE"
    File "nasm.exe"
    File "ndisasm.exe"
    File "nsis/nasm.ico"

    ;Store installation folder
    WriteRegStr HKCU "Software\${PRODUCT_SHORT_NAME}" "" $INSTDIR

    ;Store shortcuts folder
    WriteRegStr HKCU "Software\${PRODUCT_SHORT_NAME}\" "lnk" $SMPROGRAMS\$StartMenuFolder

    ;
    ; the bat we need
    StrCpy $CmdFailed "true"
    FileOpen $0 "nasmpath.bat" w
    IfErrors skip
    StrCpy $CmdFailed "false"
    FileWrite $0 "@set path=$INSTDIR;%path%$\r$\n"
    FileWrite $0 "@%comspec%"
    FileClose $0
    CreateShortCut "$DESKTOP\${PRODUCT_SHORT_NAME}.lnk" "$INSTDIR\nasmpath.bat" "" "$INSTDIR\nasm.ico" 0
skip:
    ;Create uninstaller
    WriteUninstaller "$INSTDIR\Uninstall.exe"

    !insertmacro MUI_STARTMENU_WRITE_BEGIN Application

    ;Create shortcuts
    CreateDirectory "$SMPROGRAMS\$StartMenuFolder"
    StrCmp $CmdFailed "true" +2
    CreateShortCut "$SMPROGRAMS\$StartMenuFolder\${PRODUCT_SHORT_NAME}-shell.lnk" "$INSTDIR\nasmpath.bat"
    CreateShortCut  "$SMPROGRAMS\$StartMenuFolder\${PRODUCT_SHORT_NAME}.lnk" "$INSTDIR\nasm.exe" "" "$INSTDIR\nasm.ico" 0
    CreateShortCut  "$SMPROGRAMS\$StartMenuFolder\Uninstall.lnk" "$INSTDIR\Uninstall.exe"

    !insertmacro MUI_STARTMENU_WRITE_END
SectionEnd

Section "RDOFF" SecRdoff
    CreateDirectory "$INSTDIR\rdoff"
    SetOutPath "$INSTDIR\rdoff"
    File "rdoff/ldrdf.exe"
    File "rdoff/rdf2bin.exe"
    File "rdoff/rdf2com.exe"
    File "rdoff/rdf2ith.exe"
    File "rdoff/rdf2ihx.exe"
    File "rdoff/rdf2srec.exe"
    File "rdoff/rdfdump.exe"
    File "rdoff/rdflib.exe"
    File "rdoff/rdx.exe"
SectionEnd

Section "Manual" SecManual
    SetOutPath "$INSTDIR"
    File "doc/nasmdoc.pdf"
    CreateShortCut "$SMPROGRAMS\$StartMenuFolder\Manual.lnk" "$INSTDIR\nasmdoc.pdf"
SectionEnd

;--------------------------------
;Descriptions

    ;Language strings
    LangString DESC_SecNasm ${LANG_ENGLISH}     "NASM assembler and disassember modules"
    LangString DESC_SecManual ${LANG_ENGLISH}   "Complete NASM manual (pdf file)"
    LangString DESC_SecRdoff ${LANG_ENGLISH}    "RDOFF utilities (you may not need it if you don't know what is it)"

    ;Assign language strings to sections
    !insertmacro MUI_FUNCTION_DESCRIPTION_BEGIN
    !insertmacro MUI_DESCRIPTION_TEXT ${SecNasm} $(DESC_SecNasm)
    !insertmacro MUI_DESCRIPTION_TEXT ${SecRdoff} $(DESC_SecRdoff)
    !insertmacro MUI_DESCRIPTION_TEXT ${SecManual} $(DESC_SecManual)
    !insertmacro MUI_FUNCTION_DESCRIPTION_END

;--------------------------------
;Uninstaller Section

Section "Uninstall"
    ;
    ; files on HDD
    Delete /rebootok "$INSTDIR\rdoff\*"
    RMDir "$INSTDIR\rdoff"
    Delete /rebootok "$INSTDIR\doc\*"
    RMDir "$INSTDIR\doc"
    Delete /rebootok "$INSTDIR\*"
    RMDir "$INSTDIR"
    Delete /rebootok "$DESKTOP\${PRODUCT_SHORT_NAME}.lnk"
    ;
    ; Start Menu folder
    ReadRegStr $0 HKCU Software\${PRODUCT_SHORT_NAME} "lnk"
    Delete /rebootok "$0\*"
    RMDir "$0"
    DeleteRegKey /ifempty HKCU "Software\${PRODUCT_SHORT_NAME}"
SectionEnd

;
; MUI requires this hooks
Function .onInit
    !insertmacro MULTIUSER_INIT
FunctionEnd

Function un.onInit
    !insertmacro MULTIUSER_UNINIT
FunctionEnd
