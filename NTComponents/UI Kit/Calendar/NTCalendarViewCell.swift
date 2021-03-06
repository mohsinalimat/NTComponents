//
//  NTCalendarViewCell.swift
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
//  Created by Nathan Tannar on 6/16/17.
//

open class NTCalendarViewCell: JTAppleCell {
    
    open static var reuseIdentifier: String {
        get {
            return "NTCalendarViewCell"
        }
    }
    
    open weak var controller: UIViewController?
    open var cellState: CellState? {
        didSet {
            dateLabel.text = cellState?.text
            
            if cellState?.dateBelongsTo != .thisMonth {
                dateLabel.textColor = Color.Default.Text.Disabled
            }
            if let date = cellState?.date {
                currentDayView.isHidden = !Calendar.current.isDateInToday(date)
            } else {
                currentDayView.isHidden = false
            }
        }
    }
    
    open var dateLabel: NTLabel = {
        let label = NTLabel(style: .body)
        return label
    }()
    
    open var currentDayView: UIView = {
        let view = UIView()
        view.layer.borderColor = Color.Default.Tint.View.cgColor
        view.layer.borderWidth = 2
        view.isHidden = true
        view.layer.cornerRadius = 50 / 2
        return view
    }()
    
    open var isSelectedView: UIView = {
        let view = UIView()
        view.backgroundColor = Color.Default.Tint.View
        view.isHidden = true
        view.layer.cornerRadius = 50 / 2
        return view
    }()
    
    // MARK: - Initialization
    
    convenience init() {
        self.init(frame: .zero)
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open func setupViews() {
        
        addSubview(currentDayView)
        addSubview(isSelectedView)
        addSubview(dateLabel)
        
        dateLabel.anchorCenterSuperview()
        for view in [currentDayView, isSelectedView] {
            view.anchorCenterSuperview()
            view.widthAnchor.constraint(equalToConstant: 50).isActive = true
            view.heightAnchor.constraint(equalToConstant: 50).isActive = true
        }
    }
    
    open override var isSelected: Bool {
        didSet {
            if isSelected {
                self.isSelectedView.transform = CGAffineTransform(scaleX: 0, y: 0)
                isSelectedView.isHidden = false
                UIView.animate(withDuration: 0.15, animations: {
                    self.isSelectedView.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
                }) { (finished) in
                    self.dateLabel.textColor = Color.Default.Tint.View.isDark ? .white : .black
                    UIView.animate(withDuration: 0.15, animations: {
                        self.isSelectedView.transform = CGAffineTransform.identity
                    })
                }
            } else {
                self.dateLabel.textColor = Color.Default.Text.Body
                self.isSelectedView.isHidden = true
            }
        }
    }
}
