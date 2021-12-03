*&---------------------------------------------------------------------*
*& Report ZMMB050
*&---------------------------------------------------------------------*
*& zmm001程序修改导入模板为.XLSX类型文件,
*& 修改物料时增加物料号长度检测(必须10位)
*&开发日期: 2021-09-14
*&---------------------------------------------------------------------*
REPORT ZMMB050.

*----------------------------------------------------------------------*
*BAPI参数
*----------------------------------------------------------------------*
DATA:material_number TYPE STANDARD TABLE OF bapimatinr WITH HEADER LINE,
     return          TYPE bapireturn1.
DATA:lv_matnr TYPE thead-tdname.

DATA:i_filename TYPE rlgrap-filename .
DATA:filename   TYPE string   .
DATA:itab TYPE STANDARD TABLE OF alsmex_tabline WITH HEADER LINE  .

DATA:headdata             TYPE bapimathead,  "表头数据

     clientdata           TYPE bapi_mara,    "基本数据
     clientdatax          TYPE bapi_marax,
     plantdata            TYPE bapi_marc,    "工厂级别数据
     plantdatax           TYPE bapi_marcx,
     storagelocationdata  TYPE bapi_mard,
     storagelocationdatax TYPE bapi_mardx,
     salesdata            TYPE bapi_mvke,    "销售数据
     salesdatax           TYPE bapi_mvkex,

     valuationdata        TYPE bapi_mbew,    "评估数据
     valuationdatax       TYPE bapi_mbewx,

     return2              TYPE bapiret2.     "返回消息

DATA:materialdescription    TYPE STANDARD TABLE OF bapi_makt,
     wa_materialdescription TYPE bapi_makt.

DATA:taxclassifications    TYPE STANDARD TABLE OF bapi_mlan,
     wa_taxclassifications TYPE bapi_mlan.

DATA:returnmessages    TYPE STANDARD TABLE OF bapi_matreturn2,
     wa_returnmessages TYPE bapi_matreturn2.

DATA: flines TYPE STANDARD TABLE OF tline WITH HEADER LINE.


*----------------------------------------------------------------------*
* ALV参数声明
*----------------------------------------------------------------------*
DATA:it_fieldcat TYPE lvc_t_fcat, " 字段目录内表
     wa_fieldcat TYPE lvc_s_fcat, " 字段目录工作区
     layout      TYPE lvc_s_layo. " ALV布局

*----------------------------------------------------------------------*
*数据类型和数据对象声明
*----------------------------------------------------------------------*
TYPES:BEGIN OF ty_up,
        matnr  TYPE mara-matnr,  " 物料号
        werks  TYPE marc-werks,  " 工厂
        mtart  TYPE mara-mtart,  " 物料类型

*-------------------------基础视图-------------------------------------*
        maktx  TYPE makt-maktx,     " 物料描述
        bismt  TYPE mara-bismt,     " 旧物料号(易飞系统料号)
        matkl  TYPE mara-matkl,     " 物料组
        extwg  TYPE mara-extwg,     " 外部物料组
        groes  TYPE mara-groes,     " 大小量纲
        meins  TYPE mara-meins,     " 基本计量单位
        blatt  TYPE mara-blatt,     " 箱数
*-------------------------销售视图-------------------------------------*
        vkorg  TYPE mvke-vkorg,  " 销售组织
        vtweg  TYPE mvke-vtweg,  " 分销渠道
*        spart  TYPE mara-spart,  " 产品组
        dwerk  TYPE mvke-dwerk,  " 交货工厂
        taxm1  TYPE c LENGTH 1,  " 税分类1
        ktgrm  TYPE mvke-ktgrm,  " 科目设置组
        mtpos  TYPE mvke-mtpos,  " 项目类别组
        mtvfp  TYPE c LENGTH 2,  " 可用性检查
        tragr  TYPE mara-tragr,  " 运输组
        ladgr  TYPE marc-ladgr,  " 转载组
*-------------------------采购视图-------------------------------------*
        " ekgrp  TYPE marc-ekgrp,  " 采购组
        xchpf  TYPE marc-xchpf,  " 批次管理
*-------------------------MRP视图--------------------------------------*
        dismm  TYPE marc-dismm,  " MRP类型
        dispo  TYPE marc-dispo,  " MRP控制者
        disls  TYPE marc-disls,  " 批量大小
        bstmi  TYPE c LENGTH 16, "MARC-BSTMI,  " 最小批量大小
        bstfe  TYPE c LENGTH 16, "MARC-BSTFE,  " 固定批量大小
        bstrf  TYPE c LENGTH 16, "MARC-BSTRF,  " 舍入值
        beskz  TYPE marc-beskz,  " 采购类型
        sobsl  TYPE marc-sobsl,  " 特殊采购类型
        rgekz  TYPE marc-rgekz,  " 反冲标识
        lgpro  TYPE marc-lgpro,  " 生产仓储地点
        lgfsb  TYPE marc-lgfsb,  " 外部采购仓储地点
        dzeit  TYPE c LENGTH 3,  "MARC-DZEIT,  " 自制生产时间
        plifz  TYPE c LENGTH 3,  "MARC-PLIFZ,  " 计划交货时间/采购提前期
        eisbe  TYPE c LENGTH 16, "MARC-EISBE,  " 安全库存
        mtvfp2 TYPE marc-mtvfp,  " 可用性检查(默认为02)
        strgr  TYPE marc-strgr,  " 策略组
        vrmod  TYPE marc-vrmod,  " 消耗模式
        vint1  TYPE c LENGTH 3,   "MARC-VINT1,  " 逆向消耗期间
        vint2  TYPE c LENGTH 3,   "MARC-VINT2,  " 向前消耗期间
        sbdkz  TYPE marc-sbdkz,  " 独立/集中
        sauft  TYPE marc-sauft,  " 重复制造
        sfepr  TYPE marc-sfepr,  " 重复制造文件
        fevor  TYPE marc-fevor,  " 生产调度员
        "xchpf2 TYPE marc-xchpf,  " 批次管理（默认为√）
        schgt  TYPE marc-schgt,  "散装物料
*-------------------------财务视图-------------------------------------*
        bklas  TYPE mbew-bklas ,     "  评估类
        mlast  TYPE mbew-mlast ,     "  价格确定
        peinh  TYPE c LENGTH 5,      "MBEW-PEINH ,     "  价格单位
        vprsv  TYPE mbew-vprsv ,     "  价格控制
        ekalr  TYPE mbew-ekalr ,     "  用QS的成本估算
        hkmat  TYPE mbew-hkmat ,     "  物料来源
        awsls  TYPE marc-awsls ,     "  差异码
        losgr  TYPE c LENGTH 16,     "MARC-LOSGR ,     "  成本核算批量
        zplp1  TYPE c LENGTH 13,     "MBEW-ZPLP1 ,     "  计划价格1
        zpld1  TYPE c LENGTH 8,      "MBEW-ZPLD1 ,     "  计划价格日期1
      END OF ty_up.

*--------------------用于函数ALSM_EXCEL_TO_INTERNAL_TABLE循环赋值------20210917lk------*
DATA:gt_up TYPE STANDARD TABLE OF ty_up,
     gs_up TYPE ty_up.
DATA:i_tab TYPE ty_up OCCURS 0 WITH HEADER LINE.
FIELD-SYMBOLS: <fs>.
*--------------------用于函数ALSM_EXCEL_TO_INTERNAL_TABLE循环赋值------20210917lk------*

TYPES:BEGIN OF ty_alv,
        matnr   TYPE mara-matnr,  " 物料号
        werks   TYPE marc-werks,  " 工厂
        mtart   TYPE mara-mtart,  " 物料类型

*-------------------------基础视图-------------------------------------*
        maktx   TYPE makt-maktx,  " 物料描述
        bismt   TYPE mara-bismt,  " 旧物料号(易飞系统料号)
        matkl   TYPE mara-matkl,  " 物料组
        extwg   TYPE mara-extwg,  " 外部物料组
        groes   TYPE mara-groes,  " 大小量纲
        meins   TYPE mara-meins,  " 基本计量单位
        blatt   TYPE mara-blatt,  " 箱数
*-------------------------销售视图-------------------------------------*
        vkorg   TYPE mvke-vkorg,  " 销售组织
        vtweg   TYPE mvke-vtweg,  " 分销渠道
*        spart   TYPE mara-spart,  " 产品组
        dwerk   TYPE mvke-dwerk,  " 交货工厂
        taxm1   TYPE c LENGTH 1,  " 税分类1
        ktgrm   TYPE mvke-ktgrm,  " 科目设置组
        mtpos   TYPE mvke-mtpos,  " 项目类别组
        mtvfp   TYPE c LENGTH 2,  " 可用性检查
        tragr   TYPE mara-tragr,  " 运输组
        ladgr   TYPE marc-ladgr,  " 转载组
*-------------------------采购视图-------------------------------------*
        "ekgrp   TYPE marc-ekgrp,  " 采购组
        xchpf   TYPE marc-xchpf,  " 批次管理
*-------------------------MRP视图--------------------------------------*
        dismm   TYPE marc-dismm,  " MRP类型
        dispo   TYPE marc-dispo,  " MRP控制者
        disls   TYPE marc-disls,  " 批量大小
        bstmi   TYPE c LENGTH 16, "MARC-BSTMI,  " 最小批量大小
        bstfe   TYPE c LENGTH 16, "MARC-BSTFE,  " 固定批量大小
        bstrf   TYPE c LENGTH 16, "MARC-BSTRF,  " 舍入值
        beskz   TYPE marc-beskz,  " 采购类型
        sobsl   TYPE marc-sobsl,  " 特殊采购类型
        rgekz   TYPE marc-rgekz,  " 反冲标识
        lgpro   TYPE marc-lgpro,  " 生产仓储地点
        lgfsb   TYPE marc-lgfsb,  " 外部采购仓储地点
        dzeit   TYPE c LENGTH 3,  "MARC-DZEIT,  " 自制生产时间
        plifz   TYPE c LENGTH 3,  "MARC-PLIFZ,  " 计划交货时间/采购提前期
        eisbe   TYPE c LENGTH 16, "MARC-EISBE,  " 安全库存
        mtvfp2  TYPE marc-mtvfp,  " 可用性检查(默认为02)
        strgr   TYPE marc-strgr,  " 策略组
        vrmod   TYPE marc-vrmod,  " 消耗模式
        vint1   TYPE c LENGTH 3,  "MARC-VINT1,  " 逆向消耗期间
        vint2   TYPE c LENGTH 3,  "MARC-VINT2,  " 向前消耗期间
        sbdkz   TYPE marc-sbdkz,  " 独立/集中
        sauft   TYPE marc-sauft,  " 重复制造
        sfepr   TYPE marc-sfepr,  " 重复制造文件
        fevor   TYPE marc-fevor,  " 生产调度员
        " xchpf2  TYPE marc-xchpf,  " 批次管理（默认为√）
        schgt   TYPE marc-schgt,  "散装物料
*-------------------------财务视图-------------------------------------*
        bklas   TYPE mbew-bklas ,     "  评估类
        mlast   TYPE mbew-mlast ,     "  价格确定
        peinh   TYPE c LENGTH 5,      "MBEW-PEINH ,     "  价格单位
        vprsv   TYPE mbew-vprsv ,     "  价格控制
        ekalr   TYPE mbew-ekalr ,     "  用QS的成本估算
        hkmat   TYPE mbew-hkmat ,     "  物料来源
        awsls   TYPE marc-awsls ,     "  差异码
        losgr   TYPE c LENGTH 16,     "MARC-LOSGR ,     "  成本核算批量
        zplp1   TYPE c LENGTH 13,     "MBEW-ZPLP1 ,     "  计划价格1
        zpld1   TYPE c LENGTH 8,      "MBEW-ZPLD1 ,     "  计划价格日期1
        type    TYPE c,               " 消息类型
        message TYPE c LENGTH 3600,   " 消息
        icon    TYPE c LENGTH 4,      " 预警信号灯
        box     TYPE c,
        flag    TYPE c,
      END OF ty_alv.

DATA:gt_alv TYPE STANDARD TABLE OF ty_alv,
     gs_alv TYPE ty_alv.

DATA:return3    TYPE STANDARD TABLE OF bapiret2,
     wa_return3 TYPE bapiret2.
DATA:objectkeynew_long TYPE bapi1003_key-object_long.
DATA:lv_meins TYPE mara-meins,
     lv_webaz TYPE marc-webaz,
     lv_dzeit TYPE marc-dzeit,
     lv_plifz TYPE marc-plifz,
     lv_vint1 TYPE marc-vint1,
     lv_vint2 TYPE marc-vint2,
     lv_peinh TYPE mbew-peinh,
     lv_zpld1 TYPE mbew-zpld1.
DATA:lv_bstmi TYPE marc-bstmi,
     lv_bstfe TYPE marc-bstfe,
     lv_bstrf TYPE marc-bstrf,
     lv_eisbe TYPE marc-eisbe,
     lv_losgr TYPE marc-losgr,
     lv_zplp1 TYPE mbew-zplp1.
DATA:gs_mbew TYPE mbew.
*---------------------------------------------------------------------*
*选择屏幕
*---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK blk1 WITH FRAME TITLE text001.
PARAMETERS: p_file TYPE rlgrap-filename.
PARAMETERS: r_up   RADIOBUTTON GROUP g1 DEFAULT 'X',
            r_down RADIOBUTTON GROUP g1.
SELECTION-SCREEN END OF BLOCK blk1.

SELECTION-SCREEN BEGIN OF BLOCK blk2 WITH FRAME TITLE text002.
PARAMETERS:r_base AS CHECKBOX,                          " 基础视图
           r_sale AS CHECKBOX,                          " 销售视图
           r_buy  AS CHECKBOX,                          " 采购视图
           r_mrp  AS CHECKBOX,                          " MRP视图
           r_fi   AS CHECKBOX.                          " 财务视图
SELECTION-SCREEN END OF BLOCK blk2.

*---------------------------------------------------------------------*
* Declare  Hong                                                       *
*                                                                     *
*---------------------------------------------------------------------*
DEFINE init_fieldcat.      "  ALV Fieldcat Setting  通过宏来定义字段目录
  CLEAR wa_fieldcat.
  wa_fieldcat-fieldname = &1.
  wa_fieldcat-coltext = &2.
  wa_fieldcat-ref_table = &3.
  wa_fieldcat-ref_field = &4.
  APPEND wa_fieldcat TO it_fieldcat.
END-OF-DEFINITION.

*---------------------------------------------------------------------*
*INITIALIZATION事件
*---------------------------------------------------------------------*
INITIALIZATION.
  text002 = '分视图导入'.
*---------------------------------------------------------------------*
*AT SELECTION-SCREEN事件
*---------------------------------------------------------------------*
AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_file.
  "导入文件的路径选择
  PERFORM frm_filepath.

*---------------------------------------------------------------------*
* Start-of-selection                                                  *
*                                                                     *
*---------------------------------------------------------------------*
START-OF-SELECTION.
  IF r_up  = 'X'.
    IF p_file IS INITIAL .
      MESSAGE '请选择上传文件!' TYPE 'S' DISPLAY LIKE 'E'.
      STOP.
    ELSE.
      PERFORM frm_convert_xls_to_sap.
      PERFORM frm_set_fieldcat.
      PERFORM frm_layout.
      PERFORM frm_display.
    ENDIF.

  ELSEIF r_down = 'X'.
    PERFORM frm_downloap.
  ENDIF.
*&---------------------------------------------------------------------*
*&      Form  FRM_FILEPATH
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM frm_filepath .
  DATA:i_filetable TYPE filetable,
       i_rc        TYPE i.

  CALL METHOD cl_gui_frontend_services=>file_open_dialog
    EXPORTING
      window_title            = '选择数据文件'
      multiselection          = space
      file_filter             = 'Excel Files(*.xlsx)|*.xls;*.XLS;*.xlsx;*.XLSX'
    CHANGING
      file_table              = i_filetable
      rc                      = i_rc
    EXCEPTIONS
      file_open_dialog_failed = 1
      cntl_error              = 2
      error_no_gui            = 3
      not_supported_by_gui    = 4
      OTHERS                  = 5.
  IF sy-subrc = 0 AND i_rc = 1.                      "判断是否成功打开
    READ TABLE i_filetable INTO p_file INDEX 1.
    filename = p_file.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  FRM_CONVERT_XLS_TO_SAP
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM frm_convert_xls_to_sap .

*--------------更换此函数适应xlsx文件类型的导入-------LK20210916---------*
  DATA:lv_message TYPE c LENGTH 36.
*
  DATA: t_raw TYPE truxs_t_text_data.



*-------------------------------------------------LK20210916-------------------*

  PERFORM alsm_xlsx_to_table .    "把导入文件转换为内表存入GT_UP中

*-------------------------------------------------LK20210916-------------------*
  LOOP AT gt_up INTO gs_up.
*&--创建物料
    IF gs_up-matnr IS INITIAL.
      IF gs_up-werks IS INITIAL.
        IF gs_alv-message IS INITIAL.
          gs_alv-message = '工厂为空'.
        ELSE.
          CLEAR lv_message.
          lv_message = '工厂为空'.
          CONCATENATE gs_alv-message ';' lv_message INTO gs_alv-message.
        ENDIF.
        gs_alv-type = 'E'.
        gs_alv-icon = icon_red_light.
      ENDIF.
      IF r_base = 'X'.
        IF gs_up-mtart IS INITIAL.
          IF gs_alv-message IS INITIAL.
            gs_alv-message = '物料类型为空'.
          ELSE.
            CLEAR lv_message.
            lv_message = '物料类型为空'.
            CONCATENATE gs_alv-message ';' lv_message INTO gs_alv-message.
          ENDIF.
          gs_alv-type = 'E'.
          gs_alv-icon = icon_red_light.
        ENDIF.
        IF gs_up-maktx IS INITIAL .
          IF gs_alv-message IS INITIAL.
            gs_alv-message = '物料描述为空'.
          ELSE.
            CLEAR lv_message.
            lv_message = '物料描述为空'.
            CONCATENATE gs_alv-message ';' lv_message INTO gs_alv-message.
          ENDIF.
          gs_alv-type = 'E'.
          gs_alv-icon = icon_red_light.
        ENDIF.
        IF gs_up-matkl IS INITIAL.
          IF gs_alv-message IS INITIAL.
            gs_alv-message = '物料组为空'.
          ELSE.
            CLEAR lv_message.
            lv_message = '物料组为空'.
            CONCATENATE gs_alv-message ';' lv_message INTO gs_alv-message.
          ENDIF.
          gs_alv-type = 'E'.
          gs_alv-icon = icon_red_light.
        ENDIF.
        IF gs_up-meins IS INITIAL.
          IF gs_alv-message IS INITIAL.
            gs_alv-message = '基本单位为空'.
          ELSE.
            CLEAR lv_message.
            lv_message = '基本单位为空'.
            CONCATENATE gs_alv-message ';' lv_message INTO gs_alv-message.
          ENDIF.
          gs_alv-type = 'E'.
          gs_alv-icon = icon_red_light.
        ENDIF.
      ENDIF.

      IF r_sale = 'X' .
        " 销售组织
        IF gs_up-vkorg IS INITIAL.
          IF gs_alv-message IS INITIAL.
            gs_alv-message = '销售组织为空'.
          ELSE.
            CLEAR lv_message.
            lv_message = '销售组织为空'.
            CONCATENATE gs_alv-message ';' lv_message INTO gs_alv-message.
          ENDIF.
          gs_alv-type = 'E'.
          gs_alv-icon = icon_red_light.
        ENDIF.
        " 分销渠道
        IF gs_up-vtweg IS INITIAL.
          IF gs_alv-message IS INITIAL.
            gs_alv-message = '分销渠道为空'.
          ELSE.
            CLEAR lv_message.
            lv_message = '分销渠道为空'.
            CONCATENATE gs_alv-message ';' lv_message INTO gs_alv-message.
          ENDIF.
          gs_alv-type = 'E'.
          gs_alv-icon = icon_red_light.
        ENDIF.
        "  交货工厂
        IF gs_up-dwerk IS INITIAL.
          IF gs_alv-message IS INITIAL.
            gs_alv-message = '交货工厂为空'.
          ELSE.
            CLEAR lv_message.
            lv_message = '交货工厂为空'.
            CONCATENATE gs_alv-message ';' lv_message INTO gs_alv-message.
          ENDIF.
          gs_alv-type = 'E'.
          gs_alv-icon = icon_red_light.
        ENDIF.
        " 税分类1
        IF gs_up-taxm1 IS INITIAL.
          IF gs_alv-message IS INITIAL.
            gs_alv-message = '税分类1为空'.
          ELSE.
            CLEAR lv_message.
            lv_message = '税分类1为空'.
            CONCATENATE gs_alv-message ';' lv_message INTO gs_alv-message.
          ENDIF.
          gs_alv-type = 'E'.
          gs_alv-icon = icon_red_light.
        ENDIF.
        " 科目设置组
        IF gs_up-ktgrm IS INITIAL.
          IF gs_alv-message IS INITIAL.
            gs_alv-message = '科目设置组为空'.
          ELSE.
            CLEAR lv_message.
            lv_message = '科目设置组为空'.
            CONCATENATE gs_alv-message ';' lv_message INTO gs_alv-message.
          ENDIF.
          gs_alv-type = 'E'.
          gs_alv-icon = icon_red_light.
        ENDIF.
        " 项目类别组
        IF gs_up-mtpos IS INITIAL.
          IF gs_alv-message IS INITIAL.
            gs_alv-message = '项目类别组为空'.
          ELSE.
            CLEAR lv_message.
            lv_message = '项目类别组为空'.
            CONCATENATE gs_alv-message ';' lv_message INTO gs_alv-message.
          ENDIF.
          gs_alv-type = 'E'.
          gs_alv-icon = icon_red_light.
        ENDIF.
        " 可用性检查
        IF gs_up-mtvfp IS INITIAL.
          IF gs_alv-message IS INITIAL.
            gs_alv-message = '可用性检查为空'.
          ELSE.
            CLEAR lv_message.
            lv_message = '可用性检查为空'.
            CONCATENATE gs_alv-message ';' lv_message INTO gs_alv-message.
          ENDIF.
          gs_alv-type = 'E'.
          gs_alv-icon = icon_red_light.
        ENDIF.
        " 运输组
        IF gs_up-tragr IS INITIAL.
          IF gs_alv-message IS INITIAL.
            gs_alv-message = '运输组为空'.
          ELSE.
            CLEAR lv_message.
            lv_message = '运输组组为空'.
            CONCATENATE gs_alv-message ';' lv_message INTO gs_alv-message.
          ENDIF.
          gs_alv-type = 'E'.
          gs_alv-icon = icon_red_light.
        ENDIF.
        " 转载组
        IF gs_up-ladgr IS INITIAL.
          IF gs_alv-message IS INITIAL.
            gs_alv-message = '装载组为空'.
          ELSE.
            CLEAR lv_message.
            lv_message = '装载组为空'.
            CONCATENATE gs_alv-message ';' lv_message INTO gs_alv-message.
          ENDIF.
          gs_alv-type = 'E'.
          gs_alv-icon = icon_red_light.
        ENDIF.
      ENDIF.


      IF r_mrp = 'X'.
        " MRP类型
        IF gs_up-dismm IS INITIAL.
          IF gs_alv-message IS INITIAL.
            gs_alv-message = 'MRP类型为空'.
          ELSE.
            CLEAR lv_message.
            lv_message = 'MRP类型为空'.
            CONCATENATE gs_alv-message ';' lv_message INTO gs_alv-message.
          ENDIF.
          gs_alv-type = 'E'.
          gs_alv-icon = icon_red_light.
        ENDIF.
        " MRP控制者
        IF gs_up-dispo IS INITIAL.
          IF gs_alv-message IS INITIAL.
            gs_alv-message = 'MRP控制者为空'.
          ELSE.
            CLEAR lv_message.
            lv_message = 'MRP控制者为空'.
            CONCATENATE gs_alv-message ';' lv_message INTO gs_alv-message.
          ENDIF.
          gs_alv-type = 'E'.
          gs_alv-icon = icon_red_light.

        ENDIF.
        " 批量大小
        IF gs_up-disls IS INITIAL.
          IF gs_alv-message IS INITIAL.
            gs_alv-message = '批量大小为空'.
          ELSE.
            CLEAR lv_message.
            lv_message = '批量大小为空'.
            CONCATENATE gs_alv-message ';' lv_message INTO gs_alv-message.
          ENDIF.
          gs_alv-type = 'E'.
          gs_alv-icon = icon_red_light.

        ENDIF.
        " 采购类型
        IF gs_up-beskz IS INITIAL.
          IF gs_alv-message IS INITIAL.
            gs_alv-message = '采购类型为空'.
          ELSE.
            CLEAR lv_message.
            lv_message = '采购类型为空'.
            CONCATENATE gs_alv-message ';' lv_message INTO gs_alv-message.
          ENDIF.
          gs_alv-type = 'E'.
          gs_alv-icon = icon_red_light.
        ENDIF.
        "可用性检查
        IF gs_up-mtvfp2 IS  INITIAL.
          IF gs_alv-message IS INITIAL.
            gs_alv-message = '可用性检查为空'.
          ELSE.
            CLEAR lv_message.
            lv_message = '可用性检查为空'.
            CONCATENATE gs_alv-message ';' lv_message INTO gs_alv-message.
          ENDIF.
          gs_alv-type = 'E'.
          gs_alv-icon = icon_red_light.
        ENDIF.
      ENDIF.

      IF r_fi = 'X'.
        " 评估类
        IF gs_up-bklas IS INITIAL.
          IF gs_alv-message IS INITIAL.
            gs_alv-message = '评估类为空'.
          ELSE.
            CLEAR lv_message.
            lv_message = '评估类为空'.
            CONCATENATE gs_alv-message ';' lv_message INTO gs_alv-message.
          ENDIF.
          gs_alv-type = 'E'.
          gs_alv-icon = icon_red_light.
        ENDIF.
        " 价格确定
        IF  gs_up-mlast IS  INITIAL.
          IF gs_alv-message IS INITIAL.
            gs_alv-message = '价格确定为空'.
          ELSE.
            CLEAR lv_message.
            lv_message = '价格确定为空'.
            CONCATENATE gs_alv-message ';' lv_message INTO gs_alv-message.
          ENDIF.
          gs_alv-type = 'E'.
          gs_alv-icon = icon_red_light.
        ENDIF.
        " 价格单位
        IF gs_up-peinh IS INITIAL.
          IF gs_alv-message IS INITIAL.
            gs_alv-message = '价格单位为空'.
          ELSE.
            CLEAR lv_message.
            lv_message = '价格单位为空'.
            CONCATENATE gs_alv-message ';' lv_message INTO gs_alv-message.
          ENDIF.
          gs_alv-type = 'E'.
          gs_alv-icon = icon_red_light.
        ENDIF.
        " 价格控制
        IF gs_up-vprsv IS INITIAL .
          IF gs_alv-message IS INITIAL.
            gs_alv-message = '价格控制为空'.
          ELSE.
            CLEAR lv_message.
            lv_message = '价格控制为空'.
            CONCATENATE gs_alv-message ';' lv_message INTO gs_alv-message.
          ENDIF.
          gs_alv-type = 'E'.
          gs_alv-icon = icon_red_light.
        ENDIF.
        "  用QS的成本估算
        IF gs_up-ekalr IS INITIAL.
          IF gs_alv-message IS INITIAL.
            gs_alv-message = '用QS的成本估算为空'.
          ELSE.
            CLEAR lv_message.
            lv_message = '用QS的成本估算为空'.
            CONCATENATE gs_alv-message ';' lv_message INTO gs_alv-message.
          ENDIF.
          gs_alv-type = 'E'.
          gs_alv-icon = icon_red_light.
        ENDIF.
        " 物料来源
        IF gs_up-hkmat IS INITIAL.
          IF gs_alv-message IS INITIAL.
            gs_alv-message = '物料来源为空'.
          ELSE.
            CLEAR lv_message.
            lv_message = '物料来源为空'.
            CONCATENATE gs_alv-message ';' lv_message INTO gs_alv-message.
          ENDIF.
          gs_alv-type = 'E'.
          gs_alv-icon = icon_red_light.
        ENDIF.
        " 成本核算批量
        IF gs_up-losgr IS INITIAL.
          IF gs_alv-message IS INITIAL.
            gs_alv-message = '成本核算批量为空'.
          ELSE.
            CLEAR lv_message.
            lv_message = '成本核算批量为空'.
            CONCATENATE gs_alv-message ';' lv_message INTO gs_alv-message.
          ENDIF.
          gs_alv-type = 'E'.
          gs_alv-icon = icon_red_light.
        ENDIF.
      ENDIF.

      MOVE-CORRESPONDING gs_up TO gs_alv.
      APPEND gs_alv TO gt_alv.
      CLEAR gs_alv.

*&--修改物料
    ELSEIF gs_up-matnr IS  NOT INITIAL.
*-------------增加检测物料号长度代码-------lk--20210917-------------------------------*
      IF  strlen( gs_up-matnr ) <> 10 .
        IF gs_alv-message IS INITIAL.
          gs_alv-message = '物料号长度不等于10位'.
        ELSE.
          CLEAR lv_message.
          lv_message = '物料号长度不等于10位'.
          CONCATENATE gs_alv-message ';' lv_message INTO gs_alv-message.
        ENDIF.
        gs_alv-type = 'E'.
        gs_alv-icon = icon_red_light.
      ENDIF .
*-------------增加检测物料号长度代码-------lk--20210917-------------------------------*
      IF gs_up-werks IS INITIAL.
        IF gs_alv-message IS INITIAL.
          gs_alv-message = '工厂为空'.
        ELSE.
          CLEAR lv_message.
          lv_message = '工厂为空'.
          CONCATENATE gs_alv-message ';' lv_message INTO gs_alv-message.
        ENDIF.
        gs_alv-type = 'E'.
        gs_alv-icon = icon_red_light.
      ENDIF.

      IF r_base = 'X'.
        IF gs_up-mtart IS INITIAL.
          IF gs_alv-message IS INITIAL.
            gs_alv-message = '物料类型为空'.
          ELSE.
            CLEAR lv_message.
            lv_message = '物料类型为空'.
            CONCATENATE gs_alv-message ';' lv_message INTO gs_alv-message.
          ENDIF.
          gs_alv-type = 'E'.
          gs_alv-icon = icon_red_light.
        ENDIF.
        IF gs_up-meins IS INITIAL.
          IF gs_alv-message IS INITIAL.
            gs_alv-message = '基本单位为空'.
          ELSE.
            CLEAR lv_message.
            lv_message = '基本单位为空'.
            CONCATENATE gs_alv-message ';' lv_message INTO gs_alv-message.
          ENDIF.
          gs_alv-type = 'E'.
          gs_alv-icon = icon_red_light.
        ENDIF.
      ENDIF.
      IF r_sale = 'X' .
        " 销售组织
        IF gs_up-vkorg IS INITIAL.
          IF gs_alv-message IS INITIAL.
            gs_alv-message = '销售组织为空'.
          ELSE.
            CLEAR lv_message.
            lv_message = '销售组织为空'.
            CONCATENATE gs_alv-message ';' lv_message INTO gs_alv-message.
          ENDIF.
          gs_alv-type = 'E'.
          gs_alv-icon = icon_red_light.
        ENDIF.
        " 分销渠道
        IF gs_up-vtweg IS INITIAL.
          IF gs_alv-message IS INITIAL.
            gs_alv-message = '分销渠道为空'.
          ELSE.
            CLEAR lv_message.
            lv_message = '分销渠道为空'.
            CONCATENATE gs_alv-message ';' lv_message INTO gs_alv-message.
          ENDIF.
          gs_alv-type = 'E'.
          gs_alv-icon = icon_red_light.
        ENDIF.
        "  交货工厂
        IF gs_up-dwerk IS INITIAL.
          IF gs_alv-message IS INITIAL.
            gs_alv-message = '交货工厂为空'.
          ELSE.
            CLEAR lv_message.
            lv_message = '交货工厂为空'.
            CONCATENATE gs_alv-message ';' lv_message INTO gs_alv-message.
          ENDIF.
          gs_alv-type = 'E'.
          gs_alv-icon = icon_red_light.
        ENDIF.
        " 税分类1
        IF gs_up-taxm1 IS INITIAL.
          IF gs_alv-message IS INITIAL.
            gs_alv-message = '税分类1为空'.
          ELSE.
            CLEAR lv_message.
            lv_message = '税分类1为空'.
            CONCATENATE gs_alv-message ';' lv_message INTO gs_alv-message.
          ENDIF.
          gs_alv-type = 'E'.
          gs_alv-icon = icon_red_light.
        ENDIF.
        " 科目设置组
        IF gs_up-ktgrm IS INITIAL.
          IF gs_alv-message IS INITIAL.
            gs_alv-message = '科目设置组为空'.
          ELSE.
            CLEAR lv_message.
            lv_message = '科目设置组为空'.
            CONCATENATE gs_alv-message ';' lv_message INTO gs_alv-message.
          ENDIF.
          gs_alv-type = 'E'.
          gs_alv-icon = icon_red_light.
        ENDIF.
        " 项目类别组
        IF gs_up-mtpos IS INITIAL.
          IF gs_alv-message IS INITIAL.
            gs_alv-message = '项目类别组为空'.
          ELSE.
            CLEAR lv_message.
            lv_message = '项目类别组为空'.
            CONCATENATE gs_alv-message ';' lv_message INTO gs_alv-message.
          ENDIF.
          gs_alv-type = 'E'.
          gs_alv-icon = icon_red_light.
        ENDIF.
        " 可用性检查
        IF gs_up-mtvfp IS INITIAL.
          IF gs_alv-message IS INITIAL.
            gs_alv-message = '可用性检查为空'.
          ELSE.
            CLEAR lv_message.
            lv_message = '可用性检查为空'.
            CONCATENATE gs_alv-message ';' lv_message INTO gs_alv-message.
          ENDIF.
          gs_alv-type = 'E'.
          gs_alv-icon = icon_red_light.
        ENDIF.
        " 运输组
        IF gs_up-tragr IS INITIAL.
          IF gs_alv-message IS INITIAL.
            gs_alv-message = '运输组为空'.
          ELSE.
            CLEAR lv_message.
            lv_message = '运输组组为空'.
            CONCATENATE gs_alv-message ';' lv_message INTO gs_alv-message.
          ENDIF.
          gs_alv-type = 'E'.
          gs_alv-icon = icon_red_light.
        ENDIF.
        " 转载组
        IF gs_up-ladgr IS INITIAL.
          IF gs_alv-message IS INITIAL.
            gs_alv-message = '装载组为空'.
          ELSE.
            CLEAR lv_message.
            lv_message = '装载组为空'.
            CONCATENATE gs_alv-message ';' lv_message INTO gs_alv-message.
          ENDIF.
          gs_alv-type = 'E'.
          gs_alv-icon = icon_red_light.
        ENDIF.
      ENDIF.


      MOVE-CORRESPONDING gs_up TO gs_alv.
      APPEND gs_alv TO gt_alv.
      CLEAR gs_alv.
    ENDIF.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  FRM_DOWNLOAP
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM frm_downloap .
  DATA: p_objid(20) TYPE c.  "文件名
  DATA: lv_fname TYPE string,
        lv_title TYPE string,
        lv_path  TYPE string VALUE 'D:/',
        lv_fpath TYPE string VALUE 'D:/'.

  DATA: gs_wdatb   LIKE wwwdatatab.
  DATA: lv_rc   TYPE sy-subrc.
  DATA: gv_msg TYPE string .

  p_objid = 'ZMM061'.   "服务器中的文件名


  lv_fname = '物料批导导入模板新版'."默认文件名

  CONCATENATE lv_fname '下载' INTO lv_title.

  CALL METHOD cl_gui_frontend_services=>file_save_dialog
    EXPORTING
      window_title              = lv_title
      default_extension         = 'xlsx'
      default_file_name         = lv_fname
"     with_encoding             =
      file_filter               = 'EXCEL文件(*.xlsx)|*.xlsx|全部文件 (*.*)|*.*|'
      initial_directory         = 'D:\'
      prompt_on_overwrite       = 'X'
    CHANGING
      filename                  = lv_fname  "默认文件名称
      path                      = lv_path   "文件路径
      fullpath                  = lv_fpath  "文件路径
"     user_action               =
"     file_encoding             =
    EXCEPTIONS
      cntl_error                = 1
      error_no_gui              = 2
      not_supported_by_gui      = 3
      invalid_default_file_name = 4
      OTHERS                    = 5.
  IF sy-subrc <> 0.
*   Implement suitable error handling here
  ELSE.
    SELECT SINGLE
                relid
                objid
    FROM wwwdata
    INTO CORRESPONDING FIELDS OF gs_wdatb
    WHERE srtf2 = 0
    AND relid = 'MI'        "对象类型，MI代表EXCEL
    AND objid = p_objid.    "服务器中上传的对象名
    IF gs_wdatb IS INITIAL.
      MESSAGE '模板文件不存在！' TYPE 'E'.
    ELSE.
      p_file = lv_fpath.
      IF p_file IS NOT INITIAL.
        CALL FUNCTION 'DOWNLOAD_WEB_OBJECT'
          EXPORTING
            key         = gs_wdatb
            destination = p_file
          IMPORTING
            rc          = lv_rc.
        IF lv_rc NE 0.
          MESSAGE '模板下载失败！' TYPE 'E'.
        ELSE.
          CLEAR gv_msg.
          CONCATENATE '模板下载到本地文件' p_file INTO gv_msg.
          MESSAGE gv_msg TYPE 'S' .
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  FRM_SET_FIELDCAT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM frm_set_fieldcat .

  CLEAR:wa_fieldcat.
  wa_fieldcat-fieldname = 'ICON'.
  wa_fieldcat-scrtext_l = '信号灯'.
*  wa_fieldcat-ref_table = 'MARA'.
*  wa_fieldcat-ref_field = 'MATNR'.
  APPEND wa_fieldcat TO it_fieldcat.

  CLEAR:wa_fieldcat.
  wa_fieldcat-fieldname = 'MATNR'.
  wa_fieldcat-scrtext_l = 'SAP物料号'.
  wa_fieldcat-ref_table = 'MARA'.
  wa_fieldcat-ref_field = 'MATNR'.
  APPEND wa_fieldcat TO it_fieldcat.

  CLEAR:wa_fieldcat.
  wa_fieldcat-fieldname = 'WERKS'.
  wa_fieldcat-scrtext_l = '工厂'.
  wa_fieldcat-ref_table = 'MRAC'.
  wa_fieldcat-ref_field = 'WERKS'.
  APPEND wa_fieldcat TO it_fieldcat.

  CLEAR:wa_fieldcat.
  wa_fieldcat-fieldname = 'MTART'.
  wa_fieldcat-scrtext_l = '物料类型'.
  wa_fieldcat-ref_table = 'MARA'.
  wa_fieldcat-ref_field = 'MTART'.
  APPEND wa_fieldcat TO it_fieldcat.

  CLEAR:wa_fieldcat.
  wa_fieldcat-fieldname = 'MAKTX'.
  wa_fieldcat-scrtext_l = '物料描述'.
  wa_fieldcat-ref_table = 'MAKT'.
  wa_fieldcat-ref_field = 'MAKTX'.
  APPEND wa_fieldcat TO it_fieldcat.

  CLEAR:wa_fieldcat.
  wa_fieldcat-fieldname = 'BISMT'.
  wa_fieldcat-scrtext_l = '易飞系统料号(旧物料号)'.
  wa_fieldcat-ref_table = 'MARA'.
  wa_fieldcat-ref_field = 'BISMT'.
  APPEND wa_fieldcat TO it_fieldcat.



  CLEAR:wa_fieldcat.
  wa_fieldcat-fieldname = 'MATKL'.
  wa_fieldcat-scrtext_l = '物料组'.
  wa_fieldcat-ref_table = 'MARA'.
  wa_fieldcat-ref_field = 'MATKL'.
  APPEND wa_fieldcat TO it_fieldcat.

  CLEAR:wa_fieldcat.
  wa_fieldcat-fieldname = 'EXTWG'.
  wa_fieldcat-scrtext_l = '外部物料组'.
  wa_fieldcat-ref_table = 'MARA'.
  wa_fieldcat-ref_field = 'EXTWG'.
  APPEND wa_fieldcat TO it_fieldcat.




  CLEAR:wa_fieldcat.
  wa_fieldcat-fieldname = 'GROES'.
  wa_fieldcat-scrtext_l = '大小量纲'.
  APPEND wa_fieldcat TO it_fieldcat.


  CLEAR:wa_fieldcat.
  wa_fieldcat-fieldname = 'MEINS'.
  wa_fieldcat-scrtext_l = '基本计量单位'.
*-------------------------2017.10.02 handzx 单位*问题------------------*
*  WA_FIELDCAT-REF_TABLE = 'MARA'.
*  WA_FIELDCAT-REF_FIELD = 'MEINS'.
*----------------------------------------------------------------------*
  APPEND wa_fieldcat TO it_fieldcat.

  CLEAR:wa_fieldcat.
  wa_fieldcat-fieldname = 'BLATT'.
  wa_fieldcat-scrtext_l = '箱数'.
  APPEND wa_fieldcat TO it_fieldcat.


  CLEAR:wa_fieldcat.
  wa_fieldcat-fieldname = 'VKORG'.
  wa_fieldcat-scrtext_l = '销售组织'.
  wa_fieldcat-ref_table = 'MVKE'.
  wa_fieldcat-ref_field = 'VKORG'.
  APPEND wa_fieldcat TO it_fieldcat.

  CLEAR:wa_fieldcat.
  wa_fieldcat-fieldname = 'VTWEG'.
  wa_fieldcat-scrtext_l = '分销渠道'.
  wa_fieldcat-ref_table = 'MVKE'.
  wa_fieldcat-ref_field = 'VTWEG'.
  APPEND wa_fieldcat TO it_fieldcat.

*  CLEAR:wa_fieldcat.
*  wa_fieldcat-fieldname = 'SPART'.
*  wa_fieldcat-scrtext_l = '产品组'.
*  wa_fieldcat-ref_table = 'MARA'.
*  wa_fieldcat-ref_field = 'SPART'.
*  APPEND wa_fieldcat TO it_fieldcat.

  CLEAR:wa_fieldcat.
  wa_fieldcat-fieldname = 'DWERK'.
  wa_fieldcat-scrtext_l = '交货工厂'.
  wa_fieldcat-ref_table = 'MVKE'.
  wa_fieldcat-ref_field = 'DWERK'.
  APPEND wa_fieldcat TO it_fieldcat.

  CLEAR:wa_fieldcat.
  wa_fieldcat-fieldname = 'TAXM1'.
  wa_fieldcat-scrtext_l = '税分类1'.
  APPEND wa_fieldcat TO it_fieldcat.

  CLEAR:wa_fieldcat.
  wa_fieldcat-fieldname = 'KTGRM'.
  wa_fieldcat-scrtext_l = '科目设置组'.
  wa_fieldcat-ref_table = 'MVKE'.
  wa_fieldcat-ref_field = 'KTGRM'.
  APPEND wa_fieldcat TO it_fieldcat.

  CLEAR:wa_fieldcat.
  wa_fieldcat-fieldname = 'MTPOS'.
  wa_fieldcat-scrtext_l = '项目类别组'.
  wa_fieldcat-ref_table = 'MVKE'.
  wa_fieldcat-ref_field = 'MTPOS'.
  APPEND wa_fieldcat TO it_fieldcat.

  CLEAR:wa_fieldcat.
  wa_fieldcat-fieldname = 'MTVFP'.
  wa_fieldcat-scrtext_l = '可用性检查'.
  APPEND wa_fieldcat TO it_fieldcat.

  CLEAR:wa_fieldcat.
  wa_fieldcat-fieldname = 'TRAGR'.
  wa_fieldcat-scrtext_l = '运输组'.
  wa_fieldcat-ref_table = 'MARA'.
  wa_fieldcat-ref_field = 'TRAGR'.
  APPEND wa_fieldcat TO it_fieldcat.

  CLEAR:wa_fieldcat.
  wa_fieldcat-fieldname = 'LADGR'.
  wa_fieldcat-scrtext_l = '装载组'.
  wa_fieldcat-ref_table = 'MARC'.
  wa_fieldcat-ref_field = 'LADGR'.
  APPEND wa_fieldcat TO it_fieldcat.

  CLEAR:wa_fieldcat.
  wa_fieldcat-fieldname = 'XCHPF'.
  wa_fieldcat-scrtext_l = '批次管理'.
  wa_fieldcat-ref_table = 'MARC'.
  wa_fieldcat-ref_field = 'XCHPF'.
  APPEND wa_fieldcat TO it_fieldcat.

*  CLEAR:wa_fieldcat.
*  wa_fieldcat-fieldname = 'MFRGR'.
*  wa_fieldcat-scrtext_l = '物料运输组'.
*  wa_fieldcat-ref_table = 'MARC'.
*  wa_fieldcat-ref_field = 'MFRGR'.
*  APPEND wa_fieldcat TO it_fieldcat.

  CLEAR:wa_fieldcat.
  wa_fieldcat-fieldname = 'DISMM'.
  wa_fieldcat-scrtext_l = 'MRP类型'.
  wa_fieldcat-ref_table = 'MARC'.
  wa_fieldcat-ref_field = 'DISMM'.
  APPEND wa_fieldcat TO it_fieldcat.

  CLEAR:wa_fieldcat.
  wa_fieldcat-fieldname = 'DISPO'.
  wa_fieldcat-scrtext_l = 'MRP控制者'.
  wa_fieldcat-ref_table = 'MARC'.
  wa_fieldcat-ref_field = 'DISPO'.
  APPEND wa_fieldcat TO it_fieldcat.

  CLEAR:wa_fieldcat.
  wa_fieldcat-fieldname = 'DISLS'.
  wa_fieldcat-scrtext_l = '批量大小'.
  wa_fieldcat-ref_table = 'MARC'.
  wa_fieldcat-ref_field = 'DISLS'.
  APPEND wa_fieldcat TO it_fieldcat.

  CLEAR:wa_fieldcat.
  wa_fieldcat-fieldname = 'BSTMI'.
  wa_fieldcat-scrtext_l = '最小批量大小'.
  wa_fieldcat-ref_table = 'MARC'.
  wa_fieldcat-ref_field = 'BSTMI'.
  APPEND wa_fieldcat TO it_fieldcat.

  CLEAR:wa_fieldcat.
  wa_fieldcat-fieldname = 'BSTFE'.
  wa_fieldcat-scrtext_l = '固定批量大小'.
  wa_fieldcat-ref_table = 'MARC'.
  wa_fieldcat-ref_field = 'BSTFE'.
  APPEND wa_fieldcat TO it_fieldcat.

  CLEAR:wa_fieldcat.
  wa_fieldcat-fieldname = 'BSTRF'.
  wa_fieldcat-scrtext_l = '舍入值'.
  wa_fieldcat-ref_table = 'MARC'.
  wa_fieldcat-ref_field = 'BSTRF'.
  APPEND wa_fieldcat TO it_fieldcat.


  CLEAR:wa_fieldcat.
  wa_fieldcat-fieldname = 'BESKZ'.
  wa_fieldcat-scrtext_l = '采购类型'.
  wa_fieldcat-ref_table = 'MARC'.
  wa_fieldcat-ref_field = 'BESKZ'.
  APPEND wa_fieldcat TO it_fieldcat.

  CLEAR:wa_fieldcat.
  wa_fieldcat-fieldname = 'SOBSL'.
  wa_fieldcat-scrtext_l = '特殊采购类型'.
  wa_fieldcat-ref_table = 'MARC'.
  wa_fieldcat-ref_field = 'SOBSL'.
  APPEND wa_fieldcat TO it_fieldcat.

  CLEAR:wa_fieldcat.
  wa_fieldcat-fieldname = 'RGEKZ'.
  wa_fieldcat-scrtext_l = '反冲'.
  wa_fieldcat-ref_table = 'MARC'.
  wa_fieldcat-ref_field = 'RGEKZ'.
  APPEND wa_fieldcat TO it_fieldcat.

  CLEAR:wa_fieldcat.
  wa_fieldcat-fieldname = 'LGPRO'.
  wa_fieldcat-scrtext_l = '生产仓储地点'.
  wa_fieldcat-ref_table = 'MARC'.
  wa_fieldcat-ref_field = 'LGPRO'.
  APPEND wa_fieldcat TO it_fieldcat.

  CLEAR:wa_fieldcat.
  wa_fieldcat-fieldname = 'LGFSB'.
  wa_fieldcat-scrtext_l = '外部采购仓储地点'.
  wa_fieldcat-ref_table = 'MARC'.
  wa_fieldcat-ref_field = 'LGFSB'.
  APPEND wa_fieldcat TO it_fieldcat.

  CLEAR:wa_fieldcat.
  wa_fieldcat-fieldname = 'DZEIT'.
  wa_fieldcat-scrtext_l = '自制生产'.
  wa_fieldcat-ref_table = 'MARC'.
  wa_fieldcat-ref_field = 'DZEIT'.
  APPEND wa_fieldcat TO it_fieldcat.

  CLEAR:wa_fieldcat.
  wa_fieldcat-fieldname = 'PLIFZ'.
  wa_fieldcat-scrtext_l = '计划交货时间'.
  wa_fieldcat-ref_table = 'MARC'.
  wa_fieldcat-ref_field = 'PLIFZ'.
  APPEND wa_fieldcat TO it_fieldcat.

  CLEAR:wa_fieldcat.
  wa_fieldcat-fieldname = 'EISBE'.
  wa_fieldcat-scrtext_l = '安全库存'.
  wa_fieldcat-ref_table = 'MARC'.
  wa_fieldcat-ref_field = 'EISBE'.
  APPEND wa_fieldcat TO it_fieldcat.

  CLEAR:wa_fieldcat.
  wa_fieldcat-fieldname = 'MTVFP2'.
  wa_fieldcat-scrtext_l = '可用性检查'.
  wa_fieldcat-ref_table = 'MARC'.
  wa_fieldcat-ref_field = 'MTVFP'.
  APPEND wa_fieldcat TO it_fieldcat.

  CLEAR:wa_fieldcat.
  wa_fieldcat-fieldname = 'STRGR'.
  wa_fieldcat-scrtext_l = '策略组'.
  wa_fieldcat-ref_table = 'MARC'.
  wa_fieldcat-ref_field = 'STRGR'.
  APPEND wa_fieldcat TO it_fieldcat.

  CLEAR:wa_fieldcat.
  wa_fieldcat-fieldname = 'VRMOD'.
  wa_fieldcat-scrtext_l = '消耗模式'.
  wa_fieldcat-ref_table = 'MARC'.
  wa_fieldcat-ref_field = 'VRMOD'.
  APPEND wa_fieldcat TO it_fieldcat.

  CLEAR:wa_fieldcat.
  wa_fieldcat-fieldname = 'VINT1'.
  wa_fieldcat-scrtext_l = '逆向消耗期间'.
  wa_fieldcat-ref_table = 'MARC'.
  wa_fieldcat-ref_field = 'VINT1'.
  APPEND wa_fieldcat TO it_fieldcat.

  CLEAR:wa_fieldcat.
  wa_fieldcat-fieldname = 'VINT2'.
  wa_fieldcat-scrtext_l = '向前消耗期间'.
  wa_fieldcat-ref_table = 'MARC'.
  wa_fieldcat-ref_field = 'VINT2'.
  APPEND wa_fieldcat TO it_fieldcat.

  CLEAR:wa_fieldcat.
  wa_fieldcat-fieldname = 'SBDKZ'.
  wa_fieldcat-scrtext_l = '独立/集中'.
  wa_fieldcat-ref_table = 'MARC'.
  wa_fieldcat-ref_field = 'SBDKZ'.
  APPEND wa_fieldcat TO it_fieldcat.

  CLEAR:wa_fieldcat.
  wa_fieldcat-fieldname = 'SAUFT'.
  wa_fieldcat-scrtext_l = '重复制造'.
  wa_fieldcat-ref_table = 'MARC'.
  wa_fieldcat-ref_field = 'SAUFT'.
  APPEND wa_fieldcat TO it_fieldcat.

  CLEAR:wa_fieldcat.
  wa_fieldcat-fieldname = 'SFEPR'.
  wa_fieldcat-scrtext_l = '重复制造参数文件'.
  wa_fieldcat-ref_table = 'MARC'.
  wa_fieldcat-ref_field = 'SFEPR'.
  APPEND wa_fieldcat TO it_fieldcat.

  CLEAR:wa_fieldcat.
  wa_fieldcat-fieldname = 'FEVOR'.
  wa_fieldcat-scrtext_l = '生产调度员'.
  wa_fieldcat-ref_table = 'MARC'.
  wa_fieldcat-ref_field = 'FEVOR'.
  APPEND wa_fieldcat TO it_fieldcat.

*  CLEAR:wa_fieldcat.
*  wa_fieldcat-fieldname = 'XCHPF2'.
*  wa_fieldcat-scrtext_l = '批次管理'.
*  wa_fieldcat-ref_table = 'MARC'.
*  wa_fieldcat-ref_field = 'XCHPF'.
*  APPEND wa_fieldcat TO it_fieldcat.

  CLEAR:wa_fieldcat.
  wa_fieldcat-fieldname = 'SCHGT'.
  wa_fieldcat-scrtext_l = '散装物料'.
  wa_fieldcat-ref_table = 'MARC'.
  wa_fieldcat-ref_field = 'SCHGT'.
  APPEND wa_fieldcat TO it_fieldcat.


  CLEAR:wa_fieldcat.
  wa_fieldcat-fieldname = 'BKLAS'.
  wa_fieldcat-scrtext_l = '评估分类'.
  wa_fieldcat-ref_table = 'MBEW'.
  wa_fieldcat-ref_field = 'BKLAS'.
  APPEND wa_fieldcat TO it_fieldcat.

  CLEAR:wa_fieldcat.
  wa_fieldcat-fieldname = 'MLAST'.
  wa_fieldcat-scrtext_l = '价格确定'.
  wa_fieldcat-ref_table = 'MBEW'.
  wa_fieldcat-ref_field = 'MLAST'.
  APPEND wa_fieldcat TO it_fieldcat.

  CLEAR:wa_fieldcat.
  wa_fieldcat-fieldname = 'PEINH'.
  wa_fieldcat-scrtext_l = '价格单位'.
  wa_fieldcat-ref_table = 'MBEW'.
  wa_fieldcat-ref_field = 'PEINH'.
  APPEND wa_fieldcat TO it_fieldcat.

  CLEAR:wa_fieldcat.
  wa_fieldcat-fieldname = 'VPRSV'.
  wa_fieldcat-scrtext_l = '价格控制'.
  wa_fieldcat-ref_table = 'MBEW'.
  wa_fieldcat-ref_field = 'VPRSV'.
  APPEND wa_fieldcat TO it_fieldcat.

  CLEAR:wa_fieldcat.
  wa_fieldcat-fieldname = 'EKALR'.
  wa_fieldcat-scrtext_l = '用QS的成本估算'.
  wa_fieldcat-ref_table = 'MBEW'.
  wa_fieldcat-ref_field = 'EKALR'.
  APPEND wa_fieldcat TO it_fieldcat.

  CLEAR:wa_fieldcat.
  wa_fieldcat-fieldname = 'HKMAT'.
  wa_fieldcat-scrtext_l = '物料来源'.
  wa_fieldcat-ref_table = 'MBEW'.
  wa_fieldcat-ref_field = 'HKMAT'.
  APPEND wa_fieldcat TO it_fieldcat.

  CLEAR:wa_fieldcat.
  wa_fieldcat-fieldname = 'AWSLS'.
  wa_fieldcat-scrtext_l = '差异码'.
  wa_fieldcat-ref_table = 'MARC'.
  wa_fieldcat-ref_field = 'AWSLS'.
  APPEND wa_fieldcat TO it_fieldcat.

  CLEAR:wa_fieldcat.
  wa_fieldcat-fieldname = 'LOSGR'.
  wa_fieldcat-scrtext_l = '成本核算批量'.
  wa_fieldcat-ref_table = 'MARC'.
  wa_fieldcat-ref_field = 'LOSGR'.
  APPEND wa_fieldcat TO it_fieldcat.

  CLEAR:wa_fieldcat.
  wa_fieldcat-fieldname = 'ZPLP1'.
  wa_fieldcat-scrtext_l = '计划价格1'.
  wa_fieldcat-ref_table = 'MBEW'.
  wa_fieldcat-ref_field = 'ZPLP1'.
  APPEND wa_fieldcat TO it_fieldcat.

  CLEAR:wa_fieldcat.
  wa_fieldcat-fieldname = 'ZPLD1'.
  wa_fieldcat-scrtext_l = '计划价格日期1'.
  wa_fieldcat-ref_table = 'MBEW'.
  wa_fieldcat-ref_field = 'ZPLD1'.
  APPEND wa_fieldcat TO it_fieldcat.


  CLEAR:wa_fieldcat.
  wa_fieldcat-fieldname = 'TYPE'.
  wa_fieldcat-scrtext_l = '消息类型'.
  APPEND wa_fieldcat TO it_fieldcat.


  CLEAR:wa_fieldcat.
  wa_fieldcat-fieldname = 'MESSAGE'.
  wa_fieldcat-scrtext_l = '消息'.
  APPEND wa_fieldcat TO it_fieldcat.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  FRM_LAYOUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM frm_layout .
  CLEAR layout.
  layout-box_fname  = 'BOX'.
  layout-sel_mode   = 'A'.     "选择行模式
  layout-cwidth_opt = 'X'.     "优化列宽设置
  layout-zebra      = 'X'.     "设置斑马线
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  FRM_DISPLAY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM frm_display .
  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY_LVC'
    EXPORTING
*     I_INTERFACE_CHECK        = ' '
*     I_BYPASSING_BUFFER       =
*     I_BUFFER_ACTIVE          =
      i_callback_program       = sy-repid
      i_callback_pf_status_set = 'FRM_SET_STATUS'
      i_callback_user_command  = 'FRM_SET_COMMAND'
*     I_CALLBACK_TOP_OF_PAGE   = ' '
*     I_CALLBACK_HTML_TOP_OF_PAGE       = ' '
*     I_CALLBACK_HTML_END_OF_LIST       = ' '
*     I_STRUCTURE_NAME         =
*     I_BACKGROUND_ID          = ' '
*     I_GRID_TITLE             =
*     I_GRID_SETTINGS          =
      is_layout_lvc            = layout
      it_fieldcat_lvc          = it_fieldcat
*     IT_EXCLUDING             =
*     IT_SPECIAL_GROUPS_LVC    =
*     IT_SORT_LVC              =
*     IT_FILTER_LVC            =
*     IT_HYPERLINK             =
*     IS_SEL_HIDE              =
*     I_DEFAULT                = 'X'
*     I_SAVE                   = ' '
*     IS_VARIANT               =
*     IT_EVENTS                =
*     IT_EVENT_EXIT            =
    TABLES
      t_outtab                 = gt_alv
    EXCEPTIONS
      program_error            = 1
      OTHERS                   = 2.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.


ENDFORM.

FORM frm_set_status USING rt_extab TYPE slis_t_extab.
  SET PF-STATUS 'STANDARD_FULLSCR'.
ENDFORM.


FORM frm_set_command USING  r_ucomm LIKE sy-ucomm
                         rs_selfield TYPE slis_selfield.
  "实时更新内表数据
  DATA:ref_grid TYPE REF TO cl_gui_alv_grid.

  CALL FUNCTION 'GET_GLOBALS_FROM_SLVC_FULLSCR'
    IMPORTING
      e_grid = ref_grid.                    " 获取全局变量

  CALL METHOD ref_grid->check_changed_data. " 获取响应事件
  rs_selfield-refresh = 'X'.

  CASE r_ucomm.
    WHEN 'CREATE'.
      PERFORM frm_create.

      "刷新ALV
      CALL FUNCTION 'GET_GLOBALS_FROM_SLVC_FULLSCR'
        IMPORTING
          e_grid = ref_grid.                    " 获取全局变量

      CALL METHOD ref_grid->check_changed_data. " 获取响应事件
      rs_selfield-refresh = 'X'.


  ENDCASE.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  FRM_CREATE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM frm_create .

  LOOP AT gt_alv INTO gs_alv WHERE type <> 'E' AND  box = 'X'.
    CLEAR gs_alv-flag.
    IF gs_alv-matnr IS INITIAL.
      gs_alv-flag = 'X'."flag用来标记该条数据是创建的
*&--创建物料，首先要获取物料号
      "获取物料编码
      CLEAR:return,material_number,material_number[].
      CALL FUNCTION 'BAPI_MATERIAL_GETINTNUMBER'
        EXPORTING
          material_type   = gs_alv-mtart
          industry_sector = 'M'
        IMPORTING
          return          = return
        TABLES
          material_number = material_number.
      READ TABLE material_number INDEX 1.
      gs_alv-matnr = material_number-material.
      IF gs_alv-matnr = ''.
        gs_alv-message = return-message.
      ENDIF.
    ELSEIF gs_alv-matnr IS NOT INITIAL.

*&---修改物料，用户传入的物料要加前导零
      CALL FUNCTION 'CONVERSION_EXIT_MATN1_INPUT'
        EXPORTING
          input        = gs_alv-matnr
        IMPORTING
          output       = gs_alv-matnr
        EXCEPTIONS
          length_error = 1
          OTHERS       = 2.
      IF sy-subrc <> 0.
* Implement suitable error handling here
      ENDIF.
    ENDIF.

*---------------------------头数据-------------------------------------------*
    headdata-material = gs_alv-matnr.   "带前导零的物料号
    headdata-ind_sector = 'M'.          "行业领域(机械行业)
    headdata-matl_type = gs_alv-mtart.  "物料类型
    headdata-storage_view = 'X'.       " 扩工厂视图

    headdata-basic_view = 'X'.          "扩基础视图
    IF r_sale  = 'X'.
      headdata-sales_view = 'X'.        "扩销售视图
    ENDIF.
    IF r_buy = 'X'.
      headdata-purchase_view  = 'X'.    "扩采购视图
    ENDIF.
    IF r_mrp = 'X'.
      headdata-mrp_view ='X'.           "扩MRP视图
      headdata-work_sched_view = 'X'.   "扩工作视图
    ENDIF.
    IF r_fi = 'X'.
      headdata-account_view = 'X'.       "扩会计视图
      headdata-cost_view = 'X'.          "扩成本视图
    ENDIF.


**----------------------------基础数据------------------------------------------*
    IF gs_alv-bismt <>  '/'.                 "旧物料号
      clientdata-old_mat_no = gs_alv-bismt.
      clientdata-old_mat_no_long = gs_alv-bismt.
      clientdata-inv_mat_no = gs_alv-bismt.
      clientdata-inv_mat_no_long = gs_alv-bismt.
      clientdatax-old_mat_no = 'X'.
      clientdatax-old_mat_no_long = 'X'.
      clientdatax-inv_mat_no = 'X'.
      clientdatax-inv_mat_no_long = 'X'.
    ENDIF.

    IF gs_alv-matkl <> '/' .               "物料组
      clientdata-matl_group = gs_alv-matkl.
      clientdatax-matl_group = 'X'.
    ENDIF.
    IF gs_alv-extwg <> '/'.
      clientdata-extmatlgrp = gs_alv-extwg.  " 外部物料组
      clientdatax-extmatlgrp = 'X'.
    ENDIF.

    IF gs_alv-groes <> '/'.              "大小量纲
      clientdata-size_dim = gs_alv-groes.
      clientdatax-size_dim = 'X'.
    ENDIF.

    IF gs_alv-meins <> '/'.              "基本计量单位
      CLEAR:lv_meins.
      CALL FUNCTION 'CONVERSION_EXIT_CUNIT_INPUT'
        EXPORTING
          input          = gs_alv-meins
          language       = sy-langu
        IMPORTING
          output         = lv_meins
        EXCEPTIONS
          unit_not_found = 1
          OTHERS         = 2.
      IF sy-subrc <> 0.
* Implement suitable error handling here
      ENDIF.
      clientdata-base_uom = lv_meins.
      clientdatax-base_uom = 'X'.
    ENDIF.
    IF gs_alv-blatt <> '/'.             " 箱数
      clientdata-page_no = gs_alv-blatt.
      clientdatax-page_no = 'X'.
    ENDIF.

    IF r_sale = 'X'.
*      IF gs_alv-spart <> '/'.            "产品组
*        clientdata-division = gs_alv-spart.
*        clientdatax-division = 'X'.
*      ENDIF.
      IF gs_alv-tragr <> '/'.           "运输组
        clientdata-trans_grp = gs_alv-tragr .
        clientdatax-trans_grp = 'X'.
      ENDIF.
    ENDIF.

*--------------------------------工厂数据-------------------------------------*

    plantdata-plant = gs_alv-werks.                        "工厂
    plantdatax-plant  = gs_alv-werks.

    IF r_sale = 'X'.
      IF gs_alv-mtvfp <> '/'.                     "可用性检查
        plantdata-availcheck = gs_alv-mtvfp.
        plantdatax-availcheck = 'X'.
      ENDIF.
      IF gs_alv-ladgr <> '/'.                     "装载组
        plantdata-loadinggrp = gs_alv-ladgr.
        plantdatax-loadinggrp = 'X'.
      ENDIF.
    ENDIF.

    IF r_buy  = 'X'.

      IF gs_alv-xchpf <> '/'.
        clientdata-batch_mgmt = gs_alv-xchpf.
        clientdatax-batch_mgmt = 'X'.
        plantdata-batch_mgmt = gs_alv-xchpf .                          "批次管理
        plantdatax-batch_mgmt = 'X' .
      ENDIF.

    ENDIF.

    IF r_mrp = 'X'.
      IF gs_alv-dismm <> '/'.
        plantdata-mrp_type = gs_alv-dismm.                "MRP类型
        plantdatax-mrp_type   = 'X'.
      ENDIF.
      IF gs_alv-dispo <> '/'.
        plantdata-mrp_ctrler = gs_alv-dispo.              "MRP控制者
        plantdatax-mrp_ctrler = 'X'.
      ENDIF.
      IF gs_alv-disls <> '/'.
        plantdata-lotsizekey = gs_alv-disls.              "批量大小
        plantdatax-lotsizekey = 'X'.
      ENDIF.
      IF gs_alv-bstmi <> '/'.
        CLEAR lv_bstmi.
        CONDENSE gs_alv-bstmi NO-GAPS.
        lv_bstmi = gs_alv-bstmi.
        plantdata-minlotsize = lv_bstmi.              "最小批量大小
        plantdatax-minlotsize = 'X'.
      ENDIF.
      IF gs_alv-bstfe <> '/'.
        CLEAR lv_bstfe .
        CONDENSE gs_alv-bstfe NO-GAPS.
        lv_bstfe = gs_alv-bstfe.
        plantdata-fixed_lot  = lv_bstfe.              "固定批量大小
        plantdatax-fixed_lot  = 'X'.
      ENDIF.
      IF gs_alv-bstrf <> '/'.
        CLEAR lv_bstrf.
        CONDENSE gs_alv-bstrf NO-GAPS.
        lv_bstrf = gs_alv-bstrf.
        plantdata-round_val  = lv_bstrf.              "舍入值
        plantdatax-round_val  = 'X'.
      ENDIF.
      IF gs_alv-beskz <> '/'.
        plantdata-proc_type  = gs_alv-beskz.              "采购类型
        plantdatax-proc_type  = 'X'.
      ENDIF.
      IF gs_alv-sobsl <> '/'.
        plantdata-spproctype = gs_alv-sobsl.              "特殊采购类型
        plantdatax-spproctype = 'X'.
      ENDIF.
      IF gs_alv-rgekz <> '/'.
        plantdata-backflush  = gs_alv-rgekz.              "反冲
        plantdatax-backflush  = 'X'.
      ENDIF.
      IF gs_alv-lgpro <> '/'.
        plantdata-iss_st_loc = gs_alv-lgpro.              "生产仓储地点
        plantdatax-iss_st_loc = 'X'.
      ENDIF.
      IF gs_alv-lgfsb <> '/'.
        plantdata-sloc_exprc = gs_alv-lgfsb.              "外部采购仓储地点
        plantdatax-sloc_exprc = 'X'.
      ENDIF.
      IF gs_alv-dzeit <> '/'.
        CLEAR lv_dzeit.
        CONDENSE gs_alv-dzeit NO-GAPS.
        lv_dzeit = gs_alv-dzeit.
        plantdata-inhseprodt = lv_dzeit.              "自制生产(问题)
        plantdatax-inhseprodt = 'X'.
      ENDIF.
      IF gs_alv-plifz <> '/'.
        CLEAR lv_plifz.
        CONDENSE gs_alv-plifz NO-GAPS.
        lv_plifz = gs_alv-plifz.
        plantdata-plnd_delry = lv_plifz.              "计划交货时间
        plantdatax-plnd_delry = 'X'.
      ENDIF.
      IF gs_alv-eisbe <> '/'.
        CLEAR lv_eisbe.
        CONDENSE gs_alv-eisbe NO-GAPS.
        lv_eisbe = gs_alv-eisbe.
        plantdata-safety_stk = lv_eisbe.              "安全库存
        plantdatax-safety_stk = 'X'.
      ENDIF.
      IF gs_alv-mtvfp2 <> '/'.
        plantdata-availcheck = gs_alv-mtvfp2.             "可用性检查 (个别需求)
        plantdatax-availcheck = 'X'.
      ENDIF.
      IF gs_alv-strgr <> '/'.
        plantdata-plan_strgp = gs_alv-strgr.              "策略组
        plantdatax-plan_strgp = 'X'.
      ENDIF.
      IF gs_alv-vrmod <> '/'.
        plantdata-consummode = gs_alv-vrmod.              "消耗模式
        plantdatax-consummode = 'X'.
      ENDIF.
      IF gs_alv-vint1 <> '/'.
        CLEAR lv_vint1.
        CONDENSE gs_alv-vint1 NO-GAPS.
        lv_vint1 = gs_alv-vint1.
        plantdata-bwd_cons = lv_vint1.                "逆向消耗期间
        plantdatax-bwd_cons = 'X'.
      ENDIF.
      IF gs_alv-vint2 <> '/'.
        CLEAR lv_vint2.
        CONDENSE gs_alv-vint2 NO-GAPS.
        lv_vint2 = gs_alv-vint2.
        plantdata-fwd_cons = lv_vint2.                "向前消耗期间
        plantdatax-fwd_cons = 'X'.
      ENDIF.
      IF gs_alv-sbdkz <> '/'.
        plantdata-dep_req_id = gs_alv-sbdkz.              "独立/集中
        plantdatax-dep_req_id = 'X'.
      ENDIF.
      IF gs_alv-sauft <> '/'.
        plantdata-rep_manuf = gs_alv-sauft.               "重复制造
        plantdatax-rep_manuf = 'X'.
      ENDIF.
      IF gs_alv-sfepr <> '/'.
        plantdata-repmanprof = gs_alv-sfepr.              "重复制造参数文件
        plantdatax-repmanprof = 'X'.
      ENDIF.
      IF gs_alv-fevor <> '/'.
        plantdata-production_scheduler = gs_alv-fevor.    "生产调度员
        plantdatax-production_scheduler = 'X'.
      ENDIF.

      IF gs_alv-schgt <> '/'.
        plantdata-bulk_mat = gs_alv-schgt.             "散装物料
        plantdatax-bulk_mat = 'X'.
      ENDIF.
    ENDIF.

    IF r_fi = 'X'.
      IF gs_alv-awsls <> '/'.
        plantdata-variance_key = gs_alv-awsls.                 "差异码
        plantdatax-variance_key = 'X'.
      ENDIF.
      IF gs_alv-losgr <> '/'.
        CLEAR lv_losgr.
        CONDENSE gs_alv-losgr NO-GAPS.
        lv_losgr = gs_alv-losgr.
        plantdata-lot_size = lv_losgr.                        "成本核算批量
        plantdatax-lot_size = 'X'.
      ENDIF.
    ENDIF.

*---------------------------销售数据-------------------------------------------*

    IF r_sale = 'X'.
      salesdata-sales_org = gs_alv-vkorg.                   "销售组织
      salesdatax-sales_org = gs_alv-vkorg.

      salesdata-distr_chan = gs_alv-vtweg.                  "分销渠道
      salesdatax-distr_chan = gs_alv-vtweg.

      IF gs_alv-dwerk <> '/'.
        salesdata-delyg_plnt =  gs_alv-dwerk.               "交货工厂
        salesdatax-delyg_plnt = 'X'.
      ENDIF.
      IF gs_alv-ktgrm <> '/'.
        salesdata-acct_assgt = gs_alv-ktgrm.                "科目设置组
        salesdatax-acct_assgt = 'X'.
      ENDIF.
      IF gs_alv-mtpos <> '/'.
        salesdata-item_cat = gs_alv-mtpos .                 "项目类别组
        salesdatax-item_cat = 'X'.
      ENDIF.
    ENDIF.

*--------------------------评估数据--------------------------------------------*

    IF r_fi = 'X'.

*&---20180109HANDZX
      IF gs_alv-flag = 'X'.
        plantdata-pur_status = 'Z1'.                            "工厂特定的物料状态
        plantdatax-pur_status = 'X'.
      ELSE.
        CLEAR gs_mbew.
        SELECT SINGLE * FROM mbew  INTO gs_mbew WHERE matnr = gs_alv-matnr.
        IF sy-subrc <> 0.
          plantdata-pur_status = 'Z1'.                            "工厂特定的物料状态
          plantdatax-pur_status = 'X'.
        ENDIF.

      ENDIF.
*&--

      valuationdata-val_area  = gs_alv-werks.                 "评估范围为工厂
      valuationdatax-val_area  = gs_alv-werks.

      IF gs_alv-bklas <> '/'.
        valuationdata-val_class = gs_alv-bklas.               "评估分类
        valuationdatax-val_class =  'X'.
      ENDIF.
      IF gs_alv-mlast <> '/'.
        valuationdata-ml_settle = gs_alv-mlast.               "价格确定
        valuationdatax-ml_settle =   'X'.
      ENDIF.
      IF gs_alv-peinh <> '/'.
        CLEAR lv_peinh.
        CONDENSE gs_alv-peinh NO-GAPS.
        lv_peinh = gs_alv-peinh.
        valuationdata-price_unit = lv_peinh.                  "价格单位
        valuationdatax-price_unit =   'X'.
      ENDIF.
      IF gs_alv-vprsv <> '/'.
        valuationdata-price_ctrl = gs_alv-vprsv.              "价格控制标识
        valuationdatax-price_ctrl =  'X'.
      ENDIF.
      IF gs_alv-ekalr <> '/'.
        valuationdata-qty_struct =  gs_alv-ekalr.             "用QS的成本估算
        valuationdatax-qty_struct =   'X'.
      ENDIF.
      IF gs_alv-hkmat <> '/'.
        valuationdata-orig_mat =   gs_alv-hkmat.              "物料来源
        valuationdatax-orig_mat =   'X'.
      ENDIF.
      IF gs_alv-zplp1 <> '/'.
        CLEAR lv_zplp1.
        CONDENSE gs_alv-zplp1 NO-GAPS.
        lv_zplp1 = gs_alv-zplp1.
        valuationdata-plndprice1 =  lv_zplp1.                 "计划价格1
        valuationdatax-plndprice1 =    'X'.
      ENDIF.
      IF gs_alv-zpld1 <> '/'.
        lv_zpld1 = gs_alv-zpld1.
        valuationdata-plndprdate1 = lv_zpld1.                 "计划价格日期1
        valuationdatax-plndprdate1 =  'X'.
      ENDIF.
    ENDIF.

    IF gs_alv-maktx <> '/'.
      wa_materialdescription-langu = sy-langu.
      wa_materialdescription-matl_desc = gs_alv-maktx.        "客户料号
      APPEND wa_materialdescription TO materialdescription.
    ENDIF.
*
    IF r_sale = 'X'.
      IF gs_alv-taxm1 <> '/'.
        wa_taxclassifications-depcountry = 'CN'.
        wa_taxclassifications-tax_type_1 = 'MWST'.
        wa_taxclassifications-taxclass_1 = gs_alv-taxm1.      "税分类1
        APPEND wa_taxclassifications TO taxclassifications.
      ENDIF.
    ENDIF.
    CALL FUNCTION 'BAPI_MATERIAL_SAVEDATA'
      EXPORTING
        headdata             = headdata
        clientdata           = clientdata
        clientdatax          = clientdatax
        plantdata            = plantdata
        plantdatax           = plantdatax
        storagelocationdata  = storagelocationdata
        storagelocationdatax = storagelocationdatax
        valuationdata        = valuationdata
        valuationdatax       = valuationdatax
        salesdata            = salesdata
        salesdatax           = salesdatax
      IMPORTING
        return               = return2
      TABLES
        materialdescription  = materialdescription
        taxclassifications   = taxclassifications
        returnmessages       = returnmessages.
    READ TABLE returnmessages INTO wa_returnmessages WITH KEY type = 'E'.
    IF sy-subrc = 0 .

      CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'
*       IMPORTING
*         RETURN        =
        .
      gs_alv-type = 'E'.
      gs_alv-icon = icon_red_light.

      IF gs_alv-flag = 'X'.
        "未创建成功的内部物料号不显示
        gs_alv-matnr = ''.
      ENDIF.

      CONCATENATE gs_alv-message  wa_returnmessages-message INTO gs_alv-message.

      MODIFY gt_alv FROM gs_alv.

    ELSE.
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          wait = 'X'
*   IMPORTING
*         RETURN        =
        .
      gs_alv-type = 'S'.
      gs_alv-icon = icon_green_light.
      gs_alv-message = return2-message.
      MODIFY gt_alv FROM gs_alv.


      "如果批次管理选择为'X',则扩充分类视图
      IF gs_alv-flag = 'X'.
        IF gs_alv-xchpf = 'X' AND gs_alv-mtart = 'Z001'.
          objectkeynew_long = gs_alv-matnr.
          CALL FUNCTION 'BAPI_OBJCL_CREATE'
            EXPORTING
*             OBJECTKEYNEW      =
              objecttablenew    = 'MARA'
              classnumnew       = 'ZCHARG_P'
              classtypenew      = '023'
              status            = '1'
              standardclass     = 'X' "此处务必赋值‘X’，是为了bapi执行成功之后，MM03查看物料可以看到分类视图
*             CHANGENUMBER      =
*             KEYDATE           = SY-DATUM
*             NO_DEFAULT_VALUES = ' '
              objectkeynew_long = objectkeynew_long
*         IMPORTING
*             CLASSIF_STATUS    =
            TABLES
*             ALLOCVALUESNUM    =
*             ALLOCVALUESCHAR   =
*             ALLOCVALUESCURR   =
              return            = return3.

          READ TABLE return3 INTO wa_return3 WITH KEY type = 'E'.
          IF sy-subrc <> 0.
            COMMIT WORK AND WAIT .
          ENDIF.
        ELSEIF gs_alv-xchpf = 'X' AND gs_alv-mtart <> 'Z001'.
          objectkeynew_long = gs_alv-matnr.
          CALL FUNCTION 'BAPI_OBJCL_CREATE'
            EXPORTING
*             OBJECTKEYNEW      =
              objecttablenew    = 'MARA'
              classnumnew       = 'ZCHARG'
              classtypenew      = '023'
              status            = '1'
              standardclass     = 'X' "此处务必赋值‘X’，是为了bapi执行成功之后，MM03查看物料可以看到分类视图
*             CHANGENUMBER      =
*             KEYDATE           = SY-DATUM
*             NO_DEFAULT_VALUES = ' '
              objectkeynew_long = objectkeynew_long
*         IMPORTING
*             CLASSIF_STATUS    =
            TABLES
*             ALLOCVALUESNUM    =
*             ALLOCVALUESCHAR   =
*             ALLOCVALUESCURR   =
              return            = return3.

          READ TABLE return3 INTO wa_return3 WITH KEY type = 'E'.
          IF sy-subrc <> 0.
            COMMIT WORK AND WAIT .
          ENDIF.
        ENDIF.
      ENDIF.

    ENDIF.
    CLEAR:gs_alv.
    CLEAR:headdata,clientdata,clientdatax, plantdata,plantdatax,salesdata,salesdatax,valuationdata,valuationdatax,
          taxclassifications,wa_taxclassifications,materialdescription,wa_materialdescription ,return2,returnmessages,wa_returnmessages.

    WAIT UP TO '0.1' SECONDS.

  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form ALSM_XLSX_TO_TABLE
*&---------------------------------------------------------------------*
*&调用XLSX转内表程序
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM alsm_xlsx_to_table .


  i_filename = filename.

  CALL FUNCTION 'ALSM_EXCEL_TO_INTERNAL_TABLE'
    EXPORTING
      filename                = i_filename
      i_begin_col             = 1
      i_begin_row             = 2
      i_end_col               = 255
      i_end_row               = 65535
    TABLES
      intern                  = itab
    EXCEPTIONS
      inconsistent_parameters = 1
      upload_ole              = 2
      OTHERS                  = 3.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.

  IF itab[] IS NOT INITIAL.
    LOOP AT itab.
      ON CHANGE OF itab-row.      " ITAB-ROW值有变化就执行以下语句
        IF sy-tabix NE 1.
          APPEND i_tab.
          CLEAR i_tab.
        ENDIF.
      ENDON.

      ASSIGN COMPONENT itab-col OF STRUCTURE i_tab TO <fs>.
      <fs> = itab-value.
    ENDLOOP.
    APPEND i_tab.
    CLEAR i_tab.
  ENDIF.
  LOOP AT i_tab.
    CLEAR gs_up.
    MOVE-CORRESPONDING i_tab TO gs_up.
    APPEND gs_up TO gt_up.
    CLEAR i_tab.
  ENDLOOP.



ENDFORM.