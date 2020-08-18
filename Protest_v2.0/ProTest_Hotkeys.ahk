;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;     TEST SECTION       ;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

#if WinExist("Notepad++")
^t::
return 

F5::
if (A_IsCompiled != 1)
	{
	Send, ^S
	SaveToHistory("RELOAD")
	Reload
	}
return
#if

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;   Basic WORK HOTKEYS   ;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

+F5::
	SaveToHistory("RELOAD")
	if (CurrentLFD != "")
		SaveIniValue(ProjectFile, "ProjectFiles", "CurrentLFD", CurrentLFD)
	Reload
return

F6::
	PAUSE
	if (A_IsPaused = 0)
		SaveToHistory("PAUSE")
Return

+ESC::
	Suspend
Return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;    ADVANCED HOTKEYS    ;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

+F3::
Goto AutoEdit
return

+F8::
Goto AutoEdit
return

#if WinActive(GuiF3)
~Tab::
if (TabVar != "")
	{
	SetCurrentEditFieldText(GuiF3, TabVar)
	TabVar := ""
	}
return
#if

#if WinActive(GuiF8)
~Tab::
if (TabVar != "")
	{
	SetCurrentEditFieldText(GuiF8, TabVar)
	TabVar := ""
	}
return
#if 

#if WinActive(WorkWindow)
^m::
L_SkipXModul()
return

^d::
SendDate()
return

^r::
L_RestartQ()
SaveToHistory("########### RESTART ###########")
return

F9::
L_RemoteFeedbackTest()
return
#if

F1::
MsgBox, 4096 , �berblick Tastenk�rzel (F1) - Version: %ProTestVersion%, 
(
Interaktion mit  ProTest:
F6		= Vorgang pausieren/fortfahren
F12		= ProTest beenden
Shift + F5%A_Tab%%A_Tab%= ProTest neu starten
Shift + ESC%A_Tab%= Tastenk�rzel (de-)aktivieren
Strg + u 		= pr�ft auf Updates
F9		= Remote Feedback Test

Funktionsmen�s:
F2		= %GuiF2%
F3		= %GuiF3%
F4		= %GuiF4%
F7		= %GuiF7%
F8		= %GuiF8%
F10		= %GuiF10%
Men� offen + F1	= �ffnet jeweiliges Hilfefenster
Shift + F3/F8	= �ffnet AutoEdit Men�

Interaktion mit NIPO-Software:
Strg + d 	 	= gibt aktuelles Datum ein
Strg + m 	 	= �berspringt XModul
Strg + r 	 	= startet Befragung neu
Bild hoch		= dr�ckt verweigert-Button
Bild runter	= dr�ckt Clear- & Back-Button 
)
return

F12::
Gui, 12: +AlwaysOnTop ToolWindow
Gui, 12:Add, Groupbox, x10 y10 w185 h48 cnavy, L�schen
Gui, 12:Add, CheckBox, x20 y30 w170  h20 vc_DeleteHistoryFile, % HistoryFileName
Gui, 12:Add, Button,   x10 y62 w50 h25 g12GuiBack, Zur�ck
Gui, 12:Add, Button, x135 y62 w60 h25 Default g12GuiExit, Beenden
Gui, 12:Show, Autosize Center, %GuiF12%
return

12GuiBack:
12GuiClose:
12GuiEscape:
Gui 12:Destroy
return

12GuiExit:
Gui 12:Submit
If (c_DeleteHistoryFile = 1)
	FileDelete, %HistoryFile%
CloseCapture2Text(Captur2TextPID)
return

CloseCapture2Text(Captur2TextPID){
if (Captur2TextPID != 0)
	{
	Process, Close , %Captur2TextPID%
	Process, WaitClose , %Captur2TextPID%
	}
Gui 12:Destroy
ExitApp
}