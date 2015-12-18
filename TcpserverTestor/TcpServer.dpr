program TcpServer;

uses
  Forms,
  TCPMainUnit in 'TCPMainUnit.pas' {TCPTestForm},
  Commons in '..\publics\Commons.pas',
  CommonsNet in '..\publics\CommonsNet.pas',
  NMTCPEx in '..\publics\NMTCPEx.pas';

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TTCPTestForm, TCPTestForm);
  Application.Run;
end.
