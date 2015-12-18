unit EventManager;

interface

uses Classes;

type
  TEventManager = class(TObject)
  private
  protected
    FEvents: array of TMethod;
    procedure DoDeleteIndex(aIndex: integer); virtual;
    function GetCount: Integer;
  public
    constructor Create; virtual;
    destructor Destroy; override;
    function IndexOf(aMethod : TMethod): Integer;
    function IsExist(aMethod : TMethod): Boolean;
    procedure RegisterEvent(aMethod : TMethod);
    procedure UnRegisterEvent(aMethod : TMethod);
    property Count: Integer read GetCount;
  end;

  TNotifyManager = class(TEventManager)
  public
    procedure Execute(Sender : TObject);
    procedure RegisterEvent(aNotifyEvent : TNotifyEvent); overload;
    procedure UnRegisterEvent(aNotifyEvent : TNotifyEvent); overload;
  end;

  TEventObjecManager = class(TObject)
  protected
    FEvents: array of TMethod;
    FList: TList;
    procedure DoDeleteIndex(aIndex: integer); virtual;
    function GetCount: Integer;
  public
    constructor Create; virtual;
    destructor Destroy; override;
    function IndexOf(aMethod: TMethod; pObject: TObject): Integer;
    function IsExist(aMethod: TMethod; pObject: TObject): Boolean;
    procedure RegisterEvent(aMethod: TMethod; pObject: TObject);
    procedure UnRegisterEvent(aMethod: TMethod; pObject: TObject);
    property Count: Integer read GetCount;
  end;

  TNotifyObjectManager = class(TEventObjecManager)
  public
    procedure Execute(Sender : TObject);
    procedure RegisterEvent(aNotifyEvent: TNotifyEvent; pObject: TObject); overload;
    procedure UnRegisterEvent(aNotifyEvent: TNotifyEvent; pObject: TObject);
        overload;
  end;

function SameMethod(Method1, Method2: TMethod): Boolean;

implementation

function SameMethod(Method1, Method2: TMethod): Boolean;
begin
  if (Method1.Code = Method2.Code) and (Method1.Data = Method2.Data) then
    Result := true
  else
    Result := false;
end;

constructor TEventManager.Create;
begin
  setLength(FEvents, 0);
end;

destructor TEventManager.Destroy;
begin
  setLength(FEvents, 0);
  inherited Destroy;
end;

procedure TEventManager.DoDeleteIndex(aIndex: integer);
begin

end;

function TEventManager.GetCount: Integer;
begin
  Result := High(FEvents) + 1;
end;

function TEventManager.IndexOf(aMethod : TMethod): Integer;
var
  i: Integer;
begin
  Result := -1;

  for i := 0 to Count - 1 do
  begin
    if SameMethod(FEvents[i], aMethod) then
    begin
      Result := i;
      exit;
    end;
  end;
end;

function TEventManager.IsExist(aMethod : TMethod): Boolean;
begin
  if IndexOf(aMethod) > -1 then
    Result := true
  else
    Result := false;
end;

procedure TEventManager.RegisterEvent(aMethod : TMethod);
begin
  if not IsExist(aMethod) then
  begin
    setLength(FEvents, Count + 1);
    FEvents[Count - 1] := aMethod;
  end;
end;

procedure TEventManager.UnRegisterEvent(aMethod : TMethod);
var
  i: Integer;
  j: Integer;
begin
  for i := 0 to Count - 1 do
  begin
    if SameMethod(FEvents[i], aMethod) then
    begin
      for j := i to Count - 1 - 1 do
      begin
        FEvents[j] := FEvents[j + 1];
      end;

      setLength(FEvents, Count - 1);
      DoDeleteIndex(i);
      exit;
    end;
  end;

end;

procedure TNotifyManager.Execute(Sender : TObject);
var
  i: Integer;
begin
  for i := 0 to Count - 1 do
  begin
    TNotifyEvent(FEvents[i])(Sender);
  end;
end;

procedure TNotifyManager.RegisterEvent(aNotifyEvent : TNotifyEvent);
begin
  RegisterEvent(TMethod(aNotifyEvent));
end;

procedure TNotifyManager.UnRegisterEvent(aNotifyEvent : TNotifyEvent);
begin
  UnRegisterEvent(TMethod(aNotifyEvent));
end;

constructor TEventObjecManager.Create;
begin
  setLength(FEvents, 0);
  FList := TList.Create();
end;

destructor TEventObjecManager.Destroy;
begin
  if FList.Count > 0 then
    FList.Clear();
  setLength(FEvents, 0);

  FList.Free();
  
  inherited Destroy;
end;

procedure TEventObjecManager.DoDeleteIndex(aIndex: integer);
begin

end;

function TEventObjecManager.GetCount: Integer;
begin
  Result := High(FEvents) + 1;
end;

function TEventObjecManager.IndexOf(aMethod: TMethod; pObject: TObject): Integer;
var
  i: Integer;
begin
  Result := -1;

  for i := 0 to Count - 1 do
  begin
    if (SameMethod(FEvents[i], aMethod)) and (TObject(FList[i]) = pObject) then
    begin
      Result := i;
      exit;
    end;
  end;
end;

function TEventObjecManager.IsExist(aMethod: TMethod; pObject: TObject): Boolean;
begin
  if IndexOf(aMethod, pObject) > -1 then
    Result := true
  else
    Result := false;
end;

procedure TEventObjecManager.RegisterEvent(aMethod: TMethod; pObject: TObject);
begin
  if not IsExist(aMethod, pObject) then
  begin
    setLength(FEvents, Count + 1);
    FEvents[Count - 1] := aMethod;

    FList.Add(pObject);
  end;
end;

procedure TEventObjecManager.UnRegisterEvent(aMethod: TMethod; pObject: TObject);
var
  i: Integer;
  j: Integer;
begin
  for i := 0 to Count - 1 do
  begin
    if (SameMethod(FEvents[i], aMethod)) and (TObject(FList[i]) = pObject) then
    begin
      for j := i to Count - 1 - 1 do
      begin
        FEvents[j] := FEvents[j + 1];
      end;

      setLength(FEvents, Count - 1);
      FList.Delete(i);

      DoDeleteIndex(i);

      exit;
    end;
  end;

end;

procedure TNotifyObjectManager.Execute(Sender : TObject);
var
  i: Integer;
begin
  for i := 0 to Count - 1 do
  begin
    if (TObject(FList[i]) = Sender) then
      TNotifyEvent(FEvents[i])(Sender);
  end;
end;

procedure TNotifyObjectManager.RegisterEvent(aNotifyEvent: TNotifyEvent;
    pObject: TObject);
begin
  RegisterEvent(TMethod(aNotifyEvent), pObject);
end;

procedure TNotifyObjectManager.UnRegisterEvent(aNotifyEvent: TNotifyEvent;
    pObject: TObject);
begin
  UnRegisterEvent(TMethod(aNotifyEvent), pObject);
end;

end.


