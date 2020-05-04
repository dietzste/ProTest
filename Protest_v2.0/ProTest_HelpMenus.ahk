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
Je nach Aktionsmodus (Intro, fn Suche, Beides)
werden einige Aktionen (de-)aktiviert. 
'Beide' überspringt erst das Intro, dann erfolgt
die fn-Suche.

Auswahl 'Suche mit LFD-Finder' öffnet F3-Menü,
'Erweiterte Optionen' (Ein) öfnnet das F4-Menü. 

Falls die aktuelle Erhebung ohne LFDs arbeitet: Bei
Auswahl 'Keine Eingabe' die Checkbox 'LFDs vorhanden'
abwählen.

Stop-fn(s): 
Eingaben können einstellig oder mehrstellig sein (z.B. 3).

Skip-Button 'verweigert': drückt verweigert 
Button. 'Clear&Back' drückt Clear und Back
hintereinander (=Rückwärtssuche).

{Enter} = drückt Enter Taste

Priorität der fn-Suche:
1) Stop-fns
2) Eingaben der Erweiterten Optionen (F4)
3) NagFns -> Library.ini -> [fnNag]
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

AutoEdit: öffnet einen weiteren Editor, mit dem die 
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
Zulässig sind sind neben Zahlen 
folgende Funktionswörter:
Ende/Stop	-> beendet/stoppt Durchlauf 
{Enter}	-> drückt NUR Enter
[Button]-> drückt Button

Preloadwert abrufen mit Get(Preload), für
mehrere Get(Proload1/Preload2...) eingeben.

Beispiele:
fn	Wert
24104	2
32620	Ende
20103	Get(sexPRE)
290102	[Aufgaben]

X-Prüfmodul überspringen
[Adresstool noch nicht implementiert]
)
Helptext = %4GuiHelpText%
return 
}

if (Window = GuiF8)
{
8GuiHelpText := "Automatische Konvertierung für:`n"
8GuiHelpText .= GetIniSection(LibraryFile, "Converter")
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
3) Maus an Anfangsposition bewegen, dann x drücken
4) mit den Pfeiltasten Bereich vergrößern/verkleinern
5) Button Speichern drücken

Einstellungen dauerhaft speichern:
Button 'Speichern' und die Shift-Taste gleichzeitig 
drücken. Und anschließende Message-Box bestätigen. 

)
Helptext = %10GuiHelpText%
return 
}

}