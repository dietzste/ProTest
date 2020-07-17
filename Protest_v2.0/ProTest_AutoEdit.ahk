;; MINI - AUTO EDIT
AutoEdit:
Gosub RemoveToolTip
; Fenster richtig darstellen
if WinExist(GuiF3) OR WinExist(GuiF8)
	{
	if WinExist(GuiF3)
		WinGetPos,MenuPosX, MenuPosY, MenuWidth, MenuHeight, %GuiF3%
	else if WinExist(GuiF8)
		WinGetPos,MenuPosX, MenuPosY, MenuWidth, MenuHeight, %GuiF8%
	FineTuneX := Ceil((ScreenWidth * 5)/StandardWidth)
	AutoEditX := MenuPosX + MenuWidth + FineTuneX
	AutoEditY := MenuPosY
	5GuiCenter := ""
	}
else
	{
	5GuiCenter := "Center"
	AutoEditX := 0
	AutoEditY := 0
	}
; PreloadList laden
if !FileExist(PreloadListPath)
	{
	PreloadListBox := ""
	PreloadList := ""
	5GuiDis := DisON
	}
else
	{
	PreloadListBox := ""
	5GuiDis := DisOFF
	Loop, Read, %PreloadListPath%
		PreloadListBox .= A_LoopReadLine . "|"
	FileRead, PreloadList , %PreloadListPath%
	}

Gui, 5:+AlwaysOnTop ToolWindow
Gui, 5:Add, Groupbox, x9 y10 w322 h180 cNavy, Hinterlegte Preloads durchsuchen
Gui, 5:Add, Edit, x16 y30 w120 h20 %5GuiDis% ve_SearchEdit g5GuiSearchEdit
Gui, 5:Add, Button, x28 y55 w100 h20 %5GuiDis% g5GuiAddPreload, Hinzufügen
Gui, 5:Add, Button, x28 y77 w100 h20 g5GuiLoadPreloadList, Lade Preloadliste
Gui, 5:Add, Listbox, x152 y30 w170 h150  %5GuiDis% Sort vAutoEditResult , % PreloadListBox
Gui, 5:Add, Text, x50 y195 w280 h20, Hinweis: Preloadliste abhängig von LFD-Eingabe
Gui, 5:Show, x%AutoEditX% y%AutoEditY% %5GuiCenter% Autosize, AutoEdit
return 

5GuiClose:
5GuiEscape:
if WinActive(GuiF3)
	WinActivate, %GuiF3%
else if WinActive(GuiF8)
	WinActivate, %GuiF8%
Gui 5:Destroy
return

5GuiLoadPreloadList:
CheckWorkWindow()
FileGetSize, FileSize , %PreloadListPath%
if (FileSize != 0 AND FileSize != "")
	{
	MsgBox, 4132, PreloadList vorhanden, Neue Liste Laden und alte Liste (%PreloadListName%) löschen?
	IfMsgBox, YES
		{
		FileDelete, %PreloadListPath%
		}
	else
		Exit
	}
MsgWindow("Lade Preload-Liste...")
L_LoadPreloadList()
MsgWindow()
Gui 5:Destroy
Goto AutoEdit
return 

5GuiSearchEdit:
gui 5:Submit, Nohide
GuiControl, ChooseString, AutoEditResult, %e_SearchEdit%
return 

; Adding Preload to F3 or F8
5GuiAddPreload:
gui 5:Submit, Nohide
AddComplete := false
if WinExist(GuiF3)
	{
	gui 3:Submit, Nohide
	GoSub 3GuiSaveInput
	Gui 3:Destroy
	GoSub 3GuiSetControls
	Loop, 8 {
	ControlValue := GetIniValue(ProjectFile, LFDFinderMenu, "e_LFD_PLN" . A_Index)
	if (ControlValue = "ERROR" OR ControlValue = "")
		{
		SaveIniValue(ProjectFile, LFDFinderMenu, "e_LFD_PLN" . A_Index,  AutoEditResult)
		AddComplete := true
		Gui 3:Destroy
		Goto 3GuiSetControls
		Exit
		}
	} ; ende loop
	} ; ende GuiF3
else if WinExist(GuiF8)
	{
	gui 8:Submit, Nohide
	GoSub 8GuiSaveInput
	Gui 8:Destroy
	GoSub 8GuiSetControls
	Loop, 5 {
	ControlValue := GetIniValue(ProjectFile, PreloadReaderMenu, "e_PLN" . A_Index)
	if (ControlValue = "ERROR" OR ControlValue = "")
		{
		SaveIniValue(ProjectFile, PreloadReaderMenu, "e_PLN" . A_Index,  AutoEditResult)
		AddComplete := true
		Gui 8:Destroy
		Goto 8GuiSetControls
		Exit
		}
	} ; ende loop
	} ; ende GuiF8
if (AddComplete = false)
	{
	MsgBox, 4096, Kein Platz mehr, Edits sind schon voll :(!
	Exit
	}
return 