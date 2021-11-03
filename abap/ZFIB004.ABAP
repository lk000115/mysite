REPORT ZFIB045.
************************************************************************
*
* 程序名称: 资产批量导入
*
* 作者: 许明杰
* 开发日期: 2017-10-19
* 请求号:
* 申请者y:
* 功能/技术文档:
* 描述: 批量导入资产主数据
*
*
*
* 变更记录
*
* 修改日期  开发人员  请求号 描述
*----------------------------------------------------------------------*
*
************************************************************************
*eject
************************************************************************
* Includes
************************************************************************
*类型池
TYPE-POOLS : SLIS,ICON,TRUXS.
************************************************************************
* tables
************************************************************************
*表
TABLES: BKPF,SSCRFIELDS.
************************************************************************
* internal tables
************************************************************************
TYPES: BEGIN OF TY_INPUT,
         YFIID(30) TYPE C,            "标示号
         BUKRS     TYPE ANLA-BUKRS,   "公司代码
         ANLKL     TYPE ANLA-ANLKL,   "资产分类
         TXT50     TYPE ANLA-TXT50,   "资产描述
         TXA50     TYPE ANLA-TXA50,   "资产描述2
         ANLHTXT   TYPE ANLH-ANLHTXT, "资产主号文本
         SERNR     TYPE ANLA-SERNR,   "资产序列号
         INVNR     TYPE ANLA-INVNR,   "存货号
         MENGE     TYPE ANLA-MENGE,   "数量
         MEINS     TYPE ANLA-MEINS,   "基本计量单位
         IVDAT     TYPE ANLA-IVDAT,   "最后盘点的日期
         INKEN     TYPE ANLA-INKEN,   "是否在盘点清单中
         INVZU     TYPE ANLA-INVZU,   "盘点说明
         KOSTL     TYPE ANLZ-KOSTL,   "成本中心
         KOSTLV    TYPE ANLZ-KOSTLV,  "负责的成本中心
         WERKS     TYPE ANLZ-WERKS,   "工厂
         STORT     TYPE ANLZ-STORT,   "位置
         RAUMN     TYPE ANLZ-RAUMN,   "责任人
         KFZKZ     TYPE ANLZ-KFZKZ,   "执照牌号
         PERNR     TYPE ANLZ-PERNR,   "人员编号
         PRCTR     TYPE BSEG-PRCTR,   "利润中心
         GSBER     TYPE BSEG-GSBER,   "业务范围
         ORD41     TYPE ANLA-ORD41,   "评估组1
         ORD42     TYPE ANLA-ORD42,   "评估组2
         ORD43     TYPE ANLA-ORD43,   "评估组3
         ORD44     TYPE ANLA-ORD44,   "评估组4
         GDLGRP    TYPE ANLA-GDLGRP,  "评估组5
         LIFNR     TYPE ANLA-LIFNR,   "供应商
         TYPBZ     TYPE ANLA-TYPBZ,   "类型名
         AKTIV     TYPE ANLA-AKTIV,   "资产资本化日期
         AFABE     TYPE ANLB-AFABE,   "实际折旧范围
         AFASL     TYPE ANLB-AFASL,   "折旧码
         NDJAR     TYPE ANLB-NDJAR,   "计划年使用期
         NDPER     TYPE ANLB-NDPER,   "计划使用期间
         AFABG     TYPE ANLB-AFABG,   "折旧计算开始日期
         KANSW     TYPE ANLC-KANSW,   "累计购置价值
         KNAFA     TYPE ANLC-KNAFA,   "以前年度累计折旧
         NAFAG     TYPE ANLC-NAFAG,   "本年累计折旧
       END OF TY_INPUT.

TYPES: BEGIN OF TY_ALV.
    INCLUDE TYPE TY_INPUT.
TYPES: STATUS   TYPE C LENGTH 4. "状态
TYPES: BAPI_MSG TYPE BAPI_MSG.   "消息
TYPES: BELNR    TYPE BKPF-BELNR. "凭证编号
TYPES: ANLN1 TYPE ANLA-ANLN1. "资产编号
TYPES: END   OF TY_ALV.

DATA:GT_INPUT TYPE TABLE OF TY_INPUT,
     GS_INPUT TYPE          TY_INPUT,
     GT_ALV   TYPE TABLE OF TY_ALV,
     GS_ALV   TYPE          TY_ALV.

*BAPI 传值定义
*The parameters of BAPI
DATA: GV_TESTRUN      TYPE          BAPI1022_MISC-TESTRUN VALUE ' ',
      GS_KEY          TYPE          BAPI1022_KEY,
      GV_ASSET        TYPE          BAPI1022_1-ASSETMAINO,
      GS_GENERALDATA  TYPE          BAPI1022_FEGLG001,
      GS_GENERALDATAX TYPE          BAPI1022_FEGLG001X,
      GS_INVENTORY    TYPE          BAPI1022_FEGLG011,
      GS_INVENTORYX   TYPE          BAPI1022_FEGLG011X,
      GS_TIMEDEPDATA  TYPE          BAPI1022_FEGLG003,
      GS_TIMEDEPDATAX TYPE          BAPI1022_FEGLG003X,
      GS_ALLOCATIONS  TYPE          BAPI1022_FEGLG004,
      GS_ALLOCATIONSX TYPE          BAPI1022_FEGLG004X,
      GS_ORIGIN       TYPE          BAPI1022_FEGLG009,
      GS_ORIGINX      TYPE          BAPI1022_FEGLG009X,
      GS_POSTINFO     TYPE          BAPI1022_FEGLG002,
      GS_POSTINFOX    TYPE          BAPI1022_FEGLG002X,
      GT_DEPREAREAS   TYPE TABLE OF BAPI1022_DEP_AREAS,
      GT_DEPREAREASX  TYPE TABLE OF BAPI1022_DEP_AREASX,
      GS_DEPREAREAS   TYPE          BAPI1022_DEP_AREAS,
      GS_DEPREAREASX  TYPE          BAPI1022_DEP_AREASX,
      GT_POSTVALUES   TYPE TABLE OF BAPI1022_POSTVAL,
      GS_POSTVALUES   TYPE          BAPI1022_POSTVAL,
      GT_CUMUVALUES   TYPE TABLE OF BAPI1022_CUMVAL,
      GS_CUMUVALUES   TYPE          BAPI1022_CUMVAL,
      GT_TRANSACTIONS TYPE TABLE OF BAPI1022_TRTYPE,
      GS_TRANSACTIONS TYPE          BAPI1022_TRTYPE,
      GT_RETURN       TYPE TABLE OF BAPIRET2,
      GS_RETURN       TYPE          BAPIRET2.

*ALV 定义
DATA: GT_FIELDCAT TYPE LVC_T_FCAT,    " Fieldcat table
      GS_FIELDCAT TYPE LVC_S_FCAT,    " Fieldcat
      GS_LAYOUT   TYPE LVC_S_LAYO.    " Layout
************************************************************************
* internal data fields
************************************************************************
FIELD-SYMBOLS:<FS_ALV> TYPE TY_ALV.
FIELD-SYMBOLS:<FS_INPUT> TYPE TY_INPUT.

DATA: GS_FUNCTXT TYPE SMP_DYNTXT,
      GV_FILE    TYPE RLGRAP-FILENAME,
      GV_FLAG(1) TYPE C,
      GV_SAVE(1) TYPE C.

DATA: GV_TOTAL_LINE TYPE I,
      GV_CURRT_LINE TYPE I,
      GV_ERROR_LINE TYPE I.
************************************************************************
* Parameters and Selection Options
************************************************************************
SELECTION-SCREEN BEGIN OF BLOCK BLK WITH FRAME TITLE TEXT-001.

SELECT-OPTIONS: S_BUKRS FOR BKPF-BUKRS. "Company Code
SELECTION-SCREEN: SKIP 1.
PARAMETERS: P_FILE LIKE RLGRAP-FILENAME ."文件选择"File selection
SELECTION-SCREEN END OF BLOCK BLK.

*Activate the selection screen button
SELECTION-SCREEN: FUNCTION KEY 1.
*
************************************************************************
* Initialization
************************************************************************
INITIALIZATION.
  GS_FUNCTXT-ICON_ID   = ICON_EXPORT.
  GS_FUNCTXT-ICON_TEXT = TEXT-048.
  SSCRFIELDS-FUNCTXT_01 = GS_FUNCTXT.
************************************************************************
* at selection screen
************************************************************************
*Search help
AT SELECTION-SCREEN ON VALUE-REQUEST FOR P_FILE.
  "获取文件路径
  PERFORM FRM_GET_FILEPATH.

AT SELECTION-SCREEN.
  "屏幕事件
  CASE SSCRFIELDS-UCOMM.
    WHEN 'FC01'.
      "获取模板
      PERFORM FRM_GET_TEMPLATE.
  ENDCASE.
************************************************************************
* Event top of page
************************************************************************
TOP-OF-PAGE.

************************************************************************
* event Start of Selection
************************************************************************
START-OF-SELECTION.
  "加载数据
  PERFORM FRM_UPLOAD_DATA.
  "处理数据
  PERFORM FRM_DEAL_DATA.

************************************************************************
*EVENT End-of selection
************************************************************************
END-OF-SELECTION.
  "数据输出
  PERFORM FRM_WRITE_DATA.
************************************************************************
*EVENT  End-of page
************************************************************************
END-OF-PAGE.
************************************************************************

************************************************************************
** forms
************************************************************************
*&---------------------------------------------------------------------*
*& Form FRM_GET_FILEPATH
*&---------------------------------------------------------------------*
*& 获取文件路径
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM FRM_GET_FILEPATH .
  CALL FUNCTION 'TB_LIMIT_WS_FILENAME_GET'
    EXPORTING
      MASK             = ',EXCEL FILE,*.XLS;*.XLSX;'
      MODE             = 'O'                                         "O为打开S为保存 O to open S to preserve
      TITLE            = TEXT-047
    IMPORTING
      FILENAME         = P_FILE
    EXCEPTIONS
      SELECTION_CANCEL = 1
      SELECTION_ERROR  = 2
      OTHERS           = 3.
  IF SY-SUBRC <> 0.
    MESSAGE S011(ZFICO) DISPLAY LIKE 'E' .                                     "获取不到文件传出错误消息  Can’t get file then export an error message
    RETURN.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form FRM_GET_TEMPLATE
*&---------------------------------------------------------------------*
*& 获取模板
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM FRM_GET_TEMPLATE .
  DATA: LV_OBJDATA     LIKE WWWDATATAB,
        LV_DESTINATION LIKE RLGRAP-FILENAME,
        LV_RC          LIKE SY-SUBRC.

  "获取要保存的文件名
  PERFORM FRM_GET_SAVEPATH.
  IF GV_FILE IS INITIAL.
    RETURN.
  ENDIF.

*检索模板是否存在
  SELECT SINGLE RELID OBJID
    FROM WWWDATA
    INTO CORRESPONDING FIELDS OF LV_OBJDATA
    WHERE SRTF2 = 0
    AND RELID = 'MI'
    AND OBJID = 'ZFIB004'."ZFIB045改为ZFIB004.20180717
* 检查表wwwdata中是否存在所指定的模板文件
  IF SY-SUBRC NE 0 OR LV_OBJDATA-OBJID = ' '. "如果不存在，则给出错误提示
    MESSAGE E013(ZFICO).
  ENDIF.
*模板存放路径
  TRANSLATE GV_FILE TO UPPER CASE.
  LV_DESTINATION = GV_FILE.

* 如果存在，调用DOWNLOAD_WEB_OBJECT 函数下载模板到路径下
  CALL FUNCTION 'DOWNLOAD_WEB_OBJECT'
    EXPORTING
      KEY         = LV_OBJDATA
      DESTINATION = LV_DESTINATION
    IMPORTING
      RC          = LV_RC.
  IF LV_RC NE 0.
    MESSAGE E014(ZFICO) WITH LV_DESTINATION.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form FRM_GET_SAVEPATH
*&---------------------------------------------------------------------*
*& 获取要保存的文件名
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM FRM_GET_SAVEPATH .
  DATA: LV_FULLPATH TYPE STRING.
*获取保存路径
  CALL FUNCTION 'GUI_FILE_SAVE_DIALOG'
    EXPORTING
      WINDOW_TITLE      = TEXT-049
      DEFAULT_EXTENSION = 'XLSX'
      DEFAULT_FILE_NAME = 'ZFIB045.XLSX'
    IMPORTING
      FULLPATH          = LV_FULLPATH.

  GV_FILE = LV_FULLPATH.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form FRM_UPLOAD_DATA
*&---------------------------------------------------------------------*
*& 加载数据
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM FRM_UPLOAD_DATA .
  IF P_FILE IS INITIAL.
    MESSAGE E012(ZFICO).
  ENDIF.

  DATA:LV_FILE     TYPE RLGRAP-FILENAME,
       LT_RAW_DATA TYPE TRUXS_T_TEXT_DATA.

  TRANSLATE P_FILE TO UPPER CASE.
  LV_FILE = P_FILE.

  "加载excle数据到内表
  CALL FUNCTION 'TEXT_CONVERT_XLS_TO_SAP'
    EXPORTING
*     I_FIELD_SEPERATOR    =
      I_LINE_HEADER        = 'X' "设置导入的表格有没有表头
      I_TAB_RAW_DATA       = LT_RAW_DATA
      I_FILENAME           = LV_FILE
    TABLES
      I_TAB_CONVERTED_DATA = GT_INPUT "文件传到内表
    EXCEPTIONS
      CONVERSION_FAILED    = 1
      OTHERS               = 2.
  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
        WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

  "判断上传数据是否为空
  IF GT_INPUT IS INITIAL.
    MESSAGE E001(ZFICO).
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form FRM_DEAL_DATA
*&---------------------------------------------------------------------*
*& 处理数据
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM FRM_DEAL_DATA .
  DATA: LT_DATA LIKE TABLE OF GS_ALV.

*删除上传数据中不符合选择条件的数据
  DELETE GT_INPUT[] WHERE BUKRS NOT IN S_BUKRS.

*将处理后的excel数据传入alv表里面
  LOOP AT GT_INPUT INTO GS_INPUT.
    MOVE-CORRESPONDING GS_INPUT TO GS_ALV.
    GS_ALV-STATUS = ICON_YELLOW_LIGHT.
    APPEND GS_ALV TO GT_ALV.
    CLEAR: GS_ALV.
  ENDLOOP.
  "排序
  SORT GT_ALV BY YFIID.

  "获取总行数
  LT_DATA = GT_ALV.
  DELETE ADJACENT DUPLICATES FROM LT_DATA COMPARING YFIID.
  GV_TOTAL_LINE = LINES( LT_DATA ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form FRM_WRITE_DATA
*&---------------------------------------------------------------------*
*& 数据输出
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM FRM_WRITE_DATA .
  "设置ALV输出格式
  PERFORM FRM_SET_LAYOUT.
  "设置ALV输出字段
  PERFORM FRM_SET_FIELDCAT.
  "ALV展示
  PERFORM FRM_OUTPUT_ALV.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form FRM_SET_LAYOUT
*&---------------------------------------------------------------------*
*& 设置ALV输出格式
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM FRM_SET_LAYOUT .
  GS_LAYOUT-ZEBRA      = 'X'."斑马线
  GS_LAYOUT-CWIDTH_OPT = 'X'."自动调整ALVL列宽
ENDFORM.
*&---------------------------------------------------------------------*
*& Form FRM_SET_FIELDCAT
*&---------------------------------------------------------------------*
*& 设置ALV输出字段
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM FRM_SET_FIELDCAT .
*FIELDCAT 宏定义
  DEFINE FIELDCAT.
    CLEAR:GS_FIELDCAT.
    GS_FIELDCAT-FIELDNAME = &1.
    GS_FIELDCAT-SCRTEXT_M = &2.
    APPEND GS_FIELDCAT TO GT_FIELDCAT.
  END-OF-DEFINITION.

  FIELDCAT 'STATUS'   TEXT-006.
  FIELDCAT 'BAPI_MSG' TEXT-007.
  FIELDCAT 'BELNR'    TEXT-008.
  FIELDCAT 'ANLN1'    TEXT-009.
  FIELDCAT 'YFIID'    TEXT-010.
  FIELDCAT 'BUKRS'    TEXT-011.
  FIELDCAT 'ANLKL'    TEXT-012.
  FIELDCAT 'TXT50'    TEXT-013.
  FIELDCAT 'TXA50'    TEXT-014.
  FIELDCAT 'ANLHTXT'  TEXT-050.
  FIELDCAT 'SERNR'    TEXT-015.
  FIELDCAT 'INVNR'    TEXT-016.
  FIELDCAT 'MENGE'    TEXT-017.
  FIELDCAT 'MEINS'    TEXT-018.
  FIELDCAT 'IVDAT'    TEXT-019.
  FIELDCAT 'INKEN'    TEXT-020.
  FIELDCAT 'INVZU'    TEXT-021.
  FIELDCAT 'KOSTL'    TEXT-022.
  FIELDCAT 'KOSTLV'   TEXT-023.
  FIELDCAT 'WERKS'    TEXT-024.
  FIELDCAT 'STORT'    TEXT-025.
  FIELDCAT 'RAUMN'    TEXT-026.
  FIELDCAT 'KFZKZ'    TEXT-027.
  FIELDCAT 'PERNR'    TEXT-028.
  FIELDCAT 'PRCTR'    TEXT-029.
  FIELDCAT 'GSBER'    TEXT-030.
  FIELDCAT 'ORD41'    TEXT-031.
  FIELDCAT 'ORD42'    TEXT-032.
  FIELDCAT 'ORD43'    TEXT-033.
  FIELDCAT 'ORD44'    TEXT-034.
  FIELDCAT 'GDLGRP'   TEXT-035.
  FIELDCAT 'LIFNR'    TEXT-036.
  FIELDCAT 'TYPBZ'    TEXT-037.
  FIELDCAT 'AKTIV'    TEXT-038.
  FIELDCAT 'AFABE'    TEXT-039.
  FIELDCAT 'AFASL'    TEXT-040.
  FIELDCAT 'NDJAR'    TEXT-041.
  FIELDCAT 'NDPER'    TEXT-042.
  FIELDCAT 'AFABG'    TEXT-043.
  FIELDCAT 'KANSW'    TEXT-044.
  FIELDCAT 'KNAFA'    TEXT-045.
  FIELDCAT 'NAFAG'    TEXT-046.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form FRM_OUTPUT_ALV
*&---------------------------------------------------------------------*
*& ALV展示
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM FRM_OUTPUT_ALV .
  "VLA函数
  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY_LVC'
    EXPORTING
      I_CALLBACK_PROGRAM       = SY-REPID
      I_CALLBACK_PF_STATUS_SET = 'FRM_SET_STATUS'
      I_CALLBACK_USER_COMMAND  = 'FRM_USER_COMMAND'
      IS_LAYOUT_LVC            = GS_LAYOUT
      IT_FIELDCAT_LVC          = GT_FIELDCAT
      I_SAVE                   = 'A'
    TABLES
      T_OUTTAB                 = GT_ALV
    EXCEPTIONS
      PROGRAM_ERROR            = 1
      OTHERS                   = 2.

  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
           WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form FRM_SET_STATUS
*&---------------------------------------------------------------------*
*& 设置状态栏
*&---------------------------------------------------------------------*
*& -->RT_EXTAB   text
*&---------------------------------------------------------------------*
FORM FRM_SET_STATUS USING RT_EXTAB TYPE SLIS_T_EXTAB.
  DATA: LS_EXTAB LIKE LINE OF RT_EXTAB.

  "已保存过，这不能再进行操作
  IF GV_SAVE = 'X'.
    LS_EXTAB-FCODE = 'TESTRUN'.
    APPEND LS_EXTAB TO RT_EXTAB.
    LS_EXTAB-FCODE = 'CREATE'.
    APPEND LS_EXTAB TO RT_EXTAB.
  ENDIF.

  SET PF-STATUS 'STATUS' EXCLUDING RT_EXTAB.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form FRM_USER_COMMAND
*----------------------------------------------------------------------*
*      -->R_UCOMM      text
*      -->RS_SELFIELD  text
*----------------------------------------------------------------------*
FORM FRM_USER_COMMAND USING R_UCOMM LIKE SY-UCOMM
                           RS_SELFIELD TYPE SLIS_SELFIELD.


  CASE R_UCOMM.
    WHEN 'TESTRUN' OR 'CREATE'.
      "测试运行OR创建资产
      PERFORM FRM_PROESS_DATA USING R_UCOMM.
  ENDCASE.

  "刷新
  PERFORM FRM_REFRESH_ALV.
ENDFORM.                    "FRM_USER_COMMAND
*&---------------------------------------------------------------------*
*& Form FRM_PROESS_DATA
*&---------------------------------------------------------------------*
*& 测试运行OR创建资产
*&---------------------------------------------------------------------*
*      -->P_R_UCOMM  text
*&---------------------------------------------------------------------*
FORM FRM_PROESS_DATA  USING L_UCOMM TYPE SY-UCOMM.
  "判断是否测试运行
  IF L_UCOMM = 'TESTRUN'.
    GV_TESTRUN = 'X'.
  ELSE.
    CLEAR GV_TESTRUN.
    GV_SAVE = 'X'.
  ENDIF.

  CLEAR: GV_CURRT_LINE,GV_ERROR_LINE.

  LOOP AT GT_ALV ASSIGNING <FS_ALV>.

    AT NEW YFIID.
      "清空BAPI变量
      PERFORM FRM_CLEAR_BAPDATA.
      "判断是否为当年购置
      IF <FS_ALV>-AKTIV+0(4) = SY-DATUM+0(4).
        GV_FLAG = 'X'.
      ENDIF.
    ENDAT.

*&--折旧范围(所有逻辑字段组)
    GS_DEPREAREAS-AREA            = <FS_ALV>-AFABE.     " 实际折旧范围
    GS_DEPREAREAS-DEP_KEY         = <FS_ALV>-AFASL.     " 折旧码
    GS_DEPREAREAS-ULIFE_YRS       = <FS_ALV>-NDJAR.     " 计划年使用期
    GS_DEPREAREAS-ULIFE_PRDS      = <FS_ALV>-NDPER.     " 计划使用期间
    GS_DEPREAREAS-ODEP_START_DATE = <FS_ALV>-AFABG.     " 折旧计算开始日期
    APPEND GS_DEPREAREAS TO GT_DEPREAREAS.

    GS_DEPREAREASX-AREA            = <FS_ALV>-AFABE.
    GS_DEPREAREASX-DEP_KEY         = 'X'.
    GS_DEPREAREASX-ULIFE_YRS       = 'X'.
    GS_DEPREAREASX-ULIFE_PRDS      = 'X'.
    GS_DEPREAREASX-ODEP_START_DATE = 'X'.
    APPEND GS_DEPREAREASX TO GT_DEPREAREASX.
*&--2017.12.18 HANDZX修改
*    "判断购置年度
*    IF GV_FLAG = 'X'.
**&--年度的转帐过程中历史资产的业务
*      "本年购置
*      GS_TRANSACTIONS-AREA          = <FS_ALV>-AFABE.              " 实际折旧范围
*      GS_TRANSACTIONS-AMOUNT        = <FS_ALV>-KANSW.              " 过帐金额
*      "参考日期
*      IF <FS_ALV>-KNAFA = 0 AND <FS_ALV>-AKTIV+0(6) = '201712' .
*        GS_TRANSACTIONS-VALUEDATE     = '20180101'.                " 参考日期
*      ELSE.
*        GS_TRANSACTIONS-VALUEDATE     = <FS_ALV>-AKTIV.            " 参考日期
*      ENDIF.
*      GS_TRANSACTIONS-CURRENT_NO    = <FS_ALV>-YFIID.              " 会计年资产行项目的序号
*      GS_TRANSACTIONS-FISC_YEAR     = SY-DATUM+0(4).               " 财年
*      GS_TRANSACTIONS-ASSETTRTYP    = '100'."购置                  " 资产交易类型
*      APPEND GS_TRANSACTIONS TO GT_TRANSACTIONS.
*    ELSE.
**&--逻辑字段组 CUMUAL：已传输的累计值
*      "历史购置，之前折旧金额
*      GS_CUMUVALUES-FISC_YEAR = SY-DATUM+0(4).
*      GS_CUMUVALUES-AREA      = <FS_ALV>-AFABE.
*      GS_CUMUVALUES-ACQ_VALUE = <FS_ALV>-KANSW.                     " 购置价值
*      GS_CUMUVALUES-ORD_DEP   = <FS_ALV>-KNAFA.                     " 之前折旧金额
*      APPEND GS_CUMUVALUES TO GT_CUMUVALUES.
*    ENDIF.
    GS_CUMUVALUES-FISC_YEAR = 2021."SY-DATUM+0(4).     " LIKE20191218修改资产导入日期
    GS_CUMUVALUES-AREA      = <FS_ALV>-AFABE.
    GS_CUMUVALUES-ACQ_VALUE = <FS_ALV>-KANSW.                     " 购置价值
    GS_CUMUVALUES-ORD_DEP   = <FS_ALV>-KNAFA.                     " 之前折旧金额
    APPEND GS_CUMUVALUES TO GT_CUMUVALUES.
*&--

*&--逻辑字段组 POSTVALL：已过帐的传输值
    "本年折旧金额
    IF <FS_ALV>-NAFAG IS NOT INITIAL.
      GS_POSTVALUES-FISC_YEAR = SY-DATUM+0(4)..
      GS_POSTVALUES-AREA    = <FS_ALV>-AFABE.
      GS_POSTVALUES-ORD_DEP = <FS_ALV>-NAFAG.
      APPEND GS_POSTVALUES TO GT_POSTVALUES.
    ENDIF.

    AT END OF YFIID.
*&--Key
      GS_KEY-COMPANYCODE        = <FS_ALV>-BUKRS.
*&--General Data
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          INPUT  = <FS_ALV>-ANLKL
        IMPORTING
          OUTPUT = <FS_ALV>-ANLKL.
      GS_GENERALDATA-ASSETCLASS = <FS_ALV>-ANLKL.             " 资产分类
      GS_GENERALDATA-DESCRIPT   = <FS_ALV>-TXT50.             " 资产描述
      GS_GENERALDATA-DESCRIPT2  = <FS_ALV>-TXA50.
      GS_GENERALDATA-MAIN_DESCRIPT  = <FS_ALV>-ANLHTXT.       " 资产主号说明
      GS_GENERALDATA-SERIAL_NO  = <FS_ALV>-SERNR.             " 序列号
      GS_GENERALDATA-INVENT_NO  = <FS_ALV>-INVNR.             " 库存号
      GS_GENERALDATA-QUANTITY   = <FS_ALV>-MENGE.             " 数量
      GS_GENERALDATA-BASE_UOM   = <FS_ALV>-MEINS.             " 单位

      GS_GENERALDATAX-ASSETCLASS = 'X'.
      GS_GENERALDATAX-DESCRIPT   = 'X'.
      GS_GENERALDATAX-DESCRIPT2  = 'X'.
      GS_GENERALDATAX-MAIN_DESCRIPT  = 'X'.
      GS_GENERALDATAX-SERIAL_NO  = 'X'.
      GS_GENERALDATAX-INVENT_NO  = 'X'.
      GS_GENERALDATAX-QUANTITY   = 'X'.
      GS_GENERALDATAX-BASE_UOM   = 'X'.
*&--Inventory逻辑字段组011 - 库存
      GS_INVENTORY-DATE            = <FS_ALV>-IVDAT.
      GS_INVENTORY-INCLUDE_IN_LIST = <FS_ALV>-INKEN.
      GS_INVENTORY-NOTE            = <FS_ALV>-INVZU.

      GS_INVENTORYX-DATE            = 'X'.
      GS_INVENTORYX-INCLUDE_IN_LIST = 'X'.
      GS_INVENTORYX-NOTE            = 'X'.

*&--Posting Information逻辑字段组002 - 记帐信息S
      GS_POSTINFO-CAP_DATE = <FS_ALV>-AKTIV.                      " 资产资本化日期

      GS_POSTINFOX-CAP_DATE = 'X'.

*&--Time-Dependent Data逻辑字段组003 - 时间相关的数据
      GS_TIMEDEPDATA-COSTCENTER = <FS_ALV>-KOSTL.
      GS_TIMEDEPDATA-RESP_CCTR  = <FS_ALV>-KOSTLV.
      GS_TIMEDEPDATA-PLANT      = <FS_ALV>-WERKS.
      GS_TIMEDEPDATA-LOCATION   = <FS_ALV>-STORT.
      GS_TIMEDEPDATA-ROOM       = <FS_ALV>-RAUMN.
      GS_TIMEDEPDATA-PLATE_NO   = <FS_ALV>-KFZKZ.
      GS_TIMEDEPDATA-PERSON_NO  = <FS_ALV>-PERNR.
      GS_TIMEDEPDATA-PROFIT_CTR = <FS_ALV>-PRCTR.
      GS_TIMEDEPDATA-BUS_AREA   = <FS_ALV>-GSBER.

      GS_TIMEDEPDATAX-COSTCENTER         = 'X'.
      GS_TIMEDEPDATAX-RESP_CCTR          = 'X'.
      GS_TIMEDEPDATAX-PLANT              = 'X'.
      GS_TIMEDEPDATAX-LOCATION           = 'X'.
      GS_TIMEDEPDATAX-ROOM               = 'X'.
      GS_TIMEDEPDATAX-LICENSE_PLATE_NO   = 'X'.
      GS_TIMEDEPDATAX-PERSON_NO          = 'X'.
      GS_TIMEDEPDATAX-PROFIT_CTR         = 'X'.
      GS_TIMEDEPDATAX-BUS_AREA           = 'X'.
*&--Allocations逻辑字段组004 - 分配
      GS_ALLOCATIONS-EVALGROUP1 = <FS_ALV>-ORD41.
      GS_ALLOCATIONS-EVALGROUP2 = <FS_ALV>-ORD42.
      GS_ALLOCATIONS-EVALGROUP3 = <FS_ALV>-ORD43.
      GS_ALLOCATIONS-EVALGROUP4 = <FS_ALV>-ORD44.
      GS_ALLOCATIONS-EVALGROUP5 = <FS_ALV>-GDLGRP.

      GS_ALLOCATIONSX-EVALGROUP1 = 'X'.
      GS_ALLOCATIONSX-EVALGROUP2 = 'X'.
      GS_ALLOCATIONSX-EVALGROUP3 = 'X'.
      GS_ALLOCATIONSX-EVALGROUP4 = 'X'.
      GS_ALLOCATIONSX-EVALGROUP5 = 'X'.
*&--Origin逻辑字段组009 - 原件
      GS_ORIGIN-VENDOR_NO = <FS_ALV>-LIFNR.
      GS_ORIGIN-TYPE_NAME = <FS_ALV>-TYPBZ.

      GS_ORIGINX-VENDOR_NO = 'X'.
      GS_ORIGINX-TYPE_NAME = 'X'.

      "调用BAPI处理数据
      PERFORM FRM_FIXEDASSET_CREATE.
    ENDAT.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form FRM_CLEAR_BAPDATA
*&---------------------------------------------------------------------*
*& 清空BAPI变量
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM FRM_CLEAR_BAPDATA .
  CLEAR: GV_FLAG,GS_KEY,GV_ASSET,GS_GENERALDATA,GS_GENERALDATAX,GS_INVENTORY,GS_INVENTORYX,
         GS_TIMEDEPDATA,GS_TIMEDEPDATAX,GS_ALLOCATIONS,GS_ALLOCATIONSX,GS_ORIGIN,
         GS_ORIGINX,GS_POSTINFO,GS_POSTINFOX,GS_DEPREAREAS,
         GS_DEPREAREASX,GS_TRANSACTIONS,GS_POSTVALUES,GS_CUMUVALUES.
  REFRESH: GT_POSTVALUES,GT_DEPREAREAS,GT_DEPREAREASX,GT_CUMUVALUES,GT_TRANSACTIONS,
           GT_RETURN.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form FRM_FIXEDASSET_CREATE
*&---------------------------------------------------------------------*
*& 调用BAPI处理数据
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM FRM_FIXEDASSET_CREATE .
  DATA: LV_BELNR TYPE BKPF-BELNR.

*调用函数     Call a function
  CALL FUNCTION 'BAPI_FIXEDASSET_OVRTAKE_CREATE'
    EXPORTING
      KEY                 = GS_KEY
      TESTRUN             = GV_TESTRUN
      GENERALDATA         = GS_GENERALDATA
      GENERALDATAX        = GS_GENERALDATAX
      INVENTORY           = GS_INVENTORY
      INVENTORYX          = GS_INVENTORYX
      POSTINGINFORMATION  = GS_POSTINFO
      POSTINGINFORMATIONX = GS_POSTINFOX
      TIMEDEPENDENTDATA   = GS_TIMEDEPDATA
      TIMEDEPENDENTDATAX  = GS_TIMEDEPDATAX
      ALLOCATIONS         = GS_ALLOCATIONS
      ALLOCATIONSX        = GS_ALLOCATIONSX
      ORIGIN              = GS_ORIGIN
      ORIGINX             = GS_ORIGINX
    IMPORTING
      ASSET               = GV_ASSET
    TABLES
      DEPRECIATIONAREAS   = GT_DEPREAREAS
      DEPRECIATIONAREASX  = GT_DEPREAREASX
      TRANSACTIONS        = GT_TRANSACTIONS
      CUMULATEDVALUES     = GT_CUMUVALUES
      POSTEDVALUES        = GT_POSTVALUES
      RETURN              = GT_RETURN.

  "尝试获取错误消息
  CLEAR <FS_ALV>-BAPI_MSG.
  LOOP AT GT_RETURN INTO GS_RETURN WHERE TYPE = 'E' OR TYPE = 'A'.
    <FS_ALV>-STATUS   = ICON_RED_LIGHT.
    CONCATENATE <FS_ALV>-BAPI_MSG GS_RETURN-MESSAGE INTO <FS_ALV>-BAPI_MSG.
  ENDLOOP.
  "有错误消息
  IF <FS_ALV>-BAPI_MSG IS NOT INITIAL.
    "数据回滚
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
    "错误条目数
    GV_ERROR_LINE = GV_ERROR_LINE + 1.
  ELSE.
    "绿灯
    <FS_ALV>-STATUS   = ICON_GREEN_LIGHT.
    IF GV_TESTRUN IS NOT INITIAL.
      "测试成功
      <FS_ALV>-BAPI_MSG = TEXT-004.
    ELSE.
      "提交执行
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          WAIT = 'X'.
      "获取凭证编号
      LOOP AT GT_RETURN INTO GS_RETURN WHERE TYPE = 'S'.
        LV_BELNR = GS_RETURN-MESSAGE_V2+0(10).
      ENDLOOP.
      <FS_ALV>-BAPI_MSG = TEXT-005.
      <FS_ALV>-BELNR    = LV_BELNR.
      <FS_ALV>-ANLN1    = GV_ASSET.
    ENDIF.
  ENDIF.

  "更新ALV数据
  MODIFY GT_ALV FROM <FS_ALV> TRANSPORTING STATUS BAPI_MSG BELNR ANLN1
    WHERE YFIID = <FS_ALV>-YFIID.

  "显示状态进度栏
  PERFORM FRM_SHOW_PROGRESSBAR.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form FRM_REFRESH_ALV
*&---------------------------------------------------------------------*
*& 刷新
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM FRM_REFRESH_ALV .
  DATA: LR_GRID TYPE REF TO CL_GUI_ALV_GRID.

  FREE LR_GRID.
  "得到当前屏幕上的ALV的句柄
  CALL FUNCTION 'GET_GLOBALS_FROM_SLVC_FULLSCR'
    IMPORTING
      E_GRID = LR_GRID.

  CALL METHOD LR_GRID->REFRESH_TABLE_DISPLAY
    EXPORTING
      I_SOFT_REFRESH = 'X'.

  CALL METHOD CL_GUI_CFW=>FLUSH.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form FRM_SHOW_PROGRESSBAR
*&---------------------------------------------------------------------*
*& 显示状态进度栏
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM FRM_SHOW_PROGRESSBAR .
  DATA: LV_PERCENTAG TYPE I,
        LV_TEXT(40)  TYPE C,
        LV_CHAR(8)   TYPE C.

  "进度+1
  GV_CURRT_LINE = GV_CURRT_LINE + 1.
  "百分比
  LV_PERCENTAG = GV_CURRT_LINE  * 100 / GV_TOTAL_LINE.
  "文本
  LV_CHAR = GV_CURRT_LINE.
  CONCATENATE '当前进度：' LV_CHAR INTO LV_TEXT.
  LV_CHAR = GV_TOTAL_LINE.
  CONCATENATE LV_TEXT '/' LV_CHAR INTO LV_TEXT.
  LV_CHAR = GV_ERROR_LINE.
  CONCATENATE LV_TEXT '，错误' LV_CHAR '条' INTO LV_TEXT.
  CONDENSE LV_TEXT NO-GAPS.

  "进度条
  CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
    EXPORTING
      PERCENTAGE = LV_PERCENTAG
      TEXT       = LV_TEXT.
ENDFORM.
