//
//  ShareViewController.swift
//  Kitty Share Extension
//
//  Created by Alexsander Akers on 11/9/15.
//  Copyright © 2015 Rocket Apps Limited. All rights reserved.
//

import Cocoa
import KittyKit

class ShareViewController: NSViewController {
    @IBOutlet var resultTextField: NSTextField!
    @IBOutlet var slider: NSSlider!

    var APIClient: APIClientProtocol = KittyKit.APIClient()
    var URL: String!
    var shortenedURL: String!

    override var nibName: String? {
        return "ShareViewController"
    }

    override func loadView() {
        super.loadView()

        if let item = extensionContext!.inputItems.first as? NSExtensionItem, attachments = item.attachments,
            itemProvider = attachments.first as? NSItemProvider where itemProvider.hasItemConformingToTypeIdentifier(kUTTypeURL as String) {
                itemProvider.loadItemForTypeIdentifier(kUTTypeURL as String, options: nil) { (URL: NSSecureCoding?, error: NSError?) in
                    self.URL = (URL as! NSURL).absoluteString
                }
        } else {
            print("No attachments")
        }
    }

    @IBAction func send(sender: AnyObject?) {
        if resultTextField.hidden {
            APIClient.fetchAuthenticityToken { result in
                result.either(ifLeft: { token in
                    let expiry: URLExpiry = {
                        switch self.slider.integerValue {
                        case 0: return .TenMins
                        case 1: return .OneHour
                        case 2: return .OneDay
                        case 3: return .OneWeek
                        default:
                            fatalError("Unexpected slider value")
                        }
                    }()

                    self.APIClient.submitURL(self.URL, expiry: expiry, token: token) { result in
                        result.either(ifLeft: { URL in
                            dispatch_async(dispatch_get_main_queue()) {
                                self.slider.enabled = false
                                self.resultTextField.stringValue = URL
                                self.resultTextField.hidden = false
                                self.resultTextField.selectText(self)

                                self.shortenedURL = URL
                            }
                        }, ifRight: { error in
                            self.extensionContext!.cancelRequestWithError(error as NSError)
                        })
                    }
                }, ifRight: { error in
                    self.extensionContext!.cancelRequestWithError(error as NSError)
                })
            }
        } else {
            let outputItem = NSExtensionItem()
            outputItem.attachments = [shortenedURL]

            let outputItems = [outputItem]
            extensionContext!.completeRequestReturningItems(outputItems, completionHandler: nil)
        }
    }

    @IBAction func cancel(sender: AnyObject?) {
        let cancelError = NSError(domain: NSCocoaErrorDomain, code: NSUserCancelledError, userInfo: nil)
        extensionContext!.cancelRequestWithError(cancelError)
    }
}
