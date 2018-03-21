unit UPurWebOrders;

{$I Link.Inc}
interface

uses
  Windows, Classes, Controls, SysUtils, UMgrDBConn, UMgrParam, DB,
  UBusinessWorker, UBusinessConst, UBusinessPacker, UMITConst;

type
  PPurWebOrderItems = ^TPurWebOrderItems;
  TPurWebOrderItems = record
    FOrder_id:string;
    FOrder_Type:string;
    Ffac_order_no:string;
    FOrdernumber:string;
    FGoodsID:string;
    FGoodsname:string;
    Ftracknumber:string;
    FData:string;
    FHd_order_no:string;
    Fspare:string;
    FDriverName:string;
    FNamePinYin:string;
    FDriverPhone:string;
    FToAddress:string;
    FIdNumber:string;
    FProvID:string;
    FProvName:string;
  end;

const
  sInXml = '<?xml version="1.0" encoding="utf-8"?>' +
            '<DATA>' +
            '  <head>' +
            '    <Factory>%s</Factory>' + //工厂id
            '    <CarNumber>%s</CarNumber>' + //车牌号
            '  </head>' +
            '</DATA>';

function GetTruckNoByELabel(const nELabel:string): string;
//获取车号
function TruckMultipleCard(const nTruckno:string;var nMsg:string):Boolean;
//校验车号是否可用
function GetPurchWebOrders(const nTruck:string): Boolean;
//获取采购网上下单
function CheckOrderValidate(var nWebOrderItem: TPurWebOrderItems): Boolean;
//校验订单有效性
function SaveOrder(const nOrderData: string): string;
//保存采购单
function SaveOrderCard(const nOrder, nCard: string): Boolean;
//绑定采购卡
function SaveWebOrderMatch(const nBillID, nWebOrderID: string): Boolean;
//保存电子单号

var
  gPurWebOrderItems: array of TPurWebOrderItems;
  gCardNo:string;
  gMaxQuantity:Double;

implementation

uses
  ULibFun, USysDB, USysLoger, UTaskMonitor, UWorkerBusinessCommand;


//Date: 2014-09-15
//Parm: 命令;数据;参数;输出
//Desc: 本地调用业务对象
function CallBusinessCommand(const nCmd: Integer;
  const nData, nExt: string; const nOut: PWorkerBusinessCommand): Boolean;
var nStr: string;
    nIn: TWorkerBusinessCommand;
    nPacker: TBusinessPackerBase;
    nWorker: TBusinessWorkerBase;
begin
  nPacker := nil;
  nWorker := nil;
  try
    nIn.FCommand := nCmd;
    nIn.FData := nData;
    nIn.FExtParam := nExt;

    nPacker := gBusinessPackerManager.LockPacker(sBus_BusinessCommand);
    nStr := nPacker.PackIn(@nIn);
    nWorker := gBusinessWorkerManager.LockWorker(sBus_BusinessCommand);
    //get worker

    Result := nWorker.WorkActive(nStr);
    if Result then
         nPacker.UnPackOut(nStr, nOut)
    else nOut.FData := nStr;
  finally
    gBusinessPackerManager.RelasePacker(nPacker);
    gBusinessWorkerManager.RelaseWorker(nWorker);
  end;
end;

//Date: 2015-08-06
//Parm: 命令;数据;参数;输出
//Desc: 调用中间件上的销售单据对象
function CallBusinessPurchaseOrder(const nCmd: Integer;
  const nData, nExt: string; const nOut: PWorkerBusinessCommand): Boolean;
var nStr: string;
    nIn: TWorkerBusinessCommand;
    nPacker: TBusinessPackerBase;
    nWorker: TBusinessWorkerBase;
begin
  nPacker := nil;
  nWorker := nil;
  try
    nIn.FCommand := nCmd;
    nIn.FData := nData;
    nIn.FExtParam := nExt;

    nPacker := gBusinessPackerManager.LockPacker(sBus_BusinessCommand);
    nStr := nPacker.PackIn(@nIn);
    nWorker := gBusinessWorkerManager.LockWorker(sBus_BusinessPurchaseOrder);
    //get worker

    Result := nWorker.WorkActive(nStr);
    if Result then
         nPacker.UnPackOut(nStr, nOut)
    else nOut.FData := nStr;
  finally
    gBusinessPackerManager.RelasePacker(nPacker);
    gBusinessWorkerManager.RelaseWorker(nWorker);
  end;
end;

procedure WriteLog(const nEvent: string);
begin
  gSysLoger.AddLog('PurWebOrders ::: ' + nEvent);
end;

//根据车号获取订单信息
function Get_ShopOrderbyTruck(const nXmlStr: string): string;
var nOut: TWorkerBusinessCommand;
begin
  Result := '';
  if CallBusinessCommand(cBC_WeChat_Get_ShopOrderByTruckNo, nXmlStr, '', @nOut) then
    Result := nOut.FData;
end;

//根据车号获取供货信息
function Get_ShopPurchaseByTruck(const nXmlStr:string):string;
var nOut: TWorkerBusinessCommand;
begin
  Result := '';
  if CallBusinessCommand(cBC_WeChat_Get_ShopPurchByTruckNo, nXmlStr, '', @nOut) then
    Result := nOut.FData;
end;

//Date: 2014-09-15
//Parm: 开单数据
//Desc: 保存采购单,返回采购单号列表
function SaveOrder(const nOrderData: string): string;
var nOut: TWorkerBusinessCommand;
begin
  if CallBusinessPurchaseOrder(cBC_SaveOrder, nOrderData, '', @nOut) then
       Result := nOut.FData
  else Result := '';
end;

//Date: 2014-09-17
//Parm: 交货单号;磁卡
//Desc: 绑定nBill.nCard
function SaveOrderCard(const nOrder, nCard: string): Boolean;
var nOut: TWorkerBusinessCommand;
begin
  Result := CallBusinessPurchaseOrder(cBC_SaveOrderCard, nOrder, nCard, @nOut);
end;

//lih 2018-02-03
//保存电子单号
function SaveWebOrderMatch(const nBillID, nWebOrderID: string): Boolean;
var
  nStr,nSQL: string;
  nErrNum: Integer;
  nDBConn: PDBWorker;
begin
  Result := False;
  nDBConn := nil;

  with gParamManager.ActiveParam^ do
  try
    nDBConn := gDBConnManager.GetConnection(FDB.FID, nErrNum);
    if not Assigned(nDBConn) then
    begin
      WriteLog('连接HM数据库失败(DBConn Is Null).');
      Exit;
    end;

    if not nDBConn.FConn.Connected then
      nDBConn.FConn.Connected := True;
    //conn db

    nSQL := 'insert into %s(WOM_WebOrderID,WOM_LID) values(''%s'',''%s'')';
    nSQL := Format(nSQL,[sTable_WebOrderMatch,nWebOrderID,nBillID]);

    gDBConnManager.WorkerExec(nDBConn, nSQL);
    Result := True;
  finally
    gDBConnManager.ReleaseConnection(nDBConn);
  end;
end;

//lih 2018-02-03
//获取车号
function GetTruckNoByELabel(const nELabel:string): string;
var
  nStr,nSQL: string;
  nErrNum: Integer;
  nDBConn: PDBWorker;
begin
  Result := '';
  nDBConn := nil;

  with gParamManager.ActiveParam^ do
  try
    nDBConn := gDBConnManager.GetConnection(FDB.FID, nErrNum);
    if not Assigned(nDBConn) then
    begin
      WriteLog('连接HM数据库失败(DBConn Is Null).');
      Exit;
    end;

    if not nDBConn.FConn.Connected then
      nDBConn.FConn.Connected := True;
    //conn db

    nSQL := 'Select T_Truck From $TK Where T_Card=''$TD'' and T_CardUsePurch = ''$TP'' ';
    nSQL := MacroValue(nSQL, [MI('$TK', sTable_Truck), MI('$TD', nELabel), MI('$TP', sFlag_Yes)]);

    with gDBConnManager.WorkerQuery(nDBConn, nSQL) do
    if RecordCount > 0 then
    begin
      Result := Fields[0].AsString;
    end;

  finally
    gDBConnManager.ReleaseConnection(nDBConn);
  end;
end;

function TruckMultipleCard(const nTruckno:string;var nMsg:string):Boolean;
var
  nStr,nSQL: string;
  nErrNum: Integer;
  nDBConn: PDBWorker;
begin
  Result := False;
  nDBConn := nil;

  with gParamManager.ActiveParam^ do
  try
    nDBConn := gDBConnManager.GetConnection(FDB.FID, nErrNum);
    if not Assigned(nDBConn) then
    begin
      WriteLog('连接HM数据库失败(DBConn Is Null).');
      Exit;
    end;

    if not nDBConn.FConn.Connected then
      nDBConn.FConn.Connected := True;
    //conn db

    nSQL := 'select * from %s where l_card<>'''' and l_truck=''%s''';
    nSQL := Format(nSQL,[sTable_Bill, nTruckno]);
    with gDBConnManager.WorkerQuery(nDBConn, nSQL) do
    begin
      if RecordCount>0 then
      begin
        nMsg := '车辆%s在完成交货单%s之前禁止开单';
        nMsg := Format(nMsg, [nTruckno, FieldByName('l_id').AsString]);
        Exit;
      end;
    end;

    nSQL := 'select * from %s where O_card<>'''' and o_truck=''%s''';
    nSQL := Format(nSQL, [sTable_Order, nTruckno]);
    with gDBConnManager.WorkerQuery(nDBConn, nSQL) do
    begin
      if RecordCount>0 then
      begin
        nMsg := '车辆%s在完成采购订单%s之前禁止开单';
        nMsg := Format(nMsg, [nTruckno, FieldByName('o_id').AsString]);
        Exit;
      end;
    end;
    Result := True;
  finally
    gDBConnManager.ReleaseConnection(nDBConn);
  end;
end;

//lih 2018-02-03
//校验订单有效性
function CheckOrderValidate(var nWebOrderItem: TPurWebOrderItems): Boolean;
var
  nDBConn: PDBWorker;
  nErrNum :Integer;
  nSQL, nStr:string;
  nwebOrderValue:Double;
begin
  Result := False;
  nDBConn := nil;

  with gParamManager.ActiveParam^ do
  try
    nDBConn := gDBConnManager.GetConnection(FDB.FID, nErrNum);
    if not Assigned(nDBConn) then
    begin
      WriteLog('连接HM数据库失败(DBConn Is Null).');
      Exit;
    end;

    if not nDBConn.FConn.Connected then
      nDBConn.FConn.Connected := True;
    //conn db
    
    nSQL := 'Select *,con_quantity-con_finished_quantity as con_remain_quantity From %s where con_status>0 and pcId=''%s''';
    nSQL := Format(nSQL,[sTable_PurchaseContract,nWebOrderItem.Ffac_order_no]);

    with gDBConnManager.WorkerQuery(nDBConn, nSQL) do
    begin
      if RecordCount<=0 then
      begin
        //继续查询采购申请单
        nSQL := 'select b_proid as provider_code,b_proname as provider_name,b_stockno as con_materiel_Code,b_restvalue as con_remain_quantity from %s where b_id=''%s''';
        nSQL := Format(nSQL,[sTable_OrderBase,nWebOrderItem.Ffac_order_no]);
        
        with gDBConnManager.WorkerQuery(nDBConn, nSQL) do
        begin
          if RecordCount<=0 then
          begin
            nStr := '采购合同编号有误或采购合同已被删除[%s]。';
            nStr := Format(nStr, [nWebOrderItem.Ffac_order_no]);
            Writelog(nStr);
            Exit;
          end;
        end;
      end;

      nWebOrderItem.FProvID := FieldByName('provider_code').AsString;
      nWebOrderItem.FProvName := FieldByName('provider_name').AsString;

      if nWebOrderItem.FGoodsID<>FieldByName('con_materiel_Code').AsString then
      begin
        nStr := '商城货单中原材料[%s]有误。';
        nStr := Format(nStr, [nWebOrderItem.FGoodsname]);
        Writelog(nStr);
        Exit;
      end;

      nwebOrderValue := StrToFloatDef(nWebOrderItem.FData,0);
      gMaxQuantity := FieldByName('con_remain_quantity').AsFloat;

      if nwebOrderValue-gMaxQuantity>0.00001 then
      begin
        nStr := '商城货单中数量有误，最多可用数量为[%f]。';
        nStr := Format(nStr, [gMaxQuantity]);
        Writelog(nStr);
        Exit;
      end;
      Result := True;
    end;
  finally
    gDBConnManager.ReleaseConnection(nDBConn);
  end;
end;

function GetPurchWebOrders(const nTruck:string): Boolean;
var
  nInXml, nOutData:string;
  nListA, nListB: TStringList;
  nCount, i: Integer;
begin
  Result := False;
  nInXml := '<?xml version="1.0" encoding="UTF-8"?>'
            +'<DATA>'
            +'<head>'
            +'<Factory>%s</Factory>'
            +'<CarNumber>%s</CarNumber>'
            +'</head>'
            +'</DATA>';

  nInXml := Format(nInXml, [gSysParam.FFactory, nTruck]);
  WriteLog(nInXml);
  nInXml := PackerEncodeStr(nInXml);
  
  nOutData := Get_ShopPurchaseByTruck(nInXml);
  if nOutData = '' then
  begin
    WriteLog('未查询到网上商城订单详细信息，请检查订单号是否正确');
    Exit;
  end;

  nOutData := PackerDecodeStr(nOutData);
  {$IFDEF DEBUG}
  Writelog('Get_ShopPurchaseByTruck Res: ' + nOutData);
  {$ENDIF}
  nListA := TStringList.Create;
  nListB := TStringList.Create;
  try
    nListA.Text := nOutData;
    for i := nListA.Count-1 downto 0 do
    begin
      if Trim(nListA.Strings[i])='' then
      begin
        nListA.Delete(i);
      end;
    end;

    nCount := nListA.Count;
    SetLength(gPurWebOrderItems, nCount);
    for i := 0 to nCount-1 do
    begin
      nListB.CommaText := nListA.Strings[i];
      gPurWebOrderItems[i].FOrder_id := nListB.Values['order_id'];
      gPurWebOrderItems[i].FOrder_Type := nListB.Values['order_type'];
      gPurWebOrderItems[i].Ffac_order_no := nListB.Values['fac_order_no'];
      gPurWebOrderItems[i].FOrdernumber := nListB.Values['ordernumber'];
      gPurWebOrderItems[i].FGoodsID := nListB.Values['goodsID'];

      gPurWebOrderItems[i].FGoodsname := nListB.Values['goodsname'];
      gPurWebOrderItems[i].Ftracknumber := nListB.Values['tracknumber'];
      gPurWebOrderItems[i].FData := nListB.Values['data'];
      gPurWebOrderItems[i].FHd_Order_no := nListB.Values['hd_fac_order_no'];
      gPurWebOrderItems[i].Fspare := nListB.Values['spare'];

      gPurWebOrderItems[i].FDriverName := nListB.Values['drivername'];
      gPurWebOrderItems[i].FNamePinYin := nListB.Values['namepinyin'];
      gPurWebOrderItems[i].FDriverPhone := nListB.Values['driverphone'];
      gPurWebOrderItems[i].FToAddress := nListB.Values['toaddress'];
      gPurWebOrderItems[i].FIdNumber := nListB.Values['idnumber'];

      if (gPurWebOrderItems[i].FOrder_Type = sFlag_Provide)
        or (gPurWebOrderItems[i].FOrder_Type = '') then
      Result := True;
    end;
  finally
    nListB.Free;
    nListA.Free;
  end;
end;



end.
