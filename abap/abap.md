## SAP笔记
### abap 程序命名规则  
  c. 全局变量 GXX_XXX
        变量                        GV_  
        内表（Internal Table）       GT_  
        结构（Structure）            GS_  
        Range                       R_  
        常量                         C_  
        类型（Type）                 GTY_  
        Parameters                   P_  
        Select-options               S_  
  d. 局部变量 LX_XXX  
        变量                         LV_  
        内表                         LT_  
        结构                         LS_  
### sap-abap使用记录 

* message 的用法  [原文链接](https://blog.csdn.net/qq_37625033/article/details/61918244)
  错误消息类型:  S成功   E 错误   W  警告  I  消息  A  错误  X 系统错误
  * ` MESSAGE  '错误信息'  TYPE 'E'  DISPLAY LIKE  'W' ` 
  * ` message E001(Zlk01) with   变量  DISPLAY LIKE  'W' . `   "其中变量替代自定义消息(ZLK01)中的占位符  
* smartforms 使用
* se78 向系统中增加图片    

* 选择单行数据 `select single * from  数据库 into 工作区  where 条件 `
* 选择多行数据 
    ``` 
    select * from 数据库  into 工作区 
         语句块
    endselect  
    ```
* 选择至内表 `select * from 数据库 into table 内表 where 条件 ` 
* 事件处理  
* 在类C中定义事件,C类的实现中定义触发事件的方法并触发事件,
* 在类B中定义方法关联类C中的事件,把类B的对象中的方法注册到类C的对象中
* 效果就是: 类C的对象事件触发时,会执行类B对象中的相应方法
  1.声明事件          ` envents : 事件名 `  
  2.触发事件条件      `if  满足条件 raise event 事件名  of  类名`  
  3.声明事件处理方法  `methods 方法名  for event 事件名  of 类名`  
  4.注册事件          `set handler   类名-->方法  for 对象名 `  
* 把结构体中的字段分配给字段符号  ` assign componet 'matnr'  of structure gs_makt to <fs_field> `   通过字段名  
                               ` assign componet 1  of structure gs_makt to <fs_field> `         通过第几个字段   
* ALSM_EXCEL_TO_INTERNAL_TABLE    XLSX转内表程序                                
* ALV 报表配置步骤  
  ```  
    1. ALV 参数设置
      DATA: it_fieldcat TYPE lvc_t_fcat, " 字段目录内表  
            wa_field TYPE lvc_s_fcat, " 字段目录工作区  
            Wa_layout      TYPE lvc_s_layo. " ALV布局  
    2. 定义宏,简化ALV内表目录字段配置
        DEFINE OUTTAB. "field宏设置
          CLEAR wa_field.
          wa_field-reptext    = &1.    " alv字段显示文本
          wa_field-ref_field  = &2.
          wa_field-ref_table  = &3.
          wa_field-no_zero    = &4.
          wa_field-fieldname  = &5.     
          wa_field-icon       = &6.
          APPEND wa_field TO it_fieldcat.
          CLEAR wa_field.
        END-OF-DEFINITION.   
    3. OUTTAB  '&1'  '&2'  '&3' '&4'  '&5'  '&6'  

  ```
* 选择屏幕  parameters    select-options   
*  CONVERSION_EXIT_CUNIT_OUTPUT    ABAP单位转换函数
*  CONVERSION_EXIT_ALPHA_OUTPUT    去前导0函数  
* 赛依视频 BDC 包含 消息处理  
  