OCR(Part, OCRIndex){
local 
global Capture2TextIniFileAppDataPath, fast, ultrafast
static OCR
static OCRFirstWord := true
SetKeydelay, ultrafast
BlockInput, MouseMove 
Clipboard =
loop, 3 {
;;; OCR Field Search ;;;
if (A_Index = 1)
	{
	if (OCRIndex <= 1)
		OCRJustierung(Part)
	else
		Send #{r}
	}
else
	{
	if (A_Index = 2)
		Send #{r}
	else
		OCRJustierung(Part)
	}

;;; WAIT FOR CLIPBOARD ;;;
if (A_Index = 1) OR (A_Index = 2 AND OCR != "")
	ClipWait, 0.8
OCR := ""
OCR := Clipboard
if (OCR = "")
	SaveToHistory("VERBOSE:","OCR Empty")
;MsgBox, 4096, Test OCR Result, %OCR%

;;;; RESET FIRSTWORD SEARCH ;;;
if (A_Index = 2)
	IniWrite, true, %Capture2TextIniFileAppDataPath%, ForwardTextLineCapture, FirstWord
	
;;; OCR Clean UP ;;;
if (OCR != "")
	OCR := OCRCleanUp(OCR, Part)
OCRLength := StrLen(OCR)
BlockInput, MouseMoveOff

;;; ChECK INPUT / SEND BACK TO CALLER ;;;
if (OCR != "")
	{
	if (A_Index = 1 AND OCRLength <= 3)
		{
		OCRFirstWord := false
		SaveToHistory("VERBOSE:","OCR Short - 2. Try")
		IniWrite, false, %Capture2TextIniFileAppDataPath%, ForwardTextLineCapture, FirstWord
		Sleep, 300
		Continue
		}
	else 
		{
		if (Part != "Intro")
			{
			if Instr(Part, "!") 
				SaveToHistory(OCR, Part)
			else
				SaveToHistory(OCR, "(OCR)")
			}
		ListLines, On
		return OCR
		}
	}
else
	{
	if (A_Index <= 2)
		{
		SaveToHistory("VERBOSE:","OCR Empty (" . A_Index . ")")
		Sleep, 400
		Continue
		}
	else
		return OCR
	}
		
} ; ende loop
} ; ende function OCR

;;; OCR MOUSE MOVE FUNCTION ;;;

OCRJustierung(Part){
local
OCRMoveMouse(Part, "StartPos")
Send #{q}
OCRMoveMouse(Part, "EndPos")
Click
}

OCRMoveMouse(Part, Mode){
local
global e_fnStartPosX, e_fnStartPosY, e_fnEndPosX, e_fnEndPosY
CoordMode, Mouse, Client
;; SET SPEED CURSOR ;;
if (Part = "Test")
	SpeedCursor := 25
else
	SpeedCursor := 0

;; GET POSTION MODE ;;
;;; OCR ;;;
if (Mode = "StartPos")
	{
	PositionX := e_fnStartPosX
	PositionY := e_fnStartPosY
	}
else if (Mode = "EndPos")
	{
	PositionX := e_fnEndPosX
	PositionY := e_fnEndPosY
	}
	
;; MOVE MOUSE ;;
MouseMove, %PositionX%, %PositionY% , %SpeedCursor%
}

;;; OCR CLEAN UP FUNCTION ;;;
OCRCleanUp(OCR, Part){
local
OCR := StrReplace(OCR, "\?", "7") ; ? = 7 
OCR := RegExReplace(OCR, "\W") ; keine special Charakters
OCR := StrReplace(OCR, "_")
AlphaMatch := 0
Loop, Parse, OCR
	{
	if A_LoopField is alpha
		++AlphaMatch
	if (AlphaMatch = 2)
		{
		SecondAlphaPosition := A_Index
		Break
		}
	}
if (AlphaMatch > 1)
	OCR := SubStr(OCR, 1 , --SecondAlphaPosition)
return OCR
}