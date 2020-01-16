{*******************************************************************************
  ����: fendou116688@163.com 2015/8/8
  ����: �½��ɹ����뵥
*******************************************************************************}
unit UFormPUserYSWh;

{$I Link.Inc}
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  UDataModule, UFormBase, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxContainer, cxEdit, dxLayoutControl, cxLabel,
  cxCheckBox, cxTextEdit, cxDropDownEdit, cxMCListBox, cxMaskEdit,
  cxButtonEdit, StdCtrls, cxMemo;

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

  TfFormPUserYSWh = class(TBaseForm)
    dxLayoutControl1: TdxLayoutControl;
    BtnOK: TButton;
    BtnExit: TButton;
    EditMate: TcxComboBox;
    cxCheckBox1: TcxCheckBox;
    dxLayoutGroup1: TdxLayoutGroup;
    dxLayoutGroup2: TdxLayoutGroup;
    dxLayoutControl1Item3: TdxLayoutItem;
    dxLayoutControl1Group2: TdxLayoutGroup;
    dxLayoutItem1: TdxLayoutItem;
    dxLayoutControl1Item10: TdxLayoutItem;
    dxLayoutControl1Item11: TdxLayoutItem;
    EditPUser: TcxComboBox;
    dxLayoutControl1Item1: TdxLayoutItem;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
   
    procedure BtnOKClick(Sender: TObject);
    procedure BtnExitClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure EditDatePropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure EditProviderKeyPress(Sender: TObject; var Key: Char);
    procedure EditMateKeyPress(Sender: TObject; var Key: Char);
  private
    { Private declarations }
    FOrderID: string;
    FListA  : TStrings;
    FProvider: TProviderParam;
    FMeterail: TMeterailsParam;
    procedure InitFormData(const nID: string);
    //��������
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
  gForm: TfFormPUserYSWh = nil;
  //ȫ��ʹ��

class function TfFormPUserYSWh.CreateForm(const nPopedom: string;
  const nParam: Pointer): TWinControl;
var nP: PFormCommandParam;
begin
  Result := nil;
  if Assigned(nParam) then
       nP := nParam
  else Exit;

  case nP.FCommand of
   cCmd_AddData:
    with TfFormPUserYSWh.Create(Application) do
    begin
      Caption := '����ά�� - ���';

      InitFormData('');
      nP.FCommand := cCmd_ModalResult;
      nP.FParamA := ShowModal;
      Free;
    end;
   cCmd_EditData:
    with TfFormPUserYSWh.Create(Application) do
    begin
      FOrderID := nP.FParamA;
      Caption := '����ά�� - �޸�';

      InitFormData(FOrderID);
      nP.FCommand := cCmd_ModalResult;
      nP.FParamA := ShowModal;
      Free;
    end;
   cCmd_FormClose:
    begin
      if Assigned(gForm) then FreeAndNil(gForm);
    end;
  end;
end;

class function TfFormPUserYSWh.FormID: integer;
begin
  Result := cFI_FormUserYSWh;
end;

//------------------------------------------------------------------------------
procedure TfFormPUserYSWh.FormCreate(Sender: TObject);
var
  nStr: string;
  nIni: TIniFile;
begin
  nIni := TIniFile.Create(gPath + sFormConfig);
  try
    LoadFormConfig(Self, nIni);
  finally
    nIni.Free;
  end;

  FillChar(FMeterail, 1, #0);

  FListA := TStringList.Create;
  AdjustCtrlData(Self);

  if EditPUser.Properties.Items.Count < 1 then
  begin
    nStr := ' Select U_Name From %s where U_Group = ''%s'' ';
    nStr := Format(nStr, [sTable_User, '5']);

    with FDM.QueryTemp(nStr) do
    if RecordCount > 0 then
    begin
      First;
      while not Eof do
      begin
        EditPUser.Properties.Items.Add(FieldByName('U_Name').AsString);
        Next;
      end;
    end;
  end;
end;

procedure TfFormPUserYSWh.FormClose(Sender: TObject;
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

procedure TfFormPUserYSWh.BtnExitClick(Sender: TObject);
begin
  Close;
end;

procedure TfFormPUserYSWh.FormKeyDown(Sender: TObject; var Key: Word;
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
procedure TfFormPUserYSWh.InitFormData(const nID: string);
var nStr: string;
    nArray: TDynamicStrArray;
begin
  if nID <> '' then
  begin
    nStr := 'Select * From %s Where B_ID=''%s''';
    nStr := Format(nStr, [sTable_UserYSWh, nID]);

    LoadDataToCtrl(FDM.QuerySQL(nStr), Self);
  end;
end;

function GetStrValue(nStr: string): string;
var nPos: Integer;
begin
  nPos := Pos('.', nStr);
  Delete(nStr, 1, nPos);
  Result := nStr;
end;  

//Desc: ��ǰʱ��
procedure TfFormPUserYSWh.EditDatePropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
begin
  TcxButtonEdit(Sender).Text := DateTime2Str(Now);
end;

//Desc: ��������
procedure TfFormPUserYSWh.BtnOKClick(Sender: TObject);
var nStr, nState,nUName,nStockNo, nStockName : string;
    nVal, nWarnVal, nLimVal: Double;
begin
  nUName := Trim(EditPUser.Text);
  if Length(nUName)<1 then
  begin
    ShowMsg('����Ա����Ϊ��', sWarn);
    EditPUser.SetFocus;
    Exit;
  end;
    
  nStockNo   := FMeterail.FID;
  nStockName := Trim(EditMate.Text);
  if Length(nStockNo)<1 then
  begin
    ShowMsg('ԭ��������Ϊ��', sWarn);
    EditMate.SetFocus;
    Exit;
  end;

  if cxCheckBox1.Checked then
        nState := sFlag_Yes
  else  nState := sFlag_No;

  nStr := ' Select R_ID from %s where P_UName = ''%s'' and P_StockNo = ''%s'' ';
  nStr := Format(nStr,[sTable_UserYSWh,nUName,nStockNo]);
  with FDM.QuerySQL(nStr) do
  begin
    if RecordCount>0 then
    begin
      ActiveControl := EditPUser;
      ShowMsg('�Ѵ��ڴ�������Ϣ', sHint);
      Exit;
    end;
  end;

  nStr := MakeSQLByStr([SF('P_UName', nUName),
          SF('P_StockNo', nStockNo),
          SF('P_StockName', nStockName),
          SF('P_State', nState)
          ], sTable_UserYSWh, '', True);
  FDM.ExecuteSQL(nStr);

  ModalResult := mrOK;
  ShowMsg('����ά����Ϣ����ɹ�', sHint);
end;

procedure TfFormPUserYSWh.EditProviderKeyPress(Sender: TObject;
  var Key: Char);
var nP: TFormCommandParam;
begin
  inherited;
  if Key = Char(VK_RETURN) then
  begin
    Key := #0;
  end;
end;

procedure TfFormPUserYSWh.EditMateKeyPress(Sender: TObject;
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

initialization
  gControlManager.RegCtrl(TfFormPUserYSWh, TfFormPUserYSWh.FormID);
end.
