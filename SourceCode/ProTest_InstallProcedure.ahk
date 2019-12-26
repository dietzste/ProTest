;;; INSTALL PROCEDURE ;;;

; Create Directories Vars
Capture2TextWorkDir :=  A_Workingdir . "\Capture2Text"
Folder_imageformats := Capture2TextWorkDir . "\imageformats"
Folder_platforms 	:= Capture2TextWorkDir . "\platforms"
Folder_tessdata 	:= Capture2TextWorkDir . "\tessdata"
Folder_texttospeech := Capture2TextWorkDir . "\texttospeech"

; Create File Vars
File1 	:= Capture2TextWorkDir . "\Capture2Text.exe"
File2 	:= Capture2TextWorkDir . "\msvcp140.dll"
File3 	:= Capture2TextWorkDir . "\pvt.cppan.demo.danbloomberg.leptonica-1.74.4.dll"
File4 	:= Capture2TextWorkDir . "\pvt.cppan.demo.jpeg-9.2.0.dll"
File5 	:= Capture2TextWorkDir . "\pvt.cppan.demo.madler.zlib-1.2.11.dll"
File6 	:= Capture2TextWorkDir . "\pvt.cppan.demo.openjpeg.openjp2-2.1.2.dll"
File7 	:= Capture2TextWorkDir . "\pvt.cppan.demo.png-1.6.30.dll"
File8 	:= Capture2TextWorkDir . "\pvt.cppan.demo.tiff-4.0.8.dll"
File9 	:= Capture2TextWorkDir . "\pvt.cppan.demo.webp-0.6.0.dll"
File10 	:= Capture2TextWorkDir . "\pvt.cppan.demo.xz_utils.lzma-5.2.3.dll"
File11 	:= Capture2TextWorkDir . "\Qt5Core.dll"
File12 	:= Capture2TextWorkDir . "\Qt5Gui.dll"
File13 	:= Capture2TextWorkDir . "\Qt5Network.dll"
File14 	:= Capture2TextWorkDir . "\Qt5TextToSpeech.dll"
File15 	:= Capture2TextWorkDir . "\Qt5Widgets.dll"
File16 	:= Capture2TextWorkDir . "\readme.txt"
File17 	:= Capture2TextWorkDir . "\tesseract400.dll"
File18 	:= Capture2TextWorkDir . "\vcruntime140.dll"
File19 	:= Folder_imageformats . "\qtiff.dll"
File20 	:= Folder_platforms    . "\qwindows.dll"
File21 	:= Folder_tessdata 	   . "\deu.traineddata"
File22 	:= Folder_texttospeech . "\qtexttospeech_sapi.dll"


; Create Directories
FileCreateDir, %Capture2TextWorkDir%
FileCreateDir, %Folder_imageformats%
FileCreateDir, %Folder_platforms%
FileCreateDir, %Folder_tessdata%
FileCreateDir, %Folder_texttospeech%

; "Install" Files
FileInstall, C:\Users\Mensch\Desktop\Protest_Workflow\Protest_v2.0\Capture2Text\Capture2Text.exe , %File1%
