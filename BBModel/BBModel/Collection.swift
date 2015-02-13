//
//  Collection.swift
//  BBModel
//
//  Created by Maeda Tasuku on 2/8/15.
//
//

import Foundation

public class Collection: Events {
    public struct events {
        public static let ADD:String = "add"
        public static let REMOVE:String = "remove"
        public static let RESET:String = "reset"
    }
    
    public var model:Model.Type!
    
    private var _length:Int = 0
    public var length:Int {
        get {
            return _length
        }
    }
    
    private var _byId:[String:Model]!
    
    private var _models:[Model]!
    public var models:[Model]{
        get{
            return _models
        }
    }
    
    private let setOptions:[String:Any] = ["add": true, "remove": true, "merge": true]
    private let addOptions:[String:Any] = ["add": true, "remove": false, "merge": false]
    
    public override init() {
        super.init()
        self._reset()
    }
    
    public init(models:[Model]?, options:[String:Any]? = nil) {
        super.init()
        
        if let aModel = options?["model"] as? Model.Type {
            model = aModel
        }
        self._reset()
        if models != nil {
            let opt:[String:Any] = self.mergeDictionaries(["silent":true], dictionary: options, canOverwrite: false)
            self.reset(models, options: opt)
        }
    }
    
    public func add(model:Model, options:[String:Any]? = nil) -> [Model]{
        return self.set([model], options: self.mergeDictionaries(options, dictionary: addOptions))
    }
    
    public func add(models:[Model], options:[String:Any]? = nil) -> [Model]{
        return self.set(models, options: self.mergeDictionaries(options, dictionary: addOptions))
    }
    
    public func set(model:Model, options:[String:Any]? = nil) -> [Model]{
        return self.set([model], options: options)
    }
    
    public func set(models:[Model], options argOptions:[String:Any]? = nil) -> [Model]{
        var aModels = models
        var options:[String:Any] = self.mergeDictionaries(argOptions, dictionary: setOptions, canOverwrite: false)
        let at:Int? = options["at"] as? Int
        var toAdd:[Model] = []
        var toRemove:[Model] = []
        var modelMap = [String:Bool]()
        let add = options["add"] as Bool
        let merge = options["merge"] as Bool
        let remove = options["remove"] as Bool
        
        for var i = 0, l = models.count; i < l; i++ {
            var model = models[i]
            
            if let existing = self.get(model.cid) {
                if remove {
                    modelMap[model.cid] = true
                }
                if merge {
                    existing.set(model.attributes, options: options)
                }
                aModels[i] = existing
                
            } else if add {
              toAdd.append(model)
            }
        }
        
        if remove {
            for model in _models {
                if modelMap[model.cid] != true {
                    toRemove.append(model)
                }
            }
            if toRemove.count > 0 {
                self.remove(toRemove, options: options)
            }
        }
        
        if toAdd.count > 0 {
            self._length += toAdd.count
            
            if at != nil {
                self._models.splice(toAdd, atIndex: at!)
            }else{
                for addedModel in toAdd {
                    self._models.append(addedModel)
                }
            }
            for model in toAdd {
                self._byId[model.cid] = model
            }
        }
        
        let silent = (options["silent"] ?? false) as Bool
        if silent == false {
            for addedModel in toAdd {
                self.trigger(Collection.events.ADD, options: options, relatedObj: addedModel)
            }
        }
        return aModels
    }
    
    public func remove(model:Model, options:[String:Any]? = nil) -> [Model]{
        return self.remove([model], options: options)
    }
    
    public func remove(models:[Model], options argOptions:[String:Any]? = nil) -> [Model]{
        var options = argOptions ?? [String:Any]()
        var index:Int
        let silent = (options["silent"] ?? false) as Bool
        var toRemove:[Model] = [Model]()
        for model in models {
            if self.has(model) == false {
                continue
            }
            toRemove.append(model)
            self._byId[model.cid] = nil
            index = self.indexOf(model)!
            self._models.removeAtIndex(index)
            self._length--
            
            if silent == false {
                options["index"] = index
                self.trigger(Collection.events.REMOVE, options: options, relatedObj: model)
            }
        }
        return toRemove
    }
    
    public func indexOf(model:Model) -> Int?{
        for var i = 0, l = _models.count; i < l; i++ {
            if model.cid == _models[i].cid {
                return i
            }
        }
        return nil
    }
    
    
    public func get(cid:String)->Model?{
        return self._byId[cid]
    }
    
    public func has(model:Model)->Bool{
        return self.get(model.cid) != nil
    }
    
    public func reset(_ models:[Model]? = nil, options:[String:Any]? = nil){
        var opt:[String:Any] = options ?? [String:Any]()
        opt["previousModels"] = self._models
        self._reset()
        
        if let aModels = models {
            if aModels.count > 0 {
                let opt = self.mergeDictionaries(options, dictionary: ["silent":true], canOverwrite: true)
                self.add(aModels, options: opt)
            }
        }
        
        let silent = (options?["silent"] ?? false) as Bool
        if silent == false {
            self.trigger(Collection.events.RESET, options: options)
        }
    }
    
    public func push(model:Model, options:[String:Any]? = nil) -> Model {
        return self.add(model, options: options)[0]
    }
    
    public func pop(options:[String:Any]? = nil) -> Model? {
        var model:Model? = self.at(self.length - 1)
        if let aModel = model {
            self.remove(aModel, options: options)
            return aModel
        }
        return nil
    }
    
    public func unshift(model:Model, options:[String:Any]? = nil) -> Model {
        return self.add(model, options: self.mergeDictionaries(options, dictionary: ["at":0], canOverwrite: true))[0]
    }
    
    public func shift(options:[String:Any]? = nil) -> Model? {
        var model:Model? = self.at(0)
        if let aModel = model {
            self.remove(aModel, options: options)
            return aModel
        }
        return nil
    }
    
    public func at(index:Int)->Model?{
        if index < 0 || (index > self._length - 1) {
            return nil
        }
        return _models[index]
    }
    
    public func slice(begin:Int, end:Int) ->[Model]?{
        if begin < 0 || (end > self.length - 1) ||
           begin > end {
            return nil
        }
        var models:[Model] = [Model]()
        for var i = begin; i < end; i++ {
            models.append(self._models[i])
        }
        return models
    }
    
    func _reset(){
        _length = 0
        _models = [Model]()
        _byId = [String:Model]()
    }
    
    //shallow merge
    public func mergeDictionaries(overwrittenDictionary:[String:Any]?, dictionary:[String:Any]?, canOverwrite:Bool = true)->[String:Any]{
        if overwrittenDictionary == nil {
            if dictionary == nil {
                return [String:Any]()
            }
            return dictionary!
            
        }else if dictionary == nil {
            return overwrittenDictionary!
            
        }
        var copiedOptions = overwrittenDictionary!
        for (key, value) in dictionary! {
            if copiedOptions[key] == nil ||
               (copiedOptions[key] != nil && canOverwrite) {
                copiedOptions[key] = value
            }
        }
        return copiedOptions
    }
    
    public override func on(eventType:String, callback:(collection:Collection, options:[String:Any]?)->Void) -> String{
        if _events[eventType] == nil {
            _events[eventType] = [String:Any]()
        }
        let callbackID = self.generateGUID()
        _events[eventType]?[callbackID] = callback
        return callbackID
    }
    
    public func on(eventType:String, callback:(model:Model, collection:Collection, options:[String:Any]?)->Void) -> String{
        if _events[eventType] == nil {
            _events[eventType] = [String:Any]()
        }
        let callbackID = self.generateGUID()
        _events[eventType]?[callbackID] = callback
        return callbackID
    }
    
    override func triggerEvents(events:[String:Any], options:[String:Any]? = nil, relatedObj:AnyObject? = nil){
        for (guid, callback) in events {
            if let castedCallback = callback as? (model:Model, collection:Collection, options:[String:Any]?)->Void {
                if let model = relatedObj as? Model {
                    castedCallback(model: model, collection: self, options: options)
                }
            }else if let castedCallback = (callback as? (collection:Collection, options:[String:Any]?)->Void) {
                castedCallback(collection: self, options: options)
                
            }else if let castedCallback = (callback as? (events:Events, options:[String:Any]?)->Void) {
                castedCallback(events: self, options: options)
                
            }
        }
    }
}
