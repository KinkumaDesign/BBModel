BBModel
====

## Overview

This is a swift Model library.
It imports Events, Model, Collection from Backbone.js.
But it omits network access and Collection's sort and where function now.

The purpose of making this is for study.


## How to Install

Copy Events.swift, Model.swift, Collection.swift under BBModel directory into your project.

## Events

Events object can register callback closure for some event. The callback emits after it triggers such event .

```swift
var event:Events = Events()
 
event.on("myevent") {
    (events, options) -> Void in
    println("callback 1")
}
 
event.trigger("myevent") //output => callback 1
```

It removes callbacks for some event using off("eventName"). It also remove specified callback using callbackId. You can get callbackId from events.on method's return value.

Note: If you use self keyword in closure, you have to use [unowned self] in it to prevent memory leak.

Resolving Strong Reference Cycles for Closures
<https://developer.apple.com/library/ios/documentation/Swift/Conceptual/Swift_Programming_Language/AutomaticReferenceCounting.html#//apple_ref/doc/uid/TP40014097-CH20-ID57>

You must remove all callbacks before Events object deinit. off() with no argument removes call callbacks.

```swift
var event:Events = Events()
 
event.on("myevent") {
    (events, options) -> Void in
    println("callback 1")
}
 
event.trigger("myevent") //output => callback 1
 
let callbackId = event.on("myevent") {
    [unowned self] (events, options) -> Void in
    println("self \(self)")
    println("callback 2'")
 
    //options contains callback's id
    let id = options["callbackId"]
 
    //You can remove this callback inner closure
    //event.off("myevent", callbackId:id) 
}
 
event.on("myevent") {
    (events, options) -> Void in
    println("callback 3")
}
 
event.trigger("myevent") //output => callback 1, 2, 3
 
//remove callback 2 only
event.off("myevent", callbackId: callbackId)
 
event.trigger("myevent") //output => callback 1, 3
 
//remove all callbacks
event.off("myevent")
 
event.trigger("myevent") //no callback
```

## Model

Model is properties container.

Suppose you make below sub class.

```swift
class Person: Model{
    var name:String?{
        get{ return self.get("name") as? String }
        set{ self.set("name", newValue!) }
    }
    var age:Int?{
        get{ return self.get("age") as? Int }
        set{ self.set("age", newValue!) }
    }
    override init(attributes: [String : Any]?) {
        super.init(attributes: attributes)
    }
     
    init(name:String = "", age:Int = 0) {
        super.init()
        self.name = name
        self.age = age
    }
}
```

Let's try using it.

```swift
//Use Model's init
var jane = Person(attributes: ["name":"Jane", "age":21])
 
//Use Person's init
var joe = Person(name:"Joe", age:18)
 
//Register Change event
//It emits when model's properties change.
joe.on(Model.events.CHANGE) {
    (model, options) in
     
    let aJoe = model as Person
    for (key, attr) in aJoe.changedAttributes {
        println("changed key:\(key), value:\(attr)")
        println("previous value:\(aJoe.previous(key))")
    }
}
 
//Set properties using dictionary
joe.set(["name":"Mr. Joe", "age":24])
 
//Set a property
joe.set("name", "Super Joe")
 
println("--")
 
//Set properties using Person's property
joe.name = "President Joe"
joe.age = 30
 
println("--")
 
//If you set silent true the callback doesn't emit.
tanaka.set("name", "Special Joe", options:["silent": true])
```

## Collection

Collection is Model's collection class.

Suppose you make below sub class.

```swift
class PersonCollection: Collection {
     
    override init(models: [Model]?, options: [String : Any]?) {
        super.init(models: models, options: options)
         
        //Register Model class
        self.model = Person.self
    }
}
```

Let's try using it.

```swift
var joe = Person(name:"Joe")
var jane = Person(name:"Jane")
var mike = Person(name:"Mike")
 
var personCollection =  PersonCollection(models: nil, options: nil)
 
//register Add event
personCollection.on(Collection.events.ADD) {
    (model, collection, options) in
    let p = model as Person
    println("Person \(p.name) is added")
}
 
//register Remove event
personCollection.on(Collection.events.REMOVE) {
    (model, collection, options) in
    let p = model as Person
    println("Person \(p.name) is removed")
}
 
//add a model
personCollection.add(joe)
 
//add models
personCollection.add([jane, mike])
 
//remove model
personCollection.remove(jane)
 
//remove models
personCollection.remove([joe, mike])
 
println("collection length = \(personCollection.length)") // 0
 
personCollection.add([jane, mike])
 
//set is convenience method
//If there is a same property key it overwrites it. If there is no same propety key it adds. If it is not included arguments it removes.
personCollection.set([joe, mike])
 
//other methods
/*
personCollection.pop()
personCollection.push()
personCollection.shift()
personCollection.unshift()
personCollection.at()
personCollection.has()
personCollection.indexOf()
*/
```

## Sample Project

Todo App => 
https://github.com/KinkumaDesign/BBModelTodo

## Licence

[MIT](https://github.com/tcnksm/tool/blob/master/LICENCE)

