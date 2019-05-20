//
//  MDEditorViewController.swift
//  JSCore
//
//  Created by Gabriel Theodoropoulos on 13/02/17.
//  Copyright © 2017 Appcoda. All rights reserved.
//

import UIKit
import JavaScriptCore

class MDEditorViewController: UIViewController {

    @IBOutlet weak var tvEditor: UITextView!
    
    @IBOutlet weak var webResults: UIWebView!
    
    @IBOutlet weak var conTrailingEditor: NSLayoutConstraint!
    
    @IBOutlet weak var conLeadingWebview: NSLayoutConstraint!
    
    var jsContext: JSContext!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        initializeJS()
    }
    
    private let consoleLog: @convention(block) (String) -> Void = { logMessage in
        print("\nJS Console:", logMessage)
    }
    
    func initializeJS() {
        jsContext = JSContext()
        
        jsContext.exceptionHandler = { context, exception in
            if let exc = exception {
                print("JS Exception:", exc.toString() as String)
            }
        }
        
        let consoleLogObject = unsafeBitCast(consoleLog, to: AnyObject.self)
        jsContext.setObject(consoleLogObject, forKeyedSubscript: "consoleLog" as (NSCopying & NSObjectProtocol))
        _ = jsContext.evaluateScript("consoleLog")
        
        if let jsSourcePath = Bundle.main.path(forResource: "jssource", ofType: "js") {
            do {
                let jsSourceContents = try String(contentsOfFile: jsSourcePath)
                jsContext.evaluateScript(jsSourceContents)
                
                let snowdownScript = try String(contentsOf: URL(string: " https://cdn.rawgit.com/showdownjs/showdown/1.6.3/dist/showdown.min.js")!)
                jsContext.evaluateScript(snowdownScript)
            } catch {
                print(error.localizedDescription)
            }
        }
        
        let htmlResultHandler = unsafeBitCast(markdownToHTMLHandler, to: AnyObject.self)
        jsContext.setObject(htmlResultHandler, forKeyedSubscript: "handleConvertedMarkdown" as NSCopying & NSObjectProtocol)
        _ = jsContext.evaluateScript("handleConvertedMarkdown")
    }
    
    let markdownToHTMLHandler: @convention(block) (String) -> Void = { htmlOutput in
        NotificationCenter.default.post(name: NSNotification.Name("markdownToHTMLNotification"), object: htmlOutput)
    }

    // MARK: IBAction Methods
    
    @IBAction func dismiss(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func previewHTML(_ sender: Any) {
        var newTrailingConstant: CGFloat!
        
        if conTrailingEditor.constant == 0.0 {
            newTrailingConstant = self.view.frame.size.width/2
        }
        else if conTrailingEditor.constant == self.view.frame.size.width/2 {
            newTrailingConstant = self.view.frame.size.width
        }
        else {
            newTrailingConstant = 0.0
        }
        
        
        UIView.animate(withDuration: 0.4) {
            self.conTrailingEditor.constant = newTrailingConstant
            self.view.layoutIfNeeded()
        }
    }
    
    
    @IBAction func convert(_ sender: Any) {
        
    }
    
    

}
