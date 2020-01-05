;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;    ADVANCED HOTKEYS    ;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

^d::
SendDate()
return

F1::
If (AddOns = false)
	AddOnComment := "(AddOn) "
else
	AddOnComment := ""

MsgBox, 4096 , F1 - %GuiF1%,
(
Basic Hotkeys:
F6		= Vorgang pausieren/fortfahren
Shift + F5%A_Tab%%A_Tab%= Startet Skript neu (Restart)
Shift + ESC%A_Tab%= Hotkeys (de-)aktivieren 
F12		= ProTest beenden

Men%ue%s:
F2		= %GuiF2%
F3		= %GuiF3%
F4		= %GuiF4% 
F7		= %AddOnComment%%GuiF7%
F8		= %GuiF8%
F9		= %GuiF9%
F10		= %GuiF10%

Weitere:
Men%ue% offen + F1	= %oe%ffnet jeweiliges Hilfefenster
Strg + d 	 	= gibt aktuelles Datum ein
Shift + F3/F8	= %AddOnComment%%oe%ffnet AutoEdit Men%ue%
Strg + m 	 	= %AddOnComment%%ue%berspringt XModul
Strg + l 	 	= %AddOnComment%%oe%ffnet LibraryTool
)
return

F9::
L_RemoteFeedbackTest()
return

F12::
Gui, 12: +AlwaysOnTop ToolWindow
Gui, 12:Add, Groupbox, x10 y10 w185 h90 cnavy, L%oe%schen
Gui, 12:Add, CheckBox, x20 y30 w170  h20 vc_DeleteTempFile,	% TempFileName
Gui, 12:Add, CheckBox, x20 y52 w170  h20 vc_DeleteHistoryFile, % HistoryFileName
Gui, 12:Add, CheckBox, x20 y74 w170  h20 vc_DeletePreloadList, % PreloadListName
Gui, 12:Add, Button,   x10 y105 w50 h25 g12GuiBack, Zur%ue%ck
Gui, 12:Add, Button, x135 y105 w60 h25 Default g12GuiExit, Beenden
Gui, 12:Show, Autosize Center, %GuiF12%
if (AddOns = false)
	{
	Control, Disable ,, %HistoryFileName%, %GuiF12%
	Control, Disable ,, %PreloadListName%, %GuiF12%
	}
return

12GuiBack:
12GuiClose:
12GuiEscape:
Gui 12:Destroy
return

12GuiExit:
Gui 12:Submit
If (c_DeleteTempFile = 1)
	FileDelete, %TempFile%
If (c_DeleteHistoryFile = 1)
	FileDelete, %HistoryFile%
If (c_DeletePreloadList = 1)
	FileDelete, %PreloadListPath%

Process, Exist , %Captur2TextPID%
if (ErrorLevel = Captur2TextPID)
	{
	Process, Close , %Captur2TextPID%
	Process, WaitClose , %Captur2TextPID%
	}
Gui 12:Destroy
ExitApp
return