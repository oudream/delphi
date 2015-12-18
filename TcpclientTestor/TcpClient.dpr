program TcpClient;

uses
  Forms,
  TCPMainUnit in 'TCPMainUnit.pas' {TCPTestForm},
  Systems in '..\publics\Systems.pas',
  Commons in '..\publics\Commons.pas';

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TTCPTestForm, TCPTestForm);
  Application.Run;
end.
