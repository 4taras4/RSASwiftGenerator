# RSASwiftGenerator  🔑 🔐

[![CI Status](http://img.shields.io/travis/Tarik/RSASwiftGenerator.svg?style=flat)](https://travis-ci.org/Tarik/RSASwiftGenerator)
[![Version](https://img.shields.io/cocoapods/v/RSASwiftGenerator.svg?style=flat)](http://cocoapods.org/pods/RSASwiftGenerator)
[![License](https://img.shields.io/cocoapods/l/RSASwiftGenerator.svg?style=flat)](http://cocoapods.org/pods/RSASwiftGenerator)
[![Platform](https://img.shields.io/cocoapods/p/RSASwiftGenerator.svg?style=flat)](http://cocoapods.org/pods/RSASwiftGenerator)


To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements ⚠️

#### SWIFT 4
#### XCode 9 +

## Installation 📲

RSASwiftGenerator is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```swift
    pod 'RSASwiftGenerator'
```
## Example 💻

```swift
import UIKit
import RSASwiftGenerator

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        kRSASwiftGeneratorApplicationTag = "MY.BUNDLE.ID" //setup your id for keychain saving
        kRSASwiftGeneratorKeySize = 2048 //keySize
    // generade new key pair
        RSASwiftGenerator.shared.createSecureKeyPair() { (succes,error) in
            print(succes,error)
        }
        RSASwiftGenerator.shared.keyPairExists() // check keys for exist
        RSASwiftGenerator.shared.getPublicKeyData() // get  Data refference as public key
        RSASwiftGenerator.shared.getPublicKeyReference() // / get SecKey refference for public key
        RSASwiftGenerator.shared.getPrivateKeyReference() // get SecKey refference for private key
        RSASwiftGenerator.shared.deleteSecureKeyPair() { (succes) in
            print(succes)
        }// remove keys from keychain
    }

```

## Author 👨‍💻

Tarik, 4taras4@gmail.com

## License

RSASwiftGenerator is available under the MIT license. See the LICENSE file for more info.
