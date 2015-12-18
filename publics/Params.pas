unit Params;

interface

uses classes;

type
  TParamManager = class(TObject)
  private
    FParams: TStringList;
    function GetParams(Index: Integer): string;
    function GetValues(Index: Integer): string;
  public
    constructor Create;
    destructor Destroy; override;
    function Count: Integer;
    function IsExist(xParam: string): Boolean;
    function IndexOf(xParam: string): Integer;
    class function Singleton: TParamManager;
    function ValueByName(xParam: string): string;
    property Params[Index: Integer]: string read GetParams;
    property Values[Index: Integer]: string read GetValues;
  end;

implementation

var
  FParamManager: TParamManager;

constructor TParamManager.Create;
var
  i: Integer;
  str: string;
  pam: string;
  val: string;

  procedure MyAddParam;
  begin
    if Length(pam) > 0 then
    begin
      FParams.Add(pam + '=' + val);
    end;

    pam := '';
    val := '';
  end;  

begin
  FParams := TStringList.Create();

  if ParamCount < 1 then
    exit;

  pam := '';
  val := '';
  for i := 1 to ParamCount do
  begin
    str := ParamStr(i);
    if str[1] = '-' then
    begin
      MyAddParam();
      pam := Copy(str, 2, Length(str)-1);
    end
    else
    begin
      val := str;
      MyAddParam();
    end;

    if i = ParamCount then
    begin
      MyAddParam();
    end;
  end;
end;

destructor TParamManager.Destroy;
begin
  inherited;
  FParams.Free();
end;

function TParamManager.Count: Integer;
begin
  Result := FParams.Count;
end;

function TParamManager.GetParams(Index: Integer): string;
begin
  Result := FParams.Names[Index];
end;

function TParamManager.GetValues(Index: Integer): string;
begin
  Result := FParams.ValueFromIndex[Index];
end;

function TParamManager.IsExist(xParam: string): Boolean;
begin
  Result := IndexOf(xParam) > -1;
end;

function TParamManager.IndexOf(xParam: string): Integer;
begin
  Result := FParams.IndexOfName(xParam);
end;

class function TParamManager.Singleton: TParamManager;
begin
  if FParamManager=nil then
    FParamManager := TParamManager.Create();
  Result := FParamManager;
end;

function TParamManager.ValueByName(xParam: string): string;
begin
  Result := FParams.Values[xParam];
end;

initialization

finalization
  if FParamManager<>nil then
  begin
    FParamManager.Free;
    FParamManager := nil;
  end;  
end.
