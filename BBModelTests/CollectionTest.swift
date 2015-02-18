//
//  CollectionTest.swift
//  BBModel
//
//  Created by Maeda Tasuku on 2/8/15.
//
//

import Foundation
import XCTest
import BBModel

class MockUser: Model{
    var name:String? {
        get{ return self.get("name") as? String }
        set{ self.set("name", newValue) }
    }
    override init() {
        super.init()
    }
}

class CollectionTest: XCTestCase {
    var collection:Collection!
    
    override func setUp() {
        super.setUp()
        collection = Collection()
    }
    
    override func tearDown() {
        self.collection = nil
        super.tearDown()
    }
    
    func test_init(){
        XCTAssertNotNil(collection)
    }
    
    func test_initWithArg(){
        collection = Collection(models:nil, options: nil)
        XCTAssertNotNil(collection)

        collection = Collection(models:nil, options: ["model":MockUser.self])

        XCTAssertTrue(collection.model === MockUser.self)
        
        var model1 = MockUser()
        var model2 = MockUser()
        collection = Collection(models:[model1, model2], options:["model":MockUser.self])
        
        XCTAssertTrue(collection.length == 2)
    }
    
    func test_add1(){
        let user1 = MockUser()
        collection.add(user1)
        XCTAssertTrue(collection.length == 1)
        
        collection.add(user1)
        XCTAssertTrue(collection.length == 1)
    }
    
    func test_add2(){
        let user1 = MockUser()
        let user2 = MockUser()
        collection.add([user1, user2])
        XCTAssertTrue(collection.length == 2)
        
        collection.add(user1)
        XCTAssertTrue(collection.length == 2)
        
        collection.add([user2, user1])
        XCTAssertTrue(collection.length == 2)
        
        let user3 = MockUser()
        collection.add([user3, user1])
        XCTAssertTrue(collection.length == 3)
        
        var count = 0
        collection.on(Collection.Event.ADD) {
            (model, collection, options) in
            count = count + 1
//            println("model cid = \(model.cid)")
        }
        let user4 = MockUser()
        collection.add(user4, options: ["silent":true])
        XCTAssertTrue(count == 0)
        XCTAssertTrue(collection.length == 4)
        
        let user5 = MockUser()
        collection.add(user5, options: ["silent":false])
        XCTAssertTrue(count == 1)
        XCTAssertTrue(collection.length == 5)
//        println("original cid = \(user5.cid)")
    }
    
    func test_set(){
        let user1 = MockUser()
        user1.name = "user1"
        let user2 = MockUser()
        user2.name = "user2"
        let user3 = MockUser()
        user3.name = "user3"
        
        collection.set([user1, user2, user3], options: nil)
        
        XCTAssertTrue(collection.length == 3)
        
        user1.name = "user1_new"
        collection.set([user1, user2, user3], options: nil)
        
        XCTAssertTrue(collection.length == 3)
        let user1_1:MockUser = collection.get(user1.cid) as MockUser
        XCTAssertTrue(user1_1.name == user1.name)
        
        collection.set([user1, user3], options: nil)
        
        XCTAssertTrue(collection.length == 2)
    }
    
    func test_remove(){
        let user1 = MockUser()
        user1.name = "user1"
        let user2 = MockUser()
        user2.name = "user2"
        let user3 = MockUser()
        user3.name = "user3"
        
        collection.add([user1, user2, user3], options: nil)
        
        var removeCallbackCount = 0
        collection.on(Collection.Event.REMOVE) {
            (model, collection, options) in
            removeCallbackCount = removeCallbackCount + 1
        }
        
        collection.remove(user1, options: nil)
        
        XCTAssertTrue(collection.length == 2)
        XCTAssertTrue(removeCallbackCount == 1)
        
        collection.remove(user2, options: ["silent":true])
        XCTAssertTrue(collection.length == 1)
        XCTAssertTrue(removeCallbackCount == 1)
        
        collection.remove([user3])
        XCTAssertTrue(collection.length == 0)
        XCTAssertTrue(removeCallbackCount == 2)
    }
    
    func test_reset(){
        let user1 = MockUser()
        user1.name = "user1"
        let user2 = MockUser()
        user2.name = "user2"
        let user3 = MockUser()
        user3.name = "user3"
        
        collection.add([user1, user2, user3], options: nil)
        
        var callbackCount = 0
        collection.on(Collection.Event.RESET) {
            (collection, options) in
            callbackCount = callbackCount + 1
        }
        
        collection.reset()
        
        XCTAssertTrue(collection.length == 0)
        XCTAssertTrue(callbackCount == 1)
        
        collection.add([user1], options: nil)
        
        collection.reset([user2, user3], options: nil)
        
        XCTAssertTrue(collection.length == 2)
        XCTAssertTrue(callbackCount == 2)
        
        collection.reset(nil, options:["silent":true])
        
        XCTAssertTrue(collection.length == 0)
        XCTAssertTrue(callbackCount == 2)
    }
    
    func test_push(){
        let user1 = MockUser()
        let user2 = MockUser()
        let user3 = MockUser()
        
        let push1 = collection.push(user1)
        let at1 = collection.at(0)
        XCTAssertTrue(collection.length == 1)
        XCTAssertTrue(push1.cid == user1.cid)
        XCTAssertTrue(at1?.cid == user1.cid)
        
        let push2 = collection.push(user2)
        let at2 = collection.at(1)
        XCTAssertTrue(collection.length == 2)
        XCTAssertTrue(push2.cid == user2.cid)
        XCTAssertTrue(at2?.cid == user2.cid)
        
        let push3 = collection.push(user3)
        let at3 = collection.at(2)
        XCTAssertTrue(collection.length == 3)
        XCTAssertTrue(push3.cid == user3.cid)
        XCTAssertTrue(at3?.cid == user3.cid)
    }
    
    func test_pop(){
        let user1 = MockUser()
        let user2 = MockUser()
        let user3 = MockUser()
        
        collection.add([user1, user2, user3])
        
        let pop1 = collection.pop()
        XCTAssertTrue(collection.length == 2)
        XCTAssertTrue(pop1?.cid == user3.cid)
        
        let pop2 = collection.pop()
        XCTAssertTrue(collection.length == 1)
        XCTAssertTrue(pop2?.cid == user2.cid)
        
        let pop3 = collection.pop()
        XCTAssertTrue(collection.length == 0)
        XCTAssertTrue(pop3?.cid == user1.cid)
    }
    
    func test_unshift(){
        let user1 = MockUser()
        let user2 = MockUser()
        let user3 = MockUser()
        
        let unshift1 = collection.unshift(user1)
        let at1 = collection.at(0)
        XCTAssertTrue(collection.length == 1)
        XCTAssertTrue(unshift1.cid == user1.cid)
        XCTAssertTrue(at1?.cid == user1.cid)
        
        let unshif2 = collection.unshift(user2)
        let at2 = collection.at(0)
        XCTAssertTrue(collection.length == 2)
        XCTAssertTrue(unshif2.cid == user2.cid)
        XCTAssertTrue(at2?.cid == user2.cid)
        
        let unshif3 = collection.unshift(user3)
        let at3 = collection.at(0)
        XCTAssertTrue(collection.length == 3)
        XCTAssertTrue(unshif3.cid == user3.cid)
        XCTAssertTrue(at3?.cid == user3.cid)
    }
    
    func test_shift(){
        let user1 = MockUser()
        let user2 = MockUser()
        let user3 = MockUser()
        
        collection.add([user1, user2, user3])
        
        let shift1 = collection.shift()
        XCTAssertTrue(collection.length == 2)
        XCTAssertTrue(shift1?.cid == user1.cid)
        
        let shift2 = collection.shift()
        XCTAssertTrue(collection.length == 1)
        XCTAssertTrue(shift2?.cid == user2.cid)
        
        let shift3 = collection.shift()
        XCTAssertTrue(collection.length == 0)
        XCTAssertTrue(shift3?.cid == user3.cid)
    }
    
    func test_at(){
        let user1 = MockUser()
        let user2 = MockUser()
        let user3 = MockUser()
        
        collection.add([user1, user2, user3])
        
        let at1 = collection.at(0)
        let at2 = collection.at(1)
        let at3 = collection.at(2)
        
        XCTAssertTrue(user1.cid == at1?.cid)
        XCTAssertTrue(user2.cid == at2?.cid)
        XCTAssertTrue(user3.cid == at3?.cid)
    }
    
    func test_slice(){
        var users = [Model]()
        for i in 0 ..< 10 {
            let user = MockUser()
            users.append(user)
            collection.add(user)
        }
        
        var sliced = collection.slice(2, end: 6)
        
        XCTAssertTrue(sliced?.count == (6 - 2))
        var count = 0
        for var i = 2; i < 6; i++ {
            XCTAssertTrue(users[i].cid == sliced?[count].cid)
            count++
        }
    }
    
    func test_models(){
        let user1 = MockUser()
        let user2 = MockUser()
        let user3 = MockUser()
        
        collection.add([user1, user2, user3])
        
        var users = collection.models
        
        users.removeAtIndex(0)
        
        XCTAssertTrue(users.count == 2)
        XCTAssertTrue(collection.length == 3)
    }
    
    func test_on(){
        var count:Int = 0
        collection.on(Collection.Event.ADD, callback: { (collection, options) -> Void in
            count = count + 1
            collection.off(Collection.Event.ADD, callbackId: (options?["callbackId"] as String))
        })
        
        collection.trigger(Collection.Event.ADD)
        
        XCTAssertTrue(count == 1)
        
        collection.trigger(Collection.Event.ADD)
        
        XCTAssertTrue(count == 1)
    }
}

