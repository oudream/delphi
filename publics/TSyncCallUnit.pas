unit TSyncCallUnit;
(*
TSyncCall 实现异步调用制定函数
*)
interface

uses
  Classes, syncobjs, windows, Contnrs;

type
  TSyncCall = class;
  TThreadCallBackEnd = procedure(Sender: TSyncCall; SyncCData: TObject; EndFlug: boolean) of object;
  TThreadCallBack = procedure(Sender: TSyncCall; SyncCData: TObject) of object;
  TSyncCall = class(TThread)
  private
    FDestroying: boolean;
    FExecuteEnd: boolean;
    FOnACallEnd: TThreadCallBackEnd;
    FQueue: TQueue;
    fev: TCriticalSection;
    FAutoFreeDataObject: boolean;
    procedure ClearAllData;
    function GetDataCount: integer;
    { Private declarations }
  protected
    procedure DoCallBack; virtual;
    procedure Execute; override;

  public
    constructor Create();
    destructor Destroy; override;
    procedure AddCallBack(cb: TThreadCallBack; SyncCData: TObject);
    //每一个调用完成后触发该函数
    property OnACallEnd: TThreadCallBackEnd read FOnACallEnd write FOnACallEnd;
    //自动是否数据类的标志
    property AutoFreeDataObject: boolean read FAutoFreeDataObject write
      FAutoFreeDataObject;
    property DataCount: integer read GetDataCount;
  end;

  TThreadPool = class
  private
    FDestroying: boolean;
    FMaxThNumb: byte;
    FThList: TList;
    fev: TCriticalSection;
    FAutoFreeDataObject: boolean;
    FOnACallEnd: TThreadCallBackEnd;
    procedure SetAutoFreeDataObject(const Value: boolean);
  protected
    procedure DoCallEnd(Sender: TSyncCall; SyncCData: TObject; EndFlug: boolean);
  public
    constructor Create();
    destructor Destroy; override;
    procedure AddCallBack(cb: TThreadCallBack; SyncCData: TObject);
    //每一个调用完成后触发该函数
    property OnACallEnd: TThreadCallBackEnd read FOnACallEnd write FOnACallEnd;
    //自动是否数据类的标志
    property AutoFreeDataObject: boolean read FAutoFreeDataObject write
      SetAutoFreeDataObject;
    property MaxThreadNumb: byte read FMaxThNumb write FMaxThNumb default 10;
  end;

implementation
uses
  SysUtils, forms;
type
  TSyncCallObject = class
  public
    Cb: TThreadCallBack;
    SyncCData: TObject;
  end;

  { TSyncCall }

procedure TSyncCall.AddCallBack(cb: TThreadCallBack; SyncCData: TObject);
var
  sco: TSyncCallObject;
begin
  if FDestroying then
    exit;
  sco := TSyncCallObject.Create;
  sco.Cb := cb;
  sco.SyncCData := SyncCData;
  fev.Enter;
  try
    FQueue.Push(sco);
  finally
    fev.Leave;
  end;
end;

procedure TSyncCall.ClearAllData;
var
  sco: TSyncCallObject;
  i: integer;
begin
  fev.Enter;
  for i := 0 to FQueue.Count - 1 do
    begin
      sco := TSyncCallObject(FQueue.Pop);
      if Assigned(sco) then
        begin
          if Assigned(FOnACallEnd) then
            begin
              try
                FOnACallEnd(self, sco.SyncCData, false);
              except
              end;
              if FAutoFreeDataObject then
                begin
                  try
                    sco.SyncCData.free;
                  except
                  end;
                end;
              try
                sco.Free;
              except
              end;
            end;
        end;
    end;
  fev.Leave;
end;

constructor TSyncCall.Create;
begin
  FQueue := TQueue.Create;
  fev := TCriticalSection.Create;
  inherited Create(false);
end;

destructor TSyncCall.Destroy;
begin
  FDestroying := true;
  fev.Enter;
  fev.Leave;
  while (not FExecuteEnd) do
    sleep(50);
  fev.Free;
  FQueue.Free;
  inherited;
end;

procedure TSyncCall.DoCallBack;
var
  sco: TSyncCallObject;
  fcallok: boolean;
begin
  if FDestroying then
    exit;
  sco := nil;
  fev.Enter;
  try
    if FQueue.Count > 0 then
      begin
        sco := TSyncCallObject(FQueue.Pop);
      end;
  except
  end;
  fev.Leave;
  fcallok := false;
  if Assigned(sco) then
    begin
      if Assigned(sco.cb) then
        begin
          try
            sco.Cb(self, sco.SyncCData);
            fcallok := true;
          except
          end;
        end;
      if Assigned(FOnACallEnd) then
        begin
          try
            FOnACallEnd(self, sco.SyncCData, fcallok);
          except
          end;
        end;
      if FAutoFreeDataObject then
        begin
          try
            sco.SyncCData.Free;
          except
          end;
        end;
      try
        sco.Free;
      except
      end;
      sleep(0);
    end
  else
    sleep(100);
end;

{$OPTIMIZATION OFF}
procedure TSyncCall.Execute;
begin
  FDestroying := false;
  FExecuteEnd := false;
  while not Terminated do
    begin
      if FDestroying then
        break;
      try
        DoCallBack;
      except
      end;
    end;
  ClearAllData;
  FExecuteEnd := true;
end;
{$OPTIMIZATION ON}

function TSyncCall.GetDataCount: integer;
begin
  fev.Enter;
  try
    result := FQueue.Count;
  finally
    fev.Leave;
  end;
end;

{ TThreadPool }

{$OPTIMIZATION OFF}
procedure TThreadPool.AddCallBack(cb: TThreadCallBack; SyncCData: TObject);
var
  i: integer;
  mindata, thindex, tt: integer;
  th: TSyncCall;
begin
  if FDestroying then
      exit;
  fev.Enter;
  try
    mindata := MaxInt;
    thindex := -1;
    if FDestroying then
      exit;
    tt := FThList.Count;
    if tt > FMaxThNumb then
      tt := FMaxThNumb;
    for i := 0 to tt - 1 do
      begin
        if TSyncCall(FThList[i]).DataCount < mindata then
          begin
            mindata := TSyncCall(FThList[i]).DataCount;
            thindex := i;
          end;
      end;
    if thindex < 0 then
      begin
        if FDestroying then
          exit;
        th := TSyncCall.Create;
        th.OnACallEnd := DoCallEnd;
        th.AutoFreeDataObject := FAutoFreeDataObject;
        FThList.Add(th);
      end
    else
      begin
        if mindata = 0 then
          th := TSyncCall(FThList[thindex])
        else
          begin
            if thindex + 1 < FMaxThNumb then
              begin
                th := TSyncCall.Create;
                th.OnACallEnd := DoCallEnd;
                th.AutoFreeDataObject := FAutoFreeDataObject;
                FThList.Add(th);
              end
            else
              begin
                th := TSyncCall(FThList[thindex]);
              end;
          end;
      end;
    th.AddCallBack(cb, SyncCData);
  finally
    fev.Leave;
  end;
end;
{$OPTIMIZATION ON}

constructor TThreadPool.Create;
begin
  fev := TCriticalSection.Create;
  FThList := TList.Create;
  FMaxThNumb := 10;
  FAutoFreeDataObject := true;
end;

destructor TThreadPool.Destroy;
var
  i: integer;
begin
  FDestroying := true;
  fev.Enter;
  try
  for i := FThList.Count - 1 downto 0 do
    begin
      TSyncCall(FThList[i]).Free;
    end;
  except
  end;
  fev.Leave;
  freeandnil(FThList);
  Freeandnil(fev);
  inherited;
end;

{$OPTIMIZATION OFF}
procedure TThreadPool.DoCallEnd(Sender: TSyncCall; SyncCData: TObject; EndFlug: boolean);
begin
  if FDestroying then
    exit;
  if Assigned(FOnACallEnd) then
    begin
      try
        FOnACallEnd(Sender, SyncCData, EndFlug);
      except
      end;
      fev.Enter;
      try
        if FDestroying then
          exit;
        if FThList.Count > FMaxThNumb then
          begin
            if Sender <> nil then
              begin
                if Sender.DataCount <= 0 then
                  begin
                    FThList.Remove(Sender);
                    Sender.Free;
                  end;
              end;
          end;
      finally
        fev.Leave;
      end;
    end;
end;
{$OPTIMIZATION ON}

procedure TThreadPool.SetAutoFreeDataObject(const Value: boolean);
var
  i: integer;
begin
  if FAutoFreeDataObject <> Value then
    begin
      fev.Enter;
      try
        for i := 0 to FThList.Count - 1 do
          begin
            TSyncCall(FThList[i]).AutoFreeDataObject := Value;
          end;
      finally
        fev.Enter;
      end;
    end;
end;

end.

