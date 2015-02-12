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
        events.on("up", callback: { [unowned self](events, options) in
            count++
            XCTAssertTrue(events === self.events)
        })
        events.trigger("up")
        XCTAssertTrue(count == 1)
    }
    
    func test_off(){
        var count = 0
        events.trigger("up")
        XCTAssertTrue(count == 0)
        
        events.on("up", callback: { [unowned self](events, options) in
            count++
            XCTAssertTrue(events === self.events)
        })
        let callbackId = events.on("up", callback: { [unowned self](events, options) in
            count++
            XCTAssertTrue(events === self.events)
        })
        
        events.trigger("up")
        
        XCTAssertTrue(count == 2)
        events.off("up", callbackId: callbackId)
        
        events.trigger("up")
        
        XCTAssertTrue(count == 3)
        
        events.off("up")
        
        XCTAssertTrue(count == 3)
        
        events.off("up", callbackId: "dummy-id")
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
}
