unit SysInfos;

interface

uses Windows, Messages;

type
{
状态数值修改：在规约
本来是：
    0 DX_EMPTY,               //无地线，已解锁
    2 DX_WAIT,               //地线等待取用，已解锁
现在是：
  TDXState = (
    DX_WAIT    =  0 ,         //地线等待取用，已解锁
    DX_OK      =  1 ,         //地线在库，已闭锁
    DX_EMPTY    =  2 ,         //无地线，已解锁
    DX_BACK    =  3 ,         //还回正确的地线，未闭锁
    DX_WRONG   =  4 ,         //还回错误的地线，未闭锁
    DX_ALARM   =  5 ,         //地线桩告警，维修状态
    DX_OFFLINE =  6 ,         //地线桩离线，硬件故障
    DX_NOUSE   =  7           //点号不可用，硬件已记录，未启用
  )

  TIDXState
    0 IDX_Open_DX_EMPTY，	  //表示开锁状态，无地线插头存在
    1 IDX_Close_DX_Right，  //表示闭锁状态，有正确地线插头存在；
    2 IDX_Open_DX_WaitUse， //表示已开锁状态，有地线插头存在等待取走
    3 IDX_Open_DX_Return，  //表示开锁状态，正确的地线插头刚还回
    4 IDX_Open_DX_Error，	  //表示开锁状态，有错误的地线插头插入
    5 IDX_Alarm，	          //告警(设备异常,地线无法解闭锁)
    6 IDX_Failure，	        //没有在线(设备故障)
    7 IDX_NoInstall)	      //未安装
    8 IDX_Close_DX_Exception    //闭锁桩闭锁地线插头时出现异常
}
  TDXState = (
    DX_WAIT    =  0 ,         //地线等待取用，已解锁
    DX_OK      =  1 ,         //地线在库，已闭锁
    DX_EMPTY   =  2 ,         //无地线，已解锁
    DX_BACK    =  3 ,         //还回正确的地线，未闭锁
    DX_WRONG   =  4 ,         //还回错误的地线，未闭锁
    DX_ALARM   =  5 ,         //地线桩告警，维修状态
    DX_OFFLINE =  6 ,         //地线桩离线，硬件故障
    DX_NOUSE   =  7 ,         //点号不可用，硬件已记录，未启用
    DX_NONE    =  255         //无状态
  );

  TIOBufferEventA = function(const aBuf: array of byte; aLen: Longint; iTag: Integer): Longint
    of object;

  TIOBufferEventB = procedure(var aBuf: array of byte; aLen: Longint) of
    object;

  TIOBufferEventC = function(var aBuf: array of byte; aLen: Longint): Longint
    of object;

// 消息 message define
const
  //SPCOMM 用
//PWM_GOTCOMMDATA = WM_USER + 1;
//PWM_RECEIVEERROR = WM_USER + 2;
//PWM_REQUESTHANGUP = WM_USER + 3;
//PWM_MODEMSTATECHANGE = WM_USER + 4;
//PWM_SENDDATAEMPTY = WM_USER + 5;

  //WM_USER = $0400;
  //DC部分用到的
  WM_TX_CH375                    = WM_USER + $0340 + $0001;

  //UDP部分用到
  WM_TX_ASYNCHRONOUSPROCESS      = WM_USER + $0340 + $0002; {Message number for asynchronous socket messages}

  WM_TX_EXITAPPLICATION          = WM_USER + $0340 + $0030;
  WM_TX_HEARTJUMP                = WM_USER + $0340 + $0031;

  //DC CH375 所用
  //WM_USER + $0340 + $0030 到 WM_USER + $0340 + $0039

//默认值
const
  CMaxTimeSecond = 999999999;

const
  sCaptionTXManger = '通讯管理机';
  sCaptionConfigYXYC = '通讯设备总表';
//sCaptionConfigDiXian = '地线库';
  sCaptionDevices = '通讯设备';
//sCaptionStart = '票与任务';
//sCaptionTaskFrame = '任务列表';
//sCaptionPiaoFrame = '票的列表';
//sCaptionSystemInfo = '系统信息';
//sCaptionOutInfo = '消息显示';

const
  S_CHANNELNAME_SERIAL       = '串口通讯';
  S_CHANNELNAME_TCP_CLIENT   = 'TCP Client';
  S_CHANNELNAME_TCP_SERVER   = 'TCP Server';
  S_CHANNELNAME_UDP          = 'UDP通讯';
  S_CHANNELNAME_UDP_VLAN     = 'UDP组播通讯';
  S_CHANNELNAME_USB          = 'USB通讯';
  S_CHANNELNAME_CAN_ZLG      = 'CAN周立功';

const
  CDTBufTitle: array[0..5] of byte = ($EB, $90, $EB, $90, $EB, $90);

const
  S_GUIYUENAME_WFCDT  = '五防CDT规约';
  S_GUIYUENAME_WFDISA = '五防DISA规约';
  S_GUIYUENAME_TransPassive   = '数据被动转发规约';
  S_GUIYUENAME_TransInitiative = '数据主动转发规约';
  S_GUIYUENAME_BsxHt    = '闭锁箱后台规约';

implementation

end.










