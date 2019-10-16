//
//  Reachability.swift
//  Connected
//
//  Created by Brian Coleman on 2015-03-23.
//  Copyright (c) 2015 Brian Coleman. All rights reserved.
//

import Foundation
import SystemConfiguration

open class Reachability {
    
    class func isConnectedToNetwork() -> Bool {
        //New Changes Done
        if #available(iOS 9.0, OSX 10.10, *) {
            var zeroAddress = sockaddr_in6()
            zeroAddress.sin6_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
            zeroAddress.sin6_family = sa_family_t(AF_INET6)
            
            guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, { pointer in
                return pointer.withMemoryRebound(to: sockaddr.self, capacity: MemoryLayout<sockaddr>.size) {
                    return SCNetworkReachabilityCreateWithAddress(nil, $0)
                }
            }) else { return false }
            
            var flags : SCNetworkReachabilityFlags = []
            if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags)
            {
                return false
            }
            
            let isReachable = flags.contains(.reachable)
            let needsConnection = flags.contains(.connectionRequired)
            return (isReachable && !needsConnection)
            
        }else{
            var zeroAddress = sockaddr_in()
            zeroAddress.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
            zeroAddress.sin_family = sa_family_t(AF_INET)
            
            guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, { pointer in
                return pointer.withMemoryRebound(to: sockaddr.self, capacity: MemoryLayout<sockaddr>.size) {
                    return SCNetworkReachabilityCreateWithAddress(nil, $0)
                }
            }) else { return false }
            
            
            var flags : SCNetworkReachabilityFlags = []
            if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags)
            {
                return false
            }
            
            let isReachable = flags.contains(.reachable)
            let needsConnection = flags.contains(.connectionRequired)
            return (isReachable && !needsConnection)
        }
    }
}
