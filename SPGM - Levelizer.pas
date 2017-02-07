{
	Levelizer (name pending) 0.1a
	By -- i_am_the_soup
	
	This script is used to quickly and easily add items to leveled lists.
	
	Guide:
	1. - Select the leveld list(s) and the item(s) you'd like to add to them.
	2. - Apply the script. A form will open up.
	3. - Select the leveled list you'd like to add items to, and click [OPEN EDITOR].
	4. - Check the items you'd like to add to the list, and fill out the textboxes.
		(e.g: 	[X] LItemWeaponAny1H 	[1] [3]
				[ ] LItemWeaponAny2H	[LVL] [CNT]
				[X] Daedric Mace of Burning [47] [1]
				[X] Daedric Armor of Peerless Wielding [12] [1]
		)
	5. - Click [COMMIT]. The selected items will be added to the active list. The edit form will NOT close once commited, but you will get a message confirming that the items were indeed added.
}

unit UserScript;

uses mteFunctions;

var
	slListEntries, slEditEntries: TStringList;
	lstListSelects, lstEditSelects, lstEditLevels, lstEditCounts: TList;
	listFrm, editFrm: TForm;
	btnListDone, btnListShowEdit, btnEditCommit, btnEditClear, btnEditDone: TButton;
	pnlListBottom, pnlEditBottom: TPanel;
	listSb, editSb: TScrollBox;
	activeList: IInterface;

function NewContainerElement(container: IInterface; path: string): IInterface;
var
	entry: IInterface;
begin
	entry := ElementByPath(container, 'Leveled List Entries');
	if Assigned(entry) then
		Result := ElementAssign(entry, HighInteger, nil, false)
	else
		entry := Add(container, 'Leveled List Entries', true);
		Result := ElementByIndex(entry, 0);
end;

procedure AddToLeveledList(list, item: IInterface; level, count: integer);
var
	entry: IInterface;
begin	
	entry := NewContainerElement(list, 'Leveled List Entries');
	senv(entry, 'LVLO\Level', level);
	senv(entry, 'LVLO\Reference', GetLoadOrderFormID(item));
	senv(entry, 'LVLO\Count', count);
end;

procedure ShowEditor;
var
	i: integer;
begin
	for i := 0 to lstListSelects.Count do begin
		if TRadioButton(lstListSelects[i]).Checked = true then begin
			activeList := ObjectToElement(slListEntries.Objects[i]);
			Break;
		end;
	end;
	
	AddMessage('Editing ' + geev(activeList, 'EDID'));
	editFrm.ShowModal;
end;

procedure Clear;
var
	i: integer;
begin
	for i := 0 to slEditEntries.Count-1 do begin
		TCheckBox(lstEditSelects[i]).Checked := false;
		TEdit(lstEditLevels[i]).Text := 'LVL';
		TEdit(lstEditCounts[i]).Text := 'CNT';
	end;
end;

procedure Commit;
var
	i: integer;
	ced, led: TEdit;
begin
	for i := 0 to slEditEntries.Count-1 do begin
		led := TEdit(lstEditLevels[i]);
		ced := TEdit(lstEditCounts[i]);
		if (TCheckBox(lstEditSelects[i]).Checked <> true)
			or (led.Text = 'LVL') or (led.Text = '')
			or (ced.Text = 'CNT') or (ced.Text = '')
		then Continue;
		
		AddMessage('	Adding ' + slEditEntries[i] + ' to list ' + geev(activeList, 'EDID') + ', level is ' + led.Text + ', count is ' + ced.Text);
		AddToLeveledList(activeList, ObjectToElement(slEditEntries.Objects[i]), StrToInt(led.Text), StrToInt(ced.Text));
	end;
end;

procedure AddListEntry(le: string);
var
	rBtnSel: TRadioButton;
begin
	rBtnSel := TRadioButton.Create(listFrm);
	rBtnSel.Parent := listSb;
	rBtnSel.Left := 5;
	rBtnSel.Caption := le;
	rBtnSel.Width := listSb.Width - 34;
	if(lstListSelects.Count = 0) then begin
		rBtnSel.Top := 10;
		rBtnSel.Checked := true;
	end
	else begin
		rBtnSel.Top := TRadioButton(lstListSelects[lstListSelects.Count-1]).Top + 20;
	end;
	lstListSelects.Add(rBtnSel);
end;

procedure AddEditEntry(ee: string);
var
	cbSel: TCheckBox;
	edLvl, edCnt: TEdit;
	scrollbarWidth: integer;
begin	
	if slEditEntries.Count > 10 then
		scrollbarWidth := 17
	else
		scrollbarWidth := 0;
	
	cbSel := TCheckBox.Create(editFrm);
	cbSel.Parent := editSb;
	cbSel.Left := 6;
	cbSel.Caption := ee;
	cbSel.Width := editSb.Width - 85 - scrollbarWidth;
	if lstEditSelects.Count = 0 then
		cbSel.Top := 10
	else
		cbSel.Top := TCheckBox(lstEditSelects[lstEditSelects.Count-1]).Top + 20;
	
	lstEditSelects.Add(cbSel);
	
	edLvl := TEdit.Create(editFrm);
	edLvl.Parent := editSb;
	edLvl.Width := 36;
	edLvl.Left := editSb.Width - edLvl.Width*2 - 13 - scrollbarWidth;
	edLvl.Top := cbSel.Top;
	edLvl.Text := 'LVL';
	lstEditLevels.Add(edLvl);
	
	edCnt := TEdit.Create(editFrm);
	edCnt.Parent := editSb;
	edCnt.Width := 36;
	edCnt.Left := edLvl.Left + edLvl.Width + 4;
	edCnt.Top := cbSel.Top;
	edCnt.Text := 'CNT';
	lstEditCounts.Add(edCnt);
end;

procedure CreateForms;
var
	i: integer;
begin
	listFrm := TForm.Create(nil);
	editFrm := TForm.Create(nil);
	try
		listFrm.Width := 300;
		listFrm.Height := 500;
		listFrm.Position := poScreenCenter;
		listFrm.BorderStyle := bsDialog;
		listFrm.Caption := 'Levelizer 0.1a ---- Select a leveled list to edit..';
		
		editFrm.Width := 400;
		editFrm.Height := 300;
		editFrm.Position := poScreenCenter;
		editFrm.BorderStyle := bsDialog;
		editFrm.Caption := 'Levelizer 0.1a ---- Select the items to add to the list..';
		
		listSb := TScrollBox.Create(listFrm);
		listSb.Parent := listFrm;
		listSb.Width := listFrm.Width - 5;
		listSb.Height := listFrm.Height - 62;
		
		editSb := TScrollBox.Create(editFrm);
		editSb.Parent := editFrm;
		editSb.Width := editFrm.Width - 5;
		editSb.Height := editFrm.Height - 62;
		
		pnlListBottom := TPanel.Create(listFrm);
		pnlListBottom.Parent := listFrm;
		pnlListBottom.BevelOuter := bvNone;
		pnlListBottom.Align := alBottom;
		pnlListBottom.Height := 32;
		pnlListBottom.Width := listFrm.Width-5;
		
		pnlEditBottom := TPanel.Create(editFrm);
		pnlEditBottom.Parent := editFrm;
		pnlEditBottom.BevelOuter := bvNone;
		pnlEditBottom.Align := alBottom;
		pnlEditBottom.Height := 32;
		pnlEditBottom.Width := editFrm.Width-5;
		
		btnListDone := TButton.Create(listFrm);
		btnListDone.Parent := pnlListBottom;
		btnListDone.Top := 3;
		btnListDone.Left := 8;
		btnListDone.Caption := 'DONE';
		btnListDone.ModalResult := mrOk;
		
		btnListShowEdit := TButton.Create(listFrm);
		btnListShowEdit.Parent := pnlListBottom;
		btnListShowEdit.Top := 3;
		btnListShowEdit.Left := pnlListBottom.Width - btnListShowEdit.Width - 8;
		btnListShowEdit.Caption := 'SHOW EDITOR';
		btnListShowEdit.OnClick := ShowEditor;
		
		btnEditDone := TButton.Create(editFrm);
		btnEditDone.Parent := pnlEditBottom;
		btnEditDone.Top := 3;
		btnEditDone.Left := 8;
		btnEditDone.Caption := 'DONE';
		btnEditDone.ModalResult := mrOk;
		
		btnEditCommit := TButton.Create(editFrm);
		btnEditCommit.Parent := pnlEditBottom;
		btnEditCommit.Top := 3;
		btnEditCommit.Left := pnlEditBottom.Width - btnEditCommit.Width*2 - 16;
		btnEditCommit.Caption := 'COMMIT';
		btnEditCommit.OnClick := Commit;
		btnEditCommit.Hint := 'ALL SELECTED ITEMS WILL BE ADDED TO THE LIST AS SOON AS THE BUTTON IS CLICKED.'#10#13'THIS CAN ONLY BE UNDONE BY REMOVING THE ADDED ENTRIES.';
		btnEditCommit.ShowHint := true;
		
		btnEditClear := TButton.Create(editFrm);
		btnEditClear.Parent := pnlEditBottom;
		btnEditClear.Top := 3;
		btnEditClear.Left := pnlEditBottom.Width - btnEditClear.Width - 8;
		btnEditClear.Caption := 'CLEAR';
		btnEditClear.OnClick := Clear;

		for i := 0 to slEditEntries.Count-1 do
			AddEditEntry(slEditEntries[i]);
		
		for i := 0 to slListEntries.Count-1 do
			AddListEntry(slListEntries[i]);
		
		listFrm.ShowModal;
	finally
		editFrm.Free;
		listFrm.Free;
	end;
end;

function Initialize: integer;
begin
	slListEntries := TStringList.Create;
	slEditEntries := TStringList.Create;
	lstEditSelects := TList.Create;
	lstListSelects := TList.Create;
	lstEditLevels := TList.Create;
	lstEditCounts := TList.Create;
end;

function Process(e: IInterface): integer;
var
	sig: string;
begin
	sig := geev(e, 'Record Header\Signature');
	if (sig = 'WEAP') or (sig = 'ARMO') then slEditEntries.AddObject(geev(e, 'FULL'), TObject(e));
	if sig = 'LVLI' then begin
		slListEntries.AddObject(geev(e, 'EDID'), TObject(e));
		slEditEntries.AddObject(geev(e, 'EDID'), TObject(e));
	end;
end;

function Finalize: integer;
begin
	CreateForms;
end;
end.