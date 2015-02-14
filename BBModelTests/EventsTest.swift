//
//  EventsTest.swift
//  BBModel
//
//  Created by Maeda Tasuku on 2/8/15.
//
//

import Foundation
import BBModel
import XCTest

var deinitCount:Int = 0

class SampleEvents: Events {
    deinit{
        deinitCount = deinitCount + 1
    }
}

class MyObserver{
    var name:String = "myobserver"
    var events:SampleEvents?
    
    init(events:SampleEvents){
        self.events = events
        self.events?.on("sample") {
            [unowned self] (events, options) in
            self.name = "in closure"
        }
    }
    deinit{
        deinitCount = deinitCount + 1
    }
}

class EventsTest: XCTestCase {
    var events:Events!
    var guidCount:Int = 0
    var guids = [String]()
    
    override func setUp() {
        super.setUp()
        
        events = Events()
    }
    
    override func tearDown() {
        events = nil
        
        super.tearDown()
    }
    
    func test_deinit(){
        deinitCount = 0
        
        var sampleEvents:SampleEvents! = SampleEvents()
        var myObserver:MyObserver! = MyObserver(events: sampleEvents)
        
        sampleEvents = nil
        myObserver = nil
        XCTAssertTrue(deinitCount == 2)
        
        //change order
        deinitCount = 0
        
        sampleEvents = SampleEvents()
        myObserver = MyObserver(events: sampleEvents)
        
        myObserver = nil
        sampleEvents = nil
        XCTAssertTrue(deinitCount == 2)
    }
    
    func test_generateGUID(){
        let count = 10000
        for i in 0 ..< count {
            guids.append(events.generateGUID())
        }
        for guid in guids {
            self.compareGUID(guid, guids: guids)
        }
    }
    
    func compareGUID(guid:String, guids:[String]){
        var equalCount = 0
        for sourceGUID in guids {
            if sourceGUID == guid {
                equalCount++
            }
        }
        XCTAssertEqual(equalCount, 1)
    }
    
    func test_on(){
        var count = 0
        events.trigger("up")
        XCTAssertTrue(count == 0)
        var callbackId:String?
        callbackId = events.on("up", callback: { [unowned self](events, options) in
            count++
            XCTAssertTrue(events === self.events)
            let optionCallbackId = options?["callbackId"] as String
//            println("id1 = \(callbackId!)")
//            println("id2 = \(optionCallbackId)")
            XCTAssertEqual(callbackId!, optionCallbackId)
        })
        events.trigger("up")
        XCTAssertTrue(count == 1)
    }
    
    func test_off(){
        var count:Int = 0
        events.trigger("up")
        XCTAssertTrue(count == 0)
        
        let callbackId1 = events.on("up", callback: { [unowned self](events, options) in
            count++
            XCTAssertTrue(events === self.events)
        })
        let callbackId2 = events.on("up", callback: { [unowned self](events, options) in
            count++
            XCTAssertTrue(events === self.events)
        })
        
        events.trigger("up")
        
        XCTAssertTrue(count == 2)
        
        events.off("up", callbackId: callbackId2)
        
        events.trigger("up")
        
        XCTAssertTrue(count == 3)
        
        events.off("up")
        
        XCTAssertTrue(count == 3)
        
        events.off("up", callbackId: "dummy-id")
        
        XCTAssertTrue(count == 3)
        
        count = 0
        let callbackId3 = events.on("up") {
            (events, options) in
            count = count + 1
            events.off("up", callbackId: (options?["callbackId"] as String))
        }
        
        events.trigger("up")
        
        XCTAssertTrue(count == 1)
        
        events.trigger("up")
        
        XCTAssertTrue(count == 1)
    }
    
    func test_trigger(){
        let opts:[String:Any] = ["sample":true]
        events.on("trigger") {
            (events, options:[String:Any]?) in
            XCTAssertTrue(options?["sample"] as Bool)
        }
        events.trigger("trigger", options: opts)
        
        events.off("trigger")
        
        var count = 0
        events.on("nooption") { events, options in
            count += 1
        }
        events.trigger("nooption")
        XCTAssertTrue(count == 1)
    }
    
    func test_mergeDictionries(){
        let opt1:[String:Any] = ["msg":"hello", "age":15, "name":"Mike"]
        let opt2:[String:Any] = ["msg":"world"]
        let expetedOpt:[String:Any] = ["msg":"world", "age":15, "name":"Mike"]
        
        let mergedOpt = events.mergeDictionaries(opt1, dictionary: opt2)
        assertOptions(expetedOpt, options2: mergedOpt)
        
        let mergedOpt2:[String:Any] = events.mergeDictionaries(nil, dictionary: opt2)
        assertOptions(mergedOpt2, options2: opt2)
        
        let mergedOpt3:[String:Any] = events.mergeDictionaries(opt1, dictionary: nil)
        assertOptions(opt1, options2: mergedOpt3)
        
        let mergedOpt4:[String:Any] = events.mergeDictionaries(nil, dictionary: nil)
        assertOptions([String:Any](), options2: mergedOpt4)
        
        let opt3:[String:Any] = ["msg":"world", "phone":"0123-456"]
        
        let mergedOpt5 = events.mergeDictionaries(opt1, dictionary: opt3, canOverwrite:true)
        assertOptions(["msg":"world", "age":15, "name":"Mike", "phone":"0123-456"], options2: mergedOpt5)
        
        let mergedOpt6 = events.mergeDictionaries(opt1, dictionary: opt3, canOverwrite:false)
        assertOptions(["msg":"hello", "age":15, "name":"Mike", "phone":"0123-456"], options2: mergedOpt6)
    }
    
    func assertOptions(options1:[String:Any], options2:[String:Any]){
        XCTAssertTrue(options1.count == options2.count)
        
        for (key, value) in options1 {
            if value is Int {
                XCTAssertEqual(options2[key]! as Int, value as Int)
            }else if value is String {
                XCTAssertEqual(options2[key]! as String, value as String)
            }
        }
    }
}
