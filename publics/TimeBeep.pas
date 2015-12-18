unit TimeBeep;

interface

uses SysUtils, OutTime, MDBase;

type
  TTimeBeep = class(TObject)
  private
    FModuleTypes: TModuleTypes;
    FTimeBeep: TOutTime;
    procedure DoTimeDeep(Sender: TObject);
    function GetEnabled: boolean;
    procedure SetEnabled(const Value: boolean);
    procedure SetModuleTypes(const Value: TModuleTypes);
  public
    constructor Create;
    destructor Destroy; override;
    procedure AddModuleType(aModuleType: TModuleType);
    procedure DelModuleType(aModuleType: TModuleType);
    class function Singleton: TTimeBeep;
    property Enabled: boolean read GetEnabled write SetEnabled;
    property ModuleTypes: TModuleTypes read FModuleTypes write SetModuleTypes;
  end;

implementation

var
  FgTimeBeep: TTimeBeep;

constructor TTimeBeep.Create;
begin
  FTimeBeep := TOutTime.Create;
  FTimeBeep.Enabled := false;
  FTimeBeep.OnOutTime := DoTimeDeep;

  ModuleTypes := [];
end;

destructor TTimeBeep.Destroy;
begin
  FTimeBeep.Enabled := false;
  FTimeBeep.Free;

  inherited;
end;

procedure TTimeBeep.AddModuleType(aModuleType: TModuleType);
begin
  ModuleTypes := ModuleTypes + [aModuleType];
end;

procedure TTimeBeep.DelModuleType(aModuleType: TModuleType);
begin
  ModuleTypes := ModuleTypes - [aModuleType];
end;

procedure TTimeBeep.DoTimeDeep(Sender: TObject);
begin
  Beep();

end;

function TTimeBeep.GetEnabled: boolean;
begin
  Result := FTimeBeep.Enabled;
end;

procedure TTimeBeep.SetEnabled(const Value: boolean);
begin
  FTimeBeep.Enabled := Value;

  if Value then
    SetModuleTypes(FModuleTypes);
end;

procedure TTimeBeep.SetModuleTypes(const Value: TModuleTypes);
var
  aModuleTypes: TModuleTypes;
  aModuleTypeNum: Integer;
  i: Integer;
begin
  FModuleTypes := Value;
  aModuleTypes := Value;

  aModuleTypeNum := 0;
  for i := 0 to 255 do
  begin
    if TModuleType(i) in aModuleTypes then
    begin
      aModuleTypes := aModuleTypes - [TModuleType(i)];
      inc(aModuleTypeNum);
    end;
  end;

  if aModuleTypeNum=0 then
  begin
    FTimeBeep.Enabled := false;
  end
  else
  begin
    FTimeBeep.Interval := 2500 div aModuleTypeNum;
    FTimeBeep.Enabled := true;
  end;
end;

class function TTimeBeep.Singleton: TTimeBeep;
begin
  if FgTimeBeep = nil then
    FgTimeBeep := TTimeBeep.Create;
  Result := FgTimeBeep;
end;

initialization

finalization
  if FgTimeBeep <> nil then
  begin
    FgTimeBeep.Free;
    FgTimeBeep := nil;
  end;

end.
