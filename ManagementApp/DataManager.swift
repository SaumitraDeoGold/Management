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
         //   ViewControllerUtils.sharedInstance.showLoader()
            guard let url = URL(string:url) else {
                
                let alert = UIAlertView(title: "Error", message: "Invalid Pdf", delegate: nil, cancelButtonTitle: "OK")
                alert.show()
                
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
                      DispatchQueue.main.async {
                        success(data)
                        //print("API DATA FROM URL - - - --  -- ",data)
                      //  ViewControllerUtils.sharedInstance.removeLoader()
                        }
                    } else {
                        DispatchQueue.main.async {
                            failure(error )
                         //     ViewControllerUtils.sharedInstance.removeLoader()
                        }
                       
                    }
                }else {
                    
                    DispatchQueue.main.async {
                        failure(error )
                      //    ViewControllerUtils.sharedInstance.removeLoader()
                    }
                    
                }
                }.resume()
            
        }
        else
        {
            var alert = UIAlertView(title: "No Internet Connection", message: "Make sure your device is connected to the internet.", delegate: nil, cancelButtonTitle: "OK")
            alert.show()
            let error: Error = MyError.customError(message: "No Internet Connection")
            DispatchQueue.main.async {
                failure(error )
                print("No internet connection available")
                
                //    ViewControllerUtils.sharedInstance.removeLoader()
            }
            
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


