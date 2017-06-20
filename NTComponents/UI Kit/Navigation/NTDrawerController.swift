//
//  NTDrawerController.swift
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
//  Created by Nathan Tannar on 6/18/17.
//

public enum NTDrawerSide {
    case left, right, center
}

public enum NTDrawerControllerState {
    case leftExpanded, rightExpanded, collapsed
}

public struct NTDrawerViewProperties {
    
    public var side: NTDrawerSide
    
    /// The width of the views frame when visible
    public var width: CGFloat = 300
    
    /// If the view appears over or under the centerViewController
    public var isVisibleOnTop: Bool = true
    
    public var drawerAnimationDuration:       TimeInterval = 0.5
    public var drawerAnimationDelay:          TimeInterval = 0.0
    public var drawerAnimationSpringDamping:  CGFloat = 1.0
    public var drawerAnimationSpringVelocity: CGFloat = 1.0
    public var drawerAnimationStyle:          UIViewAnimationOptions = .curveLinear
    
    /// The view added to the edge of the view controller
    public var overflowView: UIView = {
        let view = UIView()
        view.backgroundColor = Color.Default.Background.ViewController
        return view
    }()
    
    /// Extra animations that are called when openning a drawer side
    public var additionalOpenAnimations: (() -> Void)? = nil
    
    /// Extra animations that are called when closing a drawer side
    public var additionalCloseAnimations: (() -> Void)? = nil
    
    public func transform() -> CGAffineTransform {
        if side == .right {
            return CGAffineTransform(translationX: -width, y: 0)
        } else if side == .left {
            return CGAffineTransform(translationX: width, y: 0)
        }
        return CGAffineTransform.identity
    }
    
    public init(side: NTDrawerSide) {
        self.side = side
    }
}

public extension UIViewController {
    var drawerController: NTDrawerController? {
        var parentViewController = parent
        
        while parentViewController != nil {
            if let view = parentViewController as? NTDrawerController{
                return view
            }
            parentViewController = parentViewController!.parent
        }
        Log.write(.warning, "View controller did not have an NTDrawerController as a parent")
        return nil
    }
}

open class NTDrawerController: NTViewController, UIGestureRecognizerDelegate {
    
    // MARK: - View Controllers
    fileprivate var _centerViewController: UIViewController?
    fileprivate var _leftViewController:   UIViewController?
    fileprivate var _rightViewController:  UIViewController?
    
    // MARK: - State
    fileprivate var _currentState: NTDrawerControllerState = .collapsed {
        didSet {
            Log.write(.status, "NTDrawerController is now in state \(_currentState)")
        }
    }
    
    // MARK: - Drawer View Properties
    open var leftViewProperties  = NTDrawerViewProperties(side: .left)
    open var rightViewProperties = NTDrawerViewProperties(side: .right)
    
    open lazy var overlayView: UIView = { [weak self] in
        let view = UIView()
        view.backgroundColor = Color.Gray.P900
        view.alpha = 0
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(closeDrawer))
        view.addGestureRecognizer(tapGesture)
        return view
    }()
    
    fileprivate var statusBar: UIView? {
        get {
            return UIApplication.shared.value(forKey: "statusBar") as? UIView
        }
    }
    
    open lazy var panGestureRecognizer: UIPanGestureRecognizer = { [weak self] in
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        panGestureRecognizer.delegate = self
        return panGestureRecognizer
    }()
    
    // MARK: - Initialization
    
    public convenience init(centerViewController: UIViewController) {
        self.init(centerViewController: centerViewController, leftViewController: nil, rightViewController: nil)
    }
    
    public convenience init(centerViewController: UIViewController, leftViewController: UIViewController) {
        self.init(centerViewController: centerViewController, leftViewController: leftViewController, rightViewController: nil)
    }
    
    public convenience init(centerViewController: UIViewController, rightViewController: UIViewController) {
        self.init(centerViewController: centerViewController, leftViewController: nil, rightViewController: rightViewController)
    }
    
    public required init(centerViewController: UIViewController, leftViewController: UIViewController?, rightViewController: UIViewController?) {
        self.init()
        _centerViewController = centerViewController
        _leftViewController = leftViewController
        _rightViewController = rightViewController
        setup()
    }
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// Initializes the container
    open func setup() {
        addViewController(centerViewController, toSide: .center)
        addViewController(leftViewController, toSide: .left)
        addViewController(rightViewController, toSide: .right)
    }
    
    open override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        close(drawerSide: activeSide)
    }
    
    // MARK: - NTDrawerController Methods
    
    /// Adds a view controllers view and parent pointer to 'NTDrawerController'
    ///
    /// - Parameter viewController: The view controller to remove
    fileprivate func addViewController(_ viewController: UIViewController?, toSide side: NTDrawerSide) {
        guard let vc = viewController else {
            return
        }
        addChildViewController(vc)
        
        vc.beginAppearanceTransition(true, animated: false)
        view.addSubview(vc.view)
        
        switch side {
        case .center:
            vc.view.frame = view.bounds
            vc.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            addMenuBarButtonItems()
        case .left:
            vc.view.frame = CGRect(x: -leftViewProperties.width, y: 0, width: leftViewProperties.width, height: view.bounds.height)
            vc.view.autoresizingMask = [.flexibleHeight]
            vc.view.isHidden = true
            properties(forSide: .left)!.overflowView.removeAllConstraints()
            properties(forSide: .left)!.overflowView.removeFromSuperview()
            vc.view.addSubview(properties(forSide: .left)!.overflowView)
            properties(forSide: .left)!.overflowView.anchor(vc.view.topAnchor, left: nil, bottom: vc.view.bottomAnchor, right: vc.view.leftAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 100, heightConstant: 0)
        case .right:
            vc.view.frame = CGRect(x: view.bounds.width, y: 0, width: rightViewProperties.width, height: view.bounds.height)
            vc.view.autoresizingMask = [.flexibleHeight]
            vc.view.isHidden = true
            
            // Add the overflow view
            properties(forSide: .right)!.overflowView.removeAllConstraints()
            properties(forSide: .right)!.overflowView.removeFromSuperview()
            vc.view.addSubview(properties(forSide: .right)!.overflowView)
            properties(forSide: .right)!.overflowView.anchor(vc.view.topAnchor, left: vc.view.rightAnchor, bottom: vc.view.bottomAnchor, right: nil, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 100, heightConstant: 0)
        }
    
        vc.endAppearanceTransition()
        vc.didMove(toParentViewController: self)
    }
    
    
    /// Removes a view controllers view and parent pointer from 'NTDrawerController'
    ///
    /// - Parameter viewController: The view controller to remove
    fileprivate func removeViewController(_ viewController: UIViewController?) {
        guard let vc = viewController else {
            return
        }
        vc.willMove(toParentViewController: nil)
        vc.beginAppearanceTransition(false, animated: false)
        vc.removeFromParentViewController()
        vc.view.removeFromSuperview()
        vc.endAppearanceTransition()
    }
    
    
    /// Replaces a drawers view controller and updates the properties accordingly
    ///
    /// - Parameters:
    ///   - viewController: The view controller to add
    ///   - forSide: The side to set
    ///   - completion: Called when the replacement is complete
    open func setViewController(_ viewController: UIViewController, forSide side: NTDrawerSide, withProperties properties: NTDrawerViewProperties? = nil, completion: (() -> Void)? = nil) {
        
        var oldFrame: CGRect? = nil
        // Remove the previous controller
        if let oldViewController = self.viewController(forSide: side) {
            oldFrame = oldViewController.view.frame
            removeViewController(oldViewController)
        }
        // Set the new properties (if supplied)
        if let props = properties {
            if side == .left {
                leftViewProperties = props
            } else if side == .right {
                rightViewProperties = props
            }
        }
        addViewController(viewController, toSide: side)
        if let frame = oldFrame {
            viewController.view.frame = frame
        }
        switch side {
        case .center:
            addMenuBarButtonItems(animated: true)
        case .left:
            _leftViewController = viewController
            updateView(self.properties(forSide: side)!)
        case .right:
            _rightViewController = viewController
            updateView(self.properties(forSide: side)!)
        }
    }
    
    
    /// If centerViewController is of type UINavigationController, a 'NTDrawerBarButtonItem' will be added to the rootViewController with an action to open the respective drawer side
    ///
    /// - Parameter animated: If items are added with an animation. Defaults to false
    open func addMenuBarButtonItems(animated: Bool = false) {
        guard let navigationController = _centerViewController as? UINavigationController else {
            Log.write(.warning, "The centerViewController passed to NTDrawerController was not a UINavigationController so the standard UIBarButtonItems will not be added")
            return
        }
        print(_centerViewController)
        
        if _leftViewController != nil {
            let barButtonItem = NTDrawerBarButtonItem(target: self, action: #selector(toggleLeftViewController(_:)))
            navigationController.viewControllers[0].navigationItem.leftBarButtonItem = barButtonItem
        }
        if _rightViewController != nil {
            let barButtonItem = NTDrawerBarButtonItem(target: self, action: #selector(toggleRightViewController(_:)))
            navigationController.viewControllers[0].navigationItem.rightBarButtonItem = barButtonItem
        }
    }
    
    // MARK: - Drawer Toggles and Animations
    
    
    /// Toggles the view of the supplied size, closing the opposite side first if required
    ///
    /// - Parameters:
    ///   - side: Side to toggle
    ///   - completion: Executed when the animation was complete
    open func toggle(drawerSide side: NTDrawerSide, completion: (() -> Void)? = nil) {
        Log.write(.status, "Toggling from \(activeSide) to \(side)")
        if activeSide == .center {
            open(drawerSide: side, completion: completion)
        } else if activeSide == side {
            close(drawerSide: side, completion: completion)
        } else {
            close(drawerSide: activeSide, completion: {
                self.open(drawerSide: side, completion: completion)
            })
        }
    }
    
    /// Closes the active drawer side
    open func closeDrawer() {
        toggle(drawerSide: activeSide)
    }
    
    /// Action for NTDrawerBarButtonItem that is added by default to the centerViewController
    internal func toggleLeftViewController(_ sender: AnyObject? = nil) {
        toggle(drawerSide: .left)
    }
    
    /// Action for NTDrawerBarButtonItem that is added by default to the centerViewController
    internal func toggleRightViewController(_ sender: AnyObject? = nil) {
        toggle(drawerSide: .right)
    }
    
    
    /// Opens a side drawer and performs the animations specified by the side parameter
    ///
    /// - Parameters:
    ///   - side: The side to open
    ///   - completion: Called when the animation is complete
    fileprivate func open(drawerSide side: NTDrawerSide, completion: (() -> Void)? = nil) {
        
        guard let properties = properties(forSide: side) else {
            Log.write(.error, "Cannot open the centerViewController")
            return
        }
        
        updateView(properties)
        viewController(forSide: properties.side)?.view.isHidden = false
        viewController(forSide: properties.side)?.view.addGestureRecognizer(panGestureRecognizer)
        toggleOverlayView(isActive: true)
        
        UIView.animate(withDuration: properties.drawerAnimationDuration,
                              delay: properties.drawerAnimationDelay,
             usingSpringWithDamping: properties.drawerAnimationSpringDamping,
              initialSpringVelocity: properties.drawerAnimationSpringVelocity,
                            options: properties.drawerAnimationStyle, animations: {
                                
                                if properties.isVisibleOnTop {
                                    self.viewController(forSide: side)?.view.transform = properties.transform()
                                    self.statusBar?.alpha = 0
                                } else {
                                    self._centerViewController?.view.transform = properties.transform()
                                    self.statusBar?.transform = properties.transform()
                                }
                                self.overlayView.alpha = 0.2
                                properties.additionalOpenAnimations?()
                                
        }, completion: { finished in
            
            self._currentState = self.state(forSide: side)
            completion?()
        })
    }
    
    /// Closes a side drawer and performs the animations specified by the side parameter
    ///
    /// - Parameters:
    ///   - side: The side to close
    ///   - completion: Called when the animation is complete
    fileprivate func close(drawerSide side: NTDrawerSide, completion: (() -> Void)? = nil) {
        
        guard let properties = properties(forSide: side) else {
            Log.write(.error, "Cannot open the centerViewController")
            return
        }
        
        UIView.animate(withDuration: properties.drawerAnimationDuration,
                              delay: properties.drawerAnimationDelay,
             usingSpringWithDamping: properties.drawerAnimationSpringDamping,
              initialSpringVelocity: properties.drawerAnimationSpringVelocity,
                            options: properties.drawerAnimationStyle, animations: {
                                
                                if properties.isVisibleOnTop {
                                    self.viewController(forSide: side)?.view.transform = CGAffineTransform.identity
                                    self.statusBar?.alpha = 1
                                } else {
                                    self._centerViewController?.view.transform = CGAffineTransform.identity
                                    self.statusBar?.transform = CGAffineTransform.identity
                                }
                                self.overlayView.alpha = 0

                                properties.additionalCloseAnimations?()
                                
        }, completion: { finished in
            self.toggleOverlayView(isActive: false)
            self.viewController(forSide: side)?.view.isHidden = true
            self.viewController(forSide: side)?.view.removeGestureRecognizer(self.panGestureRecognizer)
            self._currentState = .collapsed
            completion?()
        })
    }
    
    
    /// Brinds a side drawer back to its original openned state
    ///
    /// - Parameter side: The side to bounce back
    fileprivate func bounceBack(drawerSide side: NTDrawerSide) {
        
        guard let properties = properties(forSide: side) else {
            Log.write(.error, "Cannot open the centerViewController")
            return
        }
        
        UIView.animate(withDuration: properties.drawerAnimationDuration,
                       delay: properties.drawerAnimationDelay,
                       usingSpringWithDamping: properties.drawerAnimationSpringDamping,
                       initialSpringVelocity: properties.drawerAnimationSpringVelocity,
                       options: properties.drawerAnimationStyle, animations: {
                        
                        if properties.isVisibleOnTop {
                            self.viewController(forSide: side)?.view.frame.origin.x = properties.side == .left ? 0 : self.view.bounds.width - properties.width
                        }
                        
        }, completion: nil)
    }
    
    // MARK: - UIGestureRecognizerDelegate
    
    
    /// Specifies if the panGestureRecognizer should begin. Disables initial bounce effect
    ///
    /// - Parameter gestureRecognizer: gestureRecognizer
    /// - Returns: If the gesture can begin handling
    open func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        
        guard let panGesture = gestureRecognizer as? UIPanGestureRecognizer else {
            return true
        }
        let gestureIsDraggingFromLeftToRight = (panGesture.velocity(in: view).x > 0)
        
        if currentState == .leftExpanded, gestureIsDraggingFromLeftToRight {
            return false
        }
        if currentState == .rightExpanded, !gestureIsDraggingFromLeftToRight {
            return false
        }
        return true
    }
    
    open func handlePanGesture(_ gestureRecognizer: UIPanGestureRecognizer) {
        
        let boundWidth = gestureRecognizer.view!.frame.origin.x
     
        guard let props = properties(forSide: activeSide), let activeView = viewController(forSide: activeSide)?.view else {
            return
        }
        
        switch(gestureRecognizer.state) {
        case .began, .changed:
            
            if props.isVisibleOnTop {
                var xPosition: CGFloat
                
                if props.side == .left {
                    xPosition = activeView.frame.origin.x
                    
                    if xPosition <= 30 {
                        gestureRecognizer.view!.center.x = gestureRecognizer.view!.center.x + gestureRecognizer.translation(in: activeView).x
                        gestureRecognizer.setTranslation(CGPoint.zero, in: activeView)
                    }
                } else if props.side == .right {
                    xPosition = activeView.frame.origin.x
                    
                    if xPosition >= (UIScreen.main.bounds.width - props.width - 30) {
                        gestureRecognizer.view!.center.x = gestureRecognizer.view!.center.x + gestureRecognizer.translation(in: activeView).x
                        gestureRecognizer.setTranslation(CGPoint.zero, in: activeView)
                    }
                }
            }
            
        case .ended:
            let shouldAutoClose = currentState == .leftExpanded ? -boundWidth > (props.width / 3) : boundWidth > (props.width / 3)
            if shouldAutoClose {
                close(drawerSide: activeSide)
            } else {
                bounceBack(drawerSide: activeSide)
            }
        default:
            break
        }
    }
    
    open func updateView(_ properties: NTDrawerViewProperties) {
    
        if properties.side == .left {
            _leftViewController?.view.frame = CGRect(x: properties.isVisibleOnTop ? -leftViewProperties.width : 0, y: 0, width: leftViewProperties.width, height: view.bounds.height)
            if properties.isVisibleOnTop {
                view.bringSubview(toFront: _leftViewController!.view)
                _leftViewController?.view.setDefaultShadow()
                _leftViewController?.view.layer.shadowOpacity = Color.Default.Shadow.Opacity + 0.2
                _leftViewController?.view.layer.shadowOffset = CGSize(width: 3, height: 0)
            } else {
                view.bringSubview(toFront: _centerViewController!.view)
                _centerViewController?.view.setDefaultShadow()
                _centerViewController?.view.layer.shadowOpacity = Color.Default.Shadow.Opacity + 0.2
                _centerViewController?.view.layer.shadowOffset = CGSize(width: -3, height: 0)
            }
        } else if properties.side == .right {
            _rightViewController?.view.frame = CGRect(x: view.bounds.width - (properties.isVisibleOnTop ? 0 : rightViewProperties.width), y: 0, width: rightViewProperties.width, height: view.bounds.height)
            if properties.isVisibleOnTop {
                view.bringSubview(toFront: _rightViewController!.view)
                _rightViewController?.view.setDefaultShadow()
                _rightViewController?.view.layer.shadowOpacity = Color.Default.Shadow.Opacity + 0.2
                _rightViewController?.view.layer.shadowOffset = CGSize(width: -3, height: 0)
            } else {
                view.bringSubview(toFront: _centerViewController!.view)
                _centerViewController?.view.setDefaultShadow()
                _centerViewController?.view.layer.shadowOpacity = Color.Default.Shadow.Opacity + 0.2
                _centerViewController?.view.layer.shadowOffset = CGSize(width: 3, height: 0)
            }
        }
    }
    
    open func toggleOverlayView(isActive: Bool) {
        if isActive, overlayView.superview == nil {
            _centerViewController?.view.addSubview(overlayView)
            overlayView.fillSuperview()
        } else {
            overlayView.removeAllConstraints()
            overlayView.removeFromSuperview()
        }
    }
    
    
    /// Closes the active drawer if the viewControllerToPresent.modalPresentationStyle is anything other than .overCurrentContext
    open override func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
        
        if viewControllerToPresent.modalPresentationStyle != .overCurrentContext {
            close(drawerSide: activeSide) {
                super.present(viewControllerToPresent, animated: flag, completion: completion)
            }
        } else {
            super.present(viewControllerToPresent, animated: flag, completion: completion)
        }
    }
    
    // MARK: - Accessor Variables
    
    open var centerViewController: UIViewController? {
        get {
            return _centerViewController
        }
    }
    
    open var leftViewController: UIViewController? {
        get {
            return _leftViewController
        }
    }
    
    open var rightViewController: UIViewController? {
        get {
            return _rightViewController
        }
    }
    
    open var currentState: NTDrawerControllerState {
        get {
            return _currentState
        }
    }
    
    open var activeSide: NTDrawerSide {
        get {
            switch _currentState {
            case .collapsed:
                return .center
            case .leftExpanded:
                return .left
            case .rightExpanded:
                return .right
            }
        }
    }
    
    // MARK: - Mapping Methods
    
    
    /// Returns the correct drawer properties held by NTDrawerController for the respective side
    ///
    /// - Parameter side: Properties side to return
    /// - Returns: The properties for the respective side
    public func properties(forSide side: NTDrawerSide) -> NTDrawerViewProperties? {
        switch side {
        case .left:
            return leftViewProperties
        case .right:
            return rightViewProperties
        default:
            return nil
        }
    }
    
    
    /// Maps a NTDrawerControllerState to NTDrawerSide
    ///
    /// - Parameter side: NTDrawerSide to map
    /// - Returns: The mapped NTDrawerControllerState
    public func state(forSide side: NTDrawerSide) -> NTDrawerControllerState {
        switch side {
        case .center:
            return .collapsed
        case .left:
            return .leftExpanded
        case .right:
            return .rightExpanded
        }
    }
    
    
    /// Maps an NTDrawerSide to its respective controller
    ///
    /// - Parameter side: NTDrawerSide to map
    /// - Returns: The view controller for the given side
    public func viewController(forSide side: NTDrawerSide) -> UIViewController? {
        switch side {
        case .center:
            return _centerViewController
        case .left:
            return _leftViewController
        case .right:
            return _rightViewController
        }
    }
}

open class NTDrawerBarButtonItem: UIBarButtonItem {
    
    open var menuButton: AnimatedMenuButton
    
    open class AnimatedMenuButton: UIButton {
        
        lazy var top: CAShapeLayer = CAShapeLayer()
        lazy var middle: CAShapeLayer = CAShapeLayer()
        lazy var bottom: CAShapeLayer = CAShapeLayer()
        
        
        let shortStroke: CGPath = {
            let path = CGMutablePath()
            path.move(to: CGPoint(x: 3.5, y: 6))
            path.addLine(to: CGPoint(x: 22.5, y: 6))
            return path
        }()
        
        
        // MARK: - Initializers
        
        required public init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
        }
        
        override convenience init(frame: CGRect) {
            self.init(frame: frame, strokeColor: Color.Default.Tint.NavigationBar)
        }
        
        public init(frame: CGRect, strokeColor: UIColor) {
            super.init(frame: frame)
            
            self.top.path = shortStroke;
            self.middle.path = shortStroke;
            self.bottom.path = shortStroke;
            
            for layer in [ self.top, self.middle, self.bottom ] {
                layer.fillColor = nil
                layer.strokeColor = strokeColor.cgColor
                layer.lineWidth = 1
                layer.miterLimit = 2
                layer.lineCap = kCALineCapSquare
                layer.masksToBounds = true
                
                if let path = layer.path, let strokingPath = CGPath(__byStroking: path, transform: nil, lineWidth: 1, lineCap: .square, lineJoin: .miter, miterLimit: 4) {
                    layer.bounds = strokingPath.boundingBoxOfPath
                }
                
                layer.actions = [
                    "opacity": NSNull(),
                    "transform": NSNull()
                ]
                
                self.layer.addSublayer(layer)
            }
            
            self.top.anchorPoint = CGPoint(x: 1, y: 0.5)
            self.top.position = CGPoint(x: 23, y: 7)
            self.middle.position = CGPoint(x: 13, y: 13)
            
            self.bottom.anchorPoint = CGPoint(x: 1, y: 0.5)
            self.bottom.position = CGPoint(x: 23, y: 19)
        }
        
        open override func draw(_ rect: CGRect) {
            
            Color.Default.Tint.NavigationBar.setStroke()
            
            let context = UIGraphicsGetCurrentContext()
            context?.setShouldAntialias(false)
            
            let top = UIBezierPath()
            top.move(to: CGPoint(x:3,y:6.5))
            top.addLine(to: CGPoint(x:23,y:6.5))
            top.stroke()
            
            let middle = UIBezierPath()
            middle.move(to: CGPoint(x:3,y:12.5))
            middle.addLine(to: CGPoint(x:23,y:12.5))
            middle.stroke()
            
            let bottom = UIBezierPath()
            bottom.move(to: CGPoint(x:3,y:18.5))
            bottom.addLine(to: CGPoint(x:23,y:18.5))
            bottom.stroke()
        }
    }

    
    // MARK: - Initializers
    
    public override init() {
        self.menuButton = AnimatedMenuButton(frame: CGRect(x: 0, y: 0, width: 26, height: 26))
        super.init()
        self.customView = self.menuButton
    }
    
    public convenience init(target: AnyObject?, action: Selector) {
        self.init(target: target, action: action, menuIconColor: Color.Default.Tint.NavigationBar)
    }
    
    public convenience init(target: AnyObject?, action: Selector, menuIconColor: UIColor) {
        self.init(target: target, action: action, menuIconColor: menuIconColor, animatable: true)
    }
    
    public convenience init(target: AnyObject?, action: Selector, menuIconColor: UIColor, animatable: Bool) {
        let menuButton = AnimatedMenuButton(frame: CGRect(x: 0, y: 0, width: 26, height: 26), strokeColor: menuIconColor)
        menuButton.addTarget(target, action: action, for: UIControlEvents.touchUpInside)
        self.init(customView: menuButton)
        
        self.menuButton = menuButton
    }
    
    public required init?(coder aDecoder: NSCoder) {
        self.menuButton = AnimatedMenuButton(frame: CGRect(x: 0, y: 0, width: 26, height: 26))
        super.init(coder: aDecoder)
        self.customView = self.menuButton
    }
}
