unit BaseProxy;

interface

uses AdPort;

type
  TDealDataEvent = procedure(aBuf: array of byte; aLen: word) of object;

  TBaseProxy = class
  private
    FApdComPort: TApdComPort;
    FOnDealData: TDealDataEvent;
    procedure ApdComPortTriggerAvail(aCP: TObject; aCount: Word);
  protected
    procedure ReceiveData(aBuf: array of byte; aLen: word); virtual;
  public
    constructor Create(aApdComPort: TApdComPort); virtual;
    destructor Destroy(); override;
    Procedure SendBuffer(buf: array of byte);  //·¢ËÍ±¨ÎÄ
    property OnDealData: TDealDataEvent read FOnDealData write FOnDealData;
  end;
  TClassBaseProxy = class of TBaseProxy;

  TNoneBaseProxy = class(TBaseProxy)
  end;

var
  ClassBaseProxy : TClassBaseProxy;

implementation

constructor TBaseProxy.Create(aApdComPort: TApdComPort);
begin
  FApdComPort := aApdComPort ;
  FApdComPort.OnTriggerAvail :=ApdComPortTriggerAvail;
end;

destructor TBaseProxy.Destroy;
begin
  inherited;

end;

procedure TBaseProxy.ApdComPortTriggerAvail(aCP: TObject; aCount: Word);
var
  aBuf: array of byte;
begin
  if aCount<=0 then exit;
  SetLength(aBuf,aCount);
  fillchar(aBuf[0],Length(aBuf),0);
  TApdComPort(aCP).GetBlock(aBuf[0],aCount);
  ReceiveData(aBuf,aCount);
end;

procedure TBaseProxy.ReceiveData(aBuf: array of byte; aLen: word);
begin
  if Assigned(FOnDealData) then
    FOnDealData(aBuf, aLen);
end;

procedure TBaseProxy.SendBuffer(buf: array of byte);
begin
  FApdComPort.PutBlock(buf[0],Length(buf));
end;

end.
