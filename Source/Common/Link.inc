//----------------------------------- 通用 -------------------------------------
{.$DEFINE DEBUG}
//调试模式

{.$DEFINE TrialVersion}
//试用版本

{$DEFINE UseReport}
//报表支持

{.$DEFINE RandomID}
//使用随机编号

{$DEFINE cxLibrary42}
//Ver4.2编译环境

{.$DEFINE EnableBackupDB}
//备用数据库支持
{.$DEFINE EnableDoubleDB}
//双数据库支持

//---------------------------------- 中间件 ------------------------------------
{.$DEFINE ClientMon}
//进程守护客户端

{$DEFINE HardMon}
//编译硬件守护

{.$DEFINE GenRODL}
//生成RODL资源

{$DEFINE COM_MIT}
//定义系统模式

//通用中间件
{$IFDEF COM_MIT}
  {$DEFINE DBPool}
  //启用数据库支持
  {$DEFINE ChannelPool}
  //启用通道支持
  {.$DEFINE AutoChannel}
  //启用通道平衡
  {.$DEFINE SAP}
  //启用SAP支持
  {.$DEFINE ClientMon}
  //支持守护服务
{$ENDIF}

//--------------------------------- 特定系统 -----------------------------------
{.$DEFINE COMMON}
//通用版本

{$DEFINE  GZBJM}
//特定系统

//葛洲坝潜江
{$IFDEF GZBQJ}
  {$DEFINE COMMON}
  //使用常规
  {$DEFINE HYRFID201}
  //华益读头
  {$DEFINE SyncRemote}
  //远程同步
  {$DEFINE AppAtTaskBar}
  //状态栏显示
  {$DEFINE MultiReplay}
  //JSQ应答模式
  {.$DEFINE MicroMsg}
  //微信支持
  {$DEFINE CODEAREA}
  //喷码打印销售区域
  {$DEFINE ERROPENONEDOOR}
  //过磅失败倒车下磅
  {$DEFINE VoiceMValue}
  //散装语音播报毛重
  {$DEFINE AllowMultiM}
  //允许多次过重车
  {$DEFINE MultiOrderOfTruck}
  //允许车辆办理多张采购单
  {$DEFINE DaiStepWuCha}
  //包装阶梯误差
  {$DEFINE EnableWebMall}
  //使用网上商城
  {$DEFINE ASyncWriteData}
  //特定业务使用异步数据写入
  {$DEFINE ChangeYTSerialNo}
  //修改云天业务流水号规则
  {$DEFINE TruckAutoIn}
  //车辆自动进厂
  {$DEFINE XSCODE}
  //兴山喷码规则
  {$DEFINE MITTruckProber}
  //服务器操作车检
  {$DEFINE BFLED}
  //磅房小屏
  {$DEFINE XSLedShow}
  //兴山过磅完毕显示物料名称
  {$DEFINE VoiceToDoor}
  //过磅失败向门岗播报语音
  {$DEFINE SpecifyCk}
  //指定仓库
  {.$DEFINE DeleteBillOnlyLocal}
  //删除本地交货单时不再同步云天
  {$DEFINE SanLed}
  //散装网口小屏显示
  {$DEFINE SanCFNeedPound}
  //散装超发需再次过磅
{$ENDIF}

//葛洲坝老河口
{$IFDEF GZBLHK}
  {$DEFINE COMMON}
  //使用常规
  {$DEFINE HYRFID201}
  //华益读头
  {$DEFINE SyncRemote}
  //远程同步
  {$DEFINE AppAtTaskBar}
  //状态栏显示
  {$DEFINE MicroMsg}
  //微信支持
  {$DEFINE CODEAREA}
  //喷码打印销售区域
  {.$DEFINE ERROPENONEDOOR}
  //过磅失败倒车下磅
  {$DEFINE MultiOrderOfTruck}
  //允许车辆办理多张采购单
  {$DEFINE DaiStepWuCha}
  //包装阶梯误差
  {$DEFINE EnableWebMall}
  //使用网上商城
  {$DEFINE ASyncWriteData}
  //特定业务使用异步数据写入
  {$DEFINE ChangeYTSerialNo}
  //修改云天业务流水号规则
  {$DEFINE TruckParkReady}
  //验证车辆是否在停车场
  {$DEFINE PurELabelAutoCard}
  //采购电子标签自动发卡
  {$DEFINE MultiReplay}
  //JSQ应答模式
  {$DEFINE MITTruckProber}
  //服务器操作车检
  {$DEFINE SaveEmptyTruck}
  //空车出厂保存净重为0
  {$DEFINE AllowMultiM}
  //允许多次过重车
  {$DEFINE SpecifyCk}
  //指定仓库
  {$DEFINE TruckAutoIn}
  //车辆自动进厂
  {$DEFINE PurAutoOutByStokNo}
  //采购车辆根据物料号自动出厂
  {$DEFINE GlLade}
  //骨料发运
  {$DEFINE PrintHYEach}
  //随车开化验单
  {$DEFINE PrintHuaYanDan}
  //打印化验单
  {$DEFINE PrintHeGeZheng}
  //打印合格证
  {$DEFINE PurGCardOutFactWithOutPrint}
  //采购长期卡出厂不打印
  {$DEFINE CODECOMMON}
  //通用喷码
  {$DEFINE SaveCODENO}
  //保存喷码编号
  {$DEFINE SaveYTLadeID}
  //保存云天发货单号
  {$DEFINE FixLoad}
  //转子秤定制装车
  {$DEFINE DaiWCInManual}
   //超发后人工干预后才能出行
{$ENDIF}

//葛洲坝兴山
{$IFDEF GZBXS}
  {$DEFINE COMMON}
  //使用常规
  {$DEFINE HYRFID201}
  //华益读头
  {$DEFINE SyncRemote}
  //远程同步
  {$DEFINE AppAtTaskBar}
  //状态栏显示
  {$DEFINE MultiReplay}
  //JSQ应答模式
  {$DEFINE CODEAREA}
  //喷码打印销售区域
  {.$DEFINE ERROPENONEDOOR}
  //过磅失败倒车下磅
  {$DEFINE VoiceMValue}
  //散装语音播报毛重
  {$DEFINE AllowMultiM}
  //允许多次过重车
  {$DEFINE MultiOrderOfTruck}
  //允许车辆办理多张采购单
  {$DEFINE DaiStepWuCha}
  //包装阶梯误差
  {$DEFINE ASyncWriteData}
  //特定业务使用异步数据写入
  {$DEFINE ChangeYTSerialNo}
  //修改云天业务流水号规则
  {$DEFINE TruckAutoIn}
  //车辆自动进厂
  {$DEFINE XSCODE}
  //兴山喷码规则
  {$DEFINE MITTruckProber}
  //服务器操作车检
  {$DEFINE BFLED}
  //磅房小屏
  {$DEFINE XSLedShow}
  //兴山过磅完毕显示物料名称
  {$DEFINE VoiceToDoor}
  //过磅失败向门岗播报语音
  {$DEFINE SpecifyCk}
  //指定仓库
  {$DEFINE DeleteBillOnlyLocal}
  //删除本地交货单时不再同步云天
  {$DEFINE UseAllCusNameBillHK}
  //允许不同客户不同品种进行合单
 {$DEFINE UseWXServiceEx}
  //使用二期微信中间件
{$ENDIF}

//葛洲坝松滋
{$IFDEF GZBSZ}
  {$DEFINE COMMON}
  //使用常规
  {$DEFINE HYRFID201}
  //华益读头
  {$DEFINE SyncRemote}
  //远程同步
  {$DEFINE AppAtTaskBar}
  //状态栏显示
  {$DEFINE MicroMsg}
  //微信支持
  {$DEFINE CODEAREA}
  //喷码打印销售区域
 {$DEFINE CODEAREAEX}
 //喷码打印销售区域3位
  {.$DEFINE ERROPENONEDOOR}
  //过磅失败倒车下磅
  {$DEFINE MultiOrderOfTruck}
  //允许车辆办理多张采购单
  {$DEFINE DaiStepWuCha}
  //包装阶梯误差
  {$DEFINE EnableWebMall}
  //使用网上商城
  {$DEFINE ASyncWriteData}
  //特定业务使用异步数据写入
  {$DEFINE ChangeYTSerialNo}
  //修改云天业务流水号规则
  {$DEFINE TruckParkReady}
  //验证车辆是否在停车场
  {$DEFINE PurELabelAutoCard}
  //采购电子标签自动发卡
  {$DEFINE UseTTCEDispenser}
  //新版发卡驱动
  {$DEFINE PurAutoOutByStokNo}
  //采购车辆根据物料号自动出厂
  {$DEFINE MicroMsgDelaySend}
  //微信数据延迟推送(MicroMsg开关下子开关)
  {$DEFINE UseOrderDayNum}
  //原材料日进厂量限制
{$ENDIF}

//葛洲坝荆门
{$IFDEF GZBJM}
  {$DEFINE COMMON}
  //使用常规
  {$DEFINE HYRFID201}
  //华益读头
  {$DEFINE SyncRemote}
  //远程同步
  {$DEFINE AppAtTaskBar}
  //状态栏显示
  {$DEFINE MicroMsg}
  //微信支持
  {$DEFINE CODECOMMON}
  //通用喷码
  {.$DEFINE USECONTRACT}
  //采购使用合同
  {$DEFINE MITTruckProber}
  //服务器操作车检
  {$DEFINE EnableWebMall}
  //使用网上商城
  {.$DEFINE JMSecurityCode}
  //荆门专用防违流喷码
  {$DEFINE MultiOrderOfTruck}
  //允许车辆办理多张采购单
  {.$DEFINE AutoPoundInManual}
  //自动称重人工干预异常
  {$DEFINE DaiStepWuCha}
  //包装阶梯误差
  {$DEFINE TruckParkReady}
  //验证车辆是否在停车场
  {.$DEFINE PurELabelAutoCard}
  //采购电子标签自动发卡
  {$DEFINE ASyncWriteData}
  //特定业务使用异步数据写入
  {$DEFINE PlayVoiceWithOutWeight}
  //磅房袋装过磅不播报重量
  {$DEFINE PackMachine}
  //装车机
  {$DEFINE UseWLFYInfo}
  //使用物流发运接口
{$ENDIF}

//葛洲坝钟祥
{$IFDEF GZBZX}
  {$DEFINE COMMON}
  //使用常规
  {$DEFINE HYRFID201}
  //华益读头
  {$DEFINE SyncRemote}
  //远程同步
  {$DEFINE AppAtTaskBar}
  //状态栏显示
  {$DEFINE CODEBATCODE}
  //喷码打印批次号
  {$DEFINE MITTruckProber}
  //服务器操作车检
  {$DEFINE MultiReplay}
  //JSQ应答模式
  {$DEFINE BATAFTERLINE}
  //刷卡获取批次
  {$DEFINE TruckInLoop}
  //车辆循环进厂
  {$DEFINE USECONTRACT}
  //采购使用合同
  {$DEFINE EnableWebMall}
  //使用网上商城
  {.$DEFINE NoSecurityCodeQuery}
  //关闭防违流查询
  {$DEFINE DaiStepWuCha}
  //包装阶梯误差
  {$DEFINE ASyncWriteData}
  //特定业务使用异步数据写入
  {$DEFINE ChangeYTSerialNo}
  //修改云天业务流水号规则
  {$DEFINE TruckParkReady}
  //验证车辆是否在停车场
  {.$DEFINE PurELabelAutoCard}
  //采购电子标签自动发卡
  {$DEFINE GlLade}
  //骨料发运
  {$DEFINE SaveEmptyTruck}
  //空车出厂保存净重为0
  {.$DEFINE DeleteBillOnlyLocal}
  //删除本地交货单时不再同步云天
{$ENDIF}

//葛洲坝汉川
{$IFDEF GZBHC}
  {$DEFINE COMMON}
  //使用常规
  {$DEFINE HYRFID201}
  //华益读头
  {$DEFINE SyncRemote}
  //远程同步
  {$DEFINE AppAtTaskBar}
  //状态栏显示
  {$DEFINE MicroMsg}
  //微信支持
  {$DEFINE CODEHCDZ}
  //汉川定制喷码规则
  {$DEFINE SaveEmptyTruck}
  //空车出厂保存净重为0
  {$DEFINE ERROPENONEDOOR}
  //过磅失败倒车下磅
  {$DEFINE MultiOrderOfTruck}
  //允许车辆办理多张采购单
  {$DEFINE DaiStepWuCha}
  //包装阶梯误差
  {$DEFINE ASyncWriteData}
  //特定业务使用异步数据写入
  {$DEFINE ChangeYTSerialNo}
  //修改云天业务流水号规则
  {$DEFINE PurELabelAutoCard}
  //采购电子标签自动发卡
  {$DEFINE UseTTCEDispenser}
  //新版发卡驱动
  {$DEFINE PurAutoOutByStokNo}
  //采购车辆根据物料号自动出厂
  {$DEFINE TruckAutoIn}
  //车辆自动进厂
  {$DEFINE MultiReplay}
  //JSQ应答模式
  {.$DEFINE PoundTruckQueue}
  //过磅车辆排队
  {$DEFINE OnlyDaiZWuPlayVoice}
  //只有袋装正误差播放语音
  {$DEFINE EnableELabel}
  //办理电子标签默认启用
  {$DEFINE PlayVoiceWithOutWeight}
  //磅房袋装过磅不播报重量
  {$DEFINE AllUseDate}
  //一直使用日期查询条件
  {$DEFINE SaveCODENO}
  //保存喷码到数据库
 {$DEFINE UseWXServiceEx}
  //使用二期微信中间件
 {$DEFINE UseDaiJYStockNo}
  //袋装刷卡判断品种是否一致
{$ENDIF}
//葛洲坝嘉鱼
{$IFDEF GZBJY}
  {$DEFINE COMMON}
  //使用常规
  {$DEFINE HYRFID201}
  //华益读头
  {$DEFINE AppAtTaskBar}
  //状态栏显示
  {$DEFINE CODEAREA}
  //喷码打印销售区域
 {$DEFINE CODEAREAEX}
 //喷码打印销售区域3位
  {$DEFINE ERROPENONEDOOR}
  //过磅失败倒车下磅
  {$DEFINE DaiStepWuCha}
  //包装阶梯误差
  {$DEFINE ASyncWriteData}
  //特定业务使用异步数据写入
  {.$DEFINE PurELabelAutoCard}
  //采购电子标签自动发卡
  {$DEFINE UseTTCEDispenser}
  //新版发卡驱动
  {$DEFINE PurAutoOutByStokNo}
  //采购车辆根据物料号自动出厂
  {$DEFINE MicroMsgDelaySend}
  //微信数据延迟推送(MicroMsg开关下子开关)
  {$DEFINE TruckAutoIn}
  //车辆自动进厂
  {$DEFINE MultiReplay}
  //JSQ应答模式
  {$DEFINE SaveEmptyTruck}
  //空车出厂保存净重为0
  {$DEFINE GlLade}
  //骨料发运
  {$DEFINE PurchaseOrderSingle}
  //使用单厂采购业务
  {$DEFINE UseELableAsCard}
  //使用电子标签作为卡号
{$ENDIF}

