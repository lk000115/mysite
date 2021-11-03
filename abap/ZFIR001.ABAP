REPORT ZFIR001.
************************************************************************
*
* 程序名称: 资产负债表
*
* 作者: 许明杰
* 开发日期: 2017-11-07
* 请求号:
* 申请者y:
* 功能/技术文档:
* 描述: 资产负债表单体，带EXCEL导出功能
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
************************************************************************
* tables
************************************************************************
*Type pools
TYPE-POOLS:SLIS.
*Table
TABLES:ACDOCA,CEPC,SSCRFIELDS.
************************************************************************
* internal tables
************************************************************************
DATA: BEGIN OF GS_ALV,
        ZSIDE  TYPE  ZZE_SIDE, "方向
        ZDECS1 TYPE  ZZE_DESC, "项目(左)
        ZITEM1 TYPE  ZZE_ITEM, "行号(左)
        HSLQJ1 TYPE  ACDOCA-HSL, "期间金额(左)
        HSLBJ1 TYPE  ACDOCA-HSL, "比较金额(左)
        ZDECS2 TYPE  ZZE_DESC, "项目(右)
        ZITEM2 TYPE  ZZE_ITEM, "行号(右)
        HSLQJ2 TYPE  ACDOCA-HSL, "期间金额(右)
        HSLBJ2 TYPE  ACDOCA-HSL, "比较金额(右)
      END OF GS_ALV.
DATA GT_ALV LIKE TABLE OF GS_ALV.

"项目科目配置表
DATA: GS_CNBS LIKE ZFI_CNBS,
      GT_CNBS LIKE TABLE OF GS_CNBS.

DATA: BEGIN OF GS_ACDOCA,
        BUKRS LIKE ACDOCA-RBUKRS,  " 公司代码
        GJAHR TYPE ACDOCA-GJAHR,   " 会计年度
        BELNR TYPE ACDOCA-BELNR,   " 会计凭证
        DOCLN TYPE ACDOCA-DOCLN,   " 行项目
        RACCT TYPE ACDOCA-RACCT,   " 科目
        HSL   TYPE ACDOCA-HSL,     " 金额
        POPER TYPE ACDOCA-POPER,   " 期间
      END OF GS_ACDOCA.
DATA GT_ACDOCA LIKE TABLE OF GS_ACDOCA.
*&----2018011HANDZX修改
TYPES:BEGIN OF TY_TAB,
        BUKRS LIKE ACDOCA-RBUKRS,  " 公司代码
        GJAHR TYPE ACDOCA-GJAHR,   " 会计年度
        BELNR TYPE ACDOCA-BELNR,   " 会计凭证
        DOCLN TYPE ACDOCA-DOCLN,   " 行项目
        RACCT TYPE ACDOCA-RACCT,   " 科目
        HSL   TYPE ACDOCA-HSL,     " 金额
        POPER TYPE ACDOCA-POPER,   " 期间
        KUNNR TYPE ACDOCA-KUNNR,   " 客户
      END OF TY_TAB.
DATA:GT_TAB TYPE TABLE OF TY_TAB,
     GS_TAB TYPE TY_TAB.
DATA:GT_COM_TAB TYPE STANDARD TABLE OF TY_TAB,
     GS_COM_TAB TYPE TY_TAB.
TYPES:BEGIN OF TY_TAB2,
        BUKRS LIKE ACDOCA-RBUKRS,  " 公司代码
        GJAHR TYPE ACDOCA-GJAHR,   " 会计年度
        BELNR TYPE ACDOCA-BELNR,   " 会计凭证
        DOCLN TYPE ACDOCA-DOCLN,   " 行项目
        RACCT TYPE ACDOCA-RACCT,   " 科目
        HSL   TYPE ACDOCA-HSL,     " 金额
        POPER TYPE ACDOCA-POPER,   " 期间
        LIFNR TYPE ACDOCA-LIFNR,   " 客户
      END OF TY_TAB2.
DATA:GT_TAB2 TYPE TABLE OF TY_TAB2,
     GS_TAB2 TYPE TY_TAB2.
DATA:GT_COM_TAB2 TYPE TABLE OF TY_TAB2,
     GS_COM_TAB2 TYPE TY_TAB2.
TYPES:BEGIN OF TY_KUNNR,
        BUKRS LIKE ACDOCA-RBUKRS,  " 公司代码
        GJAHR TYPE ACDOCA-GJAHR,   " 会计年度
        RACCT TYPE ACDOCA-RACCT,   " 科目
        KUNNR TYPE ACDOCA-KUNNR,   " 客户
        HSL   TYPE ACDOCA-HSL,     " 金额
      END OF TY_KUNNR.
DATA:GT_KUNNR TYPE STANDARD TABLE OF TY_KUNNR,
     GS_KUNNR TYPE TY_KUNNR.
DATA:GT_COM_KUNNR TYPE STANDARD TABLE OF TY_KUNNR,
     GS_COM_KUNNR TYPE TY_KUNNR.
TYPES:BEGIN OF TY_LIFNR,
        BUKRS LIKE ACDOCA-RBUKRS,  " 公司代码
        GJAHR TYPE ACDOCA-GJAHR,   " 会计年度
        RACCT TYPE ACDOCA-RACCT,   " 科目
        LIFNR TYPE ACDOCA-LIFNR,   " 客户
        HSL   TYPE ACDOCA-HSL,     " 金额
      END OF TY_LIFNR.
DATA:GT_LIFNR TYPE STANDARD TABLE OF TY_LIFNR,
     GS_LIFNR TYPE TY_LIFNR.
DATA:GT_COM_LIFNR TYPE STANDARD TABLE OF TY_LIFNR,
     GS_COM_LIFNR TYPE TY_LIFNR.
TYPES:BEGIN OF TY_RACCT,
        BUKRS LIKE ACDOCA-RBUKRS,  " 公司代码
        GJAHR TYPE ACDOCA-GJAHR,   " 会计年度
        RACCT TYPE ACDOCA-RACCT,   " 科目
        HSL   TYPE ACDOCA-HSL,     " 金额
      END OF TY_RACCT.
DATA:GT_RACCT TYPE STANDARD TABLE OF TY_RACCT,
     GS_RACCT TYPE TY_RACCT.
DATA:GT_COM_RACCT TYPE STANDARD TABLE OF TY_RACCT,
     GS_COM_RACCT TYPE TY_RACCT.
DATA:GT_RACCT2 TYPE STANDARD TABLE OF TY_RACCT,
     GS_RACCT2 TYPE TY_RACCT.
DATA:GT_COM_RACCT2 TYPE STANDARD TABLE OF TY_RACCT,
     GS_COM_RACCT2 TYPE TY_RACCT.


*----------------------------------------------------------------------*



*ALV display
DATA: GT_FIELDCAT TYPE LVC_T_FCAT,    " Fieldcat table
      GS_FIELDCAT TYPE LVC_S_FCAT,    " Fieldcat
      GS_LAYOUT   TYPE LVC_S_LAYO.    " Layout

*宏定义      Macro definition
DEFINE FIELDCAT.
  GS_FIELDCAT-FIELDNAME = &1.
  GS_FIELDCAT-SCRTEXT_M = &2.
  GS_FIELDCAT-KEY       = &3.
  APPEND GS_FIELDCAT TO GT_FIELDCAT.
END-OF-DEFINITION.
************************************************************************
* internal data fields
************************************************************************
" 菜单制作器:动态文本的程序接
DATA: GW_FUNCTXT TYPE SMP_DYNTXT.

DATA: G_DOCUMENT TYPE REF TO CL_DD_DOCUMENT.

RANGES: R_PRCTR FOR ACDOCA-PRCTR,
        R_POPER1 FOR ACDOCA-POPER,
        R_POPER2 FOR ACDOCA-POPER.

RANGES: R_RACCT FOR ACDOCA-RACCT.

*表头参数         Header parameter
DATA: GV_COMPANY  TYPE C LENGTH 80,                "Company
      GV_CURRENCY TYPE C LENGTH 10,                "Currency
      GV_PROGROUP TYPE SETHEADERT-DESCRIPT,       "Profit Center Group
      GV_PROCENTE TYPE CEPCT-KTEXT,               "Profit Center
      GV_DATE     TYPE ACDOCA-BZDAT.              "Date

*本地文件路径变量说明
DATA:
  G_DEF_NAME       TYPE STRING VALUE '资产负债表模板.xls',        "默认文件名
  G_ITEM_URL(256),                                                 "模板在BDS上的URL地址
  G_PATH           TYPE STRING,                                              "保存的文件路径
  G_FILENAME       TYPE STRING,                                          "要保存文件的文件名
  G_FULLPATH       TYPE STRING,                                          "全路径（路径+文件名）
  G_USER_ACTION    TYPE I,                                            "用户操作（0标示点击了‘保存’，9表示‘取消’）
  G_FILE_NAME(200).                                                "全路径名

*DOI变量申明
DATA:
  GCL_CONTAINER    TYPE REF TO CL_GUI_CUSTOM_CONTAINER,            "容器
  GCL_CONTROL      TYPE REF TO I_OI_CONTAINER_CONTROL,             "DOI实例
  GCL_DOCUMENT     TYPE REF TO I_OI_DOCUMENT_PROXY,                "用来打开BDS上文件的类
  GCL_ERRORS       TYPE TABLE OF REF TO I_OI_ERROR WITH HEADER LINE, "用来存储各个方法中产生的错误
  G_RETCODE        TYPE SOI_RET_STRING,                            "存放调用DOI方法之后的返回值
  GCL_BDS_INSTANCE TYPE REF TO CL_BDS_DOCUMENT_SET.                "此类用来获取上传的文档
DATA GR_SPREADSHEET TYPE REF TO I_OI_SPREADSHEET.

CONSTANTS:
  CONS_SPLIT      VALUE '-', "分隔符
  CONS_ROOT(4)    VALUE 'ROOT', "根节点标识
  CONS_ROOT_LEVEL TYPE I VALUE 1, "根节点的层级
  CONS_INPLACE    VALUE 'X',
  CONS_EXCEL(80)  VALUE 'Excel.Sheet'.
*确定模板在BDS上的位置
DATA:
  G_DOC_CLASSNAME  TYPE SBDST_CLASSNAME VALUE 'HRFPM_EXCEL_STANDARD',
  G_DOC_CLASSTYPE  TYPE SBDST_CLASSTYPE VALUE 'OT',
  G_DOC_OBJECT_KEY TYPE SBDST_OBJECT_KEY VALUE 'ZFI001',
  G_PROP_VALUE     TYPE BAPISIGNAT-PROP_VALUE VALUE 'BS_EXPORT'.

*&-------for cell 01
DATA: RANGEITEM TYPE SOI_RANGE_ITEM.
DATA: RANGES TYPE SOI_RANGE_LIST.
DATA: EXCEL_INPUT TYPE SOI_GENERIC_TABLE.
DATA: EXCEL_INPUT_WA TYPE SOI_GENERIC_ITEM.
*&------- for cell table
DATA: GS_RANGE    TYPE SOI_RANGE_ITEM,
      GT_RANGES   TYPE SOI_RANGE_LIST,
      GT_CONTENTS TYPE SOI_GENERIC_TABLE,
      GS_CONTENT  TYPE SOI_GENERIC_ITEM.
************************************************************************
* Parameters and Selection Options
************************************************************************
SELECTION-SCREEN BEGIN OF BLOCK BLK1 WITH FRAME TITLE TEXT-001.
SELECT-OPTIONS: S_BUKRS FOR ACDOCA-RBUKRS," OBLIGATORY,
                S_RBUSA FOR ACDOCA-RBUSA NO-DISPLAY,
                S_PRCTR FOR ACDOCA-PRCTR NO-DISPLAY,
                S_KHINR FOR CEPC-KHINR NO-DISPLAY.
PARAMETERS: P_GJAHR1 LIKE ACDOCA-GJAHR OBLIGATORY,
            P_POPER1 LIKE ACDOCA-POPER OBLIGATORY,
            P_RLDNR  LIKE ACDOCA-RLDNR OBLIGATORY DEFAULT '0L'.
SELECTION-SCREEN END OF BLOCK BLK1.

SELECTION-SCREEN BEGIN OF BLOCK BLK2 WITH FRAME TITLE TEXT-002.
PARAMETERS: P_GJAHR2 LIKE ACDOCA-GJAHR OBLIGATORY, "比较期间
            P_POPER2 LIKE ACDOCA-POPER.
SELECTION-SCREEN END OF BLOCK BLK2.

SELECTION-SCREEN: FUNCTION KEY 1.
*
************************************************************************
* Initialization
************************************************************************
INITIALIZATION.
  GW_FUNCTXT-ICON_ID   = ICON_CREATE_TEXT.
  GW_FUNCTXT-QUICKINFO = '资产负债表维护'.
  GW_FUNCTXT-ICON_TEXT = '资产负债表维护'.
  SSCRFIELDS-FUNCTXT_01 = GW_FUNCTXT.

  "当前一月则默认年度为上一年
  IF SY-DATUM+4(2) = 01.
    P_GJAHR1 = SY-DATUM+0(4) - 1.
    P_POPER1 = '12'.
  ELSE.
    P_GJAHR1 = SY-DATUM+0(4).
    P_POPER1 = SY-DATUM+4(2) - 1.
  ENDIF.

  P_GJAHR2 = P_GJAHR1.
  P_POPER2 = 0.
************************************************************************
* at selection screen
************************************************************************
AT SELECTION-SCREEN.
  CASE SSCRFIELDS-UCOMM.
    WHEN 'FC01'.
*&---对资产负债表进行维护
      CALL FUNCTION 'VIEW_MAINTENANCE_CALL'                           "Maintenance table ZFICOCNBSGENERAL
        EXPORTING
          ACTION    = 'U'
          VIEW_NAME = 'ZFI_CNBS'.
  ENDCASE.

  "检查输入
  PERFORM FRM_CHECK_INPUT.
************************************************************************
* Event top of page
************************************************************************
TOP-OF-PAGE.

************************************************************************
* event Start of Selection
************************************************************************
START-OF-SELECTION.
  "根据条件选择数据
  PERFORM FRM_SELDATA.
  "处理数据
  PERFORM FRM_DEALDATA.

************************************************************************
*EVENT End-of selection
************************************************************************
END-OF-SELECTION.
  "输出数据
  PERFORM  FRM_WRITE.
************************************************************************
*EVENT  End-of page
************************************************************************
END-OF-PAGE.
************************************************************************

************************************************************************
** forms
************************************************************************
*&---------------------------------------------------------------------*
*& Form FRM_CHECK_INPUT
*&---------------------------------------------------------------------*
*& 检查输入
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM FRM_CHECK_INPUT .
*公司代码存在性检查
  DATA: LT_BUKRS TYPE TABLE OF BUKRS WITH HEADER LINE.

  IF S_BUKRS[] IS INITIAL.
    MESSAGE '请输入公司代码！' TYPE 'E'.
  ENDIF.

  SELECT  BUKRS
    FROM T001
    INTO TABLE LT_BUKRS
    WHERE BUKRS IN S_BUKRS.
  IF SY-SUBRC <> 0.
    MESSAGE E005(ZFICO) .
  ENDIF.
*公司代码权限检查
  LOOP AT LT_BUKRS.
    AUTHORITY-CHECK OBJECT 'F_BKPF_BUK'
                     ID 'ACTVT' FIELD '03'
                     ID 'BUKRS' FIELD LT_BUKRS.
    IF SY-SUBRC <> 0.
      MESSAGE E006(ZFICO) WITH LT_BUKRS.
    ENDIF.
  ENDLOOP.

*分类帐有效性检查
  DATA: L_RLDNR TYPE ACDOCA-RLDNR.

  SELECT SINGLE RLDNR
    INTO L_RLDNR
    FROM ACDOCA
    WHERE RLDNR = P_RLDNR.
  IF L_RLDNR IS INITIAL.
    MESSAGE E009(ZFICO) WITH P_RLDNR.
  ENDIF.

  "期间换算
  R_POPER1-SIGN   = 'I'.
  R_POPER1-OPTION = 'BT'.
  R_POPER1-LOW  = 0.
  R_POPER1-HIGH = P_POPER1.
  APPEND R_POPER1.
  R_POPER2-SIGN   = 'I'.
  R_POPER2-OPTION = 'BT'.
  R_POPER2-LOW  = 0.
  R_POPER2-HIGH = P_POPER2.
  APPEND R_POPER2.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form FRM_SELDATA
*&---------------------------------------------------------------------*
*& 根据条件选择数据
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM FRM_SELDATA .
  "利润中心组换算成利润中心
  PERFORM FRM_SEL_PRCTR.
  "获取配置表科目范围
  PERFORM FRM_SEL_RACCT.

  "获取凭证数据
  SELECT  RBUKRS "公司代码
          GJAHR  "会计年度
          BELNR  "会计凭证
          DOCLN  "行项目
          RACCT  "科目
          HSL    "金额
          POPER  "期间
    INTO TABLE GT_ACDOCA
    FROM ACDOCA
   WHERE  RLDNR  =  P_RLDNR
    AND   RBUKRS IN S_BUKRS
    AND   ( ( GJAHR  =  P_GJAHR1 AND POPER IN R_POPER1 )
            OR ( GJAHR  =  P_GJAHR2 AND POPER IN R_POPER2 ) )
    AND   RACCT  IN R_RACCT
    AND   PRCTR  IN R_PRCTR
    AND   RBUSA  IN S_RBUSA.

*&-----2018011HANDZX修改
*&--按客户统计,如果为HSL负,则赋值给科目2203010101
  SELECT  RBUKRS "公司代码
          GJAHR  "会计年度
          BELNR  "会计凭证
          DOCLN  "行项目
          RACCT  "科目
          HSL    "金额
          POPER  "期间
          KUNNR  "客户
    INTO TABLE GT_TAB
    FROM ACDOCA
   WHERE  RLDNR  =  P_RLDNR
    AND   RBUKRS IN S_BUKRS
    AND  (  GJAHR  =  P_GJAHR1 AND POPER IN R_POPER1 )
    AND   RACCT  IN R_RACCT
    AND   PRCTR  IN R_PRCTR
    AND   RBUSA  IN S_RBUSA
    AND   RACCT  IN ( '1122020101' , '1122010101' ).
  LOOP AT GT_TAB INTO GS_TAB.
    CLEAR GS_KUNNR.
    GS_KUNNR-BUKRS = GS_TAB-BUKRS.
    GS_KUNNR-GJAHR = GS_TAB-GJAHR.
    GS_KUNNR-RACCT = GS_TAB-RACCT.
    GS_KUNNR-KUNNR = GS_TAB-KUNNR.
    GS_KUNNR-HSL   = GS_TAB-HSL.
    COLLECT GS_KUNNR INTO GT_KUNNR.
  ENDLOOP.
  LOOP AT GT_KUNNR INTO GS_KUNNR.
    CLEAR GS_RACCT.
    GS_RACCT-BUKRS = GS_KUNNR-BUKRS.
    GS_RACCT-GJAHR = GS_KUNNR-GJAHR.
    IF GS_KUNNR-HSL < 0.
      GS_RACCT-RACCT = '2203010101'.
      GS_RACCT-HSL   = GS_KUNNR-HSL.
    ELSE.
      GS_RACCT-RACCT = GS_KUNNR-RACCT.
      GS_RACCT-HSL   = GS_KUNNR-HSL.
    ENDIF.
    COLLECT GS_RACCT INTO GT_RACCT.
  ENDLOOP.
  SORT GT_RACCT BY BUKRS GJAHR RACCT.
*&--按供应商统计，如果HSL为正，则赋值给科目1123010101
  SELECT RBUKRS "公司代码
         GJAHR  "会计年度
         BELNR  "会计凭证
         DOCLN  "行项目
         RACCT  "科目
         HSL    "金额
         POPER  "期间
         LIFNR  "供应商
  INTO TABLE GT_TAB2
  FROM ACDOCA
 WHERE  RLDNR  =  P_RLDNR
  AND   RBUKRS IN S_BUKRS
  AND   ( GJAHR  =  P_GJAHR1 AND POPER IN R_POPER1 )
  AND   RACCT  IN R_RACCT
  AND   PRCTR  IN R_PRCTR
  AND   RBUSA  IN S_RBUSA
  AND   RACCT  = '2202010101 '.
  LOOP AT GT_TAB2 INTO GS_TAB2.
    CLEAR GS_LIFNR.
    GS_LIFNR-BUKRS = GS_TAB2-BUKRS.
    GS_LIFNR-GJAHR = GS_TAB2-GJAHR.
    GS_LIFNR-RACCT = GS_TAB2-RACCT.
    GS_LIFNR-LIFNR = GS_TAB2-LIFNR.
    GS_LIFNR-HSL   = GS_TAB2-HSL.
    COLLECT GS_LIFNR INTO GT_LIFNR.
  ENDLOOP.
  LOOP AT GT_LIFNR INTO GS_LIFNR.
    CLEAR GS_RACCT2.
    GS_RACCT2-BUKRS = GS_LIFNR-BUKRS.
    GS_RACCT2-GJAHR = GS_LIFNR-GJAHR.
    IF GS_LIFNR-HSL > 0.
      GS_RACCT2-RACCT = '1123010101'.
      GS_RACCT2-HSL   = GS_LIFNR-HSL.
    ELSE.
      GS_RACCT2-RACCT = GS_LIFNR-RACCT.
      GS_RACCT2-HSL   = GS_LIFNR-HSL.
    ENDIF.
    COLLECT GS_RACCT2 INTO GT_RACCT2.
  ENDLOOP.
  SORT GT_RACCT2 BY BUKRS GJAHR RACCT.

*&--被比较数据
  SELECT  RBUKRS "公司代码
          GJAHR  "会计年度
          BELNR  "会计凭证
          DOCLN  "行项目
          RACCT  "科目
          HSL    "金额
          POPER  "期间
          KUNNR  "客户
    INTO TABLE GT_COM_TAB
    FROM ACDOCA
   WHERE  RLDNR  =  P_RLDNR
    AND   RBUKRS IN S_BUKRS
    AND  (  GJAHR  =  P_GJAHR2 AND POPER IN R_POPER2 )
    AND   RACCT  IN R_RACCT
    AND   PRCTR  IN R_PRCTR
    AND   RBUSA  IN S_RBUSA
    AND   RACCT  IN ( '1122020101' , '1122010101' ).
  LOOP AT GT_COM_TAB INTO GS_COM_TAB.
    CLEAR GS_COM_KUNNR.
    GS_COM_KUNNR-BUKRS = GS_COM_TAB-BUKRS.
    GS_COM_KUNNR-GJAHR = GS_COM_TAB-GJAHR.
    GS_COM_KUNNR-RACCT = GS_COM_TAB-RACCT.
    GS_COM_KUNNR-KUNNR = GS_COM_TAB-KUNNR.
    GS_COM_KUNNR-HSL   = GS_COM_TAB-HSL.
    COLLECT GS_COM_KUNNR INTO GT_COM_KUNNR.
  ENDLOOP.
  LOOP AT GT_COM_KUNNR INTO GS_COM_KUNNR.
    CLEAR GS_COM_RACCT.
    GS_COM_RACCT-BUKRS = GS_COM_KUNNR-BUKRS.
    GS_COM_RACCT-GJAHR = GS_COM_KUNNR-GJAHR.
    IF GS_COM_KUNNR-HSL < 0.
      GS_COM_RACCT-RACCT = '2203010101'.
      GS_COM_RACCT-HSL   = GS_COM_KUNNR-HSL.
    ELSE.
      GS_COM_RACCT-RACCT = GS_COM_KUNNR-RACCT.
      GS_COM_RACCT-HSL   = GS_COM_KUNNR-HSL.
    ENDIF.
    COLLECT GS_COM_RACCT INTO GT_COM_RACCT.
  ENDLOOP.
  SORT GT_COM_RACCT BY BUKRS GJAHR RACCT.



  SELECT RBUKRS "公司代码
        GJAHR  "会计年度
        BELNR  "会计凭证
        DOCLN  "行项目
        RACCT  "科目
        HSL    "金额
        POPER  "期间
        LIFNR  "供应商
 INTO TABLE GT_COM_TAB2
 FROM ACDOCA
WHERE  RLDNR  =  P_RLDNR
 AND   RBUKRS IN S_BUKRS
 AND   ( GJAHR  =  P_GJAHR2 AND POPER IN R_POPER2 )
 AND   RACCT  IN R_RACCT
 AND   PRCTR  IN R_PRCTR
 AND   RBUSA  IN S_RBUSA
 AND   RACCT  = '2202010101 '.
  LOOP AT GT_COM_TAB2 INTO GS_COM_TAB2.
    CLEAR GS_COM_LIFNR.
    GS_COM_LIFNR-BUKRS = GS_COM_TAB2-BUKRS.
    GS_COM_LIFNR-GJAHR = GS_COM_TAB2-GJAHR.
    GS_COM_LIFNR-RACCT = GS_COM_TAB2-RACCT.
    GS_COM_LIFNR-LIFNR = GS_COM_TAB2-LIFNR.
    GS_COM_LIFNR-HSL   = GS_COM_TAB2-HSL.
    COLLECT GS_COM_LIFNR INTO GT_COM_LIFNR.
  ENDLOOP.
  LOOP AT GT_COM_LIFNR INTO GS_COM_LIFNR.
    CLEAR GS_COM_RACCT2.
    GS_COM_RACCT2-BUKRS = GS_COM_LIFNR-BUKRS.
    GS_COM_RACCT2-GJAHR = GS_COM_LIFNR-GJAHR.
    IF GS_COM_LIFNR-HSL > 0.
      GS_COM_RACCT2-RACCT = '1123010101'.
      GS_COM_RACCT2-HSL   = GS_COM_LIFNR-HSL.
    ELSE.
      GS_COM_RACCT2-RACCT = GS_COM_LIFNR-RACCT.
      GS_COM_RACCT2-HSL   = GS_COM_LIFNR-HSL.
    ENDIF.
    COLLECT GS_COM_RACCT2 INTO GT_COM_RACCT2.
  ENDLOOP.
  SORT GT_COM_RACCT2 BY BUKRS GJAHR RACCT.

*----------------------------------------------------------------------*



ENDFORM.
*&---------------------------------------------------------------------*
*& Form FRM_SEL_PRCTR
*&---------------------------------------------------------------------*
*& 利润中心组换算成利润中心
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM FRM_SEL_PRCTR .
  DATA: BEGIN OF LW_CEPC,
          PRCTR LIKE CEPC-PRCTR,
          KHINR LIKE CEPC-KHINR,
        END OF LW_CEPC.
  DATA LT_CEPC LIKE TABLE OF LW_CEPC.

  "range值等于选择值
  R_PRCTR[] = S_PRCTR[].

  IF S_KHINR[] IS INITIAL.
    RETURN.
  ENDIF.

  "利润中心
  SELECT PRCTR
         KHINR
    INTO TABLE LT_CEPC
    FROM CEPC
   WHERE  KHINR IN S_KHINR.

  LOOP AT LT_CEPC INTO LW_CEPC.
    CLEAR R_PRCTR.
    R_PRCTR-SIGN   = 'I'.
    R_PRCTR-OPTION = 'EQ'.
    R_PRCTR-LOW    = LW_CEPC-PRCTR.
    APPEND R_PRCTR.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form FRM_SEL_RACCT
*&---------------------------------------------------------------------*
*& 获取配置表科目范围
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM FRM_SEL_RACCT .
  "科目配置表
  SELECT *
    INTO TABLE GT_CNBS
    FROM ZFI_CNBS
   WHERE SPRAS = SY-LANGU.

  SORT GT_CNBS BY ZITEM ZLINE.

  "科目范围，排除不必要的凭证
  LOOP AT GT_CNBS INTO GS_CNBS.
    "科目到为空，则科目到等于科目从
    IF GS_CNBS-ZRACCT2 IS INITIAL.
      "都为空则不处理
      IF GS_CNBS-ZRACCT1 IS INITIAL.
        CONTINUE.
      ENDIF.
      GS_CNBS-ZRACCT2 = GS_CNBS-ZRACCT1.
      MODIFY GT_CNBS FROM GS_CNBS.
    ENDIF.

    R_RACCT-SIGN   = 'I'.
    R_RACCT-OPTION = 'BT'.
    R_RACCT-LOW  = GS_CNBS-ZRACCT1.
    R_RACCT-HIGH = GS_CNBS-ZRACCT2.
    APPEND R_RACCT.
  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form FRM_DEALDATA
*&---------------------------------------------------------------------*
*& 处理数据
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM FRM_DEALDATA .
  "计算非公式项目
  PERFORM FRM_DEALDATA_NY.

  "计算公式项目
  PERFORM FRM_DEALDATA_GY.

  "按左右项目统计
  PERFORM FRM_DEALDATA_ZY.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form FRM_DEALDATA_NY
*&---------------------------------------------------------------------*
*& 计算非公式项目
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM FRM_DEALDATA_NY .
  DATA: L_INDEX TYPE I.
  DATA: LV_DRCRK TYPE ACDOCA-DRCRK.
  "遍历所有非公式计算项目
  LOOP AT GT_CNBS INTO GS_CNBS WHERE FORMULA IS INITIAL.
    L_INDEX = SY-TABIX.

    "获取科目范围的金额，计入期间对应金额字段

*&------2017.12.20HANDZX修改(如果为S只累计DRCRK为S的值,如果为H只累计DRCRK为H的值，如果为空,则累计所有值)
    IF ( GS_CNBS-ZRACCT1 = '2202010101' AND  GS_CNBS-ZRACCT2 = '2202010101' ) OR
       ( GS_CNBS-ZRACCT1 = '1123010101' AND  GS_CNBS-ZRACCT2 = '1123010101' ) OR
       ( GS_CNBS-ZRACCT1 = '1122020101' AND  GS_CNBS-ZRACCT2 = '1122020101' ) OR
       ( GS_CNBS-ZRACCT1 = '1122010101' AND  GS_CNBS-ZRACCT2 = '1122010101' ) OR
       ( GS_CNBS-ZRACCT1 = '2203010101' AND  GS_CNBS-ZRACCT2 = '2203010101' ).
    ELSE.
      LOOP AT GT_ACDOCA INTO GS_ACDOCA WHERE RACCT BETWEEN GS_CNBS-ZRACCT1 AND GS_CNBS-ZRACCT2.
        "反向取值标识
        IF GS_CNBS-ZMARK = 'X'.
          GS_ACDOCA-HSL = 0 - GS_ACDOCA-HSL.
        ENDIF.
        "期间赋值
        IF GS_ACDOCA-GJAHR = P_GJAHR1 AND GS_ACDOCA-POPER IN R_POPER1.
          GS_ALV-HSLQJ1 = GS_ALV-HSLQJ1 + GS_ACDOCA-HSL.
        ENDIF.
        "比较期间赋值
        IF GS_ACDOCA-GJAHR = P_GJAHR2 AND GS_ACDOCA-POPER IN R_POPER2.
          GS_ALV-HSLBJ1 = GS_ALV-HSLBJ1 + GS_ACDOCA-HSL.
        ENDIF.
      ENDLOOP.
    ENDIF.

*    CLEAR LV_DRCRK.
*    LV_DRCRK = GS_CNBS-ZSHKZG.
*    IF LV_DRCRK IS INITIAL.
*      LOOP AT GT_ACDOCA INTO GS_ACDOCA WHERE RACCT BETWEEN GS_CNBS-ZRACCT1 AND GS_CNBS-ZRACCT2.
*        "反向取值标识
*        IF GS_CNBS-ZMARK = 'X'.
*          GS_ACDOCA-HSL = 0 - GS_ACDOCA-HSL.
*        ENDIF.
*        "期间赋值
*        IF GS_ACDOCA-GJAHR = P_GJAHR1 AND GS_ACDOCA-POPER IN R_POPER1.
*          GS_ALV-HSLQJ1 = GS_ALV-HSLQJ1 + GS_ACDOCA-HSL.
*        ENDIF.
*        "比较期间赋值
*        IF GS_ACDOCA-GJAHR = P_GJAHR2 AND GS_ACDOCA-POPER IN R_POPER2.
*          GS_ALV-HSLBJ1 = GS_ALV-HSLBJ1 + GS_ACDOCA-HSL.
*        ENDIF.
*      ENDLOOP.
*    ELSE.
*      LOOP AT GT_ACDOCA INTO GS_ACDOCA WHERE ( RACCT BETWEEN GS_CNBS-ZRACCT1 AND GS_CNBS-ZRACCT2 ) AND
*                                               DRCRK = LV_DRCRK.
*        "反向取值标识
*        IF GS_CNBS-ZMARK = 'X'.
*          GS_ACDOCA-HSL = 0 - GS_ACDOCA-HSL.
*        ENDIF.
*        "期间赋值
*        IF GS_ACDOCA-GJAHR = P_GJAHR1 AND GS_ACDOCA-POPER IN R_POPER1.
*          GS_ALV-HSLQJ1 = GS_ALV-HSLQJ1 + GS_ACDOCA-HSL.
*        ENDIF.
*        "比较期间赋值
*        IF GS_ACDOCA-GJAHR = P_GJAHR2 AND GS_ACDOCA-POPER IN R_POPER2.
*          GS_ALV-HSLBJ1 = GS_ALV-HSLBJ1 + GS_ACDOCA-HSL.
*        ENDIF.
*      ENDLOOP.
*    ENDIF.
    IF GS_CNBS-ZRACCT1 = '1122020101' AND  GS_CNBS-ZRACCT2 = '1122020101'.
      READ TABLE GT_RACCT INTO GS_RACCT WITH KEY RACCT = GS_CNBS-ZRACCT1 BINARY SEARCH.
      IF SY-SUBRC = 0.
        "反向取值标识
        IF GS_CNBS-ZMARK = 'X'.
          GS_ALV-HSLQJ1 = GS_ALV-HSLQJ1 + ( 0 - GS_RACCT-HSL ).
        ELSE.
          GS_ALV-HSLQJ1 = GS_ALV-HSLQJ1 + GS_RACCT-HSL.
        ENDIF.

      ENDIF.
      " 被比较
      READ TABLE GT_COM_RACCT INTO GS_COM_RACCT WITH KEY RACCT = GS_CNBS-ZRACCT1 BINARY SEARCH.
      IF SY-SUBRC = 0.
        "反向取值标识
        IF GS_CNBS-ZMARK = 'X'.
          GS_ALV-HSLBJ1 = GS_ALV-HSLBJ1 + ( 0 - GS_COM_RACCT-HSL ).
        ELSE.
          GS_ALV-HSLBJ1 = GS_ALV-HSLBJ1 + GS_COM_RACCT-HSL.
        ENDIF.
      ENDIF.
    ENDIF.
    IF GS_CNBS-ZRACCT1 = '1122010101' AND  GS_CNBS-ZRACCT2 = '1122010101'.
      READ TABLE GT_RACCT INTO GS_RACCT WITH KEY RACCT = GS_CNBS-ZRACCT1 BINARY SEARCH.
      IF SY-SUBRC = 0.
        "反向取值标识
        IF GS_CNBS-ZMARK = 'X'.
          GS_ALV-HSLQJ1 = GS_ALV-HSLQJ1 + ( 0 - GS_RACCT-HSL ).
        ELSE.
          GS_ALV-HSLQJ1 = GS_ALV-HSLQJ1 + GS_RACCT-HSL.
        ENDIF.

      ENDIF.
      " 被比较
      READ TABLE GT_COM_RACCT INTO GS_COM_RACCT WITH KEY RACCT = GS_CNBS-ZRACCT1 BINARY SEARCH.
      IF SY-SUBRC = 0.
        "反向取值标识
        IF GS_CNBS-ZMARK = 'X'.
          GS_ALV-HSLBJ1 = GS_ALV-HSLBJ1 + ( 0 - GS_COM_RACCT-HSL ).
        ELSE.
          GS_ALV-HSLBJ1 = GS_ALV-HSLBJ1 + GS_COM_RACCT-HSL.
        ENDIF.
      ENDIF.
    ENDIF.
    IF GS_CNBS-ZRACCT1 = '2203010101' AND  GS_CNBS-ZRACCT2 = '2203010101' .
      READ TABLE GT_RACCT INTO GS_RACCT WITH KEY RACCT = GS_CNBS-ZRACCT1 BINARY SEARCH.
      IF SY-SUBRC = 0.
        "反向取值标识
        IF GS_CNBS-ZMARK = 'X'.
          GS_ALV-HSLQJ1 = 0 - GS_RACCT-HSL.
        ELSE.
          GS_ALV-HSLQJ1 = GS_RACCT-HSL.
        ENDIF.

      ENDIF.
      " 被比较
      READ TABLE GT_COM_RACCT INTO GS_COM_RACCT WITH KEY RACCT = GS_CNBS-ZRACCT1 BINARY SEARCH.
      IF SY-SUBRC = 0.
        "反向取值标识
        IF GS_CNBS-ZMARK = 'X'.
          GS_ALV-HSLBJ1 = GS_ALV-HSLBJ1 + ( 0 - GS_COM_RACCT-HSL ).
        ELSE.
          GS_ALV-HSLBJ1 = GS_ALV-HSLBJ1 + GS_COM_RACCT-HSL.
        ENDIF.
      ENDIF.

    ENDIF.

    IF GS_CNBS-ZRACCT1 = '2202010101' AND  GS_CNBS-ZRACCT2 = '2202010101' .
      READ TABLE GT_RACCT2 INTO GS_RACCT2 WITH KEY RACCT = GS_CNBS-ZRACCT1 BINARY SEARCH.
      IF SY-SUBRC = 0.
        "反向取值标识
        IF GS_CNBS-ZMARK = 'X'.
          GS_ALV-HSLQJ1 =  GS_ALV-HSLQJ1 +  ( 0 - GS_RACCT2-HSL ).
        ELSE.
          GS_ALV-HSLQJ1 = GS_ALV-HSLQJ1 + GS_RACCT2-HSL.
        ENDIF.

      ENDIF.
      " 被比较
      READ TABLE GT_COM_RACCT2 INTO GS_COM_RACCT2 WITH KEY RACCT = GS_CNBS-ZRACCT1 BINARY SEARCH.
      IF SY-SUBRC = 0.
        "反向取值标识
        IF GS_CNBS-ZMARK = 'X'.
          GS_ALV-HSLBJ1 = GS_ALV-HSLBJ1 + ( 0 - GS_COM_RACCT2-HSL ).
        ELSE.
          GS_ALV-HSLBJ1 = GS_ALV-HSLBJ1 + GS_COM_RACCT2-HSL.
        ENDIF.
      ENDIF.

    ENDIF.
    IF GS_CNBS-ZRACCT1 = '1123010101' AND  GS_CNBS-ZRACCT2 = '1123010101' .
      READ TABLE GT_RACCT2 INTO GS_RACCT2 WITH KEY RACCT = GS_CNBS-ZRACCT1 BINARY SEARCH.
      IF SY-SUBRC = 0.
        "反向取值标识
        IF GS_CNBS-ZMARK = 'X'.
          GS_ALV-HSLQJ1 = ( 0 - GS_RACCT2-HSL ).
        ELSE.
          GS_ALV-HSLQJ1 =  GS_RACCT2-HSL.
        ENDIF.

      ENDIF.
      " 被比较
      READ TABLE GT_COM_RACCT2 INTO GS_COM_RACCT2 WITH KEY RACCT = GS_CNBS-ZRACCT1 BINARY SEARCH.
      IF SY-SUBRC = 0.
        "反向取值标识
        IF GS_CNBS-ZMARK = 'X'.
          GS_ALV-HSLBJ1 = GS_ALV-HSLBJ1 + ( 0 - GS_COM_RACCT2-HSL ).
        ELSE.
          GS_ALV-HSLBJ1 = GS_ALV-HSLBJ1 + GS_COM_RACCT2-HSL.
        ENDIF.
      ENDIF.

    ENDIF.
*&-------

    AT END OF ZITEM.
      "项目对应ALV行
      READ TABLE GT_CNBS INTO GS_CNBS INDEX L_INDEX.
      GS_ALV-ZITEM1 = GS_CNBS-ZITEM.
      GS_ALV-ZDECS1 = GS_CNBS-ZDECS.
      GS_ALV-ZSIDE = GS_CNBS-ZSIDE.
      APPEND GS_ALV TO GT_ALV.
      CLEAR GS_ALV.
    ENDAT.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form FRM_DEALDATA_GY
*&---------------------------------------------------------------------*
*& 计算公式项目
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM FRM_DEALDATA_GY .
  DATA: L_INDEX    TYPE I,
        L_LEN      TYPE I,
        L_YGONS(4) TYPE C,
        L_SFLG     TYPE I,
        L_MON(2)   TYPE N.

  DATA: LS_ALV LIKE GS_ALV.

  "遍历所有公式计算项目
  LOOP AT GT_CNBS INTO GS_CNBS WHERE FORMULA IS NOT INITIAL.
    L_INDEX = SY-TABIX.
    CLEAR:L_LEN.

    "公式处理：4位一个字段如+002
    L_YGONS = GS_CNBS-FORMULA+L_LEN(4).
    WHILE L_YGONS IS NOT INITIAL.
      "加减符号
      IF L_YGONS+0(1) = '-'.
        L_SFLG = -1.
      ELSE.
        L_SFLG = 1.
      ENDIF.

      "获取行号对应的ALV值
      READ TABLE GT_ALV INTO LS_ALV WITH KEY ZITEM1 = L_YGONS+1(3).
      IF SY-SUBRC = 0.
        "期间、比较赋值
        GS_ALV-HSLQJ1 = GS_ALV-HSLQJ1 + LS_ALV-HSLQJ1 * L_SFLG.
        GS_ALV-HSLBJ1 = GS_ALV-HSLBJ1 + LS_ALV-HSLBJ1 * L_SFLG.
      ENDIF.

      L_LEN = L_LEN + 4.
      L_YGONS = GS_CNBS-FORMULA+L_LEN(4).
    ENDWHILE.

    AT END OF ZITEM.
      "项目对应ALV行
      READ TABLE GT_CNBS INTO GS_CNBS INDEX L_INDEX.
      GS_ALV-ZITEM1 = GS_CNBS-ZITEM.
      GS_ALV-ZDECS1 = GS_CNBS-ZDECS.
      GS_ALV-ZSIDE = GS_CNBS-ZSIDE.
      APPEND GS_ALV TO GT_ALV.
      CLEAR GS_ALV.
    ENDAT.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form FRM_DEALDATA_ZY
*&---------------------------------------------------------------------*
*& 按左右项目统计
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM FRM_DEALDATA_ZY .
  DATA: LS_ALV LIKE GS_ALV,
        LT_ALV LIKE TABLE OF GS_ALV.

  DATA: L_INDEX TYPE I.

  "排序
  SORT: GT_ALV BY ZITEM1.

  "内表差分成左右
  LT_ALV = GT_ALV.
  DELETE: GT_ALV WHERE ZSIDE <> 'L',
          LT_ALV WHERE ZSIDE = 'L'.

  "根据左边记录更新右边的值
  LOOP AT GT_ALV INTO GS_ALV.
    L_INDEX = SY-TABIX.
    READ TABLE LT_ALV INTO LS_ALV INDEX L_INDEX.
    IF SY-SUBRC = 0.
      GS_ALV-ZITEM2 = LS_ALV-ZITEM1.
      GS_ALV-ZDECS2 = LS_ALV-ZDECS1.
      GS_ALV-HSLQJ2 = LS_ALV-HSLQJ1.
      GS_ALV-HSLBJ2 = LS_ALV-HSLBJ1.
      MODIFY GT_ALV FROM GS_ALV.
    ENDIF.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form FRM_WRITE
*&---------------------------------------------------------------------*
*& 输出数据
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM FRM_WRITE .
  "输出模式
  PERFORM FRM_LAYOUT_BUILD.
  "输出结构
  PERFORM FRM_INIT_FIELDCAT.
  "数据输出
  PERFORM FRM_LISTADO.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form FRM_LAYOUT_BUILD
*&---------------------------------------------------------------------*
*& 输出模式
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM FRM_LAYOUT_BUILD .
  GS_LAYOUT-ZEBRA      = 'X'. "Zebra marking
  GS_LAYOUT-CWIDTH_OPT = 'X'. "Automatically adjust ALV column width
ENDFORM.
*&---------------------------------------------------------------------*
*& Form FRM_INIT_FIELDCAT
*&---------------------------------------------------------------------*
*& 输出结构
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM FRM_INIT_FIELDCAT .
  CLEAR:GS_FIELDCAT.

  DATA: L_TEXT(8)  TYPE C.

  IF P_POPER2 IS INITIAL.
    L_TEXT = '年初余额'.
  ELSE.
    L_TEXT = '比较余额'.
  ENDIF.

  FIELDCAT: 'ZDECS1'   '项目'     '',
            'ZITEM1'   '行号'     '',
            'HSLQJ1'   '期末余额' '',
            'HSLBJ1'   L_TEXT    '',
            'ZDECS2'   '项目'     '',
            'ZITEM2'   '行号'     '',
            'HSLQJ2'   '期末余额' '',
            'HSLBJ2'   L_TEXT    ''.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form FRM_LISTADO
*&---------------------------------------------------------------------*
*& 数据输出
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM FRM_LISTADO .
*调用alv显示函数        Call alv display function
  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY_LVC'
    EXPORTING
      I_CALLBACK_PROGRAM          = SY-REPID
      I_CALLBACK_PF_STATUS_SET    = 'FRM_SET_STATUS'
      I_CALLBACK_HTML_TOP_OF_PAGE = 'FRM_HTML_TOP_OF_PAGE'
      I_CALLBACK_USER_COMMAND     = 'FRM_USER_COMMAND'
      IS_LAYOUT_LVC               = GS_LAYOUT
      IT_FIELDCAT_LVC             = GT_FIELDCAT
      I_HTML_HEIGHT_TOP           = 30
      I_SAVE                      = 'A'
    TABLES
      T_OUTTAB                    = GT_ALV
    EXCEPTIONS
      PROGRAM_ERROR               = 1
      OTHERS                      = 2.
*  System Message
  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
           WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  FRM_SET_STATUS
*&---------------------------------------------------------------------*
*  Set the alv status bar
*----------------------------------------------------------------------*
FORM FRM_SET_STATUS USING RT_EXTAB TYPE SLIS_T_EXTAB.
  SET PF-STATUS 'STATUS' EXCLUDING RT_EXTAB.
ENDFORM.                   "FRM_SET_STATUS
*&---------------------------------------------------------------------*
*&      Form  FRM_HTML_TOP_OF_PAGE
*&---------------------------------------------------------------------*
*  Headers to set
*----------------------------------------------------------------------*
*      -->PR_DOCUMENT  text
*----------------------------------------------------------------------*
FORM FRM_HTML_TOP_OF_PAGE USING PR_DOCUMENT TYPE REF TO CL_DD_DOCUMENT.
  DATA: BEGIN OF LS_T001,
          WAERS TYPE T001-WAERS,
          BUTXT TYPE T001-BUTXT,
        END OF LS_T001.

*类型转换     Type conversion
  DATA: L_CURRENCY TYPE SDYDO_TEXT_ELEMENT, "Currency
        L_COMPANY  TYPE SDYDO_TEXT_ELEMENT, "Company
        L_PROGROUP TYPE SDYDO_TEXT_ELEMENT, "Profit Center Group
        L_PROCENTE TYPE SDYDO_TEXT_ELEMENT, "Profit Center
        L_DATE     TYPE SDYDO_TEXT_ELEMENT. "Date

*获取币种和公司地址
* Access to currency and company address
  SELECT  WAERS
          BUTXT
    FROM T001
    INTO LS_T001
    WHERE BUKRS IN S_BUKRS.
    "多公司代码时，串联显示
    IF L_COMPANY IS INITIAL.
      GV_CURRENCY = LS_T001-WAERS.
      GV_COMPANY  = LS_T001-BUTXT.
    ELSE.
      CONCATENATE GV_CURRENCY LS_T001-WAERS INTO GV_CURRENCY SEPARATED BY '/'.
      CONCATENATE GV_COMPANY LS_T001-BUTXT INTO GV_COMPANY SEPARATED BY '/'.
    ENDIF.
  ENDSELECT.

*利润中心组
  IF S_KHINR IS NOT INITIAL.
    SELECT SINGLE DESCRIPT
      FROM SETHEADERT
      INTO GV_PROGROUP
      WHERE SETHEADERT~SETCLASS = '0106'
      AND SETHEADERT~LANGU = SY-LANGU
      AND SETHEADERT~SETNAME IN S_KHINR.
  ELSE.
    GV_PROGROUP = '*'.
  ENDIF.

*利润中心
  IF S_PRCTR IS NOT INITIAL.
    SELECT SINGLE KTEXT
      FROM CEPCT
      INTO GV_PROCENTE
      WHERE PRCTR IN S_PRCTR
       AND  SPRAS = SY-LANGU.
  ELSE.
    GV_PROCENTE = '*'.
  ENDIF.

  "截止日期
  CONCATENATE P_GJAHR1 P_POPER1+1(2) '01' INTO GV_DATE.
  "获取当月最后一天
  CALL FUNCTION 'LAST_DAY_OF_MONTHS'
    EXPORTING
      DAY_IN            = GV_DATE "Entry Date
    IMPORTING
      LAST_DAY_OF_MONTH = GV_DATE "Return Date
    EXCEPTIONS
      DAY_IN_NO_DATE    = 1
      OTHERS            = 2.
  IF SY-SUBRC <> 0.
    MESSAGE S010(ZFICO).
  ENDIF.

*添加标题            Add a title
  DATA: LV_POSITION TYPE I,
        LV_BUFFER   TYPE STRING.
  CONCATENATE  '<HTML><CENTER><H1>' TEXT-003 '</H1></CENTER></HTML>' INTO LV_BUFFER.

  CALL METHOD PR_DOCUMENT->HTML_INSERT
    EXPORTING
      CONTENTS = LV_BUFFER
    CHANGING
      POSITION = LV_POSITION.

  "赋值临时变量
  L_COMPANY = GV_COMPANY.
  L_CURRENCY = GV_CURRENCY.
  L_PROGROUP = GV_PROGROUP.
  L_PROCENTE = GV_PROCENTE.
  L_DATE = GV_DATE.

  "插入抬头文本
  G_DOCUMENT = PR_DOCUMENT.
  PERFORM FRM_DOCUMENT_ADD_TEXT USING: TEXT-004 L_COMPANY,
                                       TEXT-005 L_CURRENCY,
                                       TEXT-006 L_PROCENTE,
                                       TEXT-007 L_PROGROUP,
                                       TEXT-008 L_DATE.

  PR_DOCUMENT = G_DOCUMENT.
  FREE G_DOCUMENT.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  FRM_USER_COMMAND
*&---------------------------------------------------------------------*
*       BOTTON USER_COMMAND
*----------------------------------------------------------------------*
*      -->R_UCOMM      text
*      -->RS_SELFIELD  text
*----------------------------------------------------------------------*
FORM FRM_USER_COMMAND USING R_UCOMM LIKE SY-UCOMM
                      RS_SELFIELD TYPE SLIS_SELFIELD.

  CASE R_UCOMM.
    WHEN 'DOWN'.
      PERFORM  FRM_DOWNLOAD_TEMPLATE.
  ENDCASE.
  RS_SELFIELD-COL_STABLE = 'X'.
  RS_SELFIELD-ROW_STABLE = 'X'.
  RS_SELFIELD-REFRESH    = 'X'.
  "PERFORM FRM_REFRESH_ALV.
ENDFORM.                    "FRM_USER_COMMAND
*&---------------------------------------------------------------------*
*& Form FRM_DOCUMENT_ADD_TEXT
*&---------------------------------------------------------------------*
*& 插入抬头文本
*&---------------------------------------------------------------------*
*      -->P_L_TEXT  text
*      -->P_L_VALUE  text
*&---------------------------------------------------------------------*
FORM FRM_DOCUMENT_ADD_TEXT  USING    P_L_TEXT
                                     P_L_VALUE.

  "名称
  CALL METHOD G_DOCUMENT->ADD_TEXT
    EXPORTING
      TEXT          = P_L_TEXT
      SAP_FONTSTYLE = CL_DD_DOCUMENT=>MEDIUM.
  "空格
  CALL METHOD G_DOCUMENT->ADD_GAP
    EXPORTING
      WIDTH = 1.
  "值
  CALL METHOD G_DOCUMENT->ADD_TEXT
    EXPORTING
      TEXT         = P_L_VALUE
      SAP_FONTSIZE = G_DOCUMENT->MEDIUM.
  "新行
  CALL METHOD G_DOCUMENT->NEW_LINE.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  FRM_DOWNLOAD_TEMPLATE
*&---------------------------------------------------------------------*
*       下载模板
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM FRM_DOWNLOAD_TEMPLATE .
  PERFORM FRM_GET_DOWNLOAD_PATH."取得保存的路径名
  PERFORM FRM_CREATE_DOI.
  PERFORM FRM_CREATE_DOCUMENT ."创建document
  PERFORM FRM_OPERATE_DOCUMENT."关闭文件
  PERFORM FRM_WRITE_DATA_TO_EXCEL.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  FRM_GET_DOWNLOAD_PATH
*&---------------------------------------------------------------------*
* 获取保存excel的路径名
*----------------------------------------------------------------------*
FORM FRM_GET_DOWNLOAD_PATH .
  "获得要保存文件的路径名
  CALL METHOD CL_GUI_FRONTEND_SERVICES=>FILE_SAVE_DIALOG
    EXPORTING
      WINDOW_TITLE         = '请选择路径'
      DEFAULT_FILE_NAME    = G_DEF_NAME
      FILE_FILTER          = 'Excel文件(*.xls)|*.xls|Excel工作薄(*.xlsx)|*.xlsx|'
    CHANGING
      FILENAME             = G_FILENAME
      PATH                 = G_PATH
      FULLPATH             = G_FULLPATH
      USER_ACTION          = G_USER_ACTION
    EXCEPTIONS
      CNTL_ERROR           = 1
      ERROR_NO_GUI         = 2
      NOT_SUPPORTED_BY_GUI = 3
      OTHERS               = 4.
  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
               WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

  IF G_USER_ACTION = 9.
*    取消操作
*    MESSAGE e004 DISPLAY LIKE 'S'.
  ENDIF.
*    下载路径名
  G_FILE_NAME = G_FULLPATH.
ENDFORM. " FRM_GET_DOWNLOAD_PATH

*&---------------------------------------------------------------------*
*&      Form  FRM_CREATE_DOI
*&---------------------------------------------------------------------*
*  创建DOI实例，并获取模板的路径
*----------------------------------------------------------------------*
FORM FRM_CREATE_DOI .
  DATA:
    LT_SIGNATURE TYPE SBDST_SIGNATURE WITH HEADER LINE, "存放signature属性的内表
    LT_URIS      TYPE SBDST_URI WITH HEADER LINE. "模板路径

*  创建CONTROL
  CALL METHOD C_OI_CONTAINER_CONTROL_CREATOR=>GET_CONTAINER_CONTROL
    IMPORTING
      CONTROL = GCL_CONTROL
      ERROR   = GCL_ERRORS.
  APPEND GCL_ERRORS.

*  初始化CONTROL
  CALL METHOD GCL_CONTROL->INIT_CONTROL
    EXPORTING
      R3_APPLICATION_NAME = ''
      INPLACE_ENABLED     = CONS_INPLACE                      "决定是否在GUi中打开，还是在windows中打开
      PARENT              = GCL_CONTAINER                  "EXCEL存放的容器，此处为空，未创建
      NO_FLUSH            = ''
    IMPORTING
      ERROR               = GCL_ERRORS.
  APPEND GCL_ERRORS.

*  用来确定节点下的EXCEL模板
  LT_SIGNATURE-PROP_NAME = 'DESCRIPTION'.                   "signature中的DESCRIPTION属性
  LT_SIGNATURE-PROP_VALUE = G_PROP_VALUE.                       "DESCRIPTION属性的值
  APPEND LT_SIGNATURE.
*  创建BDS实例
  CREATE OBJECT GCL_BDS_INSTANCE.
*  得到模板的URL
  CALL METHOD GCL_BDS_INSTANCE->GET_WITH_URL
    EXPORTING
      CLASSNAME  = G_DOC_CLASSNAME
      CLASSTYPE  = G_DOC_CLASSTYPE
      OBJECT_KEY = G_DOC_OBJECT_KEY
    CHANGING
      URIS       = LT_URIS[]
      SIGNATURE  = LT_SIGNATURE[].
*  释放BDC实例
  FREE GCL_BDS_INSTANCE.
*  保存EXCEL模板的URL到变量中
  READ TABLE LT_URIS INDEX 1.
  G_ITEM_URL = LT_URIS-URI.
ENDFORM. " FRM_CREATE_DOI

*&---------------------------------------------------------------------*
*&      Form  FRM_CREATE_DOCUMENT
*&---------------------------------------------------------------------*
*       创建i_oi_document_proxy实例
*----------------------------------------------------------------------*
FORM FRM_CREATE_DOCUMENT .
  "创建i_oi_document_proxy实例，类型为EXCEL
  CALL METHOD GCL_CONTROL->GET_DOCUMENT_PROXY
    EXPORTING
      DOCUMENT_TYPE  = CONS_EXCEL
      NO_FLUSH       = ''
    IMPORTING
      DOCUMENT_PROXY = GCL_DOCUMENT
      ERROR          = GCL_ERRORS.

  CALL METHOD GCL_ERRORS->RAISE_MESSAGE
    EXPORTING
      TYPE = 'E'.
  FREE GCL_ERRORS.
ENDFORM. " FRM_CREATE_DOCUMENT

*&---------------------------------------------------------------------*
*&      Form  FRM_OPERATE_DOCUMENT
*&---------------------------------------------------------------------*
*       关闭文件
*----------------------------------------------------------------------*
FORM FRM_OPERATE_DOCUMENT .
  "根据获取的URL打开BDS上面对应的文件
  CALL METHOD GCL_DOCUMENT->OPEN_DOCUMENT
    EXPORTING
      OPEN_INPLACE = CONS_INPLACE
      DOCUMENT_URL = G_ITEM_URL
    IMPORTING
      ERROR        = GCL_ERRORS.

  CALL METHOD GCL_ERRORS->RAISE_MESSAGE
    EXPORTING
      TYPE = 'E'.
  FREE GCL_ERRORS.

*&-------OPEN FILE
  CALL METHOD GCL_DOCUMENT->OPEN_DOCUMENT
    EXPORTING
      OPEN_INPLACE = CONS_INPLACE
      DOCUMENT_URL = G_ITEM_URL.

  CALL METHOD GCL_ERRORS->RAISE_MESSAGE
    EXPORTING
      TYPE = 'E'.
  FREE GCL_ERRORS.

  CALL METHOD GCL_DOCUMENT->GET_SPREADSHEET_INTERFACE
    EXPORTING
      NO_FLUSH        = 'X'
    IMPORTING
      SHEET_INTERFACE = GR_SPREADSHEET.

  CALL METHOD GR_SPREADSHEET->SELECT_SHEET
    EXPORTING
      NAME     = 'Sheet1'
      NO_FLUSH = 'X'.
ENDFORM. " FRM_OPERATE_DOCUMENT
*&---------------------------------------------------------------------*
*&      Form  FRM_WRITE_DATA_TO_EXCEL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM FRM_WRITE_DATA_TO_EXCEL .
* 行项目信息填写sheet
  PERFORM FRM_FILL_CELL_ALL.
* 头信息（公司代码等）填写sheet
  PERFORM FRM_FILL_CELL_HEAD.
* 头信息（货币等）填写sheet
  PERFORM FRM_FILL_CELL_HEAD2.
* 头信息（日期等）填写sheet
  PERFORM FRM_FILL_CELL_HEAD3.

*&-------保存文件到本地
  CALL METHOD GCL_DOCUMENT->SAVE_AS
    EXPORTING
      FILE_NAME = G_FILE_NAME
      NO_FLUSH  = ''
    IMPORTING
      ERROR     = GCL_ERRORS
      RETCODE   = G_RETCODE.

  CALL METHOD GCL_ERRORS->RAISE_MESSAGE
    EXPORTING
      TYPE = 'E'.
  FREE GCL_ERRORS.

*&-------  关闭文件
  CALL METHOD GCL_DOCUMENT->CLOSE_DOCUMENT
    EXPORTING
      DO_SAVE = ''
    IMPORTING
      ERROR   = GCL_ERRORS
      RETCODE = G_RETCODE.

  CALL METHOD GCL_ERRORS->RAISE_MESSAGE
    EXPORTING
      TYPE = 'E'.
  FREE GCL_ERRORS.
  MESSAGE '数据模板下载成功！' TYPE 'S'.
ENDFORM.


*&---------------------------------------------------------------------*
*&      Form  read_itab_structure
*&---------------------------------------------------------------------*
*       get internal number of rows and number of columns of itab
*----------------------------------------------------------------------*
FORM READ_ITAB_STRUCTURE USING P_TABNAME P_ROWCOUNT P_COLCOUNT.

  DATA: L_ROWCOUNT TYPE I,
        L_COLCOUNT TYPE I.

  FIELD-SYMBOLS: <FS1>.
  DATA: LS_ALV LIKE LINE OF GT_ALV.

* Line count
  DESCRIBE TABLE GT_ALV LINES L_ROWCOUNT.

* Row count
  DO.
    ASSIGN COMPONENT SY-INDEX OF STRUCTURE LS_ALV TO <FS1>.
    IF SY-SUBRC IS INITIAL.
      L_COLCOUNT = L_COLCOUNT + 1.
    ELSE.
      EXIT.
    ENDIF.
  ENDDO.

  P_ROWCOUNT = L_ROWCOUNT.
  P_COLCOUNT = L_COLCOUNT.

ENDFORM.                    "read_itab_structure


FORM FILL_CELL_01  USING I J VAL.
  DATA: COLUMNS_NUMBER TYPE I,
        ROWS_NUMBER    TYPE I.
  ROWS_NUMBER = 1.
  COLUMNS_NUMBER = 1.
  CALL METHOD GR_SPREADSHEET->INSERT_RANGE_DIM
    EXPORTING
      NAME     = 'cell'
      NO_FLUSH = 'X'
      TOP      = I
      LEFT     = J
      ROWS     = ROWS_NUMBER
      COLUMNS  = COLUMNS_NUMBER
    IMPORTING
      ERROR    = GCL_ERRORS.
  APPEND GCL_ERRORS.
  REFRESH: RANGES, EXCEL_INPUT.
  RANGEITEM-NAME = 'cell'.
  RANGEITEM-COLUMNS = 1.
  RANGEITEM-ROWS = 1.
  APPEND RANGEITEM TO RANGES.

  EXCEL_INPUT_WA-COLUMN = 1.
  EXCEL_INPUT_WA-ROW = 1.
  EXCEL_INPUT_WA-VALUE = VAL.
  APPEND EXCEL_INPUT_WA TO EXCEL_INPUT.

  CALL METHOD GR_SPREADSHEET->SET_RANGES_DATA
    EXPORTING
      RANGES   = RANGES
      CONTENTS = EXCEL_INPUT
      NO_FLUSH = 'X'
    IMPORTING
      ERROR    = GCL_ERRORS.
  APPEND GCL_ERRORS.

*  CALL METHOD GR_SPREADSHEET->FIT_WIDEST
*    EXPORTING
*      NAME     = SPACE
*      NO_FLUSH = 'X'.

ENDFORM.


FORM FRM_FILL_CELL_ALL .
  DATA LV_TEXT TYPE C LENGTH 25.
  DEFINE WRITE_CONTENT_CELL.
    gs_content-row = &1.
    gs_content-column = &2.
    gs_content-value = &3.
    APPEND gs_content TO gt_contents.
    CLEAR gs_content.
  END-OF-DEFINITION.
  DATA: LINE_COUNT TYPE I VALUE 0,
        COL_COUNT  TYPE I VALUE 0.
  DATA: LV_ROW     TYPE I VALUE 1.
  CHECK NOT GT_ALV IS INITIAL.

  REFRESH:GT_RANGES,GT_CONTENTS.

* 获取内表的行列数
  PERFORM READ_ITAB_STRUCTURE USING 'GT_ALV' LINE_COUNT COL_COUNT.

  COL_COUNT = 8.
  CALL METHOD GR_SPREADSHEET->INSERT_RANGE_DIM
    EXPORTING
      NAME     = 'cell'
      NO_FLUSH = 'X'
      TOP      = 7
      LEFT     = 1
      ROWS     = LINE_COUNT
      COLUMNS  = COL_COUNT.

  CLEAR GS_RANGE.
  CLEAR GT_RANGES[].
  GS_RANGE-NAME = 'cell'.
  GS_RANGE-ROWS = LINE_COUNT.
  GS_RANGE-COLUMNS = COL_COUNT.
  GS_RANGE-CODE = 8.
  APPEND GS_RANGE TO GT_RANGES.

  LOOP AT GT_ALV INTO GS_ALV.
    CLEAR GS_CONTENT.
    WRITE_CONTENT_CELL LV_ROW 1 GS_ALV-ZDECS1.
    WRITE_CONTENT_CELL LV_ROW 2 GS_ALV-ZITEM1.
    "金额转换字符串
    WRITE GS_ALV-HSLQJ1 CURRENCY 'CNY' TO LV_TEXT.
    "负号前置
    CALL FUNCTION 'CLOI_PUT_SIGN_IN_FRONT'
      CHANGING
        VALUE = LV_TEXT.
    WRITE_CONTENT_CELL LV_ROW 3 LV_TEXT.
    "金额转换字符串
    WRITE GS_ALV-HSLBJ1 CURRENCY 'CNY' TO LV_TEXT.
    "负号前置
    CALL FUNCTION 'CLOI_PUT_SIGN_IN_FRONT'
      CHANGING
        VALUE = LV_TEXT.
    WRITE_CONTENT_CELL LV_ROW 4 LV_TEXT.
    WRITE_CONTENT_CELL LV_ROW 5 GS_ALV-ZDECS2.
    WRITE_CONTENT_CELL LV_ROW 6 GS_ALV-ZITEM2.
    "金额转换字符串
    WRITE GS_ALV-HSLQJ2 CURRENCY 'CNY' TO LV_TEXT.
    "负号前置
    CALL FUNCTION 'CLOI_PUT_SIGN_IN_FRONT'
      CHANGING
        VALUE = LV_TEXT.
    WRITE_CONTENT_CELL LV_ROW 7 LV_TEXT.
    "金额转换字符串
    WRITE GS_ALV-HSLBJ2 CURRENCY 'CNY' TO LV_TEXT.
    "负号前置
    CALL FUNCTION 'CLOI_PUT_SIGN_IN_FRONT'
      CHANGING
        VALUE = LV_TEXT.
    WRITE_CONTENT_CELL LV_ROW 8 LV_TEXT.
    LV_ROW = LV_ROW + 1.
  ENDLOOP.

  CALL METHOD GR_SPREADSHEET->SET_RANGES_DATA
    EXPORTING
      RANGES   = GT_RANGES
      CONTENTS = GT_CONTENTS
      NO_FLUSH = 'X'
    IMPORTING
      ERROR    = GCL_ERRORS.
  APPEND GCL_ERRORS.

*  CALL METHOD GR_SPREADSHEET->FIT_WIDEST
*    EXPORTING
*      NAME     = SPACE
*      NO_FLUSH = 'X'.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form FRM_FILL_CELL_HEAD
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM FRM_FILL_CELL_HEAD .
  DATA LV_TEXT TYPE C LENGTH 30.

  DATA: COLUMNS_NUMBER TYPE I,
        ROWS_NUMBER    TYPE I.

  ROWS_NUMBER = 3.
  COLUMNS_NUMBER = 1.
  CALL METHOD GR_SPREADSHEET->INSERT_RANGE_DIM
    EXPORTING
      NAME     = 'cell'
      NO_FLUSH = 'X'
      TOP      = 2
      LEFT     = 1
      ROWS     = ROWS_NUMBER
      COLUMNS  = COLUMNS_NUMBER
    IMPORTING
      ERROR    = GCL_ERRORS.
  APPEND GCL_ERRORS.
  REFRESH: RANGES, EXCEL_INPUT.
  RANGEITEM-NAME = 'cell'.
  RANGEITEM-COLUMNS = COLUMNS_NUMBER.
  RANGEITEM-ROWS = ROWS_NUMBER.
  APPEND RANGEITEM TO RANGES.

  EXCEL_INPUT_WA-ROW = 1.
  EXCEL_INPUT_WA-COLUMN = 1.
  CONCATENATE '公司代码：' GV_COMPANY INTO LV_TEXT.
  EXCEL_INPUT_WA-VALUE = LV_TEXT.
  APPEND EXCEL_INPUT_WA TO EXCEL_INPUT.

  EXCEL_INPUT_WA-ROW = 2.
  EXCEL_INPUT_WA-COLUMN = 1.
  CONCATENATE '利润中心：' GV_PROCENTE INTO LV_TEXT.
  EXCEL_INPUT_WA-VALUE = LV_TEXT.
  APPEND EXCEL_INPUT_WA TO EXCEL_INPUT.

  EXCEL_INPUT_WA-ROW = 3.
  EXCEL_INPUT_WA-COLUMN = 1.
  CONCATENATE '利润中心组：' GV_PROGROUP INTO LV_TEXT.
  EXCEL_INPUT_WA-VALUE = LV_TEXT.
  APPEND EXCEL_INPUT_WA TO EXCEL_INPUT.

  CALL METHOD GR_SPREADSHEET->SET_RANGES_DATA
    EXPORTING
      RANGES   = RANGES
      CONTENTS = EXCEL_INPUT
      NO_FLUSH = 'X'
    IMPORTING
      ERROR    = GCL_ERRORS.
  APPEND GCL_ERRORS.

*  CALL METHOD GR_SPREADSHEET->FIT_WIDEST
*    EXPORTING
*      NAME     = SPACE
*      NO_FLUSH = 'X'.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form FRM_FILL_CELL_HEAD2
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM FRM_FILL_CELL_HEAD2 .
  DATA LV_TEXT TYPE C LENGTH 30.

  DATA: COLUMNS_NUMBER TYPE I,
        ROWS_NUMBER    TYPE I.

  REFRESH: RANGES, EXCEL_INPUT.

  ROWS_NUMBER = 1.
  COLUMNS_NUMBER = 1.
  CALL METHOD GR_SPREADSHEET->INSERT_RANGE_DIM
    EXPORTING
      NAME     = 'cell'
      NO_FLUSH = 'X'
      TOP      = 3
      LEFT     = 7
      ROWS     = ROWS_NUMBER
      COLUMNS  = COLUMNS_NUMBER
    IMPORTING
      ERROR    = GCL_ERRORS.
  APPEND GCL_ERRORS.

  RANGEITEM-NAME = 'cell'.
  RANGEITEM-COLUMNS = COLUMNS_NUMBER.
  RANGEITEM-ROWS = ROWS_NUMBER.
  "RANGEITEM-CODE = 2.
  APPEND RANGEITEM TO RANGES.

  EXCEL_INPUT_WA-ROW = 1.
  EXCEL_INPUT_WA-COLUMN = 1.
  CONCATENATE '货币：' GV_CURRENCY INTO LV_TEXT.
  EXCEL_INPUT_WA-VALUE = LV_TEXT.
  APPEND EXCEL_INPUT_WA TO EXCEL_INPUT.

  CALL METHOD GR_SPREADSHEET->SET_RANGES_DATA
    EXPORTING
      RANGES   = RANGES
      CONTENTS = EXCEL_INPUT
      NO_FLUSH = 'X'
    IMPORTING
      ERROR    = GCL_ERRORS.
  APPEND GCL_ERRORS.

*  CALL METHOD GR_SPREADSHEET->FIT_WIDEST
*    EXPORTING
*      NAME     = SPACE
*      NO_FLUSH = 'X'. GV_DATE
ENDFORM.
*&---------------------------------------------------------------------*
*& Form FRM_FILL_CELL_HEAD3
*&---------------------------------------------------------------------*
*& 头信息（日期等）填写sheet
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM FRM_FILL_CELL_HEAD3 .
  DATA LV_TEXT TYPE C LENGTH 30.

  DATA: COLUMNS_NUMBER TYPE I,
        ROWS_NUMBER    TYPE I.

  REFRESH: RANGES, EXCEL_INPUT.

  ROWS_NUMBER = 1.
  COLUMNS_NUMBER = 1.
  CALL METHOD GR_SPREADSHEET->INSERT_RANGE_DIM
    EXPORTING
      NAME     = 'cell'
      NO_FLUSH = 'X'
      TOP      = 4
      LEFT     = 7
      ROWS     = ROWS_NUMBER
      COLUMNS  = COLUMNS_NUMBER
    IMPORTING
      ERROR    = GCL_ERRORS.
  APPEND GCL_ERRORS.

  RANGEITEM-NAME = 'cell'.
  RANGEITEM-COLUMNS = COLUMNS_NUMBER.
  RANGEITEM-ROWS = ROWS_NUMBER.
  "RANGEITEM-CODE = 2.
  APPEND RANGEITEM TO RANGES.

  EXCEL_INPUT_WA-ROW = 1.
  EXCEL_INPUT_WA-COLUMN = 1.
  CONCATENATE GV_DATE+0(4) '年'  GV_DATE+4(2) '月' GV_DATE+6(2) '日' INTO LV_TEXT.
  EXCEL_INPUT_WA-VALUE = LV_TEXT.
  APPEND EXCEL_INPUT_WA TO EXCEL_INPUT.

  CALL METHOD GR_SPREADSHEET->SET_RANGES_DATA
    EXPORTING
      RANGES   = RANGES
      CONTENTS = EXCEL_INPUT
      NO_FLUSH = 'X'
    IMPORTING
      ERROR    = GCL_ERRORS.
  APPEND GCL_ERRORS.
ENDFORM.
