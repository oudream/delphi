unit SysInfos;

interface

uses Windows, Messages;

type
{
״̬��ֵ�޸ģ��ڹ�Լ
�����ǣ�
    0 DX_EMPTY,               //�޵��ߣ��ѽ���
    2 DX_WAIT,               //���ߵȴ�ȡ�ã��ѽ���
�����ǣ�
  TDXState = (
    DX_WAIT    =  0 ,         //���ߵȴ�ȡ�ã��ѽ���
    DX_OK      =  1 ,         //�����ڿ⣬�ѱ���
    DX_EMPTY    =  2 ,         //�޵��ߣ��ѽ���
    DX_BACK    =  3 ,         //������ȷ�ĵ��ߣ�δ����
    DX_WRONG   =  4 ,         //���ش���ĵ��ߣ�δ����
    DX_ALARM   =  5 ,         //����׮�澯��ά��״̬
    DX_OFFLINE =  6 ,         //����׮���ߣ�Ӳ������
    DX_NOUSE   =  7           //��Ų����ã�Ӳ���Ѽ�¼��δ����
  )

  TIDXState
    0 IDX_Open_DX_EMPTY��	  //��ʾ����״̬���޵��߲�ͷ����
    1 IDX_Close_DX_Right��  //��ʾ����״̬������ȷ���߲�ͷ���ڣ�
    2 IDX_Open_DX_WaitUse�� //��ʾ�ѿ���״̬���е��߲�ͷ���ڵȴ�ȡ��
    3 IDX_Open_DX_Return��  //��ʾ����״̬����ȷ�ĵ��߲�ͷ�ջ���
    4 IDX_Open_DX_Error��	  //��ʾ����״̬���д���ĵ��߲�ͷ����
    5 IDX_Alarm��	          //�澯(�豸�쳣,�����޷������)
    6 IDX_Failure��	        //û������(�豸����)
    7 IDX_NoInstall)	      //δ��װ
    8 IDX_Close_DX_Exception    //����׮�������߲�ͷʱ�����쳣
}
  TDXState = (
    DX_WAIT    =  0 ,         //���ߵȴ�ȡ�ã��ѽ���
    DX_OK      =  1 ,         //�����ڿ⣬�ѱ���
    DX_EMPTY   =  2 ,         //�޵��ߣ��ѽ���
    DX_BACK    =  3 ,         //������ȷ�ĵ��ߣ�δ����
    DX_WRONG   =  4 ,         //���ش���ĵ��ߣ�δ����
    DX_ALARM   =  5 ,         //����׮�澯��ά��״̬
    DX_OFFLINE =  6 ,         //����׮���ߣ�Ӳ������
    DX_NOUSE   =  7 ,         //��Ų����ã�Ӳ���Ѽ�¼��δ����
    DX_NONE    =  255         //��״̬
  );

  TIOBufferEventA = function(const aBuf: array of byte; aLen: Longint; iTag: Integer): Longint
    of object;

  TIOBufferEventB = procedure(var aBuf: array of byte; aLen: Longint) of
    object;

  TIOBufferEventC = function(var aBuf: array of byte; aLen: Longint): Longint
    of object;

// ��Ϣ message define
const
  //SPCOMM ��
//PWM_GOTCOMMDATA = WM_USER + 1;
//PWM_RECEIVEERROR = WM_USER + 2;
//PWM_REQUESTHANGUP = WM_USER + 3;
//PWM_MODEMSTATECHANGE = WM_USER + 4;
//PWM_SENDDATAEMPTY = WM_USER + 5;

  //WM_USER = $0400;
  //DC�����õ���
  WM_TX_CH375                    = WM_USER + $0340 + $0001;

  //UDP�����õ�
  WM_TX_ASYNCHRONOUSPROCESS      = WM_USER + $0340 + $0002; {Message number for asynchronous socket messages}

  WM_TX_EXITAPPLICATION          = WM_USER + $0340 + $0030;
  WM_TX_HEARTJUMP                = WM_USER + $0340 + $0031;

  //DC CH375 ����
  //WM_USER + $0340 + $0030 �� WM_USER + $0340 + $0039

//Ĭ��ֵ
const
  CMaxTimeSecond = 999999999;

const
  sCaptionTXManger = 'ͨѶ�����';
  sCaptionConfigYXYC = 'ͨѶ�豸�ܱ�';
//sCaptionConfigDiXian = '���߿�';
  sCaptionDevices = 'ͨѶ�豸';
//sCaptionStart = 'Ʊ������';
//sCaptionTaskFrame = '�����б�';
//sCaptionPiaoFrame = 'Ʊ���б�';
//sCaptionSystemInfo = 'ϵͳ��Ϣ';
//sCaptionOutInfo = '��Ϣ��ʾ';

const
  S_CHANNELNAME_SERIAL       = '����ͨѶ';
  S_CHANNELNAME_TCP_CLIENT   = 'TCP Client';
  S_CHANNELNAME_TCP_SERVER   = 'TCP Server';
  S_CHANNELNAME_UDP          = 'UDPͨѶ';
  S_CHANNELNAME_UDP_VLAN     = 'UDP�鲥ͨѶ';
  S_CHANNELNAME_USB          = 'USBͨѶ';
  S_CHANNELNAME_CAN_ZLG      = 'CAN������';

const
  CDTBufTitle: array[0..5] of byte = ($EB, $90, $EB, $90, $EB, $90);

const
  S_GUIYUENAME_WFCDT  = '���CDT��Լ';
  S_GUIYUENAME_WFDISA = '���DISA��Լ';
  S_GUIYUENAME_TransPassive   = '���ݱ���ת����Լ';
  S_GUIYUENAME_TransInitiative = '��������ת����Լ';
  S_GUIYUENAME_BsxHt    = '�������̨��Լ';

implementation

end.










