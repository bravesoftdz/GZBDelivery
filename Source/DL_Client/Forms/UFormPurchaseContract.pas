{*******************************************************************************
  作者: dmzn@163.com 2009-6-13
  描述: 添加、修改、删除、浏览处理Form基类
*******************************************************************************}
unit UFormPurchaseContract;

{$I Link.Inc}
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  UDataModule, UFormBase, ULibFun, UAdjustForm, USysConst, dxLayoutControl,
  StdCtrls, cxControls, cxGraphics, cxLookAndFeels, cxLookAndFeelPainters,
  cxContainer, cxEdit, cxMemo, cxTextEdit, cxMaskEdit, cxButtonEdit,
  cxCheckBox, Menus, ComCtrls, cxListView, cxButtons, cxDropDownEdit;

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
    dxLayout1Item4: TdxLayoutItem;
    editMateriel: TcxButtonEdit;
    dxLayout1Item5: TdxLayoutItem;
    editContractno: TcxTextEdit;
    dxLayout1Item6: TdxLayoutItem;
    editPrice: TcxTextEdit;
    dxLayout1Item7: TdxLayoutItem;
    editQuantity: TcxTextEdit;
    dxLayout1Item8: TdxLayoutItem;
    editRemark: TcxMemo;
    dxLayout1Item9: TdxLayoutItem;
    dxLayout1Group2: TdxLayoutGroup;
    comQuotaName: TcxComboBox;
    dxLayout1Item10: TdxLayoutItem;
    comQuotaCondition: TcxComboBox;
    dxLayout1Item11: TdxLayoutItem;
    comQuotaValue: TcxComboBox;
    dxLayout1Item12: TdxLayoutItem;
    comPunishCondition: TcxComboBox;
    dxLayout1Item13: TdxLayoutItem;
    editpunishBasis: TcxTextEdit;
    dxLayout1Item14: TdxLayoutItem;
    editpunishStandard: TcxTextEdit;
    dxLayout1Item15: TdxLayoutItem;
    dxLayout1Group4: TdxLayoutGroup;
    dxLayout1Group5: TdxLayoutGroup;
    dxLayout1Group3: TdxLayoutGroup;
    dxLayout1Group6: TdxLayoutGroup;
    comPunishMode: TcxComboBox;
    dxLayout1Item16: TdxLayoutItem;
    btnAdd: TcxButton;
    dxLayout1Item17: TdxLayoutItem;
    btnDel: TcxButton;
    dxLayout1Item18: TdxLayoutItem;
    cxMemo2: TcxMemo;
    dxLayout1Item19: TdxLayoutItem;
    InfoList: TcxListView;
    dxLayout1Item20: TdxLayoutItem;
    dxLayout1Group8: TdxLayoutGroup;
    dxLayout1Group7: TdxLayoutGroup;
    chbType: TcxCheckBox;
    dxLayout1Item3: TdxLayoutItem;
    procedure BtnExitClick(Sender: TObject);
    procedure BtnOKClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure comQuotaNamePropertiesChange(Sender: TObject);
    procedure editProviderKeyPress(Sender: TObject; var Key: Char);
    procedure editMaterielKeyPress(Sender: TObject; var Key: Char);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnAddClick(Sender: TObject);
    procedure btnDelClick(Sender: TObject);
    procedure chbTypeClick(Sender: TObject);
    procedure comPunishModePropertiesChange(Sender: TObject);
  protected
    { Private declarations }
    FProvider: TProviderParam;
    FMeterail: TMeterailsParam;
    FPurchaseContractInfo:TPurchaseContractInfo;
    Fid:string;
    FQuotaUnit:string;//指标单位
    procedure InitFormData(const nID: string);    
    procedure ClearUI;
    procedure FillUI;
    procedure InitComboxControl;
    procedure SetStrToInfoListItems(const nStr:string);
    function OnVerifyCtrl(Sender: TObject; var nHint: string): Boolean; virtual;
    function IsDataValid: Boolean; virtual;
    {*验证数据*}
    procedure GetSaveSQLList(const nList: TStrings); virtual;
    {*写SQL列表*}
    procedure AfterSaveData(var nDefault: Boolean); virtual;
    {*后续动作*}
    class function CreateForm(const nPopedom: string = '';
      const nParam: Pointer = nil): TWinControl; override;
    class function FormID: integer; override;
  end;

implementation

{$R *.dfm}
uses
  UMgrControl,USysDB,USysBusiness,UBusinessPacker,UFormCtrl,Db;
var
  gForm: TfFormPurchaseContract = nil;
  FCommand:Integer;  
  //全局使用
  
procedure TfFormPurchaseContract.BtnExitClick(Sender: TObject);
begin
  Close;
end;

//------------------------------------------------------------------------------
//Desc: 写数据SQL列表
procedure TfFormPurchaseContract.GetSaveSQLList(const nList: TStrings);
begin
  nList.Clear;
end;

//Desc: 验证Sender的数据是否正确,返回提示内容
function TfFormPurchaseContract.OnVerifyCtrl(Sender: TObject; var nHint: string): Boolean;
var
  nstr:string;
begin
  Result := False;
  if sender=editMateriel then
  begin
    nstr := Trim(editMateriel.text);
    if nstr ='' then
    begin
      nHint := '原材料不能为空';
      Exit;
    end;
    if (FMeterail.FID='') or (FMeterail.FName='') then
    begin
      nHint := '未正确选择原材料';
      Exit;
    end;
  end;
  if chbType.Checked then
  begin
    Result := True;
    Exit;
  end;
  if Sender=editContractno then
  begin
    nstr := Trim(editContractno.Text);
    if nstr ='' then
    begin
      nHint := '合同编号不能为空';
      Exit;
    end;
  end;
  if sender=editProvider then
  begin
    nstr := Trim(editProvider.text);
    if nstr ='' then
    begin
      nHint := '供应商不能为空';
      Exit;
    end;
    if (FProvider.FID='') or (FProvider.FName='') then
    begin
      nHint := '未正确选择供应商';
      Exit;
    end; 
  end;
  if Sender=editPrice then
  begin
    nStr := Trim(editPrice.Text);
    if nStr='' then
    begin
      nHint := '单价不能为空';
      exit;
    end;
    if StrToFloatDef(nstr,0)<=0.000001 then
    begin
      nHint := '请录入正确的单价';
      Exit;
    end;
  end;
  if Sender=editQuantity then
  begin
    nStr := Trim(editQuantity.Text);
    if nStr='' then
    begin
      nHint := '数量不能为空';
      exit;
    end;
    if StrToFloatDef(nstr,0)<=0.000001 then
    begin
      nHint := '请录入正确的数量';
      Exit;
    end;
  end;
  Result := True;
end;

//Desc: 验证数据是否正确
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

//Desc: 保存后续动作
procedure TfFormPurchaseContract.AfterSaveData(var nDefault: Boolean);
begin

end;

//Desc: 保存
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
      Values['QuotaList'] := PackerEncodeStr(FPurchaseContractInfo.FQuotaList.Text);
    end;
    if FCommand=cCmd_AddData then
    begin
      {$IFDEF PurchaseOrderSingle}
      if gSysParam.FIsMT = 1 then
        FID := SavePurchaseContractSingle(PackerEncodeStr(FListA.Text))
      else
        FID := SavePurchaseContract(PackerEncodeStr(FListA.Text));
      {$ELSE}
      FID := SavePurchaseContract(PackerEncodeStr(FListA.Text));
      {$ENDIF}
      if FID='' then Exit;
      ModalResult := mrOK;
      ShowMsg('采购合同保存成功', sHint);
    end
    else if FCommand=cCmd_EditData then
    begin
      FListA.Values['fid'] := Fid;
      {$IFDEF PurchaseOrderSingle}
      if gSysParam.FIsMT = 1 then
        ModifyPurchaseContractSingle(PackerEncodeStr(FListA.Text))
      else
        ModifyPurchaseContract(PackerEncodeStr(FListA.Text));
      {$ELSE}
      ModifyPurchaseContract(PackerEncodeStr(FListA.Text));
      {$ENDIF}
      ModalResult := mrOK;
      ShowMsg('采购合同修改成功', sHint);
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
  comQuotaValue.Text := '';
  comPunishCondition.Properties.DropDownListStyle := lsFixedList;
  comPunishMode.Properties.DropDownListStyle := lsFixedList;
  FillChar(FProvider, 1, #0);
  FillChar(FMeterail, 1, #0);
  InfoList.ViewStyle := vsReport;
  InfoList.RowSelect := True;
  InfoList.ReadOnly := True;
  
  ResetHintAllForm(Self, 'T', sTable_PurchaseContract);
  //重置表名称

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
          Caption := '采购合同 - 添加';
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
          Caption := '采购合同 -修改';
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
            Caption := '采购合同 - 查看';
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

procedure TfFormPurchaseContract.comQuotaNamePropertiesChange(Sender: TObject);
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

  nStr := 'select distinct reference_unit from %s where quota_name=''%s''';
  nStr := Format(nStr,[sTable_PurchaseQuotaStandard,nquota_name]);
  with FDM.QueryTemp(nStr) do
  begin
    if RecordCount>0 then
    begin
      FQuotaUnit := FieldByName('reference_unit').AsString;
    end;
  end;
  dxLayout1Item11.Caption := '指标值(单位'+FQuotaUnit+')';
  dxLayout1Item13.Caption := '扣重依据(单位'+FQuotaUnit+')'
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
  editRemark.Text := FPurchaseContractInfo.FRemark;
  for i := 0 to FPurchaseContractInfo.FQuotaList.Count-1 do
  begin
    nStr := FPurchaseContractInfo.FQuotaList.Strings[i];
    SetStrToInfoListItems(nStr);
  end;
  if (FPurchaseContractInfo.FPrice<0.000001) or (FPurchaseContractInfo.FQuantity<0.000001) then
  begin
    chbType.Checked := True;
    chbTypeClick(chbType);
  end;
end;

procedure TfFormPurchaseContract.InitComboxControl;
var
  nStr:string;
begin
  comQuotaCondition.Properties.Items.Clear;
  comQuotaCondition.Properties.Items.Add('≤');
  comQuotaCondition.Properties.Items.Add('≥');
  comQuotaCondition.Properties.Items.Add('=');
  comPunishCondition.Properties.Items.Clear;
  comPunishCondition.Properties.Items.Add('<');
  comPunishCondition.Properties.Items.Add('>');
  comPunishMode.Properties.Items.Clear;
  comPunishMode.Properties.Items.Add('重量');
  comPunishMode.Properties.Items.Add('单价');
  comPunishMode.Properties.Items.Add('净重');

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
  nDelimiter:string;
  nUnit:string;
begin
  nDelimiter := ',';
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
      nUnit := nDs.FieldByName('quota_unit').AsString;
      nCondition := nDs.FieldByName('quota_condition').AsString;
      nValue := nDs.FieldByName('quota_value').AsFloat;
      nPunishCondition := nDs.FieldByName('punish_condition').AsString;
      nPunishBasic := nDs.FieldByName('punish_Basis').AsFloat;
      nPunishStandard := nDs.FieldByName('punish_standard').AsFloat;
      nPunishMode := nDs.FieldByName('punish_mode').AsInteger;
      nsValue := FloatToStr(nValue);
      if nPunishCondition<>'' then
      begin
        nsPunishBasic := FloatToStr(nPunishBasic);
        nsPunishStandard := FloatToStr(nPunishStandard);
        nsPunishMode := '重量';
        if nPunishMode=1 then
        begin
          nsPunishMode := '单价';
        end
        else if nPunishMode=2 then
        begin
          nsPunishMode := '净重';
        end;
        nPunish := nPunishCondition + nDelimiter
            + nsPunishBasic + nDelimiter
            + nsPunishStandard + nDelimiter
            + nsPunishMode;
      end;
      nStr := nName + nDelimiter
          + nUnit + nDelimiter
          + nCondition + nDelimiter
          + nsValue + nDelimiter
          + nPunish;
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
  nDelimiter:string;
begin
  nDelimiter := ',';
  nName := comQuotaName.Text;
  nCondition := comQuotaCondition.Text;
  nValue := comQuotaValue.Text;
  if nName='' then
  begin
    comQuotaName.Focused;
    ShowMsg('请选择指标名', sHint);
    Exit;
  end;
  if nCondition='' then
  begin
    comQuotaCondition.Focused;
    ShowMsg('请选择条件', sHint);
    Exit;
  end;
  if nValue='' then
  begin
    comQuotaValue.Focused;
    ShowMsg('请选择指标值', sHint);
    Exit;
  end;
  nPunishCondition := comPunishCondition.Text;
  nPunishBasic := editpunishBasis.Text;
  nPunishStandard := editpunishStandard.Text;
  nPunishMode := comPunishMode.Text;
  nPunish := '';
  if (nPunishCondition='') and (nPunishBasic='') and (nPunishStandard='') and (nPunishMode='') then
  begin
    if not QueryDlg('未录入扣重信息，是否继续？',sHint) then Exit;
  end
  else if (nPunishCondition<>'') and (nPunishBasic<>'') and (nPunishStandard<>'') and (nPunishMode<>'') then
  begin
    if ((nCondition='≤') and (nPunishCondition='<')) or ((nCondition='≥') and (nPunishCondition='>')) then
    begin
      ShowMsg('指标条件或扣重条件录入有误，请检查',sHint);
      Exit;
    end;
    if nPunishMode<>'净重' then
    begin
      if (StrToFloatDef(nPunishBasic,0)=0) or (StrToFloatDef(nPunishBasic,0)<0.00001) then
      begin
        editpunishBasis.Focused;
        ShowMsg('扣重依据录入有误', sHint);
        Exit;
      end;
      if (StrToFloatDef(nPunishStandard,0)=0) or (StrToFloatDef(nPunishStandard,0)<0.00001) then
      begin
        editpunishStandard.Focused;
        ShowMsg('扣重标准录入有误', sHint);
        Exit;
      end;
    end;

    nPunish := nPunishCondition + nDelimiter
      + nPunishBasic + nDelimiter
      + nPunishStandard + nDelimiter
      + nPunishMode;
  end
  else begin
    if not QueryDlg('扣重信息不完整，将不予处理，是否继续？',sHint) then Exit;
  end;
  nStr := nName +nDelimiter
    + FQuotaUnit + nDelimiter
    + nCondition+ nDelimiter
    + nValue + nDelimiter
    + nPunish + nDelimiter;
  if FPurchaseContractInfo.FQuotaList.IndexOf(nStr)=-1 then
  begin
//    InfoList.Items.Add(nStr);
    SetStrToInfoListItems(nStr);
    FPurchaseContractInfo.FQuotaList.Add(nStr);
  end;
end;

procedure TfFormPurchaseContract.btnDelClick(Sender: TObject);
var nIdx: integer;
begin
  if InfoList.ItemIndex < 0 then
  begin
    ShowMsg('请选择要删除的内容', sHint); Exit;
  end;

  nIdx := InfoList.ItemIndex;
  InfoList.Items.Delete(InfoList.ItemIndex);
  FPurchaseContractInfo.FQuotaList.Delete(nIdx);

  if nIdx >= InfoList.Items.Count then Dec(nIdx);
  InfoList.ItemIndex := nIdx;
  InfoList.SetFocus;
  ShowMsg('信息项已删除', sHint);
end;

procedure TfFormPurchaseContract.chbTypeClick(Sender: TObject);
begin
  editContractno.Enabled := not chbType.Checked;
  editPrice.Enabled := not chbType.Checked;
  editQuantity.Enabled := not chbType.Checked;
end;

procedure TfFormPurchaseContract.comPunishModePropertiesChange(
  Sender: TObject);
begin
  if comPunishMode.ItemIndex=2 then
  begin
    editpunishBasis.Text := '0';
    editpunishStandard.Text := '0';
    editpunishBasis.Enabled := False;
    editpunishStandard.Enabled := False;
    ShowMsg('选择【净重】模式，则扣重依据和扣重标准参数无效',sHint);
  end;
end;

procedure TfFormPurchaseContract.SetStrToInfoListItems(const nStr: string);
var
  nList:TStrings;
  nItem:TListItem;
  nIdx:integer;
begin
  nList := TStringList.Create;
  try
    nList.CommaText := nStr;
    for nIdx := nList.Count-1 downto 0 do
    begin
      if nList.Strings[nIdx]='' then
      begin
        nList.Delete(nIdx);
      end;
    end;
    nItem := InfoList.Items.Add;
    nItem.Caption := nList.Strings[0];
    nItem.SubItems.Add(nList.Strings[1]);
    nItem.SubItems.Add(nList.Strings[2]);
    nItem.SubItems.Add(nList.Strings[3]);
    if nList.Count>4 then
    begin
      nItem.SubItems.Add(nList.Strings[4]);
      nItem.SubItems.Add(nList.Strings[5]);
      nItem.SubItems.Add(nList.Strings[6]);
      nItem.SubItems.Add(nList.Strings[7]);
    end;
  finally
    nList.Free;
  end;
end;

initialization
  gControlManager.RegCtrl(TfFormPurchaseContract, TfFormPurchaseContract.FormID);

end.
