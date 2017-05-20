//
//  NTEULAController.swift
//  NTComponents
//
//  Created by Nathan Tannar on 5/19/17.
//  Copyright © 2017 Nathan Tannar. All rights reserved.
//


open class NTEULAController: NTViewController {
    
    open let navBarView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.setDefaultShadow()
        return view
    }()
    
    open let cancelButton: NTButton = {
        let button = NTButton()
        button.backgroundColor = .clear
        button.trackTouchLocation = false
        button.tintColor = Color.Gray.P500
        button.rippleColor = Color.Gray.P200
        button.image = Icon.Delete
        button.ripplePercent = 1.5
        button.rippleOverBounds = true
        button.addTarget(self, action: #selector(doneReading), for: .touchUpInside)
        return button
    }()
    
    open let titleLabel: NTLabel = {
        let label = NTLabel(style: .title)
        label.font = Font.Default.Headline.withSize(44)
        label.adjustsFontSizeToFitWidth = true
        label.text = "End-User License Agreement"
        return label
    }()
    
    open let textView: NTTextView = {
        let textView = NTTextView()
        textView.isEditable = false
        textView.isScrollEnabled = true
        textView.setPreferredFontStyle(to: .body)
        return textView
    }()
    
    open var eula: String? {
        get {
            return textView.text
        }
        set {
            if let filepath = newValue {
                do {
                    let str = try NSAttributedString(data: String(contentsOfFile: filepath)
                        .data(using: String.Encoding.unicode, allowLossyConversion: true)!, options: [NSDocumentTypeDocumentAttribute : NSHTMLTextDocumentType], documentAttributes: nil)
                    textView.attributedText = str
                } catch {
                    print(error)
                }
            }
        }
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        
        view.addSubview(navBarView)
        navBarView.anchor(view.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 84)
        
        navBarView.addSubview(cancelButton)
        navBarView.addSubview(titleLabel)
        
        cancelButton.anchor(navBarView.topAnchor, left: navBarView.leftAnchor, bottom: nil, right: nil, topConstant: 24, leftConstant: 16, bottomConstant: 0, rightConstant: 0, widthConstant: 20, heightConstant: 20)
        titleLabel.anchor(cancelButton.bottomAnchor, left: cancelButton.leftAnchor, bottom: navBarView.bottomAnchor, right: navBarView.rightAnchor, topConstant: 8, leftConstant: 0, bottomConstant: 8, rightConstant: 16, widthConstant: 0, heightConstant: 0)
        
        view.addSubview(textView)
        textView.anchor(navBarView.bottomAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, topConstant: 8, leftConstant: 12, bottomConstant: 8, rightConstant: 12, widthConstant: 0, heightConstant: 0)
        
    }
    
    open func doneReading() {
        dismiss(animated: true, completion: nil)
    }
}
