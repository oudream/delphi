unit MutexUnit;

interface

uses windows, SysUtils;

function CanRun(const text: string): boolean;

implementation

//const
//  OnlyRunOne = '{4456A421-86BC-4170-AED1-46D6BB6B4779}';

var
  MutexHandle: THandle = 0;

function CanRun(const text: string): boolean;
var
  TmpHandle: THandle;
  SA: TSecurityAttributes;
  da: DWORD;
  ss: string;
begin
  ss := UpperCase(trim(extractfilepath(text)));
  ss := StringReplace(ss, '\', ' ', [rfReplaceAll]);
  da := MUTEX_ALL_ACCESS;
  TmpHandle := OpenMutex(da, false, PChar(ss));
  if TmpHandle = 0 then
  begin
    SA.nLength := sizeof(TSecurityAttributes);
    sa.lpSecurityDescriptor := nil;
    sa.bInheritHandle := false;
    MutexHandle := CreateMutex(@sa, false, PChar(ss));
    result := True;
  end
  else
  begin
    CloseHandle(TmpHandle);
    result := false;
  end;
end;

initialization

finalization

  if MutexHandle <> 0 then
    CloseHandle(MutexHandle);

end.
