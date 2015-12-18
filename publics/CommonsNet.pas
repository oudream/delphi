unit CommonsNet;

interface

uses classes , Windows, Sysutils, WinSock;

type
  TCommonNet = class(TObject)
  private
  public
    class function GetIPAddr: string;
    class function GettoLocalIp: string;
    class procedure SettoIPList(aIPList: TStringList);
  end;

implementation

class function TCommonNet.GetIPAddr: string;
var
  WSData: TWSAData;
  Buffer: array[0..63] of AnsiChar;
  HostEnt: PHostEnt;
  PPInAddr: ^PInAddr;
  IPString: string;
begin
  IPString := '''';
  try
    WSAStartUp($101, WSData);
    GetHostName(Buffer, SizeOf(Buffer));
    HostEnt := GetHostByName(Buffer);
    if Assigned(HostEnt) then
    begin
      PPInAddr := @(PInAddr(HostEnt.H_Addr_List^));
      while Assigned(PPInAddr^) do
      begin
        IPString := StrPas(INet_NToA(PPInAddr^^));
        Inc(PPInAddr);
      end;
    end;
    Result := IPString;
  finally
    try
      WSACleanUp;
    except
    end;
  end;
end;

class function TCommonNet.GettoLocalIp: string;
var
  sl: TStringList;
begin
  result := '';

  sl := TStringList.Create();
  try
    SettoIpList(sl);

    if sl.Count > 0 then
      Result := sl[0];
  finally
    sl.Free();
  end;
end;

class procedure TCommonNet.SettoIPList(aIPList: TStringList);
var
  WSAData: TWSAData;
  p: PHostEnt;
  pb: PintegerArray;
  s: string;
  i: integer;
begin
  aIPList.Clear();
  try
    WSAStartup(2, WSAData);
    setLength(s, 255);
    gethostname(PAnsiChar(s), 255);
    setlength(s, strlen(PAnsiChar(s)));
    p := gethostbyname(PAnsiChar(s));
    if p <> nil then
    begin
      for i := 0 to 10 do
      begin
        pb := PintegerArray(P^.h_addr_list);
        pb := PintegerArray(pb[i]);
        if pb <> nil then
        begin
          s := Format('%d.%d.%d.%d', [Byte(pb[0]), Byte(pb[0] shr 8), Byte(pb[0] shr 16), Byte(pb[0] shr 24)]);
          aIPList.AddObject(s, tobject(inet_addr(PAnsiChar(s))));
        end
        else
          break;
      end;
    end;
  finally
    WSACleanup;
  end;
end;

end.
