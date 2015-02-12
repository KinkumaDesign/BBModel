//
//  ModelTest.swift
//  BBModel
//
//  Created by Maeda Tasuku on 2/8/15.
//
//

import Foundation
import XCTest
import BBModel

class ModelTest: XCTestCase {
    var model:Model!
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        model = nil
        super.tearDown()
    }
    
    func test_init(){
        model = Model()
        XCTAssertNotNil(model)
        
        var model2 = Model()
        XCTAssertTrue(model.cid != model2.cid)
    }
    
    func test_initWithAttributes(){
        model = Model(attributes: ["msg":"hello"])
        XCTAssertNotNil(model)
        
        XCTAssertEqual(model.attributes["msg"] as String, "hello")
    }
    
    func test_get(){
        model = Model(attributes: ["msg":"hello"])
        XCTAssertEqual(model.get("msg") as String, "hello")
    }
    
    func test_set(){
        model = Model()
        XCTAssertEqual(model.changedAttributes.count, 0)
        XCTAssertEqual(model.previousAttributes.count, 0)
        
        model = Model(attributes: ["msg":"hello", "age":15])
        XCTAssertEqual(model.changedAttributes.count, 2)
        XCTAssertEqual(model.previousAttributes.count, 0)
        
        var count = 0
        model.on(Model.events.CHANGE) { events, options in
            count += 1
        }
        
        model.set(["msg":"world"])
        XCTAssertEqual(model.changedAttributes.count, 1)
        XCTAssertEqual(model.previousAttributes.count, 2)
        
        XCTAssertEqual(count, 1)
        
        XCTAssertEqual(model.changedAttributes["msg"] as String, "world")
        XCTAssertEqual(model.previousAttributes["msg"] as String, "hello")
        XCTAssertEqual(model.get("msg") as String, "world")
        
        model.set(["msg":"message"], options: ["silent":true])
        
        XCTAssertEqual(count, 1)
        
        model.set(["msg":"message"], options: ["silent":false])
        
        XCTAssertEqual(count, 2)
        
        model.set("msg", "set 2")
        
        XCTAssertEqual(count, 3)
        
        model.set(["msg":"unset false"], options: ["unset":false])
        
        XCTAssertEqual(model.get("msg") as String, "unset false")
        
        model.set(["msg":"unset false"], options: ["unset":true])
        
        XCTAssertTrue(model.get("msg") == nil)
    }
    
    func test_unset(){
        model = Model(attributes: ["msg":"hello"])
        
        model.unset("msg")
        
        XCTAssertTrue(model.get("msg") == nil)
    }
    
    func test_has(){
        model = Model(attributes: ["msg":"hello"])
        
        XCTAssertFalse(model.has("age"))
        
        XCTAssertTrue(model.has("msg"))
    }
    
    func test_clear(){
        model = Model(attributes: ["msg":"hello", "age":15])
        
        model.clear()
        
        XCTAssertEqual(model.attributes.count, 0)
    }
    
    func test_hasChanged(){
        model = Model(attributes: ["msg":"hello", "age":15])
        
        model.set("msg", "world")
        XCTAssertTrue(model.hasChanged())
        XCTAssertTrue(model.hasChanged(key:"msg"))
        XCTAssertFalse(model.hasChanged(key:"age"))
    }
    
    func test_changed(){
        model = Model(attributes: ["msg":"hello", "age":15])
        
        model.set("msg", "message")
        
        XCTAssertTrue(model.changed("age") == nil)
        XCTAssertEqual(model.changed("msg") as String, "message")
    }
    
    func test_previous(){
        model = Model(attributes: ["msg":"hello", "age":15])
        
        model.set("msg", "message")
        XCTAssertEqual(model.previous("age") as Int, 15)
        XCTAssertEqual(model.previous("msg") as String, "hello")
    }
    
    func test_on(){
        model = Model(attributes: ["msg":"hello", "age":15])
        
        model.on(Model.events.CHANGE, callback: { [unowned self](aModel, options) -> Void in
            XCTAssertTrue(aModel === self.model)
            let msg = aModel.get("msg") as String
            XCTAssertEqual(msg, "world")
        })
        
        model.set("msg", "world")
    }
}

