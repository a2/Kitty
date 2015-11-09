//
//  ShareViewController.swift
//  Kitty Share Extension
//
//  Created by Alexsander Akers on 11/9/15.
//  Copyright © 2015 Rocket Apps Limited. All rights reserved.
//

import Cocoa

class ShareViewController: NSViewController {
    @IBOutlet var resultTextField: NSTextField!
    @IBOutlet var slider: NSSlider!

    var URL: NSURL!

    override var nibName: String? {
        return "ShareViewController"
    }

    override func loadView() {
        super.loadView()

        if let item = extensionContext!.inputItems.first as? NSExtensionItem, attachments = item.attachments,
            itemProvider = attachments.first as? NSItemProvider where itemProvider.hasItemConformingToTypeIdentifier(kUTTypeURL as String) {
                itemProvider.loadItemForTypeIdentifier(kUTTypeURL as String, options: nil, completionHandler: { (URL: NSSecureCoding?, error: NSError?) in
                    self.URL = URL as? NSURL
                })
        } else {
            print("No attachments")
        }
    }

    @IBAction func send(sender: AnyObject?) {
        let URLString = "small.cat/bat"
        print("\(URL) -> \(URLString)")
        if resultTextField.hidden {
            slider.enabled = false
            resultTextField.stringValue = URLString
            resultTextField.hidden = false
            resultTextField.selectText(self)
        } else {
            let outputItem = NSExtensionItem()
            outputItem.attachments = [URLString]

            let outputItems = [outputItem]
            extensionContext!.completeRequestReturningItems(outputItems, completionHandler: nil)
        }
    }

    @IBAction func cancel(sender: AnyObject?) {
        let cancelError = NSError(domain: NSCocoaErrorDomain, code: NSUserCancelledError, userInfo: nil)
        extensionContext!.cancelRequestWithError(cancelError)
    }
}
