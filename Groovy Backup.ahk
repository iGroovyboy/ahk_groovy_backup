#Persistent
#SingleInstance
SetBatchLines, -1  ; Make the operation run at maximum speed.
OnExit("ExitFunc")

Menu, Tray, NoStandard
Menu, Tray, Add, E&xit, TrayMenuExit

Menu, Tray, Tip , Backing up is in progress

TrayTip , Backup, Started Backup

;***********************************************************************

optionsFile:="options.ini"

global backup_hidden
global backup_readonly
global xcopyPID
global test_mode
global selfquit_when_done

IniRead, backup_hidden,      %optionsFile%, OPTIONS, backup_hidden,      1
IniRead, backup_readonly,    %optionsFile%, OPTIONS, backup_readonly,    1
IniRead, test_mode,          %optionsFile%, OPTIONS, test_mode,          0
IniRead, selfquit_when_done, %optionsFile%, OPTIONS, selfquit_when_done, 0

i := 0
LOOP, 50 {
	IniRead, destination, %optionsFile%, Backup%A_Index%, destination
	if (destination = "ERROR")
		break
	section = Backup%A_Index%
	;MsgBox, destination = %destination%
	TrayTip , Backup, Started copying to %destination%
	
	
	Loop, 50 {
		IniRead, src%A_Index%, %optionsFile%, %section%, src%A_Index%
		path = % src%A_Index%
		if (path = "ERROR")
			break
			
		SplitPath, path, name
		destFull = %destination%\%name%
		;MsgBox, COPY: %path% TO %destFull%
		
		Menu, Tray, Tip, Backing up %destFull% is in progress
		if (test_mode=0) {
			XCopy(path, destFull, 1)
		}		
	}
	
}

TrayTip , Backup, FINISHED BACKUP, 8, 1

XCopy(src, dest, overwrite){
	xcopyPath = %A_WinDir%\system32\xcopy.exe
	if FileExist(xcopyPath) {
		attr_h := ""
		attr_r := ""
		
		if (backup_hidden=1)
			attr_h := "/H"
			
		if (backup_readonly=1)
			attr_r := "/R"

		RunWait, %comspec%  /c xcopy "%src%" "%dest%"  /C /D /V /Q /Y /K /S /I %attr_h% %attr_r%, , Hide, xcopyPID
			;/c Ignores errors
			;/d overwrites only if src files are newer
			;/v make sure that the destination files are identical to the source files
			;/q Suppresses the display of xcopy messages.			
			;/y Suppresses prompting to confirm that you want to overwrite an existing destination file.
			;/k Copies files and retains the read-only attribute on Destination files if present on the Source files. By default, xcopy removes the read-only attribute.
			
			;/i creates dir if not exists
			;/s Copies directories and subdirectories, unless they are empty. If you omit /s, xcopy works within a single directory.
			
			;/h Copies files with hidden and system file attributes. By default, xcopy does not copy hidden or system files
			;/r Copies read-only files.
			
		;Close processess
		Process, close, %xcopyPID%
		Process Close, xcopy.exe
		Process Close, conhost.exe
	} else {
		FileCopyDir, %src%, %dest%, %overwrite%
	}	
}

ExitFunc(ExitReason, ExitCode){
	Process, close, %xcopyPID%
	Process Close, xcopy.exe
	Process Close, conhost.exe
}

TrayMenuExit:
	ExitApp
return

if (selfquit_when_done = 1) {
	ExitApp
}
