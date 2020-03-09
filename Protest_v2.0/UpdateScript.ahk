;;;;;;;;;;;;;;;;;;;;;
;  Update Procedure ;
;;;;;;;;;;;;;;;;;;;;;

^u::
UpdateProTest:

; Download UppateClient
UpdateClientName := "UpdateProTest.exe"
if FileExist(UpdateClientName)
	{
	;Run, UpdateProTest.ahk , %A_ScriptDir%
	Run, %UpdateClientName% , %A_ScriptDir%
	}
else
	{
	URLUpdateClient :=  "https://github.com/dietzste/ProTest/releases/download/U1.0/UpdateProTest.exe"
	UrlDownloadToFile, %URLUpdateClient%, %UpdateClientName%
	if !FileExist(UpdateClientName)
		MsgBox, 4096, Update Error, Die Datei %UpdateClientName% konnte nicht geladen werden! Update wird abgebrochen!
	else
		Run, %UpdateClientName%
	}
return 

; force Update 
^!u::
SaveIniValue(Basicfile, "ProTestVersion", "ForceUpdate", "true")
send, ^u
return 

