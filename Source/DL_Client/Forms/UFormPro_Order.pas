{*******************************************************************************
  ����: fendou116688@163.com 2015/8/8
  ����: �½��ɹ����뵥
*******************************************************************************}
unit UFormPro_Order;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  UDataModule, UFormBase, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxContainer, cxEdit, dxLayoutControl, cxLabel,
  cxCheckBox, cxTextEdit, cxDropDownEdit, cxMCListBox, cxMaskEdit,
  cxButtonEdit, StdCtrls,Dialogs, cxMemo, cxCalendar;

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

  TfFormPro_Order = class(TBaseForm)
    dxLayoutControl1Group_Root: TdxLayoutGroup;
    dxLayoutControl1: TdxLayoutControl;
    dxLayoutControl1Group1: TdxLayoutGroup;
    EditMemo: TcxMemo;
    dxLayoutControl1Item4: TdxLayoutItem;
    BtnOK: TButton;
    dxLayoutControl1Item10: TdxLayoutItem;
    BtnExit: TButton;
    dxLayoutControl1Item11: TdxLayoutItem;
    dxLayoutControl1Group9: TdxLayoutGroup;
    dxLayoutControl1Group2: TdxLayoutGroup;
    EditMate: TcxComboBox;
    dxLayoutControl1Item3: TdxLayoutItem;
    EditProvider: TcxButtonEdit;
    dxLayoutControl1Item6: TdxLayoutItem;
    EditValue: TcxTextEdit;
    dxLayoutControl1Item9: TdxLayoutItem;
    cxCheckBox1: TcxCheckBox;
    dxLayoutControl1Item1: TdxLayoutItem;
    EditDate: TcxDateEdit;
    dxLayoutControl1Item2: TdxLayoutItem;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
   
    procedure BtnOKClick(Sender: TObject);
    procedure BtnExitClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure EditSalesManKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure EditProviderKeyPress(Sender: TObject; var Key: Char);
    procedure EditMateKeyPress(Sender: TObject; var Key: Char);
    procedure cxCheckBox1PropertiesChange(Sender: TObject);
  private
    { Private declarations }
    FOrderID: string;
    FOldStockNo: string;
    FOldNum: Double;
    FListA  : TStrings;
    FProvider: TProviderParam;
    FMeterail: TMeterailsParam;
    procedure InitFormData(const nID: string);
    //��������
    function IsRepeatProID(const nID:string;const nStockNo:string):Boolean;
    //�ж��Ƿ��ظ�
  public
    { Public declarations }
    class function CreateForm(const nPopedom: string = '';
      const nParam: Pointer = nil): TWinControl; override;
    class function FormID: integer; override;
  end;

implementation

{$R *.dfm}
uses
  DB, IniFiles, ULibFun, UFormCtrl, UAdjustForm, UMgrControl, UFormBaseInfo,
  USysBusiness, USysGrid, USysDB, USysConst, UBusinessPacker;

var
  gForm: TfFormPro_Order = nil;
  //ȫ��ʹ��

class function TfFormPro_Order.CreateForm(const nPopedom: string;
  const nParam: Pointer): TWinControl;
var nP: PFormCommandParam;
begin
  Result := nil;
  if Assigned(nParam) then
       nP := nParam
  else Exit;

  case nP.FCommand of
   cCmd_AddData:
    with TfFormPro_Order.Create(Application) do
    begin
      Caption := '��Ӧ�̽��������� - ���';

      InitFormData('');
      EditDate.Date := Now;
      nP.FCommand := cCmd_ModalResult;
      nP.FParamA := ShowModal;
      Free;
    end;
   cCmd_EditData:
    with TfFormPro_Order.Create(Application) do
    begin
      FOrderID := nP.FParamA;
      Caption := '��Ӧ�̽��������� - �޸�';

      InitFormData(FOrderID);
      nP.FCommand := cCmd_ModalResult;
      nP.FParamA := ShowModal;
      Free;
    end;
   cCmd_ViewData:
    begin
      if not Assigned(gForm) then
      begin
        gForm := TfFormPro_Order.Create(Application);
        with gForm do
        begin
          Caption := '��Ӧ�̽��������� - �鿴';
          FormStyle := fsStayOnTop;
          BtnOK.Visible := False;
        end;
      end;

      with gForm  do
      begin
        FOrderID := nP.FParamA;
        InitFormData(FOrderID);
        if not Showing then Show;
      end;
    end;
   cCmd_FormClose:
    begin
      if Assigned(gForm) then FreeAndNil(gForm);
    end;
  end;
end;

class function TfFormPro_Order.FormID: integer;
begin
  Result := cFI_FormPro_Order;
end;

//------------------------------------------------------------------------------
procedure TfFormPro_Order.FormCreate(Sender: TObject);
var nIni: TIniFile;
begin
  nIni := TIniFile.Create(gPath + sFormConfig);
  try
    LoadFormConfig(Self, nIni);
  finally
    nIni.Free;
  end;

  FillChar(FProvider, 1, #0);
  FillChar(FMeterail, 1, #0);

  FListA := TStringList.Create;
  AdjustCtrlData(Self);
end;

procedure TfFormPro_Order.FormClose(Sender: TObject;
  var Action: TCloseAction);
var nIni: TIniFile;
begin
  nIni := TIniFile.Create(gPath + sFormConfig);
  try
    SaveFormConfig(Self, nIni);
  finally
    nIni.Free;
  end;

  FListA.Free;
  gForm := nil;
  Action := caFree;
  ReleaseCtrlData(Self);
end;

procedure TfFormPro_Order.BtnExitClick(Sender: TObject);
begin
  Close;
end;

procedure TfFormPro_Order.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
 if Key = VK_ESCAPE then
  begin
    Key := 0; Close;
  end;
end;

//Date: 2009-6-2
//Parm: ��Ӧ�̱��
//Desc: ����nID��Ӧ�̵���Ϣ������
procedure TfFormPro_Order.InitFormData(const nID: string);
var nStr: string;
    nArray: TDynamicStrArray;
begin
  if nID <> '' then
  begin
    nStr := 'Select * From %s Where P_ID=''%s''';
    nStr := Format(nStr, [sTable_Pro_Order, nID]);

    LoadDataToCtrl(FDM.QuerySQL(nStr), Self);
    with FDM.QuerySQL(nStr) do
    begin
      if RecordCount>0 then
      begin
        FProvider.FID := FieldByName('P_ID').AsString;
        FMeterail.FID := FieldByName('P_StockNo').AsString;
        FOldStockNo   := FieldByName('P_StockNo').AsString;
        FOldNum       := FieldByName('P_Value').AsFloat;
        EditDate.Date  := Str2DateTime(FieldByName('P_EndDate').AsString);
        EditProvider.Enabled := False;
        if Trim(FieldByName('P_Status').AsString) = 'Y' then
          cxCheckBox1.Checked := True
        else
          cxCheckBox1.Checked := False;
      end;
    end;
  end;
end;

function GetStrValue(nStr: string): string;
var nPos: Integer;
begin
  nPos := Pos('.', nStr);
  Delete(nStr, 1, nPos);
  Result := nStr;
end;  

//Desc: ���ٶ�λ
procedure TfFormPro_Order.EditSalesManKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
var i,nCount: integer;
    nBox: TcxComboBox;
begin
  if Key = 13 then
  begin
    Key := 0;
    nBox := Sender as TcxComboBox;

    nCount := nBox.Properties.Items.Count - 1;
    for i:=0 to nCount do
    if Pos(LowerCase(nBox.Text), LowerCase(nBox.Properties.Items[i])) > 0 then
    begin
      nBox.ItemIndex := i; Break;
    end;
  end;
end;

//Desc: ��������
procedure TfFormPro_Order.BtnOKClick(Sender: TObject);
var nStr,nStatus: string;
    nVal,nMaxNum: Double;
begin
  nVal    := StrToFloatDef(EditValue.Text, 0);
  nStr := Trim(EditProvider.Text);
  if Length(nStr)<1 then
  begin
    ShowMsg('��Ӧ�̲���Ϊ��', sWarn);
    EditProvider.SetFocus;
    Exit;
  end;

  nStr := Trim(EditMate.Text);
  if Length(nStr)<1 then
  begin
    ShowMsg('ԭ��������Ϊ��', sWarn);
    EditMate.SetFocus;
    Exit;
  end;
  if Date2Str(EditDate.Date) <>  Date2Str(Now) then
  begin
    ShowMsg('��Ч���ڲ��ܿ���,������ѡ��', sWarn);
    Exit;
  end;

  if FOrderID = '' then
  begin
    if IsRepeatProID(FProvider.FID,FMeterail.FID) then
    begin
      ShowMsg('�Ѵ��ڴ˹�Ӧ�̺�ԭ���ϵļ�¼,����', sHint); Exit;
    end;
  end;

  if (FOrderID <> '') and (FOldStockNo = FMeterail.FID) then
  begin
    nMaxNum := GetProMaxNum(FMeterail.FID) + FOldNum;
    if nMaxNum < 0 then
      nMaxNum := 0;
    if StrToFloatDef(EditValue.Text,0) > nMaxNum then
    begin
      Showmessage('ԭ���ϵ���ʣ������������Ϊ'+FloatToStr(nMaxNum)+',���ܳ�������');
      if EditValue.CanFocus then
        EditValue.SetFocus;
      Exit;
    end;
  end
  else
  begin
    nMaxNum := GetProMaxNum(FMeterail.FID);
    if nMaxNum < 0 then
      nMaxNum := 0;
    if StrToFloatDef(EditValue.Text,0) > nMaxNum then
    begin
      Showmessage('ԭ���ϵ���ʣ������������Ϊ'+FloatToStr(nMaxNum)+',���ܳ�������');
      if EditValue.CanFocus then
        EditValue.SetFocus;
      Exit;
    end;
  end;

  if cxCheckBox1.Checked then
        nStatus := sFlag_Yes
  else  nStatus := sFlag_No;

  nStr := SF('P_ID', FOrderID);

  nStr := MakeSQLByStr([SF('P_ID', FProvider.FID),
          SF('P_Name', Trim(EditProvider.Text)),
          SF('P_PY', GetPinYinOfStr(EditProvider.Text)),
          SF('P_StockNo', FMeterail.FID),
          SF('P_StockName', Trim(EditMate.Text)),
          SF('P_Value', nVal, sfVal),
          SF('P_Status', nStatus),
          SF('P_EndDate', DateTime2Str(EditDate.Date)),
          SF('P_Man', gSysParam.FUserID),
          SF('P_Memo', EditMemo.Text)
          ], sTable_Pro_Order, nStr, FOrderID = '');
  FDM.ExecuteSQL(nStr);



  ModalResult := mrOK;
  ShowMsg('����ɹ�', sHint);
end;

procedure TfFormPro_Order.EditProviderKeyPress(Sender: TObject;
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

procedure TfFormPro_Order.EditMateKeyPress(Sender: TObject;
  var Key: Char);
var nP: TFormCommandParam;
begin
  inherited;
  if Key = Char(VK_RETURN) then
  begin
    Key := #0;
    
    nP.FParamA := EditMate.Text;
    CreateBaseFormItem(cFI_FormGetMeterail, '', @nP);

    if (nP.FCommand = cCmd_ModalResult) and(nP.FParamA = mrOk) then
    with FMeterail do
    begin
      FID := nP.FParamB;
      FName:=nP.FParamC;

      EditMate.Text := FName;
    end;  

    EditMate.SelectAll;
  end;
end;

procedure TfFormPro_Order.cxCheckBox1PropertiesChange(Sender: TObject);
begin
  inherited;
  if not cxCheckBox1.Checked then
    EditValue.Text := '0';
end;

function TfFormPro_Order.IsRepeatProID(const nID: string;
  const nStockNo:string): Boolean;
var
  nStr:string;
begin
  Result := False;
  nStr := ' select * from %s where P_ID=''%s'' and P_StockNo= ''%s'' ';
  nStr := Format(nStr,[sTable_Pro_Order,nID,nStockNo]);
  with fdm.QueryTemp(nStr) do
  begin
    if RecordCount>0 then
    begin
      Result := True;
    end;
  end;
end;

initialization
  gControlManager.RegCtrl(TfFormPro_Order, TfFormPro_Order.FormID);
end.
