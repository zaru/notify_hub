//
//  Request.swift
//  NotifyHub
//
//  Created by hiro on 2016/05/02.
//  Copyright © 2016年 zaru. All rights reserved.
//

import Foundation

class Request {
    let session: NSURLSession = NSURLSession.sharedSession()
    
    // GET METHOD
    func get(url: NSURL, completionHandler: (NSData?, NSURLResponse?, NSError?) -> Void) {
        let request: NSMutableURLRequest = NSMutableURLRequest(URL: url)
        
        request.HTTPMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        session.dataTaskWithRequest(request, completionHandler: completionHandler).resume()
    }
    
    // PUT METHOD
    func post(url: NSURL, body: NSMutableDictionary, completionHandler: (NSData?, NSURLResponse?, NSError?) -> Void) {
        let request: NSMutableURLRequest = NSMutableURLRequest(URL: url)
        
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        do {
            request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(body, options: NSJSONWritingOptions.init(rawValue: 2))
        } catch {
            // Error Handling
            print("NSJSONSerialization Error")
            return
        }
        session.dataTaskWithRequest(request, completionHandler: completionHandler).resume()
    }
    
    // POST METHOD
    func put(url: NSURL, body: NSMutableDictionary, completionHandler: (NSData?, NSURLResponse?, NSError?) -> Void) {
        let request: NSMutableURLRequest = NSMutableURLRequest(URL: url)
        
        request.HTTPMethod = "PUT"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        do {
            request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(body, options: NSJSONWritingOptions.init(rawValue: 2))
        } catch {
            // Error Handling
            print("NSJSONSerialization Error")
            return
        }
        session.dataTaskWithRequest(request, completionHandler: completionHandler).resume()
    }
    
    // DELETE METHOD
    func delete(url: NSURL, completionHandler: (NSData?, NSURLResponse?, NSError?) -> Void) {
        let request: NSMutableURLRequest = NSMutableURLRequest(URL: url)
        
        request.HTTPMethod = "DELETE"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        session.dataTaskWithRequest(request, completionHandler: completionHandler).resume()
    }
}