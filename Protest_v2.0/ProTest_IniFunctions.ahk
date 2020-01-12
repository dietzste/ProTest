;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;      INI FUNCTIONS      ;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

GetIniValue(File, Section, key, params*){
local 
global TempFile
ListLines Off
if (params.MaxIndex() = 1)
	IniRead, Value, %File%, %Section%, %key%, % params[1]
else
	IniRead, Value, %File%, %Section%, %key%
Value := RegExReplace( RegExReplace( Value, "^.+\K.(?<=;).+" ), "\s+$" )
return Value
}

SaveIniValue(File, Section, key, value){
local
ListLines Off
IniWrite, %value%, %File%, %Section%, %key%
}

DeleteIniValue(File, Section, key){
ListLines Off
IniDelete, %File%, %Section%, %key%
}

DeleteIniSection(File, Section){
ListLines Off
IniDelete, %File%, %Section%
}

GetIniSection(File, Section){
local
IniRead, SectionDetails, %File%, %Section%
if (SectionDetails = "")
	{
	SectionDetails := "No details on: '" . section . "'"
	return SectionDetails
	}
else
	{
	loop, 8 {
	SectionDetails := StrReplace(SectionDetails, "we" . A_Index . "=")
	}
	return SectionDetails
	} ;ende else
}

GetIniSectionClean(File, Section){
local
IniRead, SectionDetails, %File%, %Section%
SectionDetailsClean := ""
Loop, Parse, SectionDetails , "`n"
	{
	CleanLine := Substr(A_LoopField, 1, (InStr(A_LoopField, ";") - 1)) . "`r"
	SectionDetailsClean .= CleanLine 
	}
return SectionDetailsClean
} ; ende function

GetIniSectionNames(File){
IniRead, OutputVarSectionNames, %File%
return OutputVarSectionNames
}