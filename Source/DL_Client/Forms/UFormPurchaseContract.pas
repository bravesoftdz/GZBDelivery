{*******************************************************************************
  ����: 289525016@163.com 2017-3-16
  ����: �ɹ���ͬ¼��
*******************************************************************************}
unit UFormPurchaseContract;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  UDataModule, UFormBase, ULibFun, UAdjustForm, USysConst, dxLayoutControl,
  StdCtrls, cxControls, cxGraphics, cxLookAndFeels, cxLookAndFeelPainters,
  cxContainer, cxEdit, cxTextEdit, cxMemo,
  cxMaskEdit, cxDropDownEdit, cxMCListBox, Menus, cxButtons, cxButtonEdit;

type
  TProviderParam = record
    FID   : string;
    FName : string;
    FSaler: string;
  end;

  TMeterailsParam = record
    FID   : string;
    FName : string;
  end;

  TPurchaseContractInfo = record
    FContractno : string;
    FProviderCode:string;
    FProviderName:string;
    FMaterielCode:string;
    FMaterielName:string;
    FPrice:Double;
    FQuantity:Double;
    FRemark:string;
    FQuotaList:TStrings;
  end;
  
  TfFormPurchaseContract = class(TBaseForm)
    dxLayout1Group_Root: TdxLayoutGroup;
    dxLayout1: TdxLayoutControl;
    dxGroup1: TdxLayoutGroup;
    dxGroup2: TdxLayoutGroup;
    BtnOK: TButton;
    dxLayout1Item1: TdxLayoutItem;
    BtnExit: TButton;
    dxLayout1Item2: TdxLayoutItem;
    dxLayout1Group1: TdxLayoutGroup;
    editProvider: TcxButtonEdit;
    dxLayout1Item3: TdxLayoutItem;
    editMateriel: TcxButtonEdit;
    dxLayout1Item4: TdxLayoutItem;
    editContractno: TcxTextEdit;
    dxLayout1Item5: TdxLayoutItem;
    editPrice: TcxTextEdit;
    dxLayout1Item6: TdxLayoutItem;
    editQuantity: TcxTextEdit;
    dxLayout1Item7: TdxLayoutItem;
    editRemark: TcxMemo;
    dxLayout1Item8: TdxLayoutItem;
    dxLayout1Group2: TdxLayoutGroup;
    comQuotaName: TcxComboBox;
    dxLayout1Item9: TdxLayoutItem;
    comQuotaCondition: TcxComboBox;
    dxLayout1Item10: TdxLayoutItem;
    comQuotaValue: TcxComboBox;
    dxLayout1Item11: TdxLayoutItem;
    comPunishCondition: TcxComboBox;
    dxLayout1Item12: TdxLayoutItem;
    dxLayout1Group3: TdxLayoutGroup;
    dxLayout1Group4: TdxLayoutGroup;
    editpunishBasis: TcxTextEdit;
    dxLayout1Item13: TdxLayoutItem;
    editpunishStandard: TcxTextEdit;
    dxLayout1Item14: TdxLayoutItem;
    comPunishMode: TcxComboBox;
    dxLayout1Item15: TdxLayoutItem;
    dxLayout1Group5: TdxLayoutGroup;
    cxMemo2: TcxMemo;
    dxLayout1Item16: TdxLayoutItem;
    InfoList: TcxMCListBox;
    dxLayout1Item17: TdxLayoutItem;
    btnAdd: TcxButton;
    dxLayout1Item18: TdxLayoutItem;
    btnDel: TcxButton;
    dxLayout1Item19: TdxLayoutItem;
    procedure BtnExitClick(Sender: TObject);
    procedure BtnOKClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure comQuotaNamePropertiesChange(Sender: TObject);
    procedure editProviderKeyPress(Sender: TObject; var Key: Char);
    procedure editMaterielKeyPress(Sender: TObject; var Key: Char);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnAddClick(Sender: TObject);
    procedure btnDelClick(Sender: TObject);
  protected
    { Private declarations }
    FProvider: TProviderParam;
    FMeterail: TMeterailsParam;
    FPurchaseContractInfo:TPurchaseContractInfo;
    Fid:string;
    procedure InitFormData(const nID: string);    
    function OnVerifyCtrl(Sender: TObject; var nHint: string): Boolean; virtual;
    function IsDataValid: Boolean; virtual;
    procedure ClearUI;
    procedure FillUI;
    procedure InitComboxControl;    
    {*��֤����*}
    procedure GetSaveSQLList(const nList: TStrings); virtual;
    {*дSQL�б�*}
    procedure AfterSaveData(var nDefault: Boolean); virtual;
    {*��������*}
    class function CreateForm(const nPopedom: string = '';
      const nParam: Pointer = nil): TWinControl; override;
    class function FormID: integer; override;
  end;

{$R *.dfm}
implementation
uses
  UMgrControl,USysDB,USysBusiness,UBusinessPacker,UFormCtrl,Db;
var
  gForm: TfFormPurchaseContract = nil;
  FCommand:Integer;  
  //ȫ��ʹ��
  
procedure TfFormPurchaseContract.BtnExitClick(Sender: TObject);
begin
  Close;
end;

//------------------------------------------------------------------------------
//Desc: д����SQL�б�
procedure TfFormPurchaseContract.GetSaveSQLList(const nList: TStrings);
begin
  nList.Clear;
end;

//Desc: ��֤Sender�������Ƿ���ȷ,������ʾ����
function TfFormPurchaseContract.OnVerifyCtrl(Sender: TObject; var nHint: string): Boolean;
var
  nstr:string;
begin
  Result := False;
  if Sender=editContractno then
  begin
    nstr := Trim(editContractno.Text);
    if nstr ='' then
    begin
      nHint := '��ͬ��Ų���Ϊ��';
      Exit;
    end;
  end;
  if sender=editProvider then
  begin
    nstr := Trim(editProvider.text);
    if nstr ='' then
    begin
      nHint := '��Ӧ�̲���Ϊ��';
      Exit;
    end;
    if (FProvider.FID='') or (FProvider.FName='') then
    begin
      nHint := 'δ��ȷѡ��Ӧ��';
      Exit;
    end; 
  end;
  if sender=editMateriel then
  begin
    nstr := Trim(editMateriel.text);
    if nstr ='' then
    begin
      nHint := 'ԭ���ϲ���Ϊ��';
      Exit;
    end;
    if (FMeterail.FID='') or (FMeterail.FName='') then
    begin
      nHint := 'δ��ȷѡ��ԭ����';
      Exit;
    end;
  end;
  if Sender=editPrice then
  begin
    nStr := Trim(editPrice.Text);
    if nStr='' then
    begin
      nHint := '���۲���Ϊ��';
      exit;
    end;
    if StrToFloatDef(nstr,0)<=0.000001 then
    begin
      nHint := '��¼����ȷ�ĵ���';
      Exit;
    end;
  end;
  if Sender=editQuantity then
  begin
    nStr := Trim(editQuantity.Text);
    if nStr='' then
    begin
      nHint := '��������Ϊ��';
      exit;
    end;
    if StrToFloatDef(nstr,0)<=0.000001 then
    begin
      nHint := '��¼����ȷ������';
      Exit;
    end;
  end;
  Result := True;
end;

//Desc: ��֤�����Ƿ���ȷ
function TfFormPurchaseContract.IsDataValid: Boolean;
var nStr: string;
    nCtrls: TList;
    nObj: TObject;
    i,nCount: integer;
begin
  Result := True;

  nCtrls := TList.Create;
  try
    EnumSubCtrlList(Self, nCtrls);
    nCount := nCtrls.Count - 1;

    for i:=0 to nCount do
    begin
      nObj := TObject(nCtrls[i]);
      if not OnVerifyCtrl(nObj, nStr) then
      begin
        if nObj is TWinControl then
          TWinControl(nObj).SetFocus;
        //xxxxx
        
        if nStr <> '' then
          ShowMsg(nStr, sHint);
        Result := False; Exit;
      end;
    end;
  finally
    nCtrls.Free;
  end;
end;

//Desc: �����������
procedure TfFormPurchaseContract.AfterSaveData(var nDefault: Boolean);
begin

end;

//Desc: ����
procedure TfFormPurchaseContract.BtnOKClick(Sender: TObject);
var
  FListA:Tstrings;
begin
  if not IsDataValid then Exit;
  FListA := TStringList.Create;
  try
    with FListA do
    begin
      Values['ContractNo'] := Trim(editContractno.Text);
      Values['ProviderCode'] := FProvider.FID;
      Values['ProviderName'] := FProvider.FName;
      Values['MeterailCode'] := FMeterail.FID;
      Values['MeterailName'] := FMeterail.FName;
      Values['Price'] := Trim(editPrice.Text);
      Values['Quantity'] := Trim(editQuantity.Text);
      Values['Remark'] := Trim(editRemark.Text);
      Values['QuotaList'] := PackerEncodeStr(InfoList.Items.Text);
    end;
    if FCommand=cCmd_AddData then
    begin
      FID := SavePurchaseContract(PackerEncodeStr(FListA.Text));
      if FID='' then Exit;
      ModalResult := mrOK;
      ShowMsg('�ɹ���ͬ����ɹ�', sHint);
    end
    else if FCommand=cCmd_EditData then
    begin
      FListA.Values['fid'] := Fid;
      ModifyPurchaseContract(PackerEncodeStr(FListA.Text));
      ModalResult := mrOK;
      ShowMsg('�ɹ���ͬ�޸ĳɹ�', sHint);
    end;
  finally
    FListA.Free;
  end;
end;

procedure TfFormPurchaseContract.FormCreate(Sender: TObject);
begin
  inherited;
  editpunishBasis.Clear;
  editpunishStandard.Clear;
  comQuotaName.Properties.DropDownListStyle := lsFixedList;
  comQuotaCondition.Properties.DropDownListStyle := lsFixedList;
  comQuotaValue.Properties.DropDownListStyle := lsFixedList;
  comPunishCondition.Properties.DropDownListStyle := lsFixedList;
  comPunishMode.Properties.DropDownListStyle := lsFixedList;
  InfoList.Delimiter := ',';
  FillChar(FProvider, 1, #0);
  FillChar(FMeterail, 1, #0);
  
  ResetHintAllForm(Self, 'T', sTable_PurchaseContract);
  //���ñ�����

  FPurchaseContractInfo.FQuotaList := TStringList.Create;  
end;

class function TfFormPurchaseContract.CreateForm(const nPopedom: string;
  const nParam: Pointer): TWinControl;
var nP: PFormCommandParam;  
begin
  Result := nil;
  if Assigned(nParam) then
       nP := nParam
  else Exit;
  FCommand := nP.FCommand;
  case nP.FCommand of
    cCmd_AddData:
      begin
        with TfFormPurchaseContract.Create(Application) do
        begin
          Caption := '�ɹ���ͬ - ���';
          ClearUI;
          InitFormData('');
          nP.FCommand := cCmd_ModalResult;
          nP.FParamA := ShowModal;
          Free;
        end;
      end;
    cCmd_EditData:
      begin
        with TfFormPurchaseContract.Create(Application) do
        begin
          Caption := '�ɹ���ͬ -�޸�';
          ClearUI;
          FID := nP.FParamA;
          InitFormData(FID);
          FillUI;
          nP.FCommand := cCmd_ModalResult;
          nP.FParamA := ShowModal;
          Free;
        end;
      end;
    cCmd_ViewData:
      begin
        if not Assigned(gForm) then
        begin
          gForm := TfFormPurchaseContract.Create(Application);
          with gForm do
          begin
            Caption := '�ɹ���ͬ - �鿴';
            FormStyle := fsStayOnTop;
            BtnOK.Visible := False;
          end;
        end;
        with gForm  do
        begin
          FID := nP.FParamA;
          InitFormData(FID);
          if not Showing then Show;
        end;
      end;
    cCmd_FormClose:
      begin
        if Assigned(gForm) then FreeAndNil(gForm);
      end;
  end;
end;

class function TfFormPurchaseContract.FormID: integer;
begin
  Result := cFI_FormPurchaseContract;
end;

procedure TfFormPurchaseContract.comQuotaNamePropertiesChange(
  Sender: TObject);
var
  nStr:string;
  nquota_name:string;
begin
  nquota_name := comQuotaName.Text;
  comQuotaValue.Properties.Items.Clear;
  nStr := 'select reference_value from %s where quota_name=''%s''';
  nStr := Format(nStr,[sTable_PurchaseQuotaStandard,nquota_name]);
  with FDM.QueryTemp(nStr) do
  begin
    First;
    while not Eof do
    begin
      comQuotaValue.Properties.Items.Add(FieldByName('reference_value').AsString);
      Next;
    end;
  end;
  if comQuotaValue.Properties.Items.Count=1 then
  begin
    comQuotaValue.ItemIndex := 0;
  end;
end;

procedure TfFormPurchaseContract.editProviderKeyPress(Sender: TObject;
  var Key: Char);
var nP: TFormCommandParam;
begin
  inherited;
  if Key = Char(VK_RETURN) then
  begin
    Key := #0;
    
    nP.FParamA := EditProvider.Text;
    CreateBaseFormItem(cFI_FormGetProvider, '', @nP);

    if (nP.FCommand = cCmd_ModalResult) and(nP.FParamA = mrOk) then
    with FProvider do
    begin
      FID   := nP.FParamB;
      FName := nP.FParamC;
      FSaler:= nP.FParamE;

      EditProvider.Text := FName;
    end;                               

    EditProvider.SelectAll;
  end;
end;

procedure TfFormPurchaseContract.editMaterielKeyPress(Sender: TObject;
  var Key: Char);
var nP: TFormCommandParam;
begin
  inherited;
  if Key = Char(VK_RETURN) then
  begin
    Key := #0;
    
    nP.FParamA := editMateriel.Text;
    CreateBaseFormItem(cFI_FormGetMeterail, '', @nP);

    if (nP.FCommand = cCmd_ModalResult) and(nP.FParamA = mrOk) then
    with FMeterail do
    begin
      FID := nP.FParamB;
      FName:=nP.FParamC;

      editMateriel.Text := FName;
    end;  

    editMateriel.SelectAll;
  end;
end;

procedure TfFormPurchaseContract.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  FPurchaseContractInfo.FQuotaList.Free;
  inherited;
end;

procedure TfFormPurchaseContract.ClearUI;
begin
  editContractno.Clear;
  editProvider.Clear;
  editMateriel.Clear;
  editPrice.Clear;
  editQuantity.Clear;
  InitComboxControl;
end;

procedure TfFormPurchaseContract.FillUI;
var
  nStr:string;
  i:integer;
begin
  editContractno.Text := FPurchaseContractInfo.FContractno;
  editProvider.Text := FPurchaseContractInfo.FProviderName;
  FProvider.FID := FPurchaseContractInfo.FProviderCode;
  FProvider.FName := FPurchaseContractInfo.FProviderName;
  editMateriel.Text := FPurchaseContractInfo.FMaterielName;
  FMeterail.FID := FPurchaseContractInfo.FMaterielCode;
  FMeterail.FName := FPurchaseContractInfo.FMaterielName;
  editPrice.Text := FloatToStr(FPurchaseContractInfo.FPrice);
  editQuantity.Text := FloatToStr(FPurchaseContractInfo.FQuantity);
  for i := 0 to FPurchaseContractInfo.FQuotaList.Count-1 do
  begin
    nStr := FPurchaseContractInfo.FQuotaList.Strings[i];
    InfoList.Items.Add(nStr);
  end;
end;

procedure TfFormPurchaseContract.InitComboxControl;
var
  nStr:string;
begin
  comQuotaCondition.Properties.Items.Clear;
  comQuotaCondition.Properties.Items.Add('��');
  comQuotaCondition.Properties.Items.Add('��');
  comQuotaCondition.Properties.Items.Add('=');
  comPunishCondition.Properties.Items.Clear;
  comPunishCondition.Properties.Items.Add('<');
  comPunishCondition.Properties.Items.Add('>');
  comPunishMode.Properties.Items.Clear;
  comPunishMode.Properties.Items.Add('����');
  comPunishMode.Properties.Items.Add('����');

  comQuotaName.Properties.Items.Clear;
  nStr := 'select distinct quota_name from %s';
  nStr := Format(nstr,[sTable_PurchaseQuotaStandard]);
  with FDM.QueryTemp(nStr) do
  begin
    First;
    while not Eof do
    begin
      comQuotaName.Properties.Items.Add(FieldByName('quota_name').AsString);
      Next;
    end;
  end;
end;

procedure TfFormPurchaseContract.InitFormData(const nID: string);
var
  nStr:string;
  nDs:TDataSet;
  nName,nCondition,nPunishCondition:string;
  nPunish:string;
  nPunishMode:Integer;
  nValue,nPunishBasic,nPunishStandard:double;
  nsPunishMode:string;
  nsValue,nsPunishBasic,nsPunishStandard:string;
begin
  if nID<>'' then
  begin
    FPurchaseContractInfo.FQuotaList.Clear;
    nStr := 'select * from %s where pcid=''%s''';
    nStr := Format(nStr,[sTable_PurchaseContract,nID]);
    with fdm.QuerySQL(nStr) do
    begin
      FPurchaseContractInfo.FContractno := FieldByName('con_code').AsString;
      FPurchaseContractInfo.FProviderCode := FieldByName('provider_code').AsString;
      FPurchaseContractInfo.FProviderName := FieldByName('provider_name').AsString;
      FPurchaseContractInfo.FMaterielCode := FieldByName('con_materiel_Code').AsString;
      FPurchaseContractInfo.FMaterielName := FieldByName('con_materiel_name').AsString;
      FPurchaseContractInfo.FPrice := FieldByName('con_price').AsFloat;
      FPurchaseContractInfo.FQuantity := FieldByName('con_quantity').AsFloat;
      FPurchaseContractInfo.FRemark := FieldByName('con_remark').AsString;
    end;

    nPunish := '';
    nsPunishMode := '';
    nsValue := '';
    nsPunishBasic := '';
    nsPunishStandard :='';

    nStr := 'select * from %s where pcId=''%s''';
    nStr := Format(nStr,[sTable_PurchaseContractDetail,nID]);
    nDs := fdm.QuerySQL(nStr);

    while not nDs.Eof do
    begin
      nName := nDs.FieldByName('quota_name').AsString;
      nCondition := nDs.FieldByName('quota_condition').AsString;
      nValue := nDs.FieldByName('quota_value').AsFloat;
      nPunishCondition := nDs.FieldByName('punish_condition').AsString;
      nPunishBasic := nDs.FieldByName('punish_Basis').AsFloat;
      nPunishStandard := nDs.FieldByName('punish_standard').AsFloat;
      nPunishMode := nDs.FieldByName('punish_mode').AsInteger;
      nsValue := FloatToStr(nValue*100)+'%';
      if nPunishCondition<>'' then
      begin
        nsPunishBasic := FloatToStr(nPunishBasic*100);
        nsPunishStandard := FloatToStr(nPunishStandard);
        nsPunishMode := '����';
        if nPunishMode=1 then
        begin
          nsPunishMode := '����';
        end;
        nPunish := nPunishCondition + InfoList.Delimiter + nsPunishBasic + InfoList.Delimiter
            +nsPunishStandard + InfoList.Delimiter + nsPunishMode;
      end;
      nStr := nName + InfoList.Delimiter + nsValue + InfoList.Delimiter + nCondition + InfoList.Delimiter + nPunish;
      FPurchaseContractInfo.FQuotaList.Add(nStr);
      nDs.Next;
    end;
  end;
end;
procedure TfFormPurchaseContract.btnAddClick(Sender: TObject);
var
  nName,nCondition,nValue:string;
  nStr:string;
  nPunishCondition,nPunishBasic,nPunishStandard,nPunishMode:string;
  nPunish:string;
begin
  nName := comQuotaName.Text;
  nCondition := comQuotaCondition.Text;
  nValue := comQuotaValue.Text;
  if nName='' then
  begin
    comQuotaName.Focused;
    ShowMsg('��ѡ��ָ����', sHint);
    Exit;
  end;
  if nCondition='' then
  begin
    comQuotaCondition.Focused;
    ShowMsg('��ѡ������', sHint);
    Exit;
  end;
  if nValue='' then
  begin
    comQuotaValue.Focused;
    ShowMsg('��ѡ��ָ��ֵ', sHint);
    Exit;
  end;
  nPunishCondition := comPunishCondition.Text;
  nPunishBasic := editpunishBasis.Text;
  nPunishStandard := editpunishStandard.Text;
  nPunishMode := comPunishMode.Text;
  nPunish := '';
  if (nPunishCondition='') and (nPunishBasic='') and (nPunishStandard='') and (nPunishMode='') then
  begin
    if not QueryDlg('δ¼�������Ϣ���Ƿ������',sHint) then Exit;
  end
  else if (nPunishCondition<>'') and (nPunishBasic<>'') and (nPunishStandard<>'') and (nPunishMode<>'') then
  begin
    if ((nCondition='��') and (nPunishCondition='<')) or ((nCondition='��') and (nPunishCondition='>')) then
    begin
      ShowMsg('ָ���������������¼����������',sHint);
      Exit;
    end;
      
    if (StrToFloatDef(nPunishBasic,0)=0) or (StrToFloatDef(nPunishBasic,0)<0.00001) then
    begin
      editpunishBasis.Focused;
      ShowMsg('��������¼������', sHint);
      Exit;
    end;
    if (StrToFloatDef(nPunishStandard,0)=0) or (StrToFloatDef(nPunishStandard,0)<0.00001) then
    begin
      editpunishStandard.Focused;
      ShowMsg('���ر�׼¼������', sHint);
      Exit;
    end;

    nPunish := nPunishCondition + InfoList.Delimiter + nPunishBasic + InfoList.Delimiter
      +nPunishStandard + InfoList.Delimiter + nPunishMode
  end
  else begin
    if not QueryDlg('������Ϣ�������������账���Ƿ������',sHint) then Exit;
  end;
  nStr := nName + InfoList.Delimiter + nValue + InfoList.Delimiter + nCondition + InfoList.Delimiter + nPunish;
  if InfoList.Items.IndexOf(nstr)=-1 then
  begin
    InfoList.Items.Add(nStr);
  end;
end;

procedure TfFormPurchaseContract.btnDelClick(Sender: TObject);
var nIdx: integer;
begin
  if InfoList.ItemIndex < 0 then
  begin
    ShowMsg('��ѡ��Ҫɾ��������', sHint); Exit;
  end;

  nIdx := InfoList.ItemIndex;
  InfoList.Items.Delete(InfoList.ItemIndex);

  if nIdx >= InfoList.Count then Dec(nIdx);
  InfoList.ItemIndex := nIdx;
  ShowMsg('��Ϣ����ɾ��', sHint);
end;

initialization
  gControlManager.RegCtrl(TfFormPurchaseContract, TfFormPurchaseContract.FormID);
end.
