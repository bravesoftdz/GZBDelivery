unit UExcel2003UINT;

interface
uses
  SysUtils, Classes, DB, ADODB, ActiveX, ULibFun;

type
  TExcel2003Manager = class
    FADOConn: TADOConnection;
    FADOQuery: TADOQuery;
  private
    { Private declarations }
    FTables: TStrings;
  public
    { Public declarations }
    constructor Create;
    destructor Destroy; override;
    
    function Excel2DataSet(const nFile: string; const nTable: string='';
      const nFields: string=''): TDataSet;
    //ExcelתDataSet  

    function QuerySQL(const nSQL: string; nQuery:TADOQuery=nil): TDataSet;
    //���ݿ��ѯ

    procedure CloseFile;
  end;

var
  gExcel2003: TExcel2003Manager;

implementation

resourcestring
  sConnStr = 'Provider=Microsoft.Jet.OLEDB.4.0;' +
             'Persist Security Info=False;User ID=Admin;' +
             'Extended Properties=''Excel 8.0;IMEX=1;HDR=Yes'';'+
             'Data Source=$FILE';
  //IMEX=1,���е�Ԫ���ı���ȡ,��������ʽ;
  //HDR=Yes,��һ����Ϊ������ȡ,NO��ʾȫ����ȡ;           
  sQuerySQL= 'Select $Fields From $Table';

constructor TExcel2003Manager.Create;
begin
  FADOConn := TADOConnection.Create(nil);
  FADOQuery:= TADOQuery.Create(nil);
  FTables  := TStringList.Create;

  FADOConn.LoginPrompt := False;
  //��ֹ����
  FADOQuery.Connection := FADOConn;
  //ָ������
end;

destructor TExcel2003Manager.Destroy;
begin
  FreeAndNil(FADOQuery);
  FreeAndNil(FADOConn);
  FreeAndNil(FTables);
end;

function TExcel2003Manager.Excel2DataSet(const nFile: string;
  const nTable: string=''; const nFields: string=''): TDataSet;
var nTmp, nSQL: string;
begin
  Result := nil;
  if not FileExists(nFile) then Exit;

  FADOConn.Close;
  FADOConn.ConnectionString :=  MacroValue(sConnStr, [MI('$FILE', nFile)]);
  FADOConn.Connected := True;
  FADOConn.GetTableNames(FTables, False);

  if FTables.IndexOf(nTable) < 0 then
       nTmp := '[' + FTables[0] + ']'
  else nTmp := nTable;

  if Length(nFields) < 1 then
       nSQL := MacroValue(sQuerySQL, [MI('$Fields', '*'), MI('$Table', nTmp)])
  else nSQL := MacroValue(sQuerySQL, [MI('$Fields', nFields), MI('$Table', nTmp)]);

  Result := QuerySQL(nSQL, FADOQuery);
end;

function TExcel2003Manager.QuerySQL(const nSQL: string; nQuery:TADOQuery=nil): TDataSet;
var nInt: Integer;
begin
  Result := nil;
  if not Assigned(nQuery) then Exit;

  nInt := 0;

  while nInt < 2 do
  try
    if not FADOConn.Connected then
      FADOConn.Connected := True;
    //xxxxx

    with nQuery do
    begin
      Close;
      SQL.Text := nSQL;
      Open;
    end;

    Result := nQuery;
    Exit;
  except
    on E:Exception do
    begin
      FADOConn.Connected := False;
      Inc(nInt);
    end;
  end;
end;

procedure TExcel2003Manager.CloseFile;
begin
  FADOConn.Connected := False;
end;

initialization
  CoInitialize(nil);
  //�����ʼ��

  gExcel2003 := TExcel2003Manager.Create;
finalization
  FreeAndNil(gExcel2003);
  CoUninitialize;
  //�ͷż���
end.
