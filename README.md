# ahk_groovy_backup
Copies folders to specified locations when this script runs

Script does not have any GUI, you should edit options.ini to add as much as 50 destination locations and unlimited source directories.
Destination backup location can have only one destination option; any source option should have a number suffix.

backup_hidden 1/0 - set whether to copy or not hidden files/folders
backup_readonly 1/0 - set whether to copy or not read-only files/folders
test_mode 1/0 - set to test: actual copying will not start
selfquit_when_done 1/0 - quit or stay in tray when backup's done

Script uses xcopy.exe as main copier and falls back to AHK native copier if xcopy not available in %systemroot%\system32\xcopy.exe
