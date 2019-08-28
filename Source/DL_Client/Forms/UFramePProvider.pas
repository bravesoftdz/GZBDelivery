{*******************************************************************************
  作者: dmzn@163.com 2009-7-2
  描述: 供应商
*******************************************************************************}
unit UFramePProvider;

{$I Link.Inc}
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  UFrameNormal, cxStyles, cxCustomData, cxGraphics, cxFilter, cxData,
  cxDataStorage, cxEdit, DB, cxDBData, dxLayoutControl, cxMaskEdit,
  cxButtonEdit, cxTextEdit, ADODB, cxContainer, cxLabel, UBitmapPanel,
  cxSplitter, cxGridLevel, cxClasses, cxControls, cxGridCustomView,
  cxGridCustomTableView, cxGridTableView, cxGridDBTableView, cxGrid,
  ComCtrls, ToolWin, cxLookAndFeels, cxLookAndFeelPainters, dxSkinsCore,
  dxSkinsDefaultPainters, Menus;

type
  TfFrameProvider = class(TfFrameNormal)
    cxTextEdit1: TcxTextEdit;
    dxLayout1Item1: TdxLayoutItem;
    EditName: TcxButtonEdit;
    dxLayout1Item2: TdxLayoutItem;
    cxTextEdit2: TcxTextEdit;
    dxLayout1Item4: TdxLayoutItem;
    PopupMenu1: TPopupMenu;
    N1: TMenuItem;
    N2: TMenuItem;
    N3: TMenuItem;
    procedure EditNamePropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure BtnAddClick(Sender: TObject);
    procedure BtnEditClick(Sender: TObject);
    procedure BtnDelClick(Sender: TObject);
    procedure N1Click(Sender: TObject);
    procedure PopupMenu1Popup(Sender: TObject);
    procedure N2Click(Sender: TObject);
    procedure N3Click(Sender: TObject);
  private
    { Private declarations }
    FListA: TStrings;
    function AddMallUser(const nBindcustomerid,nprov_num,nprov_name:string):Boolean;
    function DelMallUser(const nNamepinyin,nprov_num:string):Boolean;
  protected
    function InitFormDataSQL(const nWhere: string): string; override;
    procedure OnCreateFrame; override;
    procedure OnDestroyFrame; override;
    //创建释放
    {*查询SQL*}
  public
    { Public declarations }
    class function FrameID: integer; override;
  end;

implementation

{$R *.dfm}
uses
  ULibFun, UMgrControl, USysConst, USysDB, UDataModule, UFormBase, USysBusiness,
  UBusinessPacker,USysLoger;

class function TfFrameProvider.FrameID: integer;
begin
  Result := cFI_FrameProvider;
end;

function TfFrameProvider.InitFormDataSQL(const nWhere: string): string;
begin
  Result := 'Select * From ' + sTable_Provider;
  if nWhere <> '' then
    Result := Result + ' Where (' + nWhere + ')';
  Result := Result + ' Order By P_Name';
end;

//Desc: 添加
procedure TfFrameProvider.BtnAddClick(Sender: TObject);
var nP: TFormCommandParam;
begin
  nP.FCommand := cCmd_AddData;
  CreateBaseFormItem(cFI_FormProvider, '', @nP);

  if (nP.FCommand = cCmd_ModalResult) and (nP.FParamA = mrOK) then
  begin
    InitFormData('');
  end;
end;

//Desc: 修改
procedure TfFrameProvider.BtnEditClick(Sender: TObject);
var nP: TFormCommandParam;
begin
  if cxView1.DataController.GetSelectedCount > 0 then
  begin
    nP.FCommand := cCmd_EditData;
    nP.FParamA := SQLQuery.FieldByName('P_ID').AsString;
    CreateBaseFormItem(cFI_FormProvider, '', @nP);

    if (nP.FCommand = cCmd_ModalResult) and (nP.FParamA = mrOK) then
    begin
      InitFormData(FWhere);
    end;
  end;
end;

//Desc: 删除
procedure TfFrameProvider.BtnDelClick(Sender: TObject);
var nStr: string;
begin
  if cxView1.DataController.GetSelectedCount > 0 then
  begin
    nStr := SQLQuery.FieldByName('P_Name').AsString;
    nStr := Format('确定要删除供应商[ %s ]吗?', [nStr]);
    if not QueryDlg(nStr, sAsk) then Exit;

    nStr := 'Delete From %s Where R_ID=%s';
    nStr := Format(nStr, [sTable_Provider, SQLQuery.FieldByName('R_ID').AsString]);

    FDM.ExecuteSQL(nStr);
    InitFormData(FWhere);
  end;
end;

//Desc: 查询
procedure TfFrameProvider.EditNamePropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
begin
  if Sender = EditName then
  begin
    EditName.Text := Trim(EditName.Text);
    if EditName.Text = '' then Exit;

    FWhere := Format('P_Name Like ''%%%s%%''', [EditName.Text]);
    InitFormData(FWhere);
  end;
end;

procedure TfFrameProvider.N1Click(Sender: TObject);
begin
  inherited;
  SyncRemoteProviders;
  BtnRefresh.Click;
end;

procedure TfFrameProvider.PopupMenu1Popup(Sender: TObject);
begin
  inherited;
  {$IFDEF SyncRemote}
  N1.Visible := True;
  {$ENDIF}
end;

procedure TfFrameProvider.N2Click(Sender: TObject);
var
  nWechartAccount:string;
  nParam: TFormCommandParam;
  nPID,nPName,nPhone:string;
  nBindcustomerid:string;
  nStr,nMsg:string;
begin
  if cxView1.DataController.GetSelectedCount < 1 then
  begin
    ShowMsg('请选择要开通的记录', sHint);
    Exit;
  end;
  {$IFDEF UseWXServiceEx}
    nWechartAccount := SQLQuery.FieldByName('P_WechartAccount').AsString;
    if nWechartAccount<>'' then
    begin
      ShowMsg('商城账户['+nWechartAccount+']已存在', sHint);
      Exit;
    end;
    nParam.FCommand := cCmd_AddData;
    CreateBaseFormItem(cFI_FormGetWXAccount, PopedomItem, @nParam);

    if (nParam.FCommand <> cCmd_ModalResult) or (nParam.FParamA <> mrOK) then Exit;

    nBindcustomerid  := nParam.FParamB;
    nWechartAccount  := nParam.FParamC;
    nPhone           := nParam.FParamD;
    nPID      := SQLQuery.FieldByName('P_ID').AsString;
    nPName    := SQLQuery.FieldByName('P_Name').AsString;

    with FListA do
    begin
      Clear;
      Values['Action']   := 'add';
      Values['BindID']   := nBindcustomerid;
      Values['Account']  := nWechartAccount;
      Values['CusID']    := nPID;
      Values['CusName']  := nPName;
      Values['Memo']     := sFlag_Provide;
      Values['Phone']    := nPhone;
      Values['btype']    := '2';
    end;
    nMsg := edit_shopclientsEx(PackerEncodeStr(FListA.Text));
    if nMsg <> sFlag_Yes then
    begin
       ShowMsg('关联商城账户失败：'+nMsg,sHint);
       Exit;
    end;

    //call remote
    nStr := 'update %s set P_WechartAccount=''%s'',P_Phone=''%s'',P_custSerialNo=''%s'' where P_ID=''%s''';
    nStr := Format(nStr,[sTable_Provider,nWechartAccount, nPhone, nBindcustomerid, nPID]);

    FDM.ADOConn.BeginTrans;
    try
      FDM.ExecuteSQL(nStr);
      FDM.ADOConn.CommitTrans;
      ShowMsg('供应商 [ '+nPName+' ] 关联商城账户成功！',sHint);
      InitFormData(FWhere);
    except
      FDM.ADOConn.RollbackTrans;
      ShowMsg('关联商城账户失败', '未知错误');
    end;
  {$ELSE}
  nWechartAccount := SQLQuery.FieldByName('P_WechartAccount').AsString;
  if nWechartAccount<>'' then
  begin
    ShowMsg('商城账户['+nWechartAccount+']已存在', sHint);
    Exit;
  end;
  nParam.FCommand := cCmd_AddData;
  CreateBaseFormItem(cFI_FormGetWechartAccount, PopedomItem, @nParam);
  if (nParam.FCommand = cCmd_ModalResult) and (nParam.FParamA = mrOK) then
  begin
    nBindcustomerid := PackerDecodeStr(nParam.FParamB);
    nWechartAccount := PackerDecodeStr(nParam.FParamC);
    nPID := SQLQuery.FieldByName('P_ID').AsString;
    nPName := SQLQuery.FieldByName('P_Name').AsString;
    if not AddMallUser(nBindcustomerid,nPID,nPName) then Exit;

    nStr := 'update %s set P_WechartAccount=''%s'' where P_ID=''%s''';
    nStr := Format(nStr,[sTable_Provider,nWechartAccount,nPID]);
    FDM.ADOConn.BeginTrans;
    try
      FDM.ExecuteSQL(nStr);
      FDM.ADOConn.CommitTrans;
      ShowMsg('供应商 [ '+nPName+' ] 关联商城账户成功！',sHint);
      InitFormData(FWhere);
    except
      FDM.ADOConn.RollbackTrans;
      ShowMsg('关联商城账户失败', '未知错误');
    end;
  end;
  {$ENDIF}  
end;

function TfFrameProvider.AddMallUser(const nBindcustomerid,nprov_num,nprov_name:string): Boolean;
var
  nXmlStr:string;
  nData:string;
  ntype:string;
begin
  Result := False;
  ntype := 'add';
  //发送绑定请求开户请求
  nXmlStr := '<?xml version="1.0" encoding="UTF-8" ?>'
            +'<DATA>'
            +'<head>'
            +'<Factory>%s</Factory>'
            +'<Customer />'
            +'<Provider>%s</Provider>'
            +'<type>%s</type>'
            +'</head>'
            +'<Items>'
            +'<Item>'
            +'<providername>%s</providername>'
            +'<cash>0</cash>'
            +'<providernumber>%s</providernumber>'
            +'</Item>'
            +'</Items>'
            +'<remark />'
            +'</DATA>';
  nXmlStr := Format(nXmlStr,[gSysParam.FFactory,nBindcustomerid,ntype,nprov_name,nprov_num]);
  nXmlStr := PackerEncodeStr(nXmlStr);
  nData := edit_shopclients(nXmlStr);
  gSysLoger.AddLog(TfFrameProvider,'AddMallUser',nData);
  if nData<>sFlag_Yes then
  begin
    ShowMsg('供应商[ '+nProv_num+' ]关联商城账户失败！', sError);
    Exit;
  end;
  Result := True;
end;

function TfFrameProvider.DelMallUser(const nNamepinyin,nprov_num:string):Boolean;
var
  nXmlStr:string;
  nData:string;
begin
  Result := False;
  //发送http请求
  nXmlStr := '<?xml version="1.0" encoding="UTF-8"?>'
      +'<DATA>'
      +'<head>'
      +'<Factory>%s</Factory>'
      +'<Provider>%s</Provider>'
      +'<type>del</type>'
      +'</head>'
      +'<Items><Item>'
      +'<providernumber>%s</providernumber>'
      +'</Item></Items><remark/></DATA>';
  nXmlStr := Format(nXmlStr,[gSysParam.FFactory,nNamepinyin,nprov_num]);

  nXmlStr := PackerEncodeStr(nXmlStr);
  nData := edit_shopclients(nXmlStr);
  gSysLoger.AddLog(TfFrameProvider,'DelMallUser',nData);
  if nData<>sFlag_Yes then
  begin
    ShowMsg('供应商[ '+nProv_num+' ]取消商城账户关联 失败！', sError);
    Exit;
  end;
  Result := True;
end;

procedure TfFrameProvider.N3Click(Sender: TObject);
var
  nWechartAccount:string;
  nPID:string;
  nStr:string;
  nPName,nMsg,nPhone,nBindID:string;
begin
  if cxView1.DataController.GetSelectedCount < 1 then
  begin
    ShowMsg('请选择要取消的记录', sHint);
    Exit;
  end;
  {$IFDEF UseWXServiceEx}
    nWechartAccount := SQLQuery.FieldByName('P_WechartAccount').AsString;
    if nWechartAccount='' then
    begin
      ShowMsg('商城账户不存在', sHint);
      Exit;
    end;

    nPID     := SQLQuery.FieldByName('P_ID').AsString;
    nPName   := SQLQuery.FieldByName('P_Name').AsString;
    nPhone   := SQLQuery.FieldByName('P_Phone').AsString;
    nBindID  := SQLQuery.FieldByName('P_custSerialNo').AsString;

    with FListA do
    begin
      Clear;
      Values['Action']   := 'del';
      Values['Account']  := nWechartAccount;
      Values['CusID']    := nPID;
      Values['CusName']  := nPName;
      Values['Memo']     := sFlag_Provide;
      Values['Phone']    := nPhone;
      Values['BindID']   := nBindID;
      Values['btype']    := '2';
    end;
    nMsg := edit_shopclientsEx(PackerEncodeStr(FListA.Text));
    if nMsg <> sFlag_Yes then
    begin
       ShowMsg('取消关联商城账户失败：'+nMsg,sHint);
       Exit;
    end;
    //call remote

    nStr := 'update %s set P_WechartAccount='''',P_Phone='''',P_custSerialNo='''' where P_ID=''%s''';
    nStr := Format(nStr,[sTable_Provider,nPID]);
    FDM.ADOConn.BeginTrans;
    try
      FDM.ExecuteSQL(nStr);
      FDM.ADOConn.CommitTrans;
      ShowMsg('供应商 [ '+nPName+' ] 取消商城账户关联 成功！',sHint);
      InitFormData(FWhere);
    except
      FDM.ADOConn.RollbackTrans;
      ShowMsg('取消商城账户关联 失败', '未知错误');
    end;
  {$ELSE}
  nWechartAccount := SQLQuery.FieldByName('P_WechartAccount').AsString;
  if nWechartAccount='' then
  begin
    ShowMsg('商城账户不已存在', sHint);
    Exit;
  end;

  nPID := SQLQuery.FieldByName('P_ID').AsString;
  nPName := SQLQuery.FieldByName('P_Name').AsString;
  
  if not DelMallUser(nWechartAccount,nPID) then Exit;
  
  nStr := 'update %s set P_WechartAccount='''' where P_ID=''%s''';
  nStr := Format(nStr,[sTable_Provider,nPID]);
  FDM.ADOConn.BeginTrans;
  try
    FDM.ExecuteSQL(nStr);
    FDM.ADOConn.CommitTrans;
    ShowMsg('供应商 [ '+nPName+' ] 取消商城账户关联 成功！',sHint);
    InitFormData(FWhere);
  except
    FDM.ADOConn.RollbackTrans;
    ShowMsg('取消商城账户关联 失败', '未知错误');
  end;
  {$ENDIF}
end;

procedure TfFrameProvider.OnCreateFrame;
begin
  inherited;
  FListA := TStringList.Create;
end;

procedure TfFrameProvider.OnDestroyFrame;
begin
  FListA.Free;
  inherited;
end;

initialization
  gControlManager.RegCtrl(TfFrameProvider, TfFrameProvider.FrameID);
end.
