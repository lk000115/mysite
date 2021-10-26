## SAP笔记

### sap-abap使用记录 

* message 的用法  [原文链接](https://blog.csdn.net/qq_37625033/article/details/61918244)
  错误消息类型:  S成功   E 错误   W  警告  I  消息  A  错误  X 系统错误
  ` MESSAGE  '错误信息'  TYPE 'E'  DISPLAY LIKE  'W' ` 
  ` message E001(Zlk01) with   变量  DISPLAY LIKE  'W' . `   "其中变量替代自定义消息(ZLK01)中的占位符  
* smartforms 使用
  se78 向系统中增加图片  