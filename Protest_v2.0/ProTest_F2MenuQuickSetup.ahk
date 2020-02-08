;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;   (F2) Quick Setup    ;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

F2::
ListLines Off
If WinExist(GuiF2)
	WinActivate, %GuiF2%
else
	Goto F2Routine
return

F2Routine:
2GuiReset := false

2GuiSetControls:
if (2GuiReset = true)
	{
	DeleteIniSection(ProjectFile, QuickSetupMenu)
	2GuiReset := false
	}
;GuiControlArray
2GuiControlArray := [
, "r_Main1", "r_Main2", "r_Main3"
, "r_LFD1", "r_LFD2", "r_LFD3"
, "r_AdvancedON", "r_AdvancedOFF"
, "e_Beginning", "cb_UseLFD"
, "e_Stopfn1", "e_Stopfn2", "e_Stopfn3",
, "dd_SkipButton", 
, "c_Beginning", "c_SendDate", 
, "c_SkipLastPart"
, "c_StudyWithLFDs" ]
for i, control in 2GuiControlArray
	{
	%control% := GetIniValue(ProjectFile, QuickSetupMenu, control)
	if (%control% = "ERROR")
		%control% := GetIniValue(BasicFile, QuickSetupMenu, control)
	}

; Datumseingaben
e_Day := GetIniValue(ProjectFile, QuickSetupMenu, "e_Day", A_DD)
e_Month := GetIniValue(ProjectFile, QuickSetupMenu, "e_Month", A_MM )
e_Year := GetIniValue(ProjectFile, QuickSetupMenu, "e_Year", A_YYYY )

; Untermenüs (de-)aktivieren
if (r_Main1 = 1)
	{
	IntroDis := DisOFF
	IntroDisLFD := DisOFF
	fnDis := DisON
	}
else if (r_Main2 = 1)
	{	
	IntroDis := DisON
	IntroDisLFD := DisON
	fnDis := DisOFF
	}
else if (r_Main3 = 1)
	{
	IntroDis := DisOFF
	IntroDisLFD := DisOFF
	fnDis := DisOFF
	}

LFDList := CreateLFDList("F2")

if (c_StudyWithLFDs = 0)
	IntroDisLFD := DisON

;;;;;; GUI Menü ;;;;;
; Hauptauswahl
Gui, 2:+AlwaysOnTop
Gui, 2:Add, Radio, x60  y15 w70 h15 Checked%r_Main1% vr_Main1 gOnlyIntro, Intro
Gui, 2:Add, Radio, x130 y15 w70 h15 Checked%r_Main2% vr_Main2 gOnlyfnSearch, fn Suche
Gui, 2:Add, Radio, x220 y15 w70 h15 Checked%r_Main3% vr_Main3 gboth, Beides
; Intro
Gui, 2:Add, Groupbox, x10 y40 w293 h228 cNavy %IntroDis%, Intro
; 1. Beginning
Gui, 2:Add, Groupbox, x17 y60 w280 h69 %IntroDis% cBlack, Anfang
Gui, 2:Add, CheckBox, x32 y75 w70  h20 %IntroDis% Checked%c_Beginning% vc_Beginning, Starten mit:
Gui, 2:Add, Edit,    x112 y75 w160 h20 %IntroDis% ve_Beginning, %e_Beginning%
Gui, 2:Add, CheckBox, x32 y98 w100 h20 %IntroDis% Checked%c_SendDate%  vc_SendDate, Datum eingeben
Gui, 2:Add, Edit,    x137 y99 w20 h20 %IntroDis% Center ve_Day, %e_Day%
Gui, 2:Add, Edit,    x162 y99 w20 h20 %IntroDis% Center ve_Month, %e_Month%
Gui, 2:Add, Edit,    x187 y99 w35 h20 %IntroDis% Center ve_Year, %e_Year%
; 2. LFD 
Gui, 2:Add, Groupbox, x17 y124 w280 h90 cBlack %IntroDisLFD%, LFD Eingabe
Gui, 2:Add, Radio, x32 y140 w40  h20 %IntroDisLFD% Checked%r_LFD1% vr_LFD1 g2GuiShowButton, LFD:
Gui, 2:Add, Radio, x32 y162 w140 h20 %IntroDisLFD% Checked%r_LFD2% vr_LFD2 gOpenF3, Suche mit LFD-Finder
Gui, 2:Add, Radio, x32 y184 w140  h20 %IntroDisLFD% Checked%r_LFD3% vr_LFD3 g2GuiShowButton, keine Eingabe
Gui, 2:Add, ComboBox, x77 y140 w75 h100 %IntroDisLFD% Limit%LFDLimit%  vcb_UseLFD, % LFDList
Gui, 2:Add, Button, x170 y140 w75 h20 %IntroDisLFD% g2GuiShowLFDValues, LFD Werte
Gui, 2:Add, CheckBox, x180 y185 w100  h20 %IntroDis% Checked%c_StudyWithLFDs% vc_StudyWithLFDs g2GuiLFDsAvailable, LFDs vorhanden
; 3. Last Part 
Gui, 2:Add, Groupbox, x17 y210 w280 h50 %IntroDis% cBlack , Haupt-Intro
Gui, 2:Add, CheckBox, x32 y230 w84  h20 %IntroDis% Checked%c_SkipLastPart% vc_SkipLastPart, %ue%berspringen!
; fn Search
Gui, 2:Add, Groupbox, x10 y273 w293 h108 %fnDis% cNavy, fn Suche
Gui, 2:Add, Text, x19 y295 w90  h20 %fnDis%, STOP fn(s):
Gui, 2:Add, Edit, x90 y292 w46 h20 %fnDis% Limit%fnLimit% Center  ve_Stopfn1, %e_Stopfn1%
Gui, 2:Add, Edit, x140 y292 w46 h20 %fnDis% Limit%fnLimit% Center ve_Stopfn2, %e_Stopfn2%
Gui, 2:Add, Edit, x190 y292 w46 h20 %fnDis% Limit%fnLimit% Center  ve_Stopfn3, %e_Stopfn3%
Gui, 2:Add, Text, x19 y323  w92 h20 %fnDis%, Skip-Button:
Gui, 2:Add, DropDownList, x90 y321 w110 h70 %fnDis% AltSubmit Center Choose%dd_SkipButton% vdd_SkipButton, verweigert||Clear&Back
Gui, 2:Add, Text, x19 y353 w135 h20 %fnDis%, Erweiterte Optionen:
Gui, 2:Add, Radio, x130 y352 w35 h15 %fnDis% Checked%r_AdvancedON% vr_AdvancedON gOpenF4, Ein
Gui, 2:Add, Radio, x170 y352 w35 h15 %fnDis% Checked%r_AdvancedOFF% vr_AdvancedOFF, Aus
; Abschluss
Gui, 2:Add, Button, x10 y390 w50 h25 g2GuiHelp, Hilfe
Gui, 2:Add, Button, x70 y390 w50 h25 g2GuiResetControls, Reset
Gui, 2:Add, Button, x223 y390 w80 h25 g2GuiGO Default, Ok
Gui, 2:Show, x850 y480 Autosize Center, %GuiF2%
if (r_LFD3 = 1 OR r_LFD2 = 1) 
	Control, Hide ,, LFD Werte, %GuiF2%
if (r_LFD1 = 1 or r_LFD2 = 1)
	Control, Hide ,, LFDs vorhanden , %GuiF2%
return

2GuiClose:
2GuiEscape:
GoSub 2GuiSaveInput
Gui 2:Destroy
Gui 3:Destroy
Gui 4:Destroy
return

OpenF3:
GoSub 2GuiShowButton
Send, {F3}
return

OpenF4:
Send, {F4}
return

2GuiShowLFDValues:
ShowSelectedLFDValues("cb_UseLFD")
return

2GuiLFDsAvailable:
Gui 2:Submit, NoHide
GoSub 2GuiSaveInput
Gui 2:Destroy
Goto 2GuiSetControls	
return 

2GuiShowButton:
Gui 2:Submit, NoHide
if (r_LFD1 = 1)
	{
	Control, Show ,, LFD Werte, %GuiF2%
	Control, Hide ,, LFDs vorhanden , %GuiF2%
	}
if (r_LFD2 = 1)
	{
	Control, Hide ,, LFD Werte, %GuiF2%
	Control, Hide ,, LFDs vorhanden , %GuiF2%
	}
if (r_LFD3 = 1)
	{
	Control, Hide ,, LFD Werte, %GuiF2%
	Control, Show ,, LFDs vorhanden , %GuiF2%
	}
return 

2GuiResetControls:
MsgBox, 4132, Reset?, Reset %GuiF2% (to basic settings)?
IfMsgBox, YES
	{
	Gui 2:Destroy
	2GuiReset := true
	Goto 2GuiSetControls
	}
return 

2GuiHelp:
ShowHelpWindow(GuiF2)
return

OnlyIntro:
OnlyfnSearch:
both:
GoSub 2GuiSaveInput
Gui 2:Destroy
Goto 2GuiSetControls
return

2GuiSaveInput:
ListLines Off
Gui 2:Submit, NoHide
for i, control in 2GuiControlArray
	{
	if (%control% = GetIniValue(BasicFile, QuickSetupMenu, control))
		DeleteIniValue(ProjectFile, QuickSetupMenu, control)
	else
		SaveIniValue(ProjectFile, QuickSetupMenu, control, %control%)
	}
; Datumseingaben speichern
SaveIniValue(ProjectFile, QuickSetupMenu, "e_Day", e_Day)
SaveIniValue(ProjectFile, QuickSetupMenu, "e_Month", e_Month)
SaveIniValue(ProjectFile, QuickSetupMenu, "e_Year", e_Year)
return

2GuiGo:
;Eingaben sinnvoll?
Gui 2:Submit, NoHide
if (r_Main1 = 1 or r_Main3 = 1) and (c_Beginning = 1 or c_SendDate = 1) and (c_SkipLastPart = 1) and (r_LFD3 = 1)
	{
	if (c_StudyWithLFDs = 1)
		Msgbox, 4096, Ups! , Sorry, diese Kombination funktioniert nicht!
	return 
	}
else if (r_Main3 = 1 AND (r_LFD1 = 1 or r_LFD2 = 1) AND c_SkipLastPart = 0)
	{
	Msgbox, 4096, Ups! , Sorry, diese Kombination funktioniert nicht!
	return 
	}
if (r_LFD1 = 1 AND cb_UseLFD = "")
	{
	Msgbox, 4096, Ups! , Keine LFD eingeben!
	return
	}
	
GoSub 2GuiSaveInput
Gui 2:Destroy
ProtestMainFunction()
return
