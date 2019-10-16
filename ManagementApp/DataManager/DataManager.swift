//
//  DataManager.swift
//  DemoJson
//
//  Created by Rahul on 29/01/18.
//  Copyright © 2018 Rahul. All rights reserved.
//

import UIKit

//HTTP Methods
enum HttpMethod : String {
    case  GET
    case  POST
    case  DELETE
    case  PUT
}

class DataManager: NSObject {
    
    static let shared = DataManager();
    private override init() {}
    
    //TODO: remove app transport security arbitary constant from info.plist file once we get API's
    var request : URLRequest?
    var session : URLSession?
    
     //MARK: HTTP CALLS
    func makeAPICall(url: String,params: Dictionary<String, Any>?, method: HttpMethod, success:@escaping ( Any? ) -> Void, failure: @escaping (Error? )-> Void) {
        if Reachability.isConnectedToNetwork() {
            guard let url = URL(string:url) else {
                failure(nil)
                return
            }
            request = URLRequest(url: url)
            
            
            if let params = params {
                
                
                let  jsonData = try? JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
                
                request?.setValue("application/json", forHTTPHeaderField: "Content-Type")
                request?.httpBody = jsonData//?.base64EncodedData()
                
                
                //paramString.data(using: String.Encoding.utf8)
            }
            request?.httpMethod = method.rawValue
            
            
            let configuration = URLSessionConfiguration.default
            
            configuration.timeoutIntervalForRequest = 30
            configuration.timeoutIntervalForResource = 30
            
            session = URLSession(configuration: configuration)
            //session?.configuration.timeoutIntervalForResource = 5
            //session?.configuration.timeoutIntervalForRequest = 5
           
            session?.dataTask(with: request! as URLRequest) { (data, response, error) -> Void in
                
                if let data = data {
                    
                    if let response = response as? HTTPURLResponse, 200...299 ~= response.statusCode {
                        do {
                            let responseData =   try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
                            if (responseData as? Dictionary ?? [:])["success"] as? Int ?? 100 == 1
                            {
                                success(responseData)
                            }
                            else{
                                
                                let  message = (responseData as? Dictionary ?? [:])["statusMessage"] as? String ?? ""
                                 let err: Error = MyError.customError(message: message)
                                failure(err)
                            }
                           
                        } catch let errorData {
                            failure(errorData )
                        }
                        
                    } else {
                        failure(error)
                    }
                }else {
                    
                    failure(error)
                    
                }
                }.resume()
            
        }
        else
        {
            let error: Error = MyError.customError(message: "No Internet Connection")
            failure(error);
        }
    }
    
    
    
    
}
public enum MyError: Error {
    case customError(message: String)
}

extension MyError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .customError(message: let message):
            return NSLocalizedString(message, comment: "")
        }
    }
}


