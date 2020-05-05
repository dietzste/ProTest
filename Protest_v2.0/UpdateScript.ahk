;;;;;;;;;;;;;;;;;;;;;
;  Update Procedure ;
;;;;;;;;;;;;;;;;;;;;;

^u::
UpdateProTest:

; Download UppateClient
UpdateClientName := "UpdateProTest.exe"
DownloadUpdateClient(UpdateClientName)
Run, %UpdateClientName%
return 

DownloadUpdateClient(UpdateClientName){
local
URLUpdateClient :=  "https://github.com/dietzste/ProTest/releases/download/U1.0/UpdateProTest.exe"
UrlDownloadToFile, %URLUpdateClient%, %UpdateClientName%
if !FileExist(UpdateClientName)
	MsgBox, 4096, Update Error, Die Datei %UpdateClientName% konnte nicht geladen werden! Update wird abgebrochen!
}

; force Update 
^!u::
SaveIniValue(Basicfile, "ProTestVersion", "ForceUpdate", "true")
send, ^u
return 

