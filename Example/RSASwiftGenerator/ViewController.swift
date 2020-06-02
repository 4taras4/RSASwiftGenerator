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
        kRSASwiftGeneratorApplicationTag = "MY.BUNDLE.ID" //setup your id for keychain saving

        RSASwiftGenerator.shared.createSecureKeyPair() { (success,error) in
            print(success,error)
            if success {
                print(  RSASwiftGenerator.shared.getPublicKeyData(), // get  Data refference as public key
                        RSASwiftGenerator.shared.getPublicKeyReference(), // / get SecKey refference for public key
                        RSASwiftGenerator.shared.getPrivateKeyReference()) // get SecKey refference for private key)
            }
        } // generade new key  pair
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

