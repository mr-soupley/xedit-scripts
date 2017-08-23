{
	Soupy Enchantifier 1.0.0
	By -- i_am_the_soup
	
	This script is used to enchant selected items in bulk.
	
	Guide:
	1. - Select the enchantment(s) to be applied, and the item(s) to apply them to.
	2. - Apply the script. A form will open up.
	3. - Fill out the textboxes. SUFFIX is the text appended to the end of the item's name, while CHARGES is the enchantment charge.
		(e.g: EnchWeaponFire02 [Burning] [1000]) - The 'of' is not needed, it's added automatically.
	4. - Click [GO], select the destination file, and wait.
}

unit UserScript;

uses mteFunctions;
uses SPGM_Util;

var
	slEnchantments, slItems: TStringList;
	lstEnchantmentSuffixes, lstEnchantmentAmounts: TList;
	frm: TForm;
	btnGo, btnCancel, btnSave, btnLoad: TButton;
	sb: TScrollBox;
	pnlBottom: TPanel;
	destRecord: IInterface;
	OpenDialog: TOpenDialog;
	SaveDialog: TSaveDialog;

procedure AddEnchantmentEntry(echt: string);
var
	lb: TLabel;
	edn, eda: TEdit;
begin

	lb := TLabel.Create(frm);
	lb.Parent := sb;
	lb.Left := 8;
	if(lstEnchantmentAmounts.Count = 0) then
		lb.Top := 10
	else
		lb.Top := TEdit(lstEnchantmentAmounts[lstEnchantmentAmounts.Count-1]).Top + 30;
	
	lb.Caption := echt;
	lb.Width := round(sb.Width / 8) * 3 - 16;
	
	edn := TEdit.Create(frm);
	edn.Parent := sb;
	edn.Top := lb.Top;
	edn.Width := round(sb.Width / 8) * 4 - 10;
	edn.Left := lb.Left + lb.Width + 8;
	edn.Text := 'SUFFIX';
	lstEnchantmentSuffixes.Add(edn);
	
	eda := TEdit.Create(frm);
	eda.Parent := sb;
	eda.Top := lb.Top;
	eda.Width := round(sb.Width / 8) * 1 - 8;
	eda.Left := edn.Left + edn.Width + 2;
	eda.Text := 'CHARGES';
	lstEnchantmentAmounts.Add(eda);
end;

procedure LoadFromFile;
var
	i, si: integer;
	slLoad: TStringList;
	eid, esf, eam, ln: string;
begin
	slLoad := TStringList.Create;
	if OpenDialog.Execute then begin
		slLoad.LoadFromFile(OpenDialog.FileName);
	
		for i := 0 to slLoad.Count - 1 do begin
			ln := slLoad.ValueFromIndex[i];
			eid := slLoad.Names[i];
			si := slEnchantments.IndexOf(eid);
			if si = -1 then Continue;

			esf := CopyFromTo(ln, 1, Pos(',', ln) - 1);
			eam := CopyFromTo(ln, Pos(',', ln) + 1, Length(ln));
			
			TEdit(lstEnchantmentSuffixes[si]).Text := esf;
			TEdit(lstEnchantmentAmounts[si]).Text := eam;
		end;
	end;
	
	slLoad.Free;	
end;

procedure SaveToFile;
var
	i: integer;
	ln, es, as: string;
	slSave: TStringList;
begin
	slSave := TStringList.Create;
	
	if SaveDialog.Execute then begin
		for i := 0 to slEnchantments.Count - 1 do begin
			es := TEdit(lstEnchantmentSuffixes[i]).Text;
			as := Tedit(lstEnchantmentAmounts[i]).Text;
			if (es = 'SUFFIX') or (es = '') or (as = 'CHARGES') or (as = '') then Continue;
			
			ln := slEnchantments[i];
			ln := ln + '=' + es + ',' + as;
			slSave.Add(ln);
		end;
		
		slSave.SaveToFile(SaveDialog.FileName);
	end;
end;

function EnchantItem(item, echt: IInterface; amount: integer; suffix: string): IInterface;
var
	er: IInterface;
begin
	er := wbCopyElementToFile(item, destRecord, true, true);
	
	SetElementEditValues(er, 'EITM', GetEditValue(echt));
	SetElementEditValues(er, 'EAMT', amount);

	seev(er, 'DATA\Value', round(GetElementEditValues(item, 'DATA\Value') + (0.12 * amount) + (1.4 * (amount / Max(GetElementEditValues(echt, 'ENIT\Enchantment Cost'), 1.0))) * 1.0));
	
	seev(er, 'EDID', 'SPGMAUTOGEN' + HexFormID(er));
	seev(er, 'FULL', geev(item, 'FULL') + ' of ' + suffix);
	
	SetElementEditValues(er, 'CNAM', GetEditValue(item));
	
	Result := er;
end;

procedure OptionsForm;
var
	i: integer;
	clb: TCheckListBox;
begin
	frm := TForm.Create(nil);
	try
		frm.Caption := 'Enchantifier 0.1a';
		frm.Width := 500;
		frm.Height := 360;
		frm.Position := poScreenCenter;
		frm.BorderStyle := bsDialog;
		
		sb := TScrollBox.Create(frm);
		sb.Parent := frm;
		sb.Height := frm.Height - 62;
		sb.Width := frm.Width - 5;
		
		pnlBottom := TPanel.Create(frm);
		pnlBottom.Parent := frm;
		pnlBottom.BevelOuter := bvNone;
		pnlBottom.Align := alBottom;
		pnlBottom.Width := frm.Width-5;
		pnlBottom.Height := 34;
		
		OpenDialog := TOpenDialog.Create(frm);
		OpenDialog.Title := 'Load enchantment list';
		OpenDialog.Filter := 'Text Documents|*.txt';
		OpenDialog.DefaultExt := 'txt';
		OpenDialog.InitialDir := ProgramPath + 'Edit Scripts\';
		
		SaveDialog := TSaveDialog.Create(frm);
		SaveDialog.Title := 'Save enchantment list';
		SaveDialog.Filter := 'Text Documents|*.txt';
		SaveDialog.DefaultExt := 'txt';
		SaveDialog.InitialDir := ProgramPath + 'Edit Scripts\';
		
		btnGo := TButton.Create(frm);
		btnGo.Parent := pnlBottom;
		btnGo.Caption := 'GO';
		btnGo.ModalResult := mrOk;
		btnGo.Left := pnlBottom.Width - btnGo.Width*2 - 16;
		btnGo.Top := 5;
		
		btnCancel := TButton.Create(frm);
		btnCancel.Parent := pnlBottom;
		btnCancel.Caption := 'CANCEL';
		btnCancel.ModalResult := mrCancel;
		btnCancel.Left := pnlBottom.Width - btnCancel.Width - 8;
		btnCancel.Top := btnGo.Top;
		
		btnSave := TButton.Create(frm);
		btnSave.Parent := pnlBottom;
		btnSave.Caption := 'SAVE';
		btnSave.Left := 5;
		btnSave.Top := btnGo.Top;
		btnSave.OnClick := SaveToFile;
		
		btnLoad := TButton.Create(frm);
		btnLoad.Parent := pnlBottom;
		btnLoad.Caption := 'LOAD';
		btnLoad.Left := btnSave.Left + btnSave.Width + 8;
		btnLoad.Top := btnGo.Top;
		btnLoad.OnClick := LoadFromFile;
		
		for i := 0 to slEnchantments.Count - 1 do begin
			AddEnchantmentEntry(slEnchantments[i]);
		end;
		
		if(frm.ShowModal = mrOk) then begin			
			destRecord := SelectFile;
		end;
	finally
		frm.Free;
	end;
end;

function Initialize: integer;
begin
	slEnchantments := TStringList.Create;
	slItems := TStringList.Create;
	lstEnchantmentSuffixes := TList.Create;
	lstEnchantmentAmounts := TList.Create;
end;

function Process(e: IInterface): integer;
var
	sig: string;
begin
	sig := geev(e, 'Record Header\Signature');

	if sig = 'ENCH' then
		slEnchantments.AddObject(geev(e, 'EDID'), TObject(e))
	else if (sig = 'WEAP') or (sig = 'ARMO') then
		slItems.AddObject(geev(e, 'FULL'), TObject(e));
end;

function Finalize: integer;
var
	i, j: integer;
	grp: IInterface;
begin
	OptionsForm;
	
	for i := 0 to slEnchantments.Count-1 do
		AddRequiredElementMasters(ObjectToElement(slEnchantments.Objects[i]), destRecord, false);
	
	for i := 0 to slItems.Count-1 do begin
		AddMessage('Processing item ' + slItems[i]);
		AddRequiredElementMasters(ObjectToElement(slItems.Objects[i]), destRecord, false);
		for j := 0 to slEnchantments.Count-1 do begin
			if (TEdit(lstEnchantmentSuffixes[j]).Text = 'SUFFIX') or (TEdit(lstEnchantmentAmounts[j]).Text = 'CHARGES') then Continue;
			AddMessage('	Adding enchantment ' + geev(ObjectToElement(slEnchantments.Objects[j]), 'FULL'));
			EnchantItem(
				ObjectToElement(slItems.Objects[i]),
				ObjectToElement(slEnchantments.Objects[j]),
				StrToInt(TEdit(lstEnchantmentAmounts[j]).Text),
				TEdit(lstEnchantmentSuffixes[j]).Text);
		end;
	end;
end;
end.
