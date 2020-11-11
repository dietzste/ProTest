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
Eingangsfragen übersprungen, anschließend wird zu einer
gewünschten Fragenummer gesprungen.

LFD Eingabe:
Die Auswahl 'Suche nach passender LFD' öffnet ein weiteres
Menü (F3), in dem die Preload-Ausprägungen für die 
gewünschte LFD definiert werden können. Falls in der 
aktuellen Erhebung keine LFDs vorhanden sind, muss bei 
der Auswahl 'Keine Eingabe' die Checkbox 'LFDs vorhanden' 
abgewählt werden.

Zu einer Fragenummer springen: 
Eingaben unter 'Fragenummer(n)' können einstellig oder 
mehrstellig sein (z.B. 3, 30, 30312 usw.). Skip-Button
'verweigert': drückt verweigert Button. 'Clear&Back' drückt
Clear und Back hintereinander (= Rückwärtssuche).
Beim Auswählen von 'Erweiterte Optionen' (Ein) öffnet sich
das F4-Menü (Erweiterte Optionen).

{Enter} = drückt Enter Taste
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

Start LFD ist der StartPunkt für die LFD-Suche.

Button 'LFD Werte' zeigt Werte der Start LFD an
(Quelle: %TempFileName%). 

Preload-Liste: öffnet einen weiteren Editor, mit dem die 
Preloadliste geladen werden kann. über den Button 
'Hinzufügen' werden gewählte Preload-Variablen in das 
Menü eingefügt. (Auch im Fenster F8 anwendbar)
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
[Aufgaben]  -> drückt Button mit dem Wort 'Aufgaben'

Zum Abrufen meherer Preload-Werte 
Get(Proload1/Preload2...) eingeben.

)
Helptext = %4GuiHelpText%
return 
}

if (Window = GuiF8)
{
global PreloadDetailsFile
8GuiHelpText := "Automatische Konvertierung für:`n"
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
Länge 		= Länge des Suchfensters (in Pixel)
Breite		= Breite des Suchfensters (in Pixel)

Der Button 'Show' zeigt den (ungefähren) Bereich
an, in der die Texterkennung sucht. Der Button 
'Test' führt eine Testung der Einstellungen durch.
Scale factor (Default: 4.0)

Einstellungen ändern:
1) Button ändern drücken
2) Button Show drücken
3) Maus an gewünschte Position bewegen
4) Strg und linke Maustaste gleichzeitig drücken
4) mit den Pfeiltasten Bereich vergrößern/verkleinern
5) Button Speichern drücken

Scale Factor Scan: 
Button 'Test' und die Shift-Taste gleichzeitig
drücken. ProTest  führt eine Testung mit versch.
Scale-Faktoren durch.

Einstellungen dauerhaft speichern:
Button 'Speichern' und die Shift-Taste gleichzeitig 
drücken. Und anschließende Message-Box bestätigen. 

)
Helptext = %10GuiHelpText%
return 
}

}