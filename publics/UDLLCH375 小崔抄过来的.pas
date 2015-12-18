unit UDLLCH375;

interface

uses
  WinTypes;

const
  SCH375DLL_NAME = 'CH375DLL.DLL'; //��̬������

type

  //����CAN��Ϣ֡���������͡�
  USB_CAN_OBJ = packed record
    canff: byte;
    canid: dword;
    Data: array[0..7] of BYTE;
  end;
  PUSB_CAN_OBJ = ^USB_CAN_OBJ;

  //CAN�������õ���������
  USB_CAN_CONFIG = record
    mstx: Byte;
    mcomd: Byte;
    mbtr0: Byte; //������,����Ĭ��ֵ18H
    mbtr1: Byte; //������,����Ĭ��ֵ1CH
    macr: dword; //������,����Ĭ��ֵ00000000H
    mamr: dword; //������,����Ĭ��ֵFFFFFFFFH
  end;
  PUSB_CAN_CONFIG = ^USB_CAN_CONFIG;

  INT_PARAM = array[0..63] of byte;
  PINT_PARAM = ^INT_PARAM;
  //���붯̬�⺯��
  TRoutineCallBack = procedure(buf: PINT_PARAM);
  TRoutineCallBackObject = procedure(buf: PINT_PARAM) of object;

//CH375OpenDevice()����USB�豸 ��
//����ԭ�ͣ�HANDLE WINAPI CH375OpenDevice(ULONG iIndex // ָ��CH375�豸���,0��Ӧ��һ���豸������ͬ); // ��CH375�豸,���ؾ��,��������Ч
//������ֵΪ-1������ԭ��
//1��û������Ӳ����
//2��û�а�װ��������
function CH375OpenDevice(DeviceIndex: ULong): THandle;
stdcall;
external SCH375DLL_NAME;

//CH375CloseDevice ()���ر�USB�豸 ��
//����ԭ�ͣ�VOID WINAPI CH375CloseDevice( ULONG iIndex // ָ��CH375�豸);
//�˺���һ��Ҫ�����á������ڹر��豸���˳�Ӧ�ó�����ٰγ�USB���¡�
procedure CH375CloseDevice(DeviceIndex: ULong);
stdcall;
external SCH375DLL_NAME;

//CH375ReadData��������ȡ�ϴ����ݿ顣
//����ԭ�ͣ�BOOL WINAPI CH375ReadData��ULONG iIndex, // ָ��USB�豸��ţ���ͬ
//PVOID oBuffer, // ָ��һ���㹻��Ļ�����,���ڱ����ȡ������
//PULONG ioLength ); // ָ�򳤶ȵ�Ԫ,����ʱΪ׼����ȡ�ĳ���,���غ�Ϊʵ�ʶ�ȡ�ĳ��ȣ���󳤶�Ϊ64���ֽڡ�
//����ֵ������״̬���ɹ���ʧ��
function CH375ReadData(DeviceIndex: ULong; PRead: PUSB_CAN_OBJ; Len: PULong):
  boolean;
stdcall;
external SCH375DLL_NAME;

//CH375WriteData�������´����ݿ�
//����ԭ�ͣ�BOOL WINAPI CH371WriteData��ULONG iIndex,
//PVOID iBuffer, // ָ��һ��������,����׼��д��������
//PULONG ioLength ); // ָ�򳤶ȵ�Ԫ,����ʱΪ׼��д���ĳ���,���غ�Ϊʵ��д���ĳ��ȣ���󳤶�Ϊ64���ֽڡ�
//����ֵ������״̬���ɹ���ʧ��
//typedef VOID ( * mPCH375_INT_ROUTINE ) ( // �жϷ������
//PUCHAR iBuffer ); // ָ��һ��������,�ṩ��ǰ���ж���������
function CH375WriteData(DeviceIndex: ULong; PWrite: PUSB_CAN_OBJ; Len: PULong):
  boolean;
stdcall;
external SCH375DLL_NAME;

//CH375SetIntRoutine�������趨�жϷ������
//BOOL WINAPI CH375SetIntRoutine( ULONG iIndex,
//mPCH371_INT_ROUTINE iIntRoutine ); // ָ���жϷ������,ΪNULL��ȡ���жϷ���,�������ж�ʱ���øó��� 4
//��Ʒ˵����
function CH375SetIntRoutine(DeviceIndex: ULong; uCallBack: TRoutineCallBack):
  boolean;
stdcall;
external SCH375DLL_NAME;

//BOOL	WINAPI	CH375SetExclusive(  // ���ö�ռʹ�õ�ǰCH375�豸
//ULONG			iIndex,  // ָ��CH375�豸���
//ULONG			iExclusive );  // Ϊ0���豸���Թ���ʹ��,��0���ռʹ��
function CH375SetExclusive(DeviceIndex: ULong; iExclusive: Ulong): boolean;
stdcall;
external SCH375DLL_NAME;

implementation

end.

