{
	Soupy Worldanator 1.0.0
	By -- i-am-the-soup
	
	Copies a worldspace and changes it's FormIDs
	
	Usage:
		1. - Select the worldspace to copy and select the destination file
		2. - Enter the starting FormID (the first two digits should match the load order of the file)
		3. - ???
		4. - Profit
}

unit UserScript;

uses SPGM_Util;

var
	newFID: cardinal;
	destFile: IInterface;

function Initialize: integer;
begin
	newFID := 0;
	while not Assigned(destFile) do begin
		AddMessage('Select a destination file.');
		destFile := SelectFile;
	end;
end;


function Process(e: IInterface): integer;
var
	m, newElt: IInterface;
	oldFID: cardinal;
	s: string;
begin
	AddRequiredElementMasters(e, destFile, false);
	newElt := wbCopyElementToFile(e, destFile, false, true);
	oldFID := GetLoadOrderFormID(newElt);
	while newFID = 0 do begin
		s := InputBox('Enter', 'New starting FormID', IntToHex64(oldFID, 8));
		newFID := StrToInt64('$' + s);
	end;
	
	m := MasterOrSelf(e);
	
	if not Equals(m, e) then
		exit;
	
	while ReferencedByCount(m) > 0 do
		CompareExchangeFormID(ReferencedByIndex(m, 0), oldFID, newFID);
	
	SetLoadOrderFormID(newElt, newFID);
	
	inc(newFID);
end;
end.
	