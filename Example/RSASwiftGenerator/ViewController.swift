//
//  ViewController.swift
//  RSASwiftGenerator
//
//  Created by Tarik on 01/19/2018.
//  Copyright (c) 2018 Tarik. All rights reserved.
//

import UIKit
import RSASwiftGenerator

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        RSASwiftGenerator.shared.createSecureKeyPair() { (succes,error) in
            print(succes,error)
        } // generade new key pair
        RSASwiftGenerator.shared.keyPairExists() // check keys for exist
        RSASwiftGenerator.shared.getPublicKeyData() // get  Data refference as public key
        RSASwiftGenerator.shared.getPublicKeyReference() // / get SecKey refference for public key
        RSASwiftGenerator.shared.getPrivateKeyReference() // get SecKey refference for private key
        RSASwiftGenerator.shared.deleteSecureKeyPair() { (succes) in
            print(succes)
        }// remove keys from keychain
        kRSASwiftGeneratorApplicationTag = "MY.BUNDLE.ID" //setup your id for keychain saving
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

