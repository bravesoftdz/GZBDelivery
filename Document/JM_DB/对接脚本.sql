----------------------------------------------------------------------------------------------------------------------
--  ��ѯ����ϵͳ�����(��Ʊ)��Ϣ
----------------------------------------------------------------------------------------------------------------------
select XCB_ID,                                --�ڲ����
       XCB_CardId,                            --���ۿ�Ƭ���
       XCB_Origin,                            --��Ƭ��Դ
       XCB_BillID,                            --��Դ���ݺ�
       XCB_SetDate,                           --��������
       XCB_CardType,                          --��Ƭ����
       XCB_SourceType,                        --��Դ����
       XCB_Option,                            --���Ʒ�ʽ:0,�ص���;1,������
       XCB_Client,                            --�ͻ����
       XOB_Name as XCB_ClientName,            --�ͻ�����
       XCB_Alias,                             --�ͻ�����
       XCB_OperMan,                           --ҵ��Ա
       XCB_Area,                              --��������                     
       XCB_CementType as XCB_Cement,          --Ʒ�ֱ��
       PCM_Name as XCB_CementName,            --Ʒ������
       XCB_LadeType,                          --�����ʽ    
       XCB_Number,                            --��ʼ����
       XCB_FactNum,                           --�ѿ�����
       XCB_PreNum,                            --ԭ������
       XCB_ReturnNum,                         --�˻�����
       XCB_OutNum,                            --ת������
       XCB_RemainNum,                         --ʣ������
       XCB_ValidS,XCB_ValidE,                 --�����Ч��
       XCB_Status,                            --��Ƭ״̬:0,ͣ��;1,����;2,���;3,����
       XCB_IsImputed,                         --��Ƭ�Ƿ����
       XCB_IsOnly,                            --�Ƿ�һ��һƱ
       XCB_Del,                               --ɾ�����:0,����;1,ɾ��
       XCB_Creator,                           --������
       pub.pub_name as XCB_CreatorNM,         --��������
       XCB_CDate,                             --����ʱ��
       XCB_Firm,                              --��������
       pbf.pbf_name XCB_FirmName,             --��������
       pcb.pcb_id, pcb.pcb_name               --����Ƭ��
       
from XS_Card_Base xcb
  left join XS_Compy_Base xob on xob.XOB_ID = xcb.XCB_Client
  left join PB_Code_Material pcm on pcm.PCM_ID = xcb.XCB_CementType
  Left Join pb_code_block pcb On pcb.pcb_id=xob.xob_block
  Left Join pb_basic_firm pbf On pbf.pbf_id=xcb.xcb_firm
  Left Join PB_USER_BASE pub on pub.pub_id=xcb.xcb_creator

where rownum < 200 
  and xcb.xcb_remainnum>0
--  and PCM_Name='����' 
--  and XCB_CardID='07703'
--  and XCB_FactNum < XCB_OutNum
--  and XCB_SetDate > to_date('2015/09/01', 'yyyy-mm-dd')
Order By XCB_SetDate DESC

----------------------------------------------------------------------------------------------------------------------
--  ��ѯ����ϵͳ��Ч��Ʒ���б�
----------------------------------------------------------------------------------------------------------------------
select * from PB_Code_Material where pcm_status=1 
  and (pcm_kind in ('2001001002004000', '2001001001001000'))
--  and (pcm_name like '%32.5%' or pcm_name like '%42.5%' or pcm_name like '%52.5%' or pcm_name like '%����%')

