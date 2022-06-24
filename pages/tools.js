// 两个对象之间的深层拷贝
function deepClone(origin, target) {
    var target = target || {},
        tostr = Object.prototype.toString,
        arrStr = "[object Array]";
    for (var prop in origin) {
        if (origin.hasOwnProperty(prop)) {
            if (typeof target[prop] == 'object') {

                if (tostr.call(origin[prop]) == arrStr) {
                    target[prop] = [];
                } else {
                    target[prop] = {};
                }

                deepClone(origin[prop], target[prop]);

            } else {
                target[prop] = origin[prop];
            }

        }
    }
}

// 自定义判断对象类型函数type
function type(target) {
    var template = {
        "[object Array]": "array",
        "[object Object]": "object",
        "[object Number]": "number",
        "[object Boolean]": "boolean",
        "[object String]": "string"

    }
    if (target === null) {
        return null;
    }
    if (typeof (target) == "object") {
        var str = Object.prototype.toString.call(target);
        return template[str];
    } else {
        return typeof (target);
    }
}
// 数组去重,利用对象不能有重复的属性来操作
Array.prototype.unique = function () {
    var temp = {},
        arr = [],
        len = this.length;
    for (var i = 0; i < len; i++) {
        if (!temp[this[i]]) {
            temp[this[i]] = "abc";
            arr.push(this[i]);
        }
    }
    return arr;
}



// var obj1 = { name: "like", age: 20, arr: [1, 2, 3] };
// var obj2 = {};
// deepClone(obj1, obj2);
// console.log(obj2);


