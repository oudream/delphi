program UDPTest;

uses
  Forms,
  UDPMainUnit in 'UDPMainUnit.pas' {UDPTestForm},
  Commons in '..\txserver\publics\Commons.pas',
  CommonsNet in '..\txserver\publics\CommonsNet.pas',
  NMUDPEx in '..\txserver\Server\Channel\NMUDPEx.pas',
  SysInfos in '..\txserver\publics\SysInfos.pas',
  NMTCPEx in '..\txserver\Server\Channel\NMTCPEx.pas',
  OutTime in '..\txserver\publics\OutTime.pas';

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TUDPTestForm, UDPTestForm);
  Application.Run;
end.
