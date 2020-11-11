;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;     Hilfe-Texte Menues      ;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

#if WinExist(GuiF2) and WinActive(GuiF2)
F1::
Goto 2GuiHelp
#if

#if WinExist(GuiF3) and WinActive(GuiF3)
F1::
Goto 3GuiHelp
#if

#if WinExist(GuiF4) and WinActive(GuiF4)
F1::
Goto 4GuiHelp
#if

#if WinExist(GuiF8) and WinActive(GuiF8)
F1::
Goto 8GuiHelp
#if

#if WinExist(GuiF10) and WinActive(GuiF10)
F1::
Goto 10GuiHelp
#if

ShowHelpWindow(Window){
local
global ScreenWidth, ScreenHeight, StandardWidth, StandardHeight
global GuiF2, GuiF3, GuiF4, GuiF8, GuiF10
GetHelpText(Window, GuiHelptext)
SetTimer, WinMoveMsgBox, 50
; Finetuning
if (Window = GuiF3)
	FinetuneY := (ScreenHeight * -30)/StandardHeight
else
	FinetuneY := 0

FineTuneX := Ceil((ScreenWidth * 5)/StandardWidth)
WinGetPos,MenuPosX,MenuPosY, MenuWidth, MenuHeight, %Window%
HelpMsgX := MenuPosX + MenuWidth + FineTuneX
HelpMsgY := MenuPosY + FineTuneY
MsgBox, 4096, Hilfe %Window%, %GuiHelptext%

WinMoveMsgBox:
SetTimer, WinMoveMsgBox, OFF
WinMove, Hilfe %Window%,, %HelpMsgX%, %HelpMsgY%
return 
}


GetHelpText(Window, Byref HelpText){
local
global x_ADDToStartfnX, x_ADDToStartfnY
global GuiF2, GuiF3, GuiF4, GuiF8, GuiF10
global ProjectFile, BasicFile, LibraryFile
global ProjectName, TempFileName

if (Window = GuiF2)
{
2GuiHelpText =
(
Aktionsmodus:
Je nach Aktionsmodus werden einige Einstellungen aktiviert
oder deaktiviert. Beim Aktionsmodus 'Beides' werden zuerst
Eingangsfragen �bersprungen, anschlie�end wird zu einer
gew�nschten Fragenummer gesprungen.

LFD Eingabe:
Die Auswahl 'Suche nach passender LFD' �ffnet ein weiteres
Men� (F3), in dem die Preload-Auspr�gungen f�r die 
gew�nschte LFD definiert werden k�nnen. Falls in der 
aktuellen Erhebung keine LFDs vorhanden sind, muss bei 
der Auswahl 'Keine Eingabe' die Checkbox 'LFDs vorhanden' 
abgew�hlt werden.

Zu einer Fragenummer springen: 
Eingaben unter 'Fragenummer(n)' k�nnen einstellig oder 
mehrstellig sein (z.B. 3, 30, 30312 usw.). Skip-Button
'verweigert': dr�ckt verweigert Button. 'Clear&Back' dr�ckt
Clear und Back hintereinander (= R�ckw�rtssuche).
Beim Ausw�hlen von 'Erweiterte Optionen' (Ein) �ffnet sich
das F4-Men� (Erweiterte Optionen).

{Enter} = dr�ckt Enter Taste
)
Helptext = %2GuiHelpText%
return 
}

if (Window = GuiF3)
{
3GuiHelpText =
(
Namen und Wunschwerte der Preloadvariablen eingeben. 
Minuszeichen ("-") = 'keine Angabe'. 

Beispiele:
Name Preload	Wunschwert	Ausschluss 
sexPRE		2		-
sexPRE		-		1
sexPRE		-		

Bsp. 1: Suche Preload (sexPRE) mit dem Wert 2
Bsp. 2: Suche Preload (sexPRE), Wert darf nicht 1 sein. 
Bsp. 3: Suche Preload (sexPRE), Wert darf nicht leer sein.

Start LFD ist der StartPunkt f�r die LFD-Suche.

Button 'LFD Werte' zeigt Werte der Start LFD an
(Quelle: %TempFileName%). 

Preload-Liste: �ffnet einen weiteren Editor, mit dem die 
Preloadliste geladen werden kann. �ber den Button 
'Hinzuf�gen' werden gew�hlte Preload-Variablen in das 
Men� eingef�gt. (Auch im Fenster F8 anwendbar)
)
Helptext = %3GuiHelpText%
return 
}

if (Window = GuiF4)
{
4GuiHelpText =
(
Beispiele:
fn	Wert
24104	2
32620	Ende
20103	Get(sexPRE)
290102	[Aufgaben]

Legende:
2	   -> gibt Wert 2 ein
Ende	   -> beendet Durchlauf
Get(sexPRE) -> ruft Preload sexPRE ab, gibt Wert ein
[Aufgaben]  -> dr�ckt Button mit dem Wort 'Aufgaben'

Zum Abrufen meherer Preload-Werte 
Get(Proload1/Preload2...) eingeben.

)
Helptext = %4GuiHelpText%
return 
}

if (Window = GuiF8)
{
global PreloadDetailsFile
8GuiHelpText := "Automatische Konvertierung f�r:`n"
8GuiHelpText .= GetIniSection(PreloadDetailsFile, "Converter")
8GuiHelpText .= "`r`rz.B Eingabe '2101P1' sucht `rnach Preload 'P41598PRE'"
Helptext = %8GuiHelpText%
return 
}

if (Window = GuiF10)
{
10GuiHelpText =
(
Pos X/Y		= Startkoordinaten des Suchfensters 
L�nge 		= L�nge des Suchfensters (in Pixel)
Breite		= Breite des Suchfensters (in Pixel)

Der Button 'Show' zeigt den (ungef�hren) Bereich
an, in der die Texterkennung sucht. Der Button 
'Test' f�hrt eine Testung der Einstellungen durch.
Scale factor (Default: 4.0)

Einstellungen �ndern:
1) Button �ndern dr�cken
2) Button Show dr�cken
3) Maus an gew�nschte Position bewegen
4) Strg und linke Maustaste gleichzeitig dr�cken
4) mit den Pfeiltasten Bereich vergr��ern/verkleinern
5) Button Speichern dr�cken

Scale Factor Scan: 
Button 'Test' und die Shift-Taste gleichzeitig
dr�cken. ProTest  f�hrt eine Testung mit versch.
Scale-Faktoren durch.

Einstellungen dauerhaft speichern:
Button 'Speichern' und die Shift-Taste gleichzeitig 
dr�cken. Und anschlie�ende Message-Box best�tigen. 

)
Helptext = %10GuiHelpText%
return 
}

}