{
	Copyfier 0.1a
	By -- i_am_the_soup
	
	Copies the selected records into the destination file multiple times.
	Guide:
	1. Select the records to be copied.
	2. Apply the script and select the destination file.
	3. Enter the amount of times to copy and click GO.
}

unit UserScript;

var
	destFile: IInterface;
	lstRecords: TList;
	amount: integer;

procedure SelectFile;
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
				if i = 0 then destFile := AddNewFile else
					destFile := ObjectToElement(clb.Items.Objects[i]);
				Break;
			end;
	frm.Free;
end;
	
function Initialize: integer;
var
	i, j: integer;
	frm: TForm;
	lblAmount: TLabel;
	edAmount: TEdit;
	btnGo: TButton;
begin
	while not Assigned(destFile) do SelectFile;
	frm := TForm.Create(nil);
	try
		frm.Caption := 'Copyfier 0.1a';
		frm.Height := 61;
		frm.Width := 15;
		frm.Position := poScreenCenter;
		frm.BorderStyle := bsDialog;
		
		lblAmount := TLabel.Create(frm);
		lblAmount.Parent := frm;
		lblAmount.Top := 10;
		lblAmount.Left := 5;
		lblAmount.Caption := 'Amount: ';
		frm.Width := frm.Width + lblAmount.Width + 5;
		
		edAmount := TEdit.Create(frm);
		edAmount.Parent := frm;
		edAmount.Width := 30;
		edAmount.Top := 5;
		edAmount.Left := lblAmount.Left + lblAmount.Width + 5;
		frm.Width := frm.Width + edAmount.Width + 5;
		
		btnGo := TButton.Create(frm);
		btnGo.Parent := frm;
		btnGo.Width := 25;
		btnGo.Left := edAmount.Left + edAmount.Width + 5;
		btnGo.Top := edAmount.Top;
		btnGo.Caption := 'GO';
		btnGo.ModalResult := mrOk;
		frm.Width := frm.Width + btnGo.Width + 5;
		
		frm.ShowModal;
		
		amount := StrToInt(edAmount.Text);
	finally
	frm.Free;
	end;
end;

function Process(e: IInterface): integer;
var
	i: integer;
begin
	AddRequiredElementMasters(e, destFile, false);
	for i := 0 to amount-1 do
		wbCopyElementToFile(e, destFile, true, true);
end;
end.