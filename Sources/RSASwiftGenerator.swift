//
//  RSASwiftGenerator.swift
//  Taras Markevych
//
//  Created by Taras on 1/19/18.
//  Copyright © 2018 tarik. All rights reserved.
//

import Foundation
import Security
import CommonCrypto

// Singleton instance
public let _singletonInstance = RSASwiftGenerator()

// Constants
public var kRSASwiftGeneratorApplicationTag = "com.bundleid.app"
public var kRSASwiftGeneratorKeyType = kSecAttrKeyTypeRSA
public var kRSASwiftGeneratorKeySize = 1024
public var kRSASwiftGeneratorCypheredBufferSize = 1024
public var kRSASwiftGeneratorSecPadding: SecPadding = .PKCS1

public enum CryptoException: Error {
    case unknownError
    case duplicateFoundWhileTryingToCreateKey
    case keyNotFound
    case authFailed
    case unableToAddPublicKeyToKeyChain
    case wrongInputDataFormat
    case unableToEncrypt
    case unableToDecrypt
    case unableToSignData
    case unableToVerifySignedData
    case unableToPerformHashOfData
    case unableToGenerateAccessControlWithGivenSecurity
    case outOfMemory
}

public class RSASwiftGenerator: NSObject {
    
    /** Shared instance */
   public class var shared: RSASwiftGenerator {
        return _singletonInstance
    }
    
    // MARK: - Manage keys
    
   public func createSecureKeyPair(_ completion: ((_ success: Bool, _ error: CryptoException?) -> Void)? = nil) {
        // private key parameters
        let privateKeyParams: [String: AnyObject] = [
            kSecAttrIsPermanent as String: true as AnyObject,
            kSecAttrApplicationTag as String: kRSASwiftGeneratorApplicationTag as AnyObject
        ]
        
        // public key parameters
        let publicKeyParams: [String: AnyObject] = [
            kSecAttrIsPermanent as String: true as AnyObject,
            kSecAttrApplicationTag as String: kRSASwiftGeneratorApplicationTag as AnyObject
        ]
        
        // global parameters for our key generation
        let parameters: [String: AnyObject] = [
            kSecAttrKeyType as String:          kRSASwiftGeneratorKeyType,
            kSecAttrKeySizeInBits as String:    kRSASwiftGeneratorKeySize as AnyObject,
            kSecPublicKeyAttrs as String:       publicKeyParams as AnyObject,
            kSecPrivateKeyAttrs as String:      privateKeyParams as AnyObject,
            ]
        
        // asynchronously generate the key pair and call the completion block
        DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async { () -> Void in
            var pubKey, privKey: SecKey?
            let status = SecKeyGeneratePair(parameters as CFDictionary, &pubKey, &privKey)
            
            if status == errSecSuccess {
                DispatchQueue.main.async(execute: { completion?(true, nil) })
            } else {
                var error = CryptoException.unknownError
                switch (status) {
                case errSecDuplicateItem: error = .duplicateFoundWhileTryingToCreateKey
                case errSecItemNotFound: error = .keyNotFound
                case errSecAuthFailed: error = .authFailed
                default: break
                }
                DispatchQueue.main.async(execute: { completion?(false, error) })
            }
        }
    }
    
   public func getPublicKeyData() -> Data? {
        let parameters = [
            kSecClass as String: kSecClassKey,
            kSecAttrKeyType as String: kSecAttrKeyTypeRSA,
            kSecAttrApplicationTag as String: kRSASwiftGeneratorApplicationTag,
            kSecAttrKeyClass as String: kSecAttrKeyClassPublic,
            kSecReturnData as String: true
            ] as [String : Any]
        var data: AnyObject?
        let status = SecItemCopyMatching(parameters as CFDictionary, &data)
        if status == errSecSuccess {
            return data as? Data
        } else { return nil }
    }
    
   public func getPublicKeyReference() -> SecKey? {
        let parameters = [
            kSecClass as String: kSecClassKey,
            kSecAttrKeyType as String: kSecAttrKeyTypeRSA,
            kSecAttrApplicationTag as String: kRSASwiftGeneratorApplicationTag,
            kSecAttrKeyClass as String: kSecAttrKeyClassPublic,
            kSecReturnRef as String: true,
            ] as [String : Any]
        var ref: AnyObject?
        let status = SecItemCopyMatching(parameters as CFDictionary, &ref)
        if status == errSecSuccess { return ref as! SecKey? } else { return nil }
    }
    
   public func getPrivateKeyReference() -> SecKey? {
        let parameters = [
            kSecClass as String: kSecClassKey,
            kSecAttrKeyClass as String: kSecAttrKeyClassPrivate,
            kSecAttrApplicationTag as String: kRSASwiftGeneratorApplicationTag,
            kSecReturnRef as String: true,
            ] as [String : Any]
        var ref: AnyObject?
        let status = SecItemCopyMatching(parameters as CFDictionary, &ref)
        if status == errSecSuccess { return ref as! SecKey? } else { return nil }
    }
    
    
   public func keyPairExists() -> Bool {
        return self.getPublicKeyData() != nil
    }
    
   public func deleteSecureKeyPair(_ completion: ((_ success: Bool) -> Void)?) {
        // private query dictionary
        let deleteQuery = [
            kSecClass as String: kSecClassKey,
            kSecAttrApplicationTag as String: kRSASwiftGeneratorApplicationTag,
            ] as [String : Any]
        
        DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async { () -> Void in
            let status = SecItemDelete(deleteQuery as CFDictionary) // delete private key
            DispatchQueue.main.async(execute: { completion?(status == errSecSuccess) })        }
    }
    
    // MARK: - Cypher and decypher methods
    
   public func encryptMessageWithPublicKey(_ message: String, completion: @escaping (_ success: Bool, _ data: Data?, _ error: CryptoException?) -> Void) {
        DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async { () -> Void in
            
            if let publicKeyRef = self.getPublicKeyReference() {
                guard let messageData = message.data(using: String.Encoding.utf8) else {
                    completion(false, nil, .wrongInputDataFormat)
                    return
                }
                let plainText = (messageData as NSData).bytes.bindMemory(to: UInt8.self, capacity: messageData.count)
                let plainTextLen = messageData.count
                let cipherData = Data(count: SecKeyGetBlockSize(publicKeyRef))
                let cipherText: UnsafeMutablePointer<UInt8> = cipherData.withUnsafeBytes { $0.load(as: UnsafeMutablePointer<UInt8>.self) }
                var cipherTextLen = cipherData.count
                let status = SecKeyEncrypt(publicKeyRef, .PKCS1, plainText, plainTextLen, cipherText, &cipherTextLen)
                // analyze results and call the completion in main thread
                DispatchQueue.main.async(execute: { () -> Void in
                    completion(status == errSecSuccess, cipherData, status == errSecSuccess ? nil : .unableToEncrypt)
                    cipherText.deinitialize(count: cipherTextLen)
                })
                return
            } else { DispatchQueue.main.async(execute: { completion(false, nil, .keyNotFound) }) }
        }
    }
    
   public func decryptMessageWithPrivateKey(_ encryptedData: Data, completion: @escaping (_ success: Bool, _ result: String?, _ error: CryptoException?) -> Void) {
        DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async { () -> Void in
            
            if let privateKeyRef = self.getPrivateKeyReference() {
                let encryptedText = (encryptedData as NSData).bytes.bindMemory(to: UInt8.self, capacity: encryptedData.count)
                let encryptedTextLen = encryptedData.count
                var plainData = Data(count: kRSASwiftGeneratorCypheredBufferSize)
                let plainText: UnsafeMutablePointer<UInt8> = plainData.withUnsafeBytes { $0.load(as: UnsafeMutablePointer<UInt8>.self) }
                var plainTextLen = plainData.count
                
                let status = SecKeyDecrypt(privateKeyRef, .PKCS1, encryptedText, encryptedTextLen, plainText, &plainTextLen)
                
                // analyze results and call the completion in main thread
                DispatchQueue.main.async(execute: { () -> Void in
                    if status == errSecSuccess {
                        plainData.count = plainTextLen
                        // Generate and return result string
                        if let string = NSString(data: plainData as Data, encoding: String.Encoding.utf8.rawValue) as String? {
                            completion(true, string, nil)
                        } else { completion(false, nil, .unableToDecrypt) }
                    } else { completion(false, nil, .unableToDecrypt) }
                    plainText.deinitialize(count: plainTextLen)
                })
                return
            } else { DispatchQueue.main.async(execute: { completion(false, nil, .keyNotFound) }) }
        }
    }
    
    // MARK: - Sign and verify signature.
    
  public  func signMessageWithPrivateKey(_ message: String, completion: @escaping (_ success: Bool, _ data: Data?, _ error: CryptoException?) -> Void) {
        DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async { () -> Void in
            var error: CryptoException? = nil
            
            if let privateKeyRef = self.getPrivateKeyReference() {
                // result data
                var resultData = Data(count: SecKeyGetBlockSize(privateKeyRef))
                let resultPointer: UnsafeMutablePointer<UInt8> = resultData.withUnsafeBytes { $0.load(as: UnsafeMutablePointer<UInt8>.self) }
                var resultLength = resultData.count
                
                if let plainData = message.data(using: String.Encoding.utf8) {
                    // generate hash of the plain data to sign
                    let hashData = Data(count: Int(CC_SHA1_DIGEST_LENGTH))
                    let hash: UnsafeMutablePointer<UInt8> = hashData.withUnsafeBytes { $0.load(as: UnsafeMutablePointer<UInt8>.self) }
                    CC_SHA1((plainData as NSData).bytes.bindMemory(to: Void.self, capacity: plainData.count), CC_LONG(plainData.count), hash)
                    
                    // sign the hash
                    let status = SecKeyRawSign(privateKeyRef, SecPadding.PKCS1SHA1, hash, hashData.count, resultPointer, &resultLength)
                    if status != errSecSuccess { error = .unableToEncrypt }
                    else { resultData.count = resultLength }
//                    hash.deinitialize(count: hashData.count)
                } else { error = .wrongInputDataFormat }
                
                // analyze results and call the completion in main thread
                DispatchQueue.main.async(execute: { () -> Void in
                    if error == nil {
                        // adjust NSData length and return result.
                        resultData.count = resultLength
                        completion(true, resultData as Data, nil)
                    } else { completion(false, nil, error) }
                    //resultPointer.destroy()
                })
            } else { DispatchQueue.main.async(execute: { completion(false, nil, .keyNotFound) }) }
        }
    }
    
   public func verifySignaturePublicKey(_ data: Data, signatureData: Data, completion: @escaping (_ success: Bool, _ error: CryptoException?) -> Void) {
        DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async { () -> Void in
            var error: CryptoException? = nil
            
            if let publicKeyRef = self.getPublicKeyReference() {
                // hash data
                let hashData = Data(count: Int(CC_SHA1_DIGEST_LENGTH))
                let hash: UnsafeMutablePointer<UInt8> = hashData.withUnsafeBytes { $0.load(as: UnsafeMutablePointer<UInt8>.self) }
                CC_SHA1((data as NSData).bytes.bindMemory(to: Void.self, capacity: data.count), CC_LONG(data.count), hash)
                // input and output data
                let signaturePointer = (signatureData as NSData).bytes.bindMemory(to: UInt8.self, capacity: signatureData.count)
                let signatureLength = signatureData.count
                
                let status = SecKeyRawVerify(publicKeyRef, SecPadding.PKCS1SHA1, hash, Int(CC_SHA1_DIGEST_LENGTH), signaturePointer, signatureLength)
                
                if status != errSecSuccess { error = .unableToDecrypt }
                
                // analyze results and call the completion in main thread
                hash.deinitialize(count: hashData.count)
                DispatchQueue.main.async(execute: { () -> Void in
                    completion(status == errSecSuccess, error)
                })
                return
            } else { DispatchQueue.main.async(execute: { completion(false, .keyNotFound) }) }
        }
    }
    
    
}


