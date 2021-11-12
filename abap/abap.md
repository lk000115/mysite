## SAP笔记

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
  1.声明事件          ` envents : 事件名 `  
  2.触发事件条件      `if  满足条件 raise event 事件名  of  类名`  
  3.声明事件处理方法  `methods 方法名  for event 事件名  of 类名`  
  4.注册事件          `set handler   类名-->方法  for 对象名 `  
*   