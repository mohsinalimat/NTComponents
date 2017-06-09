//
//  NTTextView.swift
//  NTComponents
//
//  Copyright © 2017 Nathan Tannar.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//
//  Created by Nathan Tannar on 2/12/17.
//

open class NTTextView: UITextView {

    // MARK: - Initialization

    open var placeholder: String? {
        didSet {
            if text.isEmpty {
                text = placeholder
                textColor = Color.Gray.P400
            }
        }
    }
    fileprivate var _textColor: UIColor?
    open override var textColor: UIColor? {
        set {
            super.textColor = newValue
            if text != placeholder {
                _textColor = newValue
            }
        }
        get {
            return super.textColor
        }
    }
    
    open var onTextViewUpdate: ((NTTextView) -> Void)?
    
    @discardableResult
    open func onTextViewUpdate(_ handler: @escaping ((NTTextView) -> Void)) -> Self {
        onTextViewUpdate = handler
        return self
    }

    public convenience init() {
        self.init(frame: .zero)

        setPreferredFontStyle(to: .body)
        backgroundColor = .clear
        isScrollEnabled = false
        tintColor = Color.Default.Tint.View

        NotificationCenter.default.addObserver(self, selector: #selector(textViewDidBeginEditing(notification:)), name: NSNotification.Name.UITextViewTextDidBeginEditing, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(textViewDidEndEditing(notification:)), name: NSNotification.Name.UITextViewTextDidEndEditing, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(textViewDidUpdate(notification:)), name: NSNotification.Name.UITextViewTextDidChange, object: nil)
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        textContainerInset = UIEdgeInsets.zero
        textContainer.lineFragmentPadding = 0
    }
    
    open func textViewDidUpdate(notification: NSNotification) {
        onTextViewUpdate?(self)
        textColor = _textColor
    }

    open func textViewDidBeginEditing(notification: NSNotification) {
        if text == placeholder {
            text = String()
            textColor = _textColor
        }
    }

    open func textViewDidEndEditing(notification: NSNotification) {
        if text.isEmpty {
            text = placeholder
            textColor = Color.Gray.P400
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UITextViewTextDidBeginEditing, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UITextViewTextDidEndEditing, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UITextViewTextDidChange, object: nil)
    }
}
