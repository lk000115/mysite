//alert("hello !!!") ;   alert不能在node环境中运行
var aa = "ffff" ;
var chr = typeof(aa);
console.log("console.log 命令可以直接在node环境中运行");
console.log('------------------------------');

function Student(props) {
   this.name = props.name || 'Unnamed';
}

Student.prototype.hello = function () {
   alert('Hello, ' + this.name + '!');
}
