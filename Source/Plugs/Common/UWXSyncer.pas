{*******************************************************************************
  ����: dmzn@163.com 2018-04-13
  ����: ΢�������Զ�˫��ͬ��
*******************************************************************************}
unit UWXSyncer;

interface

uses
  Windows, Classes, SysUtils, UBusinessWorker, UBusinessPacker, UBusinessConst,
  UWorkerBusinessCommand, UMgrDBConn, UWaitItem, ULibFun, USysDB, UMITConst,
  USysLoger;

type
  TWXSyncer = class;
  TWXSyncThread = class(TThread)
  private
    FOwner: TWXSyncer;
    //ӵ����
    FDB: string;
    FDBConn: PDBWorker;
    //���ݶ���
    FWorker: TBusinessWorkerBase;
    FPacker: TBusinessPackerBase;
    //ҵ�����
    FListA,FListB: TStrings;
    //�б����
    FNumUploadSync: Integer;
    //��ʱ����
    FWaiter: TWaitObject;
    //�ȴ�����
    FSyncLock: TCrossProcWaitObject;
    //ͬ������
  protected
    procedure DoUploadSync;
    procedure Execute; override;
    //ִ���߳�
  public
    constructor Create(AOwner: TWXSyncer);
    destructor Destroy; override;
    //�����ͷ�
    procedure Wakeup;
    procedure StopMe;
    //��ֹ�߳�
  end;

  TWXSyncer = class(TObject)
  private
    FDB: string;
    //���ݱ�ʶ
    FThread: TWXSyncThread;
    //ɨ���߳�
  public
    constructor Create;
    destructor Destroy; override;
    //�����ͷ�
    procedure Start(const nDB: string = '');
    procedure Stop;
    //��ͣ�ϴ�
  end;

var
  gWXSyncer: TWXSyncer = nil;
  //ȫ��ʹ��

implementation

procedure WriteLog(const nMsg: string);
begin
  gSysLoger.AddLog(TWXSyncer, '΢��˫��ͬ��', nMsg);
end;

constructor TWXSyncThread.Create(AOwner: TWXSyncer);
begin
  inherited Create(False);
  FreeOnTerminate := False;

  FOwner := AOwner;
  FDB := FOwner.FDB;
  
  FListA := TStringList.Create;
  FListB := TStringList.Create;

  FWaiter := TWaitObject.Create;
  FWaiter.Interval := 60 * 1000;
  //1 minute

  FSyncLock := TCrossProcWaitObject.Create('BusMIT_WeChat_Sync');
  //process sync
end;

destructor TWXSyncThread.Destroy;
begin
  FWaiter.Free;
  FListA.Free;
  FListB.Free;

  FSyncLock.Free;
  inherited;
end;

procedure TWXSyncThread.Wakeup;
begin
  FWaiter.Wakeup;
end;

procedure TWXSyncThread.StopMe;
begin
  Terminate;
  FWaiter.Wakeup;

  WaitFor;
  Free;
end;

procedure TWXSyncThread.Execute;
var nErr: Integer;
    nInit: Int64;
begin
  FNumUploadSync := 0;
  //init counter

  while not Terminated do
  try
    FWaiter.EnterWait;
    if Terminated then Exit;

    Inc(FNumUploadSync);
    //inc counter

    if FNumUploadSync >= 10 then
       FNumUploadSync :=0 ;
    //�ϴ���΢�ţ� 6��/Сʱ

    if (FNumUploadSync <> 0) then Continue;
    //��ҵ�����

    //--------------------------------------------------------------------------
    if not FSyncLock.SyncLockEnter() then Continue;
    //������������ִ��

    FDBConn := nil;
    try
      FDBConn := gDBConnManager.GetConnection(FDB, nErr);
      if not Assigned(FDBConn) then Continue;

      FWorker := nil;
      FPacker := nil;

      if FNumUploadSync = 0 then
      try
        FWorker := gBusinessWorkerManager.LockWorker(sBus_BusinessCommand);
        FPacker := gBusinessPackerManager.LockPacker(sBus_BusinessCommand);

        WriteLog('�Զ�ͬ�����ݵ�΢��ƽ̨...');
        nInit := GetTickCount;
        DoUploadSync;
        WriteLog('ͬ�����,��ʱ: ' + IntToStr(GetTickCount - nInit));
      finally
        gBusinessPackerManager.RelasePacker(FPacker);
        FPacker := nil;
        gBusinessWorkerManager.RelaseWorker(FWorker);
        FWorker := nil;
      end;
    finally
      FSyncLock.SyncLockLeave();
      gDBConnManager.ReleaseConnection(FDBConn);
    end;
  except
    on E:Exception do
    begin
      WriteLog(E.Message);
    end;
  end;
end;


procedure TWXSyncThread.DoUploadSync;
var nStr: string;
    nInt: Integer;
    nOut: TWorkerBusinessCommand;
begin
  nStr := 'Delete From %s Where (S_SyncFlag=''%s'') or (%s-S_Date>=2)';
  nStr := Format(nStr, [sTable_WeixinSync, sFlag_Yes, sField_SQLServer_Now]);
  gDBConnManager.WorkerExec(FDBConn, nStr); //���������

  nStr := 'Select * From ' + sTable_WeixinSync;
  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if RecordCount < 1 then
      Exit;
    //xxxxx

    First;
    while not Eof do
    try
      nStr := FieldByName('S_Business').AsString;
      if IsNumber(nStr, False) then
           nInt := StrToInt(nStr)
      else nInt := 0;

      case nInt of
       cBC_WeChat_complete_shoporders: //ҵ�����,����״̬
        begin
          nStr := FieldByName('S_Data').AsString;
          if TWorkerBusinessCommander.CallMe(nInt, nStr, '', @nOut) then
          begin
            nStr := 'Update %s Set S_SyncFlag=''%s'' Where R_ID=%s';
            nStr := Format(nStr, [sTable_WeixinSync, sFlag_Yes,
                    FieldByName('R_ID').AsString]);
            gDBConnManager.WorkerExec(FDBConn, nStr);
          end else
          begin
            nStr := 'Update %s Set S_SyncTime=S_SyncTime+1,S_SyncMemo=''%s'' ' +
                    'Where R_ID=%s';
            nStr := Format(nStr, [sTable_WeixinSync, nOut.FData,
                    FieldByName('R_ID').AsString]);
            gDBConnManager.WorkerExec(FDBConn, nStr);
          end;
        end;
      end;

      Next;
    except
      on nErr: Exception do
      begin
        Next; //ignor any error
        WriteLog(nErr.Message);
      end;
    end;
  end;
end;

//------------------------------------------------------------------------------
constructor TWXSyncer.Create;
begin
  FThread := nil;
end;

destructor TWXSyncer.Destroy;
begin
  Stop;
  inherited;
end;

procedure TWXSyncer.Start(const nDB: string);
begin
  if nDB = '' then
  begin
    if Assigned(FThread) then
      FThread.Wakeup;
    //start upload
  end else
  if not Assigned(FThread) then
  begin
    FDB := nDB;
    FThread := TWXSyncThread.Create(Self);
  end;
end;

procedure TWXSyncer.Stop;
begin
  if Assigned(FThread) then
  begin
    FThread.StopMe;
    FThread := nil;
  end;
end;

initialization
  gWXSyncer := TWXSyncer.Create;
finalization
  FreeAndNil(gWXSyncer);
end.
