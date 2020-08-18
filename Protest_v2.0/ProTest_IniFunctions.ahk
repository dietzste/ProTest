;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;      INI FUNCTIONS      ;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

GetIniValue(File, Section, key, params*){
local 
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
	SectionDetails := "Keine Preload-Infos hinterlegt"
	return SectionDetails
	}
return SectionDetails
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