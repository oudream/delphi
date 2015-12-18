unit InstanceLists;

interface

uses classes;

type
  //列表基类
  TInstanceList = class(TObject)
  private
    function GetCount: Integer;
    function GetItems(Index: Integer): TObject;
    procedure SetItems(Index: Integer; const Value: TObject);
  protected
    FList: TList;
    class function FreeObjectClear: Boolean; virtual;
  public
    constructor Create; virtual;
    destructor Destroy; override;
    function Add(pObject: TObject): Boolean; virtual;
    procedure Clear; virtual;
    function IndexOf(pObject: TObject): Integer;
    function IsExist(pObject: TObject): Boolean;
    function Remove(pObject: TObject): Boolean; virtual;
    property Count: Integer read GetCount;
    property Items[Index: Integer]: TObject read GetItems write SetItems; default;
  end;

implementation

constructor TInstanceList.Create;
begin
  FList := TList.Create;
end;

destructor TInstanceList.Destroy;
begin
  if Count > 0 then
    Clear;

  FList.Free;

  inherited;
end;

function TInstanceList.Add(pObject: TObject): Boolean;
begin
  Result := false;

  if IsExist(pObject) then
    exit;

  FList.Add(pObject);

  Result := true;
end;

procedure TInstanceList.Clear;
var
  F: TObject;
begin
  while FList.Count > 0 do
  begin
    F := FList.Last;
    FList.Delete(FList.Count - 1);
    if FreeObjectClear then
      F.Free;
  end;
end;

class function TInstanceList.FreeObjectClear: Boolean;
begin
  Result := true;
end;

function TInstanceList.GetCount: Integer;
begin
  Result := FList.Count;
end;

function TInstanceList.GetItems(Index: Integer): TObject;
begin
  Result := FList[Index];
end;

function TInstanceList.IndexOf(pObject: TObject): Integer;
begin
  Result := FList.IndexOf(pObject);
end;

function TInstanceList.IsExist(pObject: TObject): Boolean;
begin
  Result := FList.IndexOf(pObject) > -1;
end;

function TInstanceList.Remove(pObject: TObject): Boolean;
begin
  Result := false;

  if IsExist(pObject) then
  begin
    FList.Remove(pObject);

    Result := true;
  end;
end;

procedure TInstanceList.SetItems(Index: Integer; const Value: TObject);
begin
  FList[Index] := Value;
end;

end.


