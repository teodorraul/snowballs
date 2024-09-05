//
//  keychain.swift
//  snowballs
//
//  Created by Teodor Chicinaș on 8/29/24.
//

import Foundation
import Security

fileprivate let service = "com.teodorraul.snowballs"

class KeychainManager {
    static func storeAPIKey(account: String, apiKey: String) {
        let apiKeyData = apiKey.data(using: String.Encoding.utf8)!
        let tag = service.data(using: .utf8)!
        
        let keychainQuery: [NSString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: account,
            kSecAttrApplicationTag: tag,
            kSecValueData: apiKeyData
        ]
        
        // Delete any existing items
        var status: OSStatus = SecItemDelete(keychainQuery as CFDictionary)
        
        if status == errSecSuccess {
            Logs.shared.core("existing api key deleted")
        } else {
            let msg = SecCopyErrorMessageString(status, nil)
            Logs.shared.core("unable to delete the api key:" + msg.debugDescription)
        }
        
        // Add the new keychain item
        status = SecItemAdd(keychainQuery as CFDictionary, nil)
        
        if status == errSecSuccess {
            Logs.shared.core("api key stored successfully, length: " + String(apiKey.count))
        } else {
            let msg = SecCopyErrorMessageString(status, nil)
            Logs.shared.core("unable to store the api key:" + msg.debugDescription)
        }
    }
    
    
    static func retrieveAPIKey(account: String) -> String? {
        let tag = service.data(using: .utf8)!
        
        let keychainQuery: [NSString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: account,
            kSecAttrApplicationTag: tag,
            kSecReturnData: kCFBooleanTrue!,
            kSecMatchLimit: kSecMatchLimitOne
        ]
        
        var dataTypeRef: AnyObject?
        let status: OSStatus = SecItemCopyMatching(keychainQuery as CFDictionary, &dataTypeRef)
        
        if status == errSecSuccess {
            if let retrievedData = dataTypeRef as? Data {
                let apiKey = String(data: retrievedData, encoding: .utf8)
                return apiKey
            }
        } else {
            let msg = SecCopyErrorMessageString(status, nil)
            Logs.shared.core("unable to retrieve the API Key: " + msg.debugDescription)
        }
        
        return nil
    }
}
