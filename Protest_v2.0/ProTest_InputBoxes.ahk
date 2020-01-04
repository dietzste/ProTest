;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;     INPUT-BOXES      ;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

InputBoxProtest(fnOCR, Byref SendBack){
local
global ue, oe, ae
global ProjectFile, QuickSetupMenu
if Instr(fnOCR, "AskForLFD")
	{
	if (fnOCR = "AskForLFDSearch")
		InputBoxText := "Bitte eine Start-LFD eingeben!"
	else if (fnOCR = "AskForLFDIntro")
		InputBoxText := "Gibt die aktuelle LFD ein, wenn du m" . oe . "chtest, dass abgerufene Preload-Werte gespeichert werden."
	InptBoxTitle := "LFD-Angabe fehlt!"
	e_UseLFD := GetIniValue(ProjectFile, QuickSetupMenu, "e_UseLFD")
	if (e_UseLFD = "ERROR")
		InputBoxDefault := ""
	else
		InputBoxDefault := e_UseLFD
	}
else
	{
	InputBoxText := "Geschlechtsangabe f" . ue . "r fn """ . fnOCR . """ ben" . oe . "tigt!`n`n1: m" . ae . "nnlich `n2: weiblich"
	InptBoxTitle := "Geschlechtsangabe fehlt!"
	InputBoxDefault := 2
	}

InputBox, SendBack , %InptBoxTitle% , %InputBoxText%,, 300, 200,,,,,%InputBoxDefault%
if (fnOCR != "AskForLFD" AND ErrorLevel)
	{
	MsgBox, 4096, Ende , Durchlauf wurde beendet!
	Exit
	}
if Instr(fnOCR, "AskForLFD") AND ErrorLevel
	{
	if (fnOCR = "AskForLFDSearch")
		{
		MsgBox, 4096, Ende , LFD Finder wird gestoppt!
		Exit
		}
	else if (fnOCR = "AskForLFDIntro") 
		{
		Msgbox, 4132, Continue? , Durchlauf trotzdem fortsetzen?
		IfMsgBox, Yes
			return 
		else
			Exit
		}
	}
}