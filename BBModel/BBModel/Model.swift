//
//  Model.swift
//  BBModel
//
//  Created by Maeda Tasuku on 2/8/15.
//
//

import Foundation

public class Model: Events {
    public struct events {
        public static let CHANGE:String = "change"
    }
    private struct uniqueIdNum {
        static var count = 0
    }
    
    private var _attributes = [String:Any]()
    private var _changedAttributes = [String:Any]()
    private var _previousAttributes = [String:Any]()
    public var cid:String!
    
    public var attributes:[String:Any] {
        get {
            return _attributes
        }
    }
    
    public var changedAttributes:[String:Any] {
        get {
            return _changedAttributes
        }
    }
    
    public var previousAttributes:[String:Any] {
        get {
            return _previousAttributes
        }
    }
    
    public override init() {
        super.init()
        self.setup()
    }
    
    public init(attributes:[String:Any]?) {
        super.init()
        self.setup()
        if let myAttr = attributes {
            self.set(myAttr, options:["silent":true])
        }
    }
    
    func setup(){
        self.cid = self.uniqueId("c")
    }
    
    public func get(key:String)-> Any? {
        return _attributes[key]
    }
    
    public func set(attributes:[String:Any], options:[String:Any]? = nil) {
        _previousAttributes = self._attributes
        _changedAttributes = [String:Any]()
        let silent:Bool = (options?["silent"] ?? false) as Bool
        let unset:Bool = (options?["unset"] ?? false) as Bool
        
        for (key, attr) in attributes {
            if unset {
                self._attributes[key] = nil
            }else{
                self._attributes[key] = attr
                _changedAttributes[key] = attr
            }
        }
        
        if silent == false {
            trigger(Model.events.CHANGE, options: options)
        }
    }
    
    public func set(key:String, _ attribute:Any, options:[String:Any]? = nil) {
        self.set([key:attribute], options: options)
    }
    
    public func unset(key:String) {
        self.set([key:0], options:["unset":true])
    }
    
    public func clear(options:[String:Any]? = nil){
        var mergedOptions:[String:Any] = options ?? [String:Any]()
        mergedOptions["unset"] = true
        self.set(self.attributes, options: mergedOptions)
    }
    
    public func has(key:String) -> Bool {
        return self.get(key) != nil
    }
    
    public func hasChanged(key:String? = nil) -> Bool {
        if let akey = key {
            return _changedAttributes[akey] != nil
        }
        return _changedAttributes.count > 0
    }
    
    public func changed(key:String) -> Any? {
        return _changedAttributes[key]
    }

    public func previous(key:String) -> Any? {
        return _previousAttributes[key]
    }
    
    func uniqueId(prefix:String?)->String{
        Model.uniqueIdNum.count++
        var countStr = String(Model.uniqueIdNum.count)
        if let aPrefix = prefix {
            countStr = aPrefix + countStr
        }
        return countStr
    }
    
    public override func on(eventType:String, callback:(model:Model, options:[String:Any]?)->Void) -> String{
        if _events[eventType] == nil {
            _events[eventType] = [String:Any]()
        }
        let callbackID = self.generateGUID()
        _events[eventType]?[callbackID] = callback
        return callbackID
    }
    
    override func triggerEvents(events:[String:Any], options:[String:Any]? = nil, relatedObj:AnyObject? = nil){
        for (guid, callback) in events {
            let mOptions = self.mergeDictionaries(options, dictionary: ["callbackId":guid], canOverwrite: false)
            
            if let castedCallback = callback as? (model:Model, options:[String:Any]?)->Void {
                castedCallback(model: self, options: mOptions)
                
            }else if let castedCallback = callback as? (events:Events, options:[String:Any]?)->Void {
                castedCallback(events: self, options: mOptions)
            }
        }
    }
}
