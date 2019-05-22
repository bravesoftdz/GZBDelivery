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
            '    <Factory>%s</Factory>' + //����id
            '    <CarNumber>%s</CarNumber>' + //���ƺ�
            '  </head>' +
            '</DATA>';

function GetTruckNoByELabel(const nELabel:string): string;
//��ȡ����
function TruckMultipleCard(const nTruckno:string;var nMsg:string):Boolean;
//У�鳵���Ƿ����
function CheckSaveOrderOK(const nTruckno:string;var nMsg:string):Boolean;
//�ɹ��ѱ���δ����
function GetPurchWebOrders(const nTruck:string): Boolean;
//��ȡ�ɹ������µ�
function CheckOrderValidate(var nWebOrderItem: TPurWebOrderItems): Boolean;
//У�鶩����Ч��
function SaveOrder(const nOrderData: string): string;
//����ɹ���
function SaveOrderCard(const nOrder, nCard: string): Boolean;
//�󶨲ɹ���
function SaveWebOrderMatch(const nBillID, nWebOrderID: string): Boolean;
//������ӵ���
function CheckCardOK(const nCard:string; var nMsg:string):Boolean;
//���ſ��Ƿ�ռ��
function GetDayNumInfo(const nStockNo:string; const nProID:string;var nMsg:string):Boolean;
//��ȡ���չ�Ӧ���ѽ�����

var
  gPurWebOrderItems: array of TPurWebOrderItems;
  gCardNo:string;
  gMaxQuantity:Double;

implementation

uses
  ULibFun, USysDB, USysLoger, UTaskMonitor, UWorkerBusinessCommand;


//Date: 2014-09-15
//Parm: ����;����;����;���
//Desc: ���ص���ҵ�����
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
//Parm: ����;����;����;���
//Desc: �����м���ϵ����۵��ݶ���
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

//���ݳ��Ż�ȡ������Ϣ
function Get_ShopOrderbyTruck(const nXmlStr: string): string;
var nOut: TWorkerBusinessCommand;
begin
  Result := '';
  if CallBusinessCommand(cBC_WeChat_Get_ShopOrderByTruckNo, nXmlStr, '', @nOut) then
    Result := nOut.FData;
end;

//���ݳ��Ż�ȡ������Ϣ
function Get_ShopPurchaseByTruck(const nXmlStr:string):string;
var nOut: TWorkerBusinessCommand;
begin
  Result := '';
  if CallBusinessCommand(cBC_WeChat_Get_ShopPurchByTruckNo, nXmlStr, '', @nOut) then
    Result := nOut.FData;
end;

//Date: 2014-09-15
//Parm: ��������
//Desc: ����ɹ���,���زɹ������б�
function SaveOrder(const nOrderData: string): string;
var nOut: TWorkerBusinessCommand;
begin
  if CallBusinessPurchaseOrder(cBC_SaveOrder, nOrderData, '', @nOut) then
       Result := nOut.FData
  else Result := '';
end;

//Date: 2014-09-17
//Parm: ��������;�ſ�
//Desc: ��nBill.nCard
function SaveOrderCard(const nOrder, nCard: string): Boolean;
var nOut: TWorkerBusinessCommand;
begin
  Result := CallBusinessPurchaseOrder(cBC_SaveOrderCard, nOrder, nCard, @nOut);
end;

//lih 2018-02-03
//������ӵ���
function SaveWebOrderMatch(const nBillID, nWebOrderID: string): Boolean;
var
  nSQL: string;
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
      WriteLog('����HM���ݿ�ʧ��(DBConn Is Null).');
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
//��ȡ����
function GetTruckNoByELabel(const nELabel:string): string;
var
  nSQL: string;
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
      WriteLog('����HM���ݿ�ʧ��(DBConn Is Null).');
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
  nSQL: string;
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
      WriteLog('����HM���ݿ�ʧ��(DBConn Is Null).');
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
        nMsg := '����%s����ɽ�����%s֮ǰ��ֹ����';
        nMsg := Format(nMsg, [nTruckno, FieldByName('l_id').AsString]);
        Exit;
      end;
    end;

    nSQL := 'select o_id from %s where O_card <>'''' and o_truck=''%s''';
    nSQL := Format(nSQL, [sTable_Order, nTruckno]);
    with gDBConnManager.WorkerQuery(nDBConn, nSQL) do
    begin
      if RecordCount>0 then
      begin
        nMsg := '����%s����ɲɹ�����%s֮ǰ��ֹ����';
        nMsg := Format(nMsg, [nTruckno, FieldByName('o_id').AsString]);
        Exit;
      end;
    end;

    Result := True;
  finally
    gDBConnManager.ReleaseConnection(nDBConn);
  end;
end;

//�ɹ��ѱ���δ����
function CheckSaveOrderOK(const nTruckno:string;var nMsg:string):Boolean;
var
  nSQL: string;
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
      WriteLog('����HM���ݿ�ʧ��(DBConn Is Null).');
      Exit;
    end;

    if not nDBConn.FConn.Connected then
      nDBConn.FConn.Connected := True;
    //conn db

    nSQL := 'select top 1 o_id '+
            'from $OO oo left join $WO wo on oo.O_ID = wo.WOM_LID ' +
            'where Isnull(O_card, '''')<>'''' and o_truck=''$OTK'' ' +
            'and wo.WOM_deleted = ''$WDD'' ' +
            'order by oo.R_ID desc';
    nSQL := MacroValue(nSQL, [MI('$OO', sTable_Order),
                              MI('$WO', sTable_WebOrderMatch),
                              MI('$OTK', nTruckno),
                              MI('$WDD', sFlag_No)]);
    with gDBConnManager.WorkerQuery(nDBConn, nSQL) do
    begin
      if RecordCount>0 then
      begin
        nMsg := '%s��δ��ɲɹ�����%s֮ǰ��ֹ����';
        nMsg := Format(nMsg, [nTruckno, FieldByName('o_id').AsString]);
        Exit;
      end;
    end;
    Result := True;
  finally
    gDBConnManager.ReleaseConnection(nDBConn);
  end;
end;

//���ſ��Ƿ�ռ��
function CheckCardOK(const nCard:string; var nMsg:string):Boolean;
var
  nSQL: string;
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
      WriteLog('����HM���ݿ�ʧ��(DBConn Is Null).');
      Exit;
    end;

    if not nDBConn.FConn.Connected then
      nDBConn.FConn.Connected := True;
    //conn db

    nSQL := 'select o_id from %s where O_card =''%s'' ';
    nSQL := Format(nSQL, [sTable_Order, nCard]);
    with gDBConnManager.WorkerQuery(nDBConn, nSQL) do
    begin
      if RecordCount>0 then
      begin
        nMsg := '�ſ�%s����ɲɹ�����%s֮ǰ��ֹʹ�ã����ڻ���';
        nMsg := Format(nMsg, [nCard, FieldByName('o_id').AsString]);
        Exit;
      end;
    end;

    Result := True;
  finally
    gDBConnManager.ReleaseConnection(nDBConn);
  end;
end;

function GetDayNumInfo(const nStockNo:string; const nProID:string;var nMsg:string):Boolean;
var
  nSql :string;
  nSumNum,nOutNum,nNum: Double;
  FStart, FEnd : TDate;
  nErrNum: Integer;
  nDBConn: PDBWorker;
begin
  Result := True;
  nDBConn := nil;

  with gParamManager.ActiveParam^ do
  try
    nDBConn := gDBConnManager.GetConnection(FDB.FID, nErrNum);
    if not Assigned(nDBConn) then
    begin
      WriteLog('����HM���ݿ�ʧ��(DBConn Is Null).');
      Exit;
    end;

    if not nDBConn.FConn.Connected then
      nDBConn.FConn.Connected := True;
    //conn db
    nSql := ' Select M_Status, M_DayNum From %s where M_ID = ''%s'' ';
    nSql := Format(nSql,[sTable_Materails,nStockNo]);
    with gDBConnManager.WorkerQuery(nDBConn, nSQL) do
    begin
      if (RecordCount < 1) or (Fields[0].AsString <> sFlag_Yes) then Exit;
      nSumNum := Fields[1].AsFloat;
    end;

    nSql := ' Select P_Status, P_Value, P_EndDate From %s where P_StockNo = ''%s'' and P_ID = ''%s'' ';
    nSql := Format(nSql,[sTable_Pro_Order, nStockNo,nProID]);
    with gDBConnManager.WorkerQuery(nDBConn, nSQL) do
    begin
      if (RecordCount > 0) and (Fields[0].AsString = sFlag_Yes) then
      begin
        if Str2DateTime(FieldByName('P_EndDate').AsString) < Now then
          nMsg := '�������ƽ���ʱ���ѹ�,�޷�����';
        nSumNum := Fields[1].AsFloat;
      end;
    end;
    //��ѯ���ն�Ӧ��Ӧ��ԭ�����ѳ�����
    FStart := Str2DateTime(Date2Str(Now) + ' 00:00:00');
    FEnd   := Str2DateTime(Date2Str(Now) + ' 00:00:00');

    nSql := ' Select sum(D_Value) From %s od, %s o Where od.D_OID=o.O_ID and od.D_OutFact is not null '+
      ' and o.O_ProID=''%s'' and o.O_StockNo =''%s'' and  (o.O_Date >=''%s'' and o.O_Date<''%s'') ';
    nSql := Format(nSql,[sTable_OrderDtl,sTable_Order,nProID,nStockNo,Date2Str(FStart),Date2Str(FEnd+1)]);
    with gDBConnManager.WorkerQuery(nDBConn, nSQL) do
    begin
      if (RecordCount < 1) then
        nOutNum := 0
      else
      begin
        nOutNum := Fields[0].AsFloat;
      end;
    end;
    //��ѯ���չ�Ӧ��ԭ���ϵ���δ������
    nSql := ' Select COUNT(*) from %s o where o.O_ProID=''%s'' and o.O_StockNo = ''%s'' ' +
      ' and (o.O_Date >=''%s'' and o.O_Date<''%s'') and  ' +
      ' not exists(Select R_ID from P_OrderDtl od where o.O_ID=od.D_OID and od.D_Status = ''O'' ) ';
    nSql := Format(nSql,[sTable_Order,nProID,nStockNo,Date2Str(FStart),Date2Str(FEnd+1)]);
    with gDBConnManager.WorkerQuery(nDBConn, nSQL) do
    begin
      if (RecordCount < 1) then
        nNum := 50
      else
      begin
        nNum := (Fields[0].AsInteger+1) * 50;
      end;
    end;
    if nNum + nOutNum > nSumNum then
      Result := False;
  finally
    gDBConnManager.ReleaseConnection(nDBConn);
  end;
end;


//lih 2018-02-03
//У�鶩����Ч��
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
      WriteLog('����HM���ݿ�ʧ��(DBConn Is Null).');
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
        //������ѯ�ɹ����뵥
        nSQL := 'select b_proid as provider_code,b_proname as provider_name,b_stockno as con_materiel_Code,b_restvalue as con_remain_quantity from %s where b_id=''%s''';
        nSQL := Format(nSQL,[sTable_OrderBase,nWebOrderItem.Ffac_order_no]);
        
        with gDBConnManager.WorkerQuery(nDBConn, nSQL) do
        begin
          if RecordCount<=0 then
          begin
            nStr := '�ɹ���ͬ��������ɹ���ͬ�ѱ�ɾ��[%s]��';
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
        nStr := '�̳ǻ�����ԭ����[%s]����';
        nStr := Format(nStr, [nWebOrderItem.FGoodsname]);
        Writelog(nStr);
        Exit;
      end;

      nwebOrderValue := StrToFloatDef(nWebOrderItem.FData,0);
      gMaxQuantity := FieldByName('con_remain_quantity').AsFloat;

      if nwebOrderValue-gMaxQuantity>0.00001 then
      begin
        nStr := '�̳ǻ�����������������������Ϊ[%f]��';
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
    WriteLog('δ��ѯ�������̳Ƕ�����ϸ��Ϣ�����鶩�����Ƿ���ȷ');
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
