//alert("hello !!!") ;   alert不能在node环境中运行
var aa = "ffff" ;
var chr = typeof(aa);
console.log("console.log 命令可以直接在node环境中运行");
console.log(chr) ;
console.log('------------------------------');
var box = new Object();
box.name = "like" ;
box.age = 20 ;
console.log(box);
