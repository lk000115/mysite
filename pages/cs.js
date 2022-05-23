//alert("hello !!!") ;   alert不能在node环境中运行
var aa = "ffff" ;
var chr = typeof(aa);
console.log("console.log 命令可以直接在node环境中运行");
console.log('------------------------------');

var value = 1;
function foo() {
  console.log("变量value   " + value);
}
function bar() {
  var value = 2;
  foo();
}
bar();


