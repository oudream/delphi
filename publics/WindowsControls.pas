unit WindowsControls;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs;

type
  TWindowsControl = class(TObject)
  private
  public
    class procedure ReStartWindows;
    class function ExitWindows(RebootParam: Longword): Boolean;
  end;

implementation

class procedure TWindowsControl.ReStartWindows;
begin
  ExitWindows(EWX_REBOOT or EWX_FORCE);
end;

class function TWindowsControl.ExitWindows(RebootParam: Longword): Boolean;
var
 TTokenHd: THandle;
 TTokenPvg: TTokenPrivileges;
 cbtpPrevious: DWORD;
 rTTokenPvg: TTokenPrivileges;
 pcbtpPreviousRequired: DWORD;
 tpResult: Boolean;
const
 SE_SHUTDOWN_NAME = 'SeShutdownPrivilege';
begin
 if Win32Platform = VER_PLATFORM_WIN32_NT then
 begin
   tpResult := OpenProcessToken(GetCurrentProcess(),
     TOKEN_ADJUST_PRIVILEGES or TOKEN_QUERY,
     TTokenHd);
   if tpResult then
   begin
     tpResult := LookupPrivilegeValue(nil,
                                      SE_SHUTDOWN_NAME,
                                      TTokenPvg.Privileges[0].Luid);
     TTokenPvg.PrivilegeCount := 1;
     TTokenPvg.Privileges[0].Attributes := SE_PRIVILEGE_ENABLED;
     cbtpPrevious := SizeOf(rTTokenPvg);
     pcbtpPreviousRequired := 0;
     if tpResult then
       Windows.AdjustTokenPrivileges(TTokenHd,
                                     False,
                                     TTokenPvg,
                                     cbtpPrevious,
                                     rTTokenPvg,
                                     pcbtpPreviousRequired);
   end;
 end;
 Result := ExitWindowsEx(RebootParam, 0);
end;

end.


