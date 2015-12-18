program COMTest;

uses
  Forms,
  TestForm in 'TestForm.pas' {frmTest},
  OptionForm in 'OptionForm.pas' {frmOption},
  OptionUnit in 'OptionUnit.pas',
  CacForm in 'CacForm.pas' {frmCac},
  crc in 'crc.pas',
  Commons in '..\txserver\publics\Commons.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.Title := '串口通讯测试程序';
  Application.CreateForm(TfrmTest, frmTest);
  Application.Run;
end.
