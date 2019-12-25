{*******************************************************************************
  ����: fendou116688@163.com 2017/3/21
  ����: ԭ������ϸ����
*******************************************************************************}
unit UFrameImportOrderDetail;

{$I Link.Inc}
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  UFrameNormal, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxStyles, cxCustomData, cxFilter, cxData,
  cxDataStorage, cxEdit, DB, cxDBData, cxContainer, Menus, dxLayoutControl,
  cxMaskEdit, cxButtonEdit, cxTextEdit, ADODB, cxLabel, UBitmapPanel,
  cxSplitter, cxGridLevel, cxClasses, cxGridCustomView,
  cxGridCustomTableView, cxGridTableView, cxGridDBTableView, cxGrid,
  ComCtrls, ToolWin, Dialogs;

type
  TfFrameImportOrderDetail = class(TfFrameNormal)
    cxtxtdt1: TcxTextEdit;
    dxLayout1Item5: TdxLayoutItem;
    EditDate: TcxButtonEdit;
    dxLayout1Item6: TdxLayoutItem;
    EditCustomer: TcxButtonEdit;
    dxLayout1Item8: TdxLayoutItem;
    cxtxtdt2: TcxTextEdit;
    dxLayout1Item1: TdxLayoutItem;
    pmPMenu1: TPopupMenu;
    mniN1: TMenuItem;
    cxtxtdt3: TcxTextEdit;
    dxLayout1Item2: TdxLayoutItem;
    cxtxtdt4: TcxTextEdit;
    dxLayout1Item3: TdxLayoutItem;
    EditTruck: TcxButtonEdit;
    dxLayout1Item4: TdxLayoutItem;
    EditBill: TcxButtonEdit;
    dxLayout1Item7: TdxLayoutItem;
    FExcelFile: TOpenDialog;
    procedure EditDatePropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure EditTruckPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure mniN1Click(Sender: TObject);
    procedure BtnAddClick(Sender: TObject);
  private
    { Private declarations }
  protected
    FStart,FEnd: TDate;
    FTimeS,FTimeE: TDate;
    //ʱ������
    FJBWhere: string;
    //��������
    FListA, FListB, FListC: TStrings;
    procedure OnCreateFrame; override;
    procedure OnDestroyFrame; override;
    function InitFormDataSQL(const nWhere: string): string; override;
    //��ѯSQL
  public
    { Public declarations }
    class function FrameID: integer; override;
  end;

implementation

{$R *.dfm}
uses
  IniFiles, ULibFun, UMgrControl, UFormDateFilter, USysPopedom, USysBusiness,
  UBusinessConst, USysConst, USysDB, UFormWait, UExcel2003UINT, UBusinessPacker;

class function TfFrameImportOrderDetail.FrameID: integer;
begin
  Result := cFI_FrameImportOrderDetail;
end;

procedure TfFrameImportOrderDetail.OnCreateFrame;
begin
  inherited;
  FTimeS := Str2DateTime(Date2Str(Now) + ' 00:00:00');
  FTimeE := Str2DateTime(Date2Str(Now) + ' 00:00:00');

  FJBWhere := '';
  InitDateRange(Name, FStart, FEnd);

  FListA := TStringList.Create;
  FListB := TStringList.Create;
  FListC := TStringList.Create;
end;

procedure TfFrameImportOrderDetail.OnDestroyFrame;
begin
  SaveDateRange(Name, FStart, FEnd);

  FListA.Free;
  FListB.Free;
  FListC.Free;
  inherited;
end;

function TfFrameImportOrderDetail.InitFormDataSQL(const nWhere: string): string;
begin
  EditDate.Text := Format('%s �� %s', [Date2Str(FStart), Date2Str(FEnd)]);
  Result := 'Select *,(P_MValue-P_PValue-P_KZValue) as P_NetWeight ' +
            'From $Table Where P_Import=''$Yes''';
  //xxxxxx

  if FJBWhere = '' then
  begin
    Result := Result + ' And ((P_MDate>=''$S'' and P_MDate <''$End'') or ' +
              '(P_PDate>=''$S'' and P_PDate <''$End''))';

    if nWhere <> '' then
      Result := Result + ' And (' + nWhere + ')';
    //xxxxx
  end else
  begin
    Result := Result + ' And (' + FJBWhere + ')';
  end;

  Result := MacroValue(Result, [MI('$Table', sTable_PoundLog),
            MI('$S', Date2Str(FStart)), MI('$End', Date2Str(FEnd + 1)),
            MI('$Yes', sFlag_Yes)]);
  //xxxxx
end;


//Desc: ����ɸѡ
procedure TfFrameImportOrderDetail.EditDatePropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
begin
  if ShowDateFilterForm(FStart, FEnd) then InitFormData(FWhere);
end;

//Desc: ִ�в�ѯ
procedure TfFrameImportOrderDetail.EditTruckPropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
begin
  if Sender = EditCustomer then
  begin
    EditCustomer.Text := Trim(EditCustomer.Text);
    if EditCustomer.Text = '' then Exit;

    FWhere := 'P_CusName like ''%%%s%%''';
    FWhere := Format(FWhere, [EditCustomer.Text, EditCustomer.Text]);
    InitFormData(FWhere);
  end else

  if Sender = EditTruck then
  begin
    EditTruck.Text := Trim(EditTruck.Text);
    if EditTruck.Text = '' then Exit;

    FWhere := 'P_Truck like ''%%%s%%''';
    FWhere := Format(FWhere, [EditTruck.Text]);
    InitFormData(FWhere);
  end;

  if Sender = EditBill then
  begin
    EditBill.Text := Trim(EditBill.Text);
    if EditBill.Text = '' then Exit;

    FWhere := 'P_ID like ''%%%s%%''';
    FWhere := Format(FWhere, [EditBill.Text]);
    InitFormData(FWhere);
  end;
end;

//Desc: ���Ӱ��ѯ
procedure TfFrameImportOrderDetail.mniN1Click(Sender: TObject);
begin
  if ShowDateFilterForm(FTimeS, FTimeE, True) then
  try
    FJBWhere := '(P_PDate>=''%s'' and P_PDate <''%s'')';
    FJBWhere := Format(FJBWhere, [DateTime2Str(FTimeS), DateTime2Str(FTimeE)]);
    InitFormData('');
  finally
    FJBWhere := '';
  end;
end;

//------------------------------------------------------------------------------
//Date: 2017/3/21
//Parm: �����ļ�
//Desc: ���������¼
procedure TfFrameImportOrderDetail.BtnAddClick(Sender: TObject);
var nFile: string;
begin
  inherited;
  FExcelFile.Filter := '*.xls';
  if FExcelFile.Execute then
    nFile := FExcelFile.FileName;

  if not FileExists(nFile) then Exit;

  FListA.Clear;
  FListC.Clear;
  //ͬ����Ϣ

  ShowWaitForm('���ڵ����������.');
  try
    try
      with gExcel2003.Excel2DataSet(nFile) do
      if RecordCount > 0 then
      begin
        First;

        while not Eof do
        try
          with FListB do
          begin
            Clear;

            Values['P_ID'] := FieldByName('����').AsString;
            Values['P_Order'] := FieldByName('��ͬ��').AsString;
            Values['P_Truck'] := FieldByName('����').AsString;
            Values['P_CusID'] := FieldByName('��Ӧ�̱��').AsString;
            Values['P_CusName'] := FieldByName('��Ӧ������').AsString;
            Values['P_MID'] := FieldByName('���ϱ��').AsString;
            Values['P_MName'] := FieldByName('��������').AsString;
            Values['P_PValue'] := FieldByName('Ƥ��').AsString;
            Values['P_PDate'] := FieldByName('��Ƥʱ��').AsString;
            Values['P_MValue'] := FieldByName('ë��').AsString;
            Values['P_MDate'] := FieldByName('��ëʱ��').AsString;
            Values['P_KZValue'] := FieldByName('����').AsString;
          end;

          FListC.Add(FListB.Text);
          //���ı���

          FListA.Add(PackerEncodeStr(FListB.Text));
          //���Ĵ���
        finally
          Next;
        end;
      end;

      {$IFDEF PurchaseOrderSingle}
      if gSysParam.FIsMT = 1 then
      begin
        if not RemoteImportPoundsSingle(PackerEncodeStr(FListA.Text)) then Exit;
      end
      else
      begin
        if not RemoteImportPounds(PackerEncodeStr(FListA.Text)) then Exit;
      end;
      {$ELSE}
      if not RemoteImportPounds(PackerEncodeStr(FListA.Text)) then Exit;
      {$ENDIF}

      ShowMsg('�����������', sHint);
      
      nFile := gPath + sLogDir + FormatDateTime('YYYYMMDDhhmmss', Now) + '.txt';
      FListC.SaveToFile(nFile);
    except
      on E: Exception do
        ShowMsg(E.Message, sWarn);
    end;
  finally
    gExcel2003.CloseFile;
    CloseWaitForm;
  end;
end;

initialization
  gControlManager.RegCtrl(TfFrameImportOrderDetail, TfFrameImportOrderDetail.FrameID);
end.
