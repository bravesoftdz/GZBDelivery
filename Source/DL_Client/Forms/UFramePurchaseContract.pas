{*******************************************************************************
  ����: 289525016@163.com 2017-03-15
  ����: �ɹ���ͬ����
*******************************************************************************}
unit UFramePurchaseContract;

{$I Link.Inc}
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  UFrameNormal, cxStyles, cxCustomData, cxGraphics, cxFilter, cxData,
  cxDataStorage, cxEdit, DB, cxDBData, dxLayoutControl, cxMaskEdit,
  cxButtonEdit, cxTextEdit, ADODB, cxContainer, cxLabel, UBitmapPanel,
  cxSplitter, cxGridLevel, cxClasses, cxControls, cxGridCustomView,
  cxGridCustomTableView, cxGridTableView, cxGridDBTableView, cxGrid,
  cxCheckBox, cxLookAndFeels, cxLookAndFeelPainters, ComCtrls, ToolWin;

type
  TfFramePurchaseContract = class(TfFrameNormal)
    cxTextEdit1: TcxTextEdit;
    dxLayout1Item1: TdxLayoutItem;
    editcontactNo: TcxButtonEdit;
    dxLayout1Item2: TdxLayoutItem;
    cxTextEdit2: TcxTextEdit;
    dxLayout1Item4: TdxLayoutItem;
    cxTextEdit3: TcxTextEdit;
    dxLayout1Item3: TdxLayoutItem;
    cxTextEdit4: TcxTextEdit;
    dxLayout1Item5: TdxLayoutItem;
    editProviderCode: TcxButtonEdit;
    dxLayout1Item6: TdxLayoutItem;
    editMaterielCode: TcxButtonEdit;
    dxLayout1Item7: TdxLayoutItem;
    EditDate: TcxButtonEdit;
    dxLayout1Item8: TdxLayoutItem;
    CheckDelete: TcxCheckBox;
    dxLayout1Item9: TdxLayoutItem;
    editProviderName: TcxButtonEdit;
    dxLayout1Item10: TdxLayoutItem;
    dxLayout1Group2: TdxLayoutGroup;
    dxLayout1Group3: TdxLayoutGroup;
    procedure EditNamePropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure BtnAddClick(Sender: TObject);
    procedure BtnEditClick(Sender: TObject);
    procedure BtnDelClick(Sender: TObject);
    procedure EditDatePropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure CheckDeleteClick(Sender: TObject);
  private
    { Private declarations }
    FStart,FEnd: TDate;
  protected
    FWhere: string;
    procedure OnCreateFrame; override;
    procedure OnDestroyFrame; override;
    function InitFormDataSQL(const nWhere: string): string; override;
    {*��ѯSQL*}
  public
    { Public declarations }
    class function FrameID: integer; override;
  end;

implementation

{$R *.dfm}
uses
  ULibFun, UMgrControl, USysConst, USysDB, UDataModule, UFormBase, USysBusiness,
  UBusinessPacker,UFormDateFilter;

class function TfFramePurchaseContract.FrameID: integer;
begin
  Result := cFI_FramePurchaseContract;
end;

function TfFramePurchaseContract.InitFormDataSQL(const nWhere: string): string;
var nStr: string;
begin
  EditDate.Text := Format('%s �� %s', [Date2Str(FStart), Date2Str(FEnd)]);

  Result := 'select R_ID,pcid,con_code,provider_code,provider_name,con_materiel_Code,'
    +'con_materiel_name,con_price,con_quantity,con_price*con_quantity as con_Amount,'
    +'con_date,con_Man,case con_status when 0 then ''��ɾ��'' when 1 then ''��ͬ¼��'' '
    +'when 2 then ''������¼��'' when 3 then ''���ϴ�'' end as con_status,'
    +'con_remark from p_purchaseContract where con_date between ''%s'' and ''%s''';

  Result := Format(Result,[Date2Str(FStart),Date2Str(FEnd + 1)]);

  if CheckDelete.Checked then
  begin
    Result := Result+' and con_status=0';
  end
  else begin
    Result := Result+' and con_status>0';
  end;

  if nWhere <> '' then
    Result := Result + ' and (' + nWhere + ')';
end;

//Desc: ���
procedure TfFramePurchaseContract.BtnAddClick(Sender: TObject);
var nP: TFormCommandParam;
begin
  nP.FCommand := cCmd_AddData;
  CreateBaseFormItem(cFI_FormPurchaseContract, '', @nP);

  if (nP.FCommand = cCmd_ModalResult) and (nP.FParamA = mrOK) then
  begin
    InitFormData('');
  end;
end;

//Desc: �޸�
procedure TfFramePurchaseContract.BtnEditClick(Sender: TObject);
var nParam: TFormCommandParam;
begin
  if cxView1.DataController.GetSelectedCount < 1 then
  begin
    ShowMsg('��ѡ��Ҫ�༭�ļ�¼', sHint); Exit;
  end;

  nParam.FCommand := cCmd_EditData;
  nParam.FParamA := SQLQuery.FieldByName('pcId').AsString;
  CreateBaseFormItem(cFI_FormPurchaseContract, PopedomItem, @nParam);

  if (nParam.FCommand = cCmd_ModalResult) and (nParam.FParamA = mrOK) then
  begin
    InitFormData(FWhere);
  end;
end;

//Desc: ɾ��
procedure TfFramePurchaseContract.BtnDelClick(Sender: TObject);
var nStr: string;
  npcId:string;
  nHasconQuota:Boolean;
begin
  nHasconQuota := False;
  if cxView1.DataController.GetSelectedCount < 1 then
  begin
    ShowMsg('��ѡ��Ҫɾ���ļ�¼', sHint); Exit;
  end;

  nStr := 'select * from %s where pcid=''%s''';
  nStr := Format(nStr, [sTable_PurchaseContractDetail,SQLQuery.FieldByName('pcId').AsString]);
  with fdm.QueryTemp(nStr) do
  begin
    nHasconQuota := RecordCount>0;
  end;

  if nHasconQuota then
  begin
    nStr := '���ڶ�Ӧ�ĺ�ָͬ�꣬ɾ�����޷�¼�뻯������ȷ��Ҫɾ�����Ϊ[ %s ]�ĺ�ͬ��?';
  end
  else begin
    nStr := 'ȷ��Ҫɾ�����Ϊ[ %s ]�ĺ�ͬ��?';
  end;
  
  nStr := Format(nStr, [SQLQuery.FieldByName('pcId').AsString]);
  if not QueryDlg(nStr, sAsk) then Exit;

  {$IFDEF PurchaseOrderSingle}
  if gSysParam.FIsMT = 1 then
  begin
    if DeletePurchaseContractSingle(SQLQuery.FieldByName('pcId').AsString) then
    begin
      InitFormData(FWhere);
      ShowMsg('�ɹ���ͬ��ɾ��', sHint);
    end;
  end
  else
  begin
    if DeletePurchaseContract(SQLQuery.FieldByName('pcId').AsString) then
    begin
      InitFormData(FWhere);
      ShowMsg('�ɹ���ͬ��ɾ��', sHint);
    end;
  end;
  {$ELSE}
  if DeletePurchaseContract(SQLQuery.FieldByName('pcId').AsString) then
  begin
    InitFormData(FWhere);
    ShowMsg('�ɹ���ͬ��ɾ��', sHint);
  end;
  {$ENDIF}
end;

//Desc: ��ѯ
procedure TfFramePurchaseContract.EditNamePropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
var
  nStr:string;
begin
  nStr := Trim(TcxButtonEdit(Sender).Text);
  TcxButtonEdit(Sender).Text := nStr;
  if nStr='' then Exit;

  if Sender=editcontactNo then
  begin
    FWhere := 'con_code like ''%' + nStr + '%''';
    InitFormData(FWhere);
  end
  else if Sender=editProviderCode then
  begin
    FWhere := 'provider_code like ''%' + nStr + '%''';
    InitFormData(FWhere);
  end
  else if Sender=editProviderName then
  begin
    FWhere := 'provider_name like ''%' + nStr + '%''';
    InitFormData(FWhere);
  end  
  else if Sender=editMaterielCode then
  begin
    FWhere := 'con_materiel_Code like ''%' + nStr + '%''';
    InitFormData(FWhere);
  end;
end;

procedure TfFramePurchaseContract.EditDatePropertiesButtonClick(
  Sender: TObject; AButtonIndex: Integer);
begin
  if ShowDateFilterForm(FStart, FEnd) then InitFormData('');
end;

procedure TfFramePurchaseContract.OnCreateFrame;
begin
  inherited;
  InitDateRange(Name, FStart, FEnd);
end;

procedure TfFramePurchaseContract.OnDestroyFrame;
begin
  SaveDateRange(Name, FStart, FEnd);
  inherited;
end;

procedure TfFramePurchaseContract.CheckDeleteClick(Sender: TObject);
begin
  InitFormData('');
end;

initialization
  gControlManager.RegCtrl(TfFramePurchaseContract, TfFramePurchaseContract.FrameID);
end.
