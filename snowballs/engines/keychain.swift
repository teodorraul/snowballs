//
//  keychain.swift
//  snowballs
//
//  Created by Teodor Chicinaș on 8/29/24.
//

import Foundation
import Security

class KeychainManager {
    static func storeAPIKey(service: String, account: String, apiKey: String) {
        let apiKeyData = apiKey.data(using: String.Encoding.utf8)!
        let tag = "com.teodorraul.snowballs".data(using: .utf8)!
        
        let keychainQuery: [NSString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: account,
            kSecAttrApplicationTag: tag,
            kSecValueData: apiKeyData
        ]
        
        // Delete any existing items
        SecItemDelete(keychainQuery as CFDictionary)
        
        // Add the new keychain item
        let status: OSStatus = SecItemAdd(keychainQuery as CFDictionary, nil)
        
        if status == errSecSuccess {
            print("API Key stored successfully")
        } else {
            print("Unable to store API Key")
        }
    }
    
    
    static func retrieveAPIKey(service: String, account: String) -> String? {
        let tag = "com.teodorraul.snowballs".data(using: .utf8)!
        
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
            print("Unable to retrieve API Key: ", msg as Any)
        }
        
        return nil
    }
}
