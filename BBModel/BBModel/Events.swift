//
//  Events.swift
//  BBModel
//
//  Created by Maeda Tasuku on 2/8/15.
//
//

import Foundation

public class Events {
    var _events = [String:[String:Any]]()
    
    public init(){
        
    }
    
    deinit{
        var keys = [String]()
        for key in _events.keys {
            keys.append(key)
        }
        for key in keys {
            var callbacks = _events[key]
            callbacks?.removeAll()
            _events[key] = nil
        }
        _events.removeAll()
    }
    
    public func on(eventType:String, callback:(events:Events, options:[String:Any]?)->Void) -> String{
        if _events[eventType] == nil {
            _events[eventType] = [String:Any]()
        }
        let callbackID = self.generateGUID()
        _events[eventType]?[callbackID] = callback
        return callbackID
    }
    
    public func off(eventType:String, callbackId:String? = nil){
        if _events[eventType] == nil {
            return
        }
        if var callbacks = _events[eventType] {
            if let id = callbackId {
                if callbacks[id] != nil {
                    _events[eventType]?[id] = nil
                }
            }else{
                _events[eventType]?.removeAll()
                _events[eventType] = nil
            }
        }
    }
    
    public func trigger(eventType:String, options:[String:Any]? = nil, relatedObj:AnyObject? = nil){
        if let events = _events[eventType] {
            triggerEvents(events, options: options, relatedObj:relatedObj)
        }
    }
    
    func triggerEvents(events:[String:Any], options:[String:Any]? = nil, relatedObj:AnyObject? = nil){
        for (guid, callback) in events {
            if let castedCallback = (callback as? (events:Events, options:[String:Any]?)->Void) {
                castedCallback(events: self, options: options)
            }
        }
    }
    
    //original code
    //http://stackoverflow.com/questions/105034/create-guid-uuid-in-javascript
    public func generateGUID() -> String {
        // http://www.ietf.org/rfc/rfc4122.txt
        var len:Int = 36
        var s:[String] = Array<String>(count: len, repeatedValue: "")
        var hexDigits:String = "0123456789abcdef"
        var hexDegitsAsNSString:NSString = hexDigits as NSString
        for var i:Int = 0; i < len; i++ {
            s[i] = hexDegitsAsNSString.substringWithRange(NSMakeRange(Int(arc4random_uniform(0x10)), 1))
        }
        // bits 12-15 of the time_hi_and_version field to 0010
        s[14] = "4"
        // bits 6-7 of the clock_seq_hi_and_reserved to 01
        var s19StartIndex:Int = 0
        if let s19Int = s[19].toInt() {
            s19StartIndex = (s19Int & 0x3) | 0x8
        }else{
            s19StartIndex = 0x3 | 0x8
        }
        s[19] = hexDegitsAsNSString.substringWithRange(NSMakeRange(s19StartIndex, 1))
        s[8] = "-"
        s[13] = "-"
        s[18] = "-"
        s[23] = "-"
        
        return "".join(s)
    }
}
