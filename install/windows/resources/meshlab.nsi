; Must modify:
; - MESHLAB_VERSION
; - DISTRIB_PATH

!define MAINDIR $PROGRAMFILES64
!define PRODUCT_NAME "MeshLab"
!define PRODUCT_VERSION "MESHLAB_VERSION"
!define PRODUCT_PUBLISHER "Paolo Cignoni - VCG - ISTI - CNR"
!define PRODUCT_WEB_SITE "http://www.meshlab.net"
!define PRODUCT_DIR_REGKEY "Software\Microsoft\Windows\CurrentVersion\App Paths\meshlab.exe"
!define PRODUCT_DIR_REGKEY_S "Software\Microsoft\Windows\CurrentVersion\App Paths\meshlabserver.exe"
!define PRODUCT_UNINST_KEY "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_NAME}"
!define PRODUCT_UNINST_ROOT_KEY "HKLM"
!define DISTRIB_FOLDER "DISTRIB_PATH"
!define MICROSOFT_VS2010_REDIST_KEYDIR "Software\Microsoft\Windows\CurrentVersion\Uninstall\"

; MUI 1.67 compatible -----
!include "MUI.nsh"

; MUI Settings
!define MUI_ABORTWARNING
!define MUI_ICON "${NSISDIR}\Contrib\Graphics\Icons\modern-install.ico"
!define MUI_UNICON "${NSISDIR}\Contrib\Graphics\Icons\modern-uninstall.ico"

; Welcome page
!insertmacro MUI_PAGE_WELCOME
; License page
!insertmacro MUI_PAGE_LICENSE "${DISTRIB_FOLDER}\LICENSE.txt"
; License page
!insertmacro MUI_PAGE_LICENSE "${DISTRIB_FOLDER}\privacy.txt"
; Directory page
!insertmacro MUI_PAGE_DIRECTORY
; Instfiles page
!insertmacro MUI_PAGE_INSTFILES


; Finish page
!define MUI_FINISHPAGE_RUN "$INSTDIR\meshlab.exe"
!insertmacro MUI_PAGE_FINISH

; Uninstaller pages
!insertmacro MUI_UNPAGE_INSTFILES

; Language files
!insertmacro MUI_LANGUAGE "English"

; MUI end ------
!define /date NOW "%Y_%m_%d"

Name "${PRODUCT_NAME} ${PRODUCT_VERSION}"
OutFile "MeshLab${PRODUCT_VERSION}.exe"
InstallDir "${MAINDIR}\VCG\MeshLab"
ShowInstDetails show
ShowUnInstDetails show

!include LogicLib.nsh

; this macro executes a process and waits until has finished
; example call:
;  StrCpy $8 '"uninstall.exe"'
;  !insertmacro ExecWaitJob r8
;
!macro ExecWaitJob _exec
/*
0=ErrChk+JOBOBJECTASSOCIATE*+PROCESS_INFO 
1=hPort
2=hJob
3=ErrChk+hProcess+ioX
4=STARTINFO+hThread+ioOLAP
9="Stage"
*/
StrCpy $9 0
System::Call 'kernel32::CreateIoCompletionPort(i -1,i0,i0,i0)i.r1'
${IfThen} $1 != 0 ${|} IntOp $9 $9 + 1 ${|}
System::Call 'kernel32::CreateJobObject(i0,i0)i.r2'
${IfThen} $2 != 0 ${|} IntOp $9 $9 + 1 ${|}
System::Call '*(i 0,i $1)i.r0'
System::Call 'kernel32::SetInformationJobObject(i $2,i 7,i $0,i 8)i.r3'
${IfThen} $3 != 0 ${|} IntOp $9 $9 + 1 ${|}
System::Free $0
System::Call '*(i,i,i,i)i.r0'
System::Alloc 72
pop $4
System::Call "*$4(i 72)"
System::Call 'kernel32::CreateProcess(i0,t ${_exec},i0,i0,i0,i 0x01000004,i0,i0,i $4,i $0)i.r3'
${IfThen} $3 != 0 ${|} IntOp $9 $9 + 1 ${|}
System::Free $4
System::Call "*$0(i.r3,i.r4,i,i)"
System::Free $0
System::Call 'kernel32::AssignProcessToJobObject(i $2,i $3)i.r0'
${IfThen} $0 != 0 ${|} IntOp $9 $9 + 1 ${|}
System::Call 'kernel32::ResumeThread(i $4)i.r0'
${IfThen} $0 != -1 ${|} IntOp $9 $9 + 1 ${|}
System::Call 'kernel32::CloseHandle(i $3)'
System::Call 'kernel32::CloseHandle(i $4)'
!define __ExecWaitJob__ ExecWaitJob${__LINE__}
${__ExecWaitJob__}ioportwait:
System::Call 'kernel32::GetQueuedCompletionStatus(i $1,*i.r3,*i,*i.r4,i -1)i.r0'
${IfThen} $0 = 0 ${|} StrCpy $9 0 ${|}
${IfThen} $3 != 4 ${|} goto ${__ExecWaitJob__}ioportwait ${|}
System::Call 'kernel32::CloseHandle(i $2)'
System::Call 'kernel32::CloseHandle(i $1)'
!undef __ExecWaitJob__
${IfThen} $9 < 6 ${|} MessageBox mb_iconstop `ExecWaitJob "${_exec}" failed!` ${|}
!macroend

Function .onInit 
  ReadRegStr $0 HKLM "${PRODUCT_UNINST_KEY}" "UninstallString"
  ${If} $0 != "" ;2020.0x...
    MessageBox MB_OK|MB_ICONSTOP "Please first uninstall old MeshLab version. Starting uninstaller now..." 
	StrCpy $8 '"$0"'
	!insertmacro ExecWaitJob r8
  ${Else}
    ReadRegStr $0 HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\MeshLab_64b" "UninstallString"
    ${If} $0 != "" ;2016.12 
	  MessageBox MB_OK|MB_ICONSTOP "Please first uninstall old MeshLab version. Starting uninstaller now..." 
   	  StrCpy $8 '"$0"'
	  !insertmacro ExecWaitJob r8
    ${EndIf}
  ${EndIf}
FunctionEnd

Section "MainSection" SEC01
  SetOutPath "$INSTDIR"
  ;Let's delete all the dangerous stuff from previous releases.
  
  RMDir /r "$SMPROGRAMS\MeshLab"
  Delete "$DESKTOP\MeshLab.lnk" 

  DeleteRegKey ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}"
  DeleteRegKey HKLM "${PRODUCT_DIR_REGKEY}" 
  DeleteRegKey HKLM "${PRODUCT_DIR_REGKEY_S}"
   
  Delete "$INSTDIR\*"
  
  SetOverwrite on
  File "${DISTRIB_FOLDER}\meshlab.exe"
  File "${DISTRIB_FOLDER}\meshlabserver.exe"
  CreateDirectory "$SMPROGRAMS\MeshLab"
  CreateShortCut "$SMPROGRAMS\MeshLab\MeshLab.lnk" "$INSTDIR\meshlab.exe"
  CreateShortCut "$DESKTOP\MeshLab.lnk" "$INSTDIR\meshlab.exe"
  CreateShortCut '$SMPROGRAMS\MeshLab\MeshLabServer.lnk' 'powershell.exe -noexit -command "cd $INSTDIR\ " '
  
  ;Copy everything inside DISTRIB
  SetOutPath "$INSTDIR"
  File /nonfatal /a /r "${DISTRIB_FOLDER}\" 
SectionEnd

Section -Prerequisites
    ;always install vc_redist
	;ReadRegStr $1 HKLM "SOFTWARE\Microsoft\VisualStudio\14.0\VC\Runtimes\x64" "Installed"
	;${If} $1 <> 0
	;	Goto endPrerequisites
	;${Else}
		ExecWait '"$INSTDIR\vc_redist.x64.exe" /q /norestart'
	;${EndIf}
	;endPrerequisites:
SectionEnd

Section -Post
  WriteUninstaller "$INSTDIR\uninstall.exe"
  WriteRegStr HKLM "${PRODUCT_DIR_REGKEY}" "" "$INSTDIR\meshlab.exe"
  WriteRegStr HKLM "${PRODUCT_DIR_REGKEY_S}" "" "$INSTDIR\meshlabserver.exe"
  WriteRegStr HKLM "${PRODUCT_UNINST_KEY}" "DisplayName" "$(^Name)"
  WriteRegStr HKLM "${PRODUCT_UNINST_KEY}" "UninstallString" "$INSTDIR\uninstall.exe"
  WriteRegStr HKLM "${PRODUCT_UNINST_KEY}" "QuietUninstallString" '"$INSTDIR\uninstall.exe" /S'
  WriteRegStr HKLM "${PRODUCT_UNINST_KEY}" "DisplayIcon" "$INSTDIR\meshlab.exe"
  WriteRegStr HKLM "${PRODUCT_UNINST_KEY}" "DisplayVersion" "${PRODUCT_VERSION}"
  WriteRegStr HKLM "${PRODUCT_UNINST_KEY}" "URLInfoAbout" "${PRODUCT_WEB_SITE}"
  WriteRegStr HKLM "${PRODUCT_UNINST_KEY}" "Publisher" "${PRODUCT_PUBLISHER}"
SectionEnd

Section -AdditionalIcons
  WriteIniStr "$INSTDIR\${PRODUCT_NAME}.url" "InternetShortcut" "URL" "${PRODUCT_WEB_SITE}"
  CreateShortCut "$SMPROGRAMS\MeshLab\Website.lnk" "$INSTDIR\${PRODUCT_NAME}.url"
  CreateShortCut "$SMPROGRAMS\MeshLab\Uninstall.lnk" "$INSTDIR\uninstall.exe"
SectionEnd


Function un.onInit ;before uninstall starts
  ${If} ${Silent}
    Return
  ${Else}
	MessageBox MB_ICONQUESTION|MB_YESNO|MB_DEFBUTTON2 "Are you sure you want to completely remove $(^Name) and all of its components?" IDYES +2
	Abort
  ${EndIf}
FunctionEnd

Section Uninstall ;uninstall instructions
  RMDir /r "$INSTDIR"
  RMDir /r "$SMPROGRAMS\MeshLab"
  Delete "$DESKTOP\MeshLab.lnk" 

  DeleteRegKey ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}"
  DeleteRegKey HKLM "${PRODUCT_DIR_REGKEY}" 
  DeleteRegKey HKLM "${PRODUCT_DIR_REGKEY_S}"
  SetAutoClose true
SectionEnd

Function un.onUninstSuccess ;after uninstall
  HideWindow
  ${If} ${Silent}
    Return
  ${Else}
    MessageBox MB_ICONINFORMATION|MB_OK "$(^Name) was successfully removed from your computer."
  ${EndIf}
FunctionEnd

