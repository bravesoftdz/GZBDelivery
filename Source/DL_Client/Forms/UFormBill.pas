{*******************************************************************************
  ����: dmzn@163.com 2014-09-01
  ����: �������
*******************************************************************************}
unit UFormBill;

{$I Link.Inc}
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  UFormNormal, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxContainer, cxEdit, cxMaskEdit, cxButtonEdit,
  cxTextEdit, dxLayoutControl, StdCtrls, cxDropDownEdit;

type
  TfFormBill = class(TfFormNormal)
    dxGroup2: TdxLayoutGroup;
    EditValue: TcxTextEdit;
    dxLayout1Item8: TdxLayoutItem;
    EditCard: TcxTextEdit;
    dxLayout1Item9: TdxLayoutItem;
    EditID: TcxTextEdit;
    dxLayout1Item5: TdxLayoutItem;
    EditCus: TcxTextEdit;
    dxlytmLayout1Item3: TdxLayoutItem;
    dxGroupLayout1Group2: TdxLayoutGroup;
    EditCName: TcxTextEdit;
    dxlytmLayout1Item4: TdxLayoutItem;
    EditMan: TcxTextEdit;
    dxlytmLayout1Item5: TdxLayoutItem;
    EditDate: TcxTextEdit;
    dxlytmLayout1Item6: TdxLayoutItem;
    EditFirm: TcxTextEdit;
    dxlytmLayout1Item7: TdxLayoutItem;
    EditArea: TcxTextEdit;
    dxlytmLayout1Item8: TdxLayoutItem;
    EditStock: TcxTextEdit;
    dxlytmLayout1Item9: TdxLayoutItem;
    EditSName: TcxTextEdit;
    dxlytmLayout1Item10: TdxLayoutItem;
    EditMax: TcxTextEdit;
    dxlytmLayout1Item11: TdxLayoutItem;
    EditTruck: TcxButtonEdit;
    dxlytmLayout1Item12: TdxLayoutItem;
    dxGroupLayout1Group5: TdxLayoutGroup;
    dxlytmLayout1Item13: TdxLayoutItem;
    EditType: TcxComboBox;
    dxlytmLayout1Item14: TdxLayoutItem;
    EditFQ: TcxTextEdit;
    dxGroupLayout1Group6: TdxLayoutGroup;
    dxGroupLayout1Group4: TdxLayoutGroup;
    dxGroupLayout1Group7: TdxLayoutGroup;
    dxGroupLayout1Group3: TdxLayoutGroup;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure BtnOKClick(Sender: TObject);
    procedure EditLadingKeyPress(Sender: TObject; var Key: Char);
    procedure EditTruckPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
  protected
    { Protected declarations }
    FCardData: TStrings;
    //��Ƭ����
    FNewBillID: string;
    //���ᵥ��
    FBuDanFlag: string;
    //�������
    procedure InitFormData;
    //��ʼ������
  public
    { Public declarations }
    class function CreateForm(const nPopedom: string = '';
      const nParam: Pointer = nil): TWinControl; override;
    class function FormID: integer; override;
    function OnVerifyCtrl(Sender: TObject; var nHint: string): Boolean; override;
  end;

implementation

{$R *.dfm}
uses
  ULibFun, DB, IniFiles, UMgrControl, UAdjustForm, UFormBase, UBusinessPacker,
  UDataModule, USysBusiness, USysDB, USysGrid, USysConst;

class function TfFormBill.CreateForm(const nPopedom: string;
  const nParam: Pointer): TWinControl;
var nStr: string;
    nP: PFormCommandParam;
begin
  Result := nil;
  if GetSysValidDate < 1 then Exit;

  if not Assigned(nParam) then
  begin
    New(nP);
    FillChar(nP^, SizeOf(TFormCommandParam), #0);
  end else nP := nParam;

  try
    CreateBaseFormItem(cFI_FormBillNew, nPopedom, nP);
    if (nP.FCommand <> cCmd_ModalResult) or (nP.FParamA <> mrOK) then Exit;
    nStr := nP.FParamB;
  finally
    if not Assigned(nParam) then Dispose(nP);
  end;

  with TfFormBill.Create(Application) do
  try
    Caption := '�������';
    ActiveControl := EditTruck;

    FCardData.Text := PackerDecodeStr(nStr);
    InitFormData;

    if nPopedom = 'MAIN_D04' then //����
         FBuDanFlag := sFlag_Yes
    else FBuDanFlag := sFlag_No;

    if Assigned(nParam) then
    with PFormCommandParam(nParam)^ do
    begin
      FCommand := cCmd_ModalResult;
      FParamA := ShowModal;

      if FParamA = mrOK then
           FParamB := FNewBillID
      else FParamB := '';
    end else ShowModal;
  finally
    Free;
  end;
end;

class function TfFormBill.FormID: integer;
begin
  Result := cFI_FormBill;
end;

procedure TfFormBill.FormCreate(Sender: TObject);
begin
  FCardData := TStringList.Create;
  AdjustCtrlData(Self);
  LoadFormConfig(Self);
end;

procedure TfFormBill.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  SaveFormConfig(Self);
  ReleaseCtrlData(Self);
  FCardData.Free;
end;

//Desc: �س���
procedure TfFormBill.EditLadingKeyPress(Sender: TObject; var Key: Char);
var nP: TFormCommandParam;
begin
  if Key = Char(VK_RETURN) then
  begin
    Key := #0;

    if Sender = EditValue then
         BtnOK.Click
    else Perform(WM_NEXTDLGCTL, 0, 0);
  end;

  if (Sender = EditTruck) and (Key = Char(VK_SPACE)) then
  begin
    Key := #0;
    nP.FParamA := EditTruck.Text;
    CreateBaseFormItem(cFI_FormGetTruck, '', @nP);

    if (nP.FCommand = cCmd_ModalResult) and(nP.FParamA = mrOk) then
      EditTruck.Text := nP.FParamB;
    EditTruck.SelectAll;
  end;
end;

procedure TfFormBill.EditTruckPropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
var nChar: Char;
begin
  nChar := Char(VK_SPACE);
  EditLadingKeyPress(EditTruck, nChar);
end;

//------------------------------------------------------------------------------
procedure TfFormBill.InitFormData;
var nStr: string;
begin
  with FCardData do
  begin
    EditID.Text     := Values['XCB_ID'];
    EditCard.Text   := Values['XCB_CardId'];
    EditCus.Text    := Values['XCB_Client'];
    EditCName.Text  := Values['XCB_ClientName'];
    EditMan.Text    := Values['XCB_CreatorNM'];
    EditDate.Text   := Values['XCB_CDate'];
    EditFirm.Text   := Values['XCB_FirmName'];
    EditArea.Text   := Values['pcb_name'];
    EditStock.Text  := Values['XCB_Cement'];
    EditSName.Text  := Values['XCB_CementName'];
    EditMax.Text    := Values['XCB_RemainNum'];

    nStr := 'Select D_Memo From %s Where D_ParamB=''%s''';
    nStr := Format(nStr, [sTable_SysDict, Values['XCB_Cement']]);

    with FDM.QueryTemp(nStr) do
    begin
      BtnOK.Enabled := RecordCount > 0;
      if RecordCount < 1 then
      begin
        nStr := 'Ʒ��[ %s.%s ]û�����ֵ�������,����ϵ����Ա.';
        nStr := Format(nStr, [Values['XCB_Cement'], Values['XCB_CementName']]);
        
        ShowDlg(nStr, sHint);
        Exit;
      end;

      Values['XCB_CementType'] := Fields[0].AsString;
      //��ɢ����
    end;
  end;
end;

function TfFormBill.OnVerifyCtrl(Sender: TObject; var nHint: string): Boolean;
var nVal: Double;
begin
  Result := True;

  if Sender = EditTruck then
  begin
    Result := Length(EditTruck.Text) > 2;
    nHint := '���ƺų���Ӧ����2λ';
  end else

  if Sender = EditValue then
  begin
    Result := IsNumber(EditValue.Text, True) and (StrToFloat(EditValue.Text)>0);
    nHint := '����д��Ч�İ�����';
    if not Result then Exit;
                    
    nVal := StrToFloat(EditValue.Text);
    Result := FloatRelation(nVal, StrToFloat(FCardData.Values['XCB_RemainNum']),
              rtLE);
    nHint := '�ѳ����������';
  end;
end;

//Desc: ����
procedure TfFormBill.BtnOKClick(Sender: TObject);
var nPrint: Boolean;
    nList,nTmp,nStocks: TStrings;
begin
  if not IsDataValid then Exit;
  //check valid

  nStocks := TStringList.Create;
  nList := TStringList.Create;
  nTmp := TStringList.Create;
  try
    nList.Clear;
    nPrint := False;
    LoadSysDictItem(sFlag_PrintBill, nStocks);
    //���ӡƷ��

    //+++++: start loop
    nTmp.Values['Type'] := FCardData.Values['XCB_CementType'];
    nTmp.Values['StockNO'] := FCardData.Values['XCB_Cement'];
    nTmp.Values['StockName'] := FCardData.Values['XCB_CementName'];
    nTmp.Values['Price'] := '0.00';
    nTmp.Values['Value'] := EditValue.Text;

    nList.Add(PackerEncodeStr(nTmp.Text));
    //new bill

    if (not nPrint) and (FBuDanFlag <> sFlag_Yes) then
      nPrint := nStocks.IndexOf(FCardData.Values['XCB_Cement']) >= 0;
    //-----: end loop,�˴�����Ӷ�����ϸ

    with nList do
    begin
      Values['Bills'] := PackerEncodeStr(nList.Text);
      Values['ZhiKa'] := PackerEncodeStr(FCardData.Text);
      Values['Truck'] := EditTruck.Text;
      Values['Lading'] := sFlag_TiHuo;
      Values['IsVIP'] := GetCtrlData(EditType);
      Values['Seal'] := EditFQ.Text;
      Values['BuDan'] := FBuDanFlag;
    end;

    FNewBillID := SaveBill(PackerEncodeStr(nList.Text));
    //call mit bus
    if FNewBillID = '' then Exit;
  finally
    nList.Free;
  end;

  if FBuDanFlag <> sFlag_Yes then
    SetBillCard(FNewBillID, EditTruck.Text, True);
  //����ſ�

  if nPrint then
    PrintBillReport(FNewBillID, True);
  //print report

  ModalResult := mrOk;
  ShowMsg('���������ɹ�', sHint);
end;

initialization
  gControlManager.RegCtrl(TfFormBill, TfFormBill.FormID);
end.
