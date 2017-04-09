unit UFormPoundDaiWC;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UFormNormal, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, dxLayoutControl, StdCtrls, cxContainer, cxEdit,
  cxTextEdit, cxLabel, cxCheckBox;

type
  TfFormPoundDaiWC = class(TfFormNormal)
    EditStart: TcxTextEdit;
    dxLayout1Item3: TdxLayoutItem;
    EditEnd: TcxTextEdit;
    dxLayout1Item4: TdxLayoutItem;
    EditWCZ: TcxTextEdit;
    dxLayout1Item5: TdxLayoutItem;
    EditWCF: TcxTextEdit;
    dxLayout1Item6: TdxLayoutItem;
    EditStation: TcxTextEdit;
    dxLayout1Item7: TdxLayoutItem;
    EditPert: TcxCheckBox;
    dxLayout1Item8: TdxLayoutItem;
    cxLabel1: TcxLabel;
    dxLayout1Item9: TdxLayoutItem;
    dxLayout1Group2: TdxLayoutGroup;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure BtnOKClick(Sender: TObject);
  private
    { Private declarations }
    FRecord: String;
    //�޸ĵ�ID
    procedure LoadDaiPoundWC;
    //������Χ
    procedure LoadFormData(const nID: string='');
  public
    { Public declarations }
    class function CreateForm(const nPopedom: string = '';
      const nParam: Pointer = nil): TWinControl; override;
    class function FormID: integer; override;

    function OnVerifyCtrl(Sender: TObject; var nHint: string): Boolean; override;
  end;

var
  fFormPoundDaiWC: TfFormPoundDaiWC;

implementation

{$R *.dfm}

uses
  ULibFun, USysConst, USysDB, UMgrControl, UDataModule, UFormBase, UFormCtrl;

type
  TPoundDaiWCItem = record
    FIndex: Integer;          //����
    FStart: Double;           //��ʼ��λ
    FEnd  : Double;           //������λ
    FWuChaZ: Double;          //�����
    FWuChaF: Double;          //�����
    FIsPercent: string;       //����������
    FStation: string;         //��վ���
    FEnabled: Boolean;        //�Ƿ���Ч
  end;
var
  gPoundDaiWCParam: array of TPoundDaiWCItem;
  //��װ�������

class function TfFormPoundDaiWC.CreateForm(const nPopedom: string;
  const nParam: Pointer): TWinControl;
var nPP: PFormCommandParam;
begin
  Result := nil;
  if Assigned(nParam) then
       nPP := nParam
  else Exit;

  with TfFormPoundDaiWC.Create(Application) do
  try
    if nPP.FCommand = cCmd_AddData then
    begin
      Caption := '��Χ - ����';
      FRecord := '';
    end else

    if nPP.FCommand = cCmd_EditData then
    begin
      Caption := '��Χ - �޸�';
      FRecord := nPP.FParamA;
    end else

    if nPP.FCommand = cCmd_EditData then
    begin
      Caption := '��Χ - �鿴';
      FRecord := nPP.FParamA;

      BtnOK.Enabled := False;
    end else Exit;

    LoadFormData(FRecord);
    nPP.FCommand := cCmd_ModalResult;
    nPP.FParamA := ShowModal;
  finally
    Free;
  end;
end;

class function TfFormPoundDaiWC.FormID: integer;
begin
  Result := cFI_FormPoundDaiWC;
end;

procedure TfFormPoundDaiWC.FormCreate(Sender: TObject);
begin
  inherited;
  LoadFormConfig(Self);

  LoadDaiPoundWC;
end;

procedure TfFormPoundDaiWC.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  inherited;
  SetLength(gPoundDaiWCParam, 0);
  SaveFormConfig(Self);
end;

procedure TfFormPoundDaiWC.LoadDaiPoundWC;
var nStr: string;
    nIdx: Integer;
begin
  SetLength(gPoundDaiWCParam, 0);

  nStr := 'Select * From ' + sTable_PoundDaiWC;
  with FDM.QueryTemp(nStr) do
  if RecordCount > 0 then
  begin
    SetLength(gPoundDaiWCParam, RecordCount);
    nIdx := Low(gPoundDaiWCParam);
    First;

    while not Eof do
    with gPoundDaiWCParam[nIdx] do
    try
      FIndex := FieldByName('R_ID').AsInteger;
      FStart := FieldByName('P_Start').AsFloat;
      FEnd   := FieldByName('P_End').AsFloat;

      FWuChaZ:= FieldByName('P_DaiWuChaZ').AsFloat;
      FWuChaF:= FieldByName('P_DaiWuChaF').AsFloat;
      FIsPercent := FieldByName('P_Percent').AsString;

      FStation := FieldByName('P_Station').AsString;
      FEnabled := True;
    finally
      Inc(nIdx);
      Next;
    end;
  end;
end;

procedure TfFormPoundDaiWC.LoadFormData;
var nIdx, nInt: Integer;
begin
  if FRecord = '' then Exit;

  nInt := StrToIntDef(FRecord, 255);
  for nIdx := Low(gPoundDaiWCParam) to High(gPoundDaiWCParam) do
  with gPoundDaiWCParam[nIdx] do
  if FIndex = nInt then
  begin
    EditStart.Text := FloatToStr(FStart);
    EditEnd.Text   := FloatToStr(FEnd);

    EditWCZ.Text   := FloatToStr(FWuChaZ);
    EditWCF.Text   := FloatToStr(FWuChaF);

    EditStation.Text := FStation;
    EditPert.Checked := FIsPercent = sFlag_Yes;
  end;  
end;

function TfFormPoundDaiWC.OnVerifyCtrl(Sender: TObject;
  var nHint: string): Boolean;
begin
  Result := True;

  if Sender = EditStart then
  begin
    Result := IsNumber(EditStart.Text, True);
    nHint  := '��������Ч��ֵ(��ʼ��Χ)';
  end else

  if Sender = EditEnd then
  begin
    Result := IsNumber(EditEnd.Text, True);
    nHint  := '��������Ч��ֵ(������Χ)';

    if not Result then Exit;

    Result := IsNumber(EditStart.Text, True);
    nHint  := '��������Ч��ֵ(��ʼ��Χ)';

    if not Result then Exit;

    Result := FloatRelation(StrToFloat(EditEnd.Text), StrToFloat(EditStart.Text),
              rtGreater, cPrecision);
    nHint  := '��ʼֵӦ��С�ڽ���ֵ'
  end else

  if Sender = EditWCZ then
  begin
    Result := IsNumber(EditWCZ.Text, True);
    nHint  := '��������Ч��Χ(�����)';
  end else

  if Sender = EditWCF then
  begin
    Result := IsNumber(EditWCF.Text, True);
    nHint  := '��������Ч��Χ(�����)';
  end;
end;  

procedure TfFormPoundDaiWC.BtnOKClick(Sender: TObject);
var nStart, nEnd: Double;
    nIdx, nInt: Integer;
    nSQL, nStr: string;
begin
  inherited;
  if not IsDataValid then Exit;

  nStart := StrToFloat(EditStart.Text);
  nEnd   := StrToFloat(EditEnd.Text);
  nInt   := StrToIntDef(FRecord, 255);

  for nIdx := Low(gPoundDaiWCParam) to High(gPoundDaiWCParam) do
  with gPoundDaiWCParam[nIdx] do
  if nInt <> FIndex then
  begin
    if FloatRelation(FStart, nStart, rtLE) and
       FloatRelation(FEnd, nStart, rtGE) and FEnabled then
    begin
      ShowMsg('��ʼ��Χ���ص�.', sHint);
      Exit;
    end else

    if FloatRelation(FStart, nEnd, rtLE) and
       FloatRelation(FEnd, nEnd, rtGE) and FEnabled then
    begin
      ShowMsg('������Χ���ص�.', sHint);
      Exit;
    end;
  end;
  //��ǰ

  if EditPert.Checked then
       nStr := sFlag_Yes
  else nStr := sFlag_No;

  nSQL := MakeSQLByStr([SF('P_Start', EditStart.Text),
          SF('P_End', EditEnd.Text),
          SF('P_Percent', nStr),
          
          SF('P_DaiWuChaZ', EditWCZ.Text),
          SF('P_DaiWuChaF', EditWCF.Text),
          SF('P_Station', EditStation.Text)
          ],sTable_PoundDaiWC, SF('R_ID', FRecord), FRecord='');
  FDM.ExecuteSQL(nSQL);        

  ModalResult := mrOk;
  ShowMsg('��Χ����ɹ�', sHint);
end;

initialization
  gControlManager.RegCtrl(TfFormPoundDaiWC, TfFormPoundDaiWC.FormID);
end.
