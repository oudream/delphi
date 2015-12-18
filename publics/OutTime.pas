unit OutTime;

interface

uses Classes, SysUtils, ExtCtrls, StdCtrls;

type
  TOutTime = class(TObject)
  private
    FEnabled: Boolean;
    FInterval: Cardinal;
    FOnOutTime: TNotifyEvent;
    FTimer: TTimer;
    procedure DoOutTime(Sender: TObject);
    procedure SetEnabled(const Value: Boolean);
    procedure SetInterval(Value: Cardinal);
  public
    constructor Create;
    destructor Destroy; override;
    property Enabled: Boolean read FEnabled write SetEnabled default True;
    property Interval: Cardinal read FInterval write SetInterval default 1000;
    property OnOutTime: TNotifyEvent read FOnOutTime write FOnOutTime;
  published
  end;

const
  DefaultOutTimeInterval = 5000;
  DefaultTimeInterval = 1000;

implementation

constructor TOutTime.Create;
begin
  //字段默认值设置
  FInterval := DefaultTimeInterval;

  //用到的类创建及设置
  FTimer := TTimer.Create(nil);
  FTimer.Enabled := False;
  FTimer.Interval := FInterval;
  FTimer.OnTimer := DoOutTime;

end;

destructor TOutTime.Destroy;
begin
  FTimer.Enabled := false;
  FTimer.OnTimer := nil;
  FreeAndNil(FTimer);

  inherited;
end;

procedure TOutTime.DoOutTime(Sender: TObject);
begin
  if FEnabled then
  begin
    if Assigned(FOnOutTime) then
      FOnOutTime(Sender);
  end;
end;

procedure TOutTime.SetEnabled(const Value: Boolean);
begin
  if Value <> FEnabled then
  begin
    FEnabled := Value;

    FTimer.Enabled := FEnabled;
  end;
end;

procedure TOutTime.SetInterval(Value: Cardinal);
begin
  if Value <> FInterval then
  begin
    FInterval := Value;

    FTimer.Interval := FInterval;
  end;
end;

end.
