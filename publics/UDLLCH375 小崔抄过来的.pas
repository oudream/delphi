unit UDLLCH375;

interface

uses
  WinTypes;

const
  SCH375DLL_NAME = 'CH375DLL.DLL'; //动态库名称

type

  //定义CAN信息帧的数据类型。
  USB_CAN_OBJ = packed record
    canff: byte;
    canid: dword;
    Data: array[0..7] of BYTE;
  end;
  PUSB_CAN_OBJ = ^USB_CAN_OBJ;

  //CAN参数配置的数据类型
  USB_CAN_CONFIG = record
    mstx: Byte;
    mcomd: Byte;
    mbtr0: Byte; //波特率,出产默认值18H
    mbtr1: Byte; //波特率,出产默认值1CH
    macr: dword; //验收码,出产默认值00000000H
    mamr: dword; //屏蔽码,出产默认值FFFFFFFFH
  end;
  PUSB_CAN_CONFIG = ^USB_CAN_CONFIG;

  INT_PARAM = array[0..63] of byte;
  PINT_PARAM = ^INT_PARAM;
  //导入动态库函数
  TRoutineCallBack = procedure(buf: PINT_PARAM);
  TRoutineCallBackObject = procedure(buf: PINT_PARAM) of object;

//CH375OpenDevice()：打开USB设备 。
//函数原型：HANDLE WINAPI CH375OpenDevice(ULONG iIndex // 指定CH375设备序号,0对应第一个设备，以下同); // 打开CH375设备,返回句柄,出错则无效
//出错返回值为-1：可能原因：
//1：没有连接硬件。
//2：没有安装驱动程序
function CH375OpenDevice(DeviceIndex: ULong): THandle;
stdcall;
external SCH375DLL_NAME;

//CH375CloseDevice ()：关闭USB设备 。
//函数原型：VOID WINAPI CH375CloseDevice( ULONG iIndex // 指定CH375设备);
//此函数一定要被调用。建议在关闭设备并退出应用程序后再拔出USB电缆。
procedure CH375CloseDevice(DeviceIndex: ULong);
stdcall;
external SCH375DLL_NAME;

//CH375ReadData（）：读取上传数据块。
//函数原型：BOOL WINAPI CH375ReadData（ULONG iIndex, // 指定USB设备序号，下同
//PVOID oBuffer, // 指向一个足够大的缓冲区,用于保存读取的数据
//PULONG ioLength ); // 指向长度单元,输入时为准备读取的长度,返回后为实际读取的长度，最大长度为64个字节。
//返回值：操作状态，成功或失败
function CH375ReadData(DeviceIndex: ULong; PRead: PUSB_CAN_OBJ; Len: PULong):
  boolean;
stdcall;
external SCH375DLL_NAME;

//CH375WriteData（）：下传数据块
//函数原型：BOOL WINAPI CH371WriteData（ULONG iIndex,
//PVOID iBuffer, // 指向一个缓冲区,放置准备写出的数据
//PULONG ioLength ); // 指向长度单元,输入时为准备写出的长度,返回后为实际写出的长度，最大长度为64个字节。
//返回值：操作状态，成功或失败
//typedef VOID ( * mPCH375_INT_ROUTINE ) ( // 中断服务程序
//PUCHAR iBuffer ); // 指向一个缓冲区,提供当前的中断特征数据
function CH375WriteData(DeviceIndex: ULong; PWrite: PUSB_CAN_OBJ; Len: PULong):
  boolean;
stdcall;
external SCH375DLL_NAME;

//CH375SetIntRoutine（）；设定中断服务程序
//BOOL WINAPI CH375SetIntRoutine( ULONG iIndex,
//mPCH371_INT_ROUTINE iIntRoutine ); // 指定中断服务程序,为NULL则取消中断服务,否则在中断时调用该程序 4
//产品说明书
function CH375SetIntRoutine(DeviceIndex: ULong; uCallBack: TRoutineCallBack):
  boolean;
stdcall;
external SCH375DLL_NAME;

//BOOL	WINAPI	CH375SetExclusive(  // 设置独占使用当前CH375设备
//ULONG			iIndex,  // 指定CH375设备序号
//ULONG			iExclusive );  // 为0则设备可以共享使用,非0则独占使用
function CH375SetExclusive(DeviceIndex: ULong; iExclusive: Ulong): boolean;
stdcall;
external SCH375DLL_NAME;

implementation

end.

