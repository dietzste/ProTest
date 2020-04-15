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
else if (Window = GuiF10)
	FinetuneY := (ScreenHeight * 100)/StandardHeight 
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
global ae, ue, oe, sz
global AOx
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
'Beide' %ue%berspringt erst das Intro, dann erfolgt
die fn-Suche.

Auswahl 'Suche mit LFD-Finder' %oe%ffnet F3-Men%ue%,
'Erweiterte Optionen' (Ein) %oe%fnnet das F4-Men%ue%. 

Falls die aktuelle Erhebung ohne LFDs arbeitet: Bei
Auswahl 'Keine Eingabe' die Checkbox 'LFDs vorhanden'
abw%ae%hlen.

Stop-fn(s): 
Eingaben k%oe%nnen einstellig oder mehrstellig sein (z.B. 3).

Skip-Button 'verweigert': dr%ue%ckt verweigert 
Button. 'Clear&Back' dr%ue%ckt Clear und Back
hintereinander (=R%ue%w%ae%rtssuche).

{Enter} = dr%ue%ckt Enter Taste

Priorit%ae%t der fn-Suche:
1) Stop-fns
2) Eingaben der Erweiterten Optionen (F4)
3) NagFns -> Library.ini -> [fnNag]
)
Helptext = %2GuiHelpText%
return 
}

if (AOx = true)
{
F3AutoEditZusatz =
(
AutoEdit: %oe%ffnet einen weiteren Editor, mit dem die 
Preloadliste geladen werden kann. %ue%ber den Button 
'Hinzuf%ue%gen' werden gew%ae%hlte Preload-Variablen in das 
Men%ue% eingef%ue%gt. (Auch im Fenster F8 anwendbar)
)
}
else
	F3AutoEditZusatz = AutoEdit: AddOn

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

Start LFD ist der StartPunkt f%ue%r die LFD-Suche.

Button 'LFD Werte' zeigt Werte der Start LFD an
(Quelle: %TempFileName%). 

%F3AutoEditZusatz%
)
Helptext = %3GuiHelpText%
return 
}

if (AOx = false)
	F4XModulZusatz = AddOn: X-Pr%ue%fmodul %ue%berspringen
else
	F4XModulZusatz =

if (Window = GuiF4)
{
4GuiHelpText =
(
Zul%ae%ssig sind sind neben Zahlen 
folgende Funktionsw%oe%rter:
Ende/Stop	-> beendet/stoppt Durchlauf 
'Preload'	-> holt Preloadwert von 'Preload'
[Button]	-> dr%ue%ckt Button
{Enter}	-> dr%ue%ckt NUR Enter

Beispiele:
fn	Wert
24104	2
32620	Ende
20103	sexPRE
290102	[Aufgaben]

%F4XModulZusatz%
[Adresstool noch nicht implementiert]
)
Helptext = %4GuiHelpText%
return 
}

if (Window = GuiF8)
{
8GuiHelpText := "Automatische Konvertierung f" . ue . "r:`n"
8GuiHelpText .= GetIniSection(LibraryFile, "Converter")
8GuiHelpText .= "`r`rz.B Eingabe '2101P1' sucht `rnach Preload 'P41598PRE'"
Helptext = %8GuiHelpText%
return 
}

if (Window = GuiF10)
{
10GuiHelpText =
(
fn Start/End	= Positionen der fn
Scale		= ScaleFactor (Default: 4.0)

Der Button 'Show' zeigt den (ungef%ae%hren) Bereich
an, in der die Texterkennung sucht. Der Button 
'Test' f%ue%hrt eine Testung der Einstellungen durch.

Checkbox 'abh%ae%ngig' = Anhand der Position 
fn Start werden die Parameter fn End bestimmt:
fn End X = fn Start X + %x_ADDToStartfnX%
fn End Y = fn Start Y + %x_ADDToStartfnY%

Einstellungen dauerhaft speichern:
Button 'Speichern' und die Shift-Taste gleichzeitig 
dr%ue%cken. Und anschlie%sz%ende Message-Box best%ae%tigen. 

)
Helptext = %10GuiHelpText%
return 
}

}