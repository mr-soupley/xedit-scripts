{
	Soupy Utils 1.0.0
	By -- i_am_the_soup
	
	This script contains a selection of various utility functions
}

unit SPGM_Util;

{
	Opens a file selection form
	Returns the selected file
}
function SelectFile: IInterface;
var
	i: integer;
	clb: TCheckListBox;
	frm: TForm;
begin
	frm := frmFileSelect;
	clb := TCheckListBox(frm.FindComponent('CheckListBox1'));
	clb.Items.Add('<New File>');
	for i := Pred(FileCount) downto 0 do
		if(GetFileName(FileByIndex(i)) <> 'Skyrim.Hardcoded.keep.this.with.the.exe.and.otherwise.ignore.it.I.really.mean.it.dat') then
			clb.Items.InsertObject(1, GetFileName(FileByIndex(i)), FileByIndex(i));
	if(frm.ShowModal = mrOk) then
		for i := 0 to Pred(clb.Items.Count) do
			if(clb.Checked[i]) then begin
				if i = 0 then Result := AddNewFile else
					Result := ObjectToElement(clb.Items.Objects[i]);
				Break;
			end;
	frm.Free;
end;
end.