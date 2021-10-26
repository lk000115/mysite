## SAP笔记

### sap-abap使用记录 

* message 的用法  [原文链接](https://blog.csdn.net/qq_37625033/article/details/61918244)
  错误消息类型:  S成功   E 错误   W  警告  I  消息  A  错误  X 系统错误
  ` MESSAGE  '错误信息'  TYPE 'E'  DISPLAY LIKE  'W' ` 
  ` message E001(Zlk01) with   变量  DISPLAY LIKE  'W' . `   "其中变量替代自定义消息(ZLK01)中的占位符  
* smartforms 使用
  se78 向系统中增加图片  

## 超简单的Excel密码破解

新开一Excel，同时按Alt+F11，进入VBA界面，点菜单上的插入，模块，在新出来的窗口粘贴一下代码：

` Sub crack()  
 Dim i As Long
  Dim FileName As String
  i = 0
 FileName = Application.GetOpenFilename("Excel文件（*.xls & *.xlsx）,*.xls;*.xlsx", , "VBA破解")
  FileName = Right(FileName, Len(FileName) - InStrRev(FileName, "\"))
  Application.ScreenUpdating = False
  line2: On Error GoTo line1
  Workbooks.Open FileName, , True, , i
  MsgBox "Password is " & i
  Exit Sub
  line1: i = i + 1
  Resume line2
  Application.ScreenUpdating = True
 End Sub `
  然后在当前界面，按F5运行此宏，然后选择文件加密需要破解的EXCEL开始进行破解，这个破解速度是看你的密码对的长度、复杂程度、电脑配置。小编测试的一个【12】，是秒破。

[原文链接](https://blog.csdn.net/qq_22903531/article/details/83410527)

## git命令使用     [使用教程链接:](https://www.runoob.com/git/git-fetch.html) 

1. `git init `                                                   "初始化本地仓库
2. `git  add  要增加或修改的文件名  `             "可以同时增加多个文件,文件之间用空格隔开 
3. `git commit -m  "本次提交的备注" `                
4. `git  status `                                              " 查看git的修改状态   
5. ` git diff     `                                                    " 
6. ` git reset  --hard 要回退版本号前4位 `         ''版本号也可以用HEAD  表示回退到最近的版本
7.  `git log `                                                      "修改日志,可以查看提交历史
8.  `git  reflog `                                               "用来记录你的每一次命令      
9. `git checkout -- readme.txt`                     "把`readme.txt`文件在工作区的修改全部撤销
10. `git checkout -- file`命令中的`--`很重要，没有`--`，就变成了“切换到另一个分支”的命令
11. 场景1：当你改乱了工作区某个文件的内容，想直接丢弃工作区的修改时，用命令`git checkout -- file`。

    场景2：当你不但改乱了工作区某个文件的内容，还添加到了暂存区时，想丢弃修改，分两步，第一步用命令`git reset HEAD <file>`，就回到了场景1，第二步按场景1操作。

    场景3：已经提交了不合适的修改到版本库时，想要撤销本次提交，参考[版本回退](https://www.liaoxuefeng.com/wiki/896043488029600/897013573512192)一节，不过前提是没有推送到远程库
    
12. `ssh-keygen -t rsa -C "youremail@example.com" `  [原文链接](https://www.liaoxuefeng.com/wiki/896043488029600/896954117292416)
13. `git remote add origin git@github.com:lk000115/mysite.git `  "关联远程库,远程库的名称 "origin"
14. `git push -u origin master`  把本地库的内容推送到远程库,默认master分支
15. git push -u origin master -f "使用强制push的方法,推送失败时使用
16. push 失败     [原文链接](https://www.cnblogs.com/xu-ux/p/13844977.html)
17. git clone git@github.com:lk000115/mysite.git  "从远程克隆数据仓库
18. `git checkout -b dev` 命令加上-b参数表示创建并切换，相当于以下两条命令：
     `git branch dev`
     `git checkout dev`
19. 用git branch命令查看当前分支
20. `git fetch origin master`  把远程库更新到本地  [原文链接：](https://scofieldwyq.github.io/2016/02/29/git%E4%BB%8E%E8%BF%9C%E7%A8%8B%E5%BA%93%E5%90%8C%E6%AD%A5%E5%88%B0%E6%9C%AC%E5%9C%B0%E4%BB%93%E5%BA%93/)

21. git pull <远程主机名> <远程分支名>:<本地分支名> "把远程库的更新同步到本地库  
