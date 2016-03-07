import QtQuick 2.0

Item {
    property bool isTest: true
    id: describe
    property int expectedCalls
    property int __counter: 0
    property int delay: 100
    property var jasmine
    property var functions: []
    property var compareRender
    Timer{
        id: startupTimer
        interval: delay
        triggeredOnStart: false
        onTriggered: {
            console.log("START")
            for (var prop in describe) {
                if(typeof describe[prop] === 'function') {
                    if(prop.indexOf("it_") === 0){
                        functions.push(describe[prop]);
                    }
                }
            }
            console.log(functions)
            run(0, function(){

            })
        }
    }
    function start() {
        startupTimer.start();
    }

    function run(i, cb){
        if(i >= functions.length){
            cb()
            return
        }

        var fn = functions[i]
        if(functions[i].length === 0){ //no callback argument
            fn()
            run(i + 1, cb) //TODO: should not nest when not using callback

        }
        else {
            console.log("async")
            fn(function(){
                run(i + 1, cb)
            })
        }
    }



    function expect(value){
      console.log("expect", value)
      if(jasmine !== undefined){
        return jasmineExpect(value)
      }
      else{
        return qtExpect(value);
      }
    }
    function done(){
      if(jasmine !== undefined){
         jasmine.done()
      }
      else{
        Qt.quit()
      }
    }

    function jasmineExpect(value){
        var exp = jasmine.expect(value)
        var oldExp = exp.toBe.bind(exp);
        exp.toBe = function(value){
           __counter += 1
           console.log("counter", __counter)
           oldExp(value)

           if(__counter === expectedCalls){
              console.log("done", value)
              done()
           }
        }
        return exp
    }



    function qtExpect(value){
      return {
           toBe: function(expected){
               __counter += 1
               console.log("counter", __counter)
               if(expected !== value){
                   console.log("FAILED: expected " + expected + " to be " + value);
               }
               else console.log("PASS");
               console.log("expectedCalls", expectedCalls, __counter)
               if(__counter === expectedCalls){
                   console.log("done")
                   done()
               }
           }
       }
    }

}
