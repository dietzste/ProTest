OCR(Part, OCRIndex){
local 
global ultrafast
global RawOCRTestOutput
global SleepWhileOCREmpty
SetKeydelay, ultrafast
BlockInput, MouseMove 
Clipboard =
loop, 3 {
;;; OCR Field Search ;;;
if (A_Index = 1)
	{
	if (OCRIndex = 0)
		OCRJustierung(Part)
	else
		Send #{r}
	}
else
	{
	if (A_Index = 2)
		sleep, SleepWhileOCREmpty
	if (A_Index = 3)
		sleep, (SleepWhileOCREmpty/2)
	Send #{r}	
	}

;;; WAIT FOR CLIPBOARD ;;;
if (A_Index = 1) OR (A_Index = 2 AND OCR != "")
	ClipWait, 0.8
OCR := ""
OCR := Clipboard
if (RawOCRTestOutput = "true")
	{
	BlockInput, MouseMoveOff
	return OCR
	}

;;; OCR CleanUp ;;;
if (OCR != "")
	OCR := OCRCleanUp(OCR, Part)
OCRLength := StrLen(OCR)
BlockInput, MouseMoveOff

;;; ChECK INPUT / SEND BACK TO CALLER ;;;
if (OCR != "")
	{
	if (Part = "Test")
		{
		OCRVariation := ""
		fnOCRWithoutAlpha  := fnCorrectionRemoveLastAlpha(OCR)
		if (OCR != fnOCRWithoutAlpha)
			OCRVariation := fnOCRWithoutAlpha
		fnOCR6a := fnCorrectionReplaceLast6witha(OCR)
		if (OCR != fnOCR6a)
			{
			if (OCRVariation = "")
				OCRVariation := fnOCR6a
			else
				OCRVariation .= " und " fnOCR6a
			}
		if (OCRVariation != "")
			{
			OCRRemark := "Erkannt wurde " . OCR . ". In der Fragenbibliothek wird auch nach " . OCRVariation . " gesucht (AutoKorrektur)."
			return OCRRemark
			}
		}
	return OCR
	}
else
	{
	if (A_Index = 2 and SleepWhileOCREmpty < 1500 and Part = "fn-Suche")
		SleepWhileOCREmpty := SleepWhileOCREmpty + 50
	SaveToHistory("VERBOSE:","OCR Empty (" . A_Index . ")", "OCRIndex: " . OCRIndex, SleepWhileOCREmpty)
	Continue
	}
} ; ende loop
return OCR
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

;; SET SPEED CURSOR ;;
if (Part = "Test")
	SpeedCursor := 15
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
CoordMode, Mouse, Window
MouseMove, %PositionX%, %PositionY% , %SpeedCursor%
}

;;; OCR CLEAN UP FUNCTION ;;;
OCRCleanUp(OCR, Part){
local
global AllowAlphas
OCR := StrReplace(OCR, "?", "7") ; ? = 7
; Replace control characters
OCR := RegExReplace(OCR, "[\x00-\x1F\x7F]")
AlphaMatch := 0
HashedOCR := ""
Loop, Parse, OCR
	{
	; entferne alle außer a-zA-Z0-9_
	if A_LoopField is alnum
		{
		if A_LoopField is alpha
			++AlphaMatch
		if (AlphaMatch > AllowAlphas)
			Break
		HashedOCR .= A_LoopField
		}
	}
return HashedOCR
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;  OCR CORRECTION  ;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;

AutoCorrection(fnOCR, ByRef fnValue){
local
global LibraryFile, fnBib

; RemoveLastAlpha
fnOCRWithoutAlpha := fnCorrectionRemoveLastAlpha(fnOCR)
if (fnOCRWithoutAlpha != fnOCR)
	{
	fnValue := GetIniValue(LibraryFile, fnBib, fnOCRWithoutAlpha)
	if (fnValue != "ERROR")
		return fnOCRWithoutAlpha
	}

; ReplaceLast 6 with letter a
fnOCR6a := fnCorrectionReplaceLast6witha(fnOCR)
if (fnOCR6a != fnOCR)
	{
	fnValue := GetIniValue(LibraryFile, fnBib , fnOCR6a)
	if (fnValue != "ERROR")
		return fnOCR6a
	}
return fnOCR
}

fnCorrectionRemoveLastAlpha(fnOCR){
local
global RemoveLastAlpha
if (RemoveLastAlpha = "false")
	return fnOCR
LastDigit := Substr(fnOCR, Strlen(fnOCR))
if LastDigit is alpha
	{
	fnOCRWithoutAlpha := SubStr(fnOCR, 1, (Strlen(fnOCR)-1))
	SaveToHistory("VERBOSE:", "AutoCorrection, Probiere " . fnOCRWithoutAlpha, fnOCR, "RemoveLastAlpha")
	return fnOCRWithoutAlpha
	}
return fnOCR
}

fnCorrectionReplaceLast6witha(fnOCR){
local
global ReplaceLast6witha
if (ReplaceLast6witha = "false")
	return fnOCR
if Substr(fnOCR, Strlen(fnOCR)) = "6"
	{
	; last 6 is letter a
	fnOCR6a := Substr(fnOCR, 1, (Strlen(fnOCR)-1)) . "a"
	SaveToHistory("VERBOSE:", "AutoCorrection, Probiere " . fnOCR6a, fnOCR, "ReplaceLast6witha")
	return fnOCR6a
	}
return fnOCR
}