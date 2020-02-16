SET nameSpace=%1
SET workDir=%2

SET cscDir=%~dp0\csc\
SET refDir=%cscDir%Reference\

SET dllFileName=%workDir%%nameSpace%.dll
if exist %dllFileName% (del %dllFileName%);
SET pdbFileName=%workDir%%nameSpace%.pdb
if exist %pdbFileName% (del %pdbFileName%);
SET appConfigFileName=%workDir%app.config
if exist %appConfigFileName% (del %appConfigFileName%);

copy NUL %appConfigFileName%

%cscDir%csc.exe ^
/noconfig /nowarn:1701,1702,2008 /nostdlib+ /errorreport:prompt /warn:4 /define:DEBUG;TRACE /errorendlocation /preferreduilang:en-US /highentropyva+ ^
/reference:%refDir%Microsoft.CSharp.dll ^
/reference:%refDir%mscorlib.dll ^
/reference:%refDir%Newtonsoft.Json.dll ^
/reference:%refDir%System.ComponentModel.Composition.dll ^
/reference:%refDir%System.ComponentModel.DataAnnotations.dll ^
/reference:%refDir%System.Core.dll ^
/reference:%refDir%System.Data.DataSetExtensions.dll ^
/reference:%refDir%System.Data.dll ^
/reference:%refDir%System.dll ^
/reference:%refDir%System.Net.Http.dll ^
/reference:%refDir%System.Runtime.Serialization.dll ^
/reference:%refDir%System.Xml.dll ^
/reference:%refDir%System.Xml.Linq.dll ^
/target:library /filealign:512 /optimize- /out:%dllFileName% ^
/subsystemversion:6.00 /utf8output /deterministic+ /langversion:7.3 %workDir%%nameSpace%.cs