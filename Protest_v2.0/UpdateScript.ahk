;;;;;;;;;;;;;;;;;;;;;
;  Update Procedure ;
;;;;;;;;;;;;;;;;;;;;;

^u::
UpdateProTest:

; Download UppateClient
UpdateClientName := "UpdateProTest.exe"
PleasWaitWindow("On")
DownloadUpdateClient(UpdateClientName)
PleasWaitWindow("Off")
Run, %UpdateClientName%
return 

DownloadUpdateClient(UpdateClientName){
local
URLUpdateClient :=  "https://github.com/dietzste/ProTest/releases/download/U1.0/UpdateProTest.exe"
UrlDownloadToFile, %URLUpdateClient%, %UpdateClientName%
if (ErrorLevel = 1 OR !FileExist(UpdateClientName))
	{
	MsgBox, 4096, Fehler beim Download, Die Datei %UpdateClientName% konnte nicht geladen werden! Update wird abgebrochen!
	Run https://www.githubstatus.com/
	Exit
	}
}

; force Update 
^!u::
SaveIniValue(Basicfile, "ProTestVersion", "ForceUpdate", "true")
send, ^u
return 

