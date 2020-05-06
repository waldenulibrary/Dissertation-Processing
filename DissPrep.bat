rem change directory
cd /d %cd%\downloadedFiles

rem unzip files with 7zip
"C:\Program Files\7-Zip\7z.exe" e *.zip

rem combine XML files
@echo on
cd /d %cd%\downloadedFiles
rem clean up
erase %0.xml
rem add root node
echo ^<root^> > %0.txt
rem add all the xml files
type *.xml >> %0.txt
rem close root node
echo ^<^/root^> >> %0.txt
rem rename to xml
ren %0.txt %0.xml

rem move file
cd ..\
move DissPrep.bat.txt %~dp0\downloadedFiles

rem remove XML namespace
cd /d %cd%\downloadedFiles
type DissPrep.bat.txt | find /v /i "8859" > CombinedXML.txt

rem add XML namespace to top
echo ^<?xml version="1.0" encoding="ISO-8859-1"?^> > temp.txt
type CombinedXML.txt >> temp.txt
move /y temp.txt CombinedXML.txt

rem move file to main folder
move CombinedXML.txt %~dp0

rem delete extra files
del "*.txt"
del "*.zip"
del "*.xml"

rem convert CombineXML.txt to xml file
cd ..\
rename *.txt *.xml