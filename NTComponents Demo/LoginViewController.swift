 //
//  LoginViewController.swift
//  Engage
//
//  Created by Nathan Tannar on 5/12/17.
//  Copyright © 2017 Nathan Tannar. All rights reserved.
//

import UIKit
import NTComponents

class LoginViewController: NTLoginViewController, NTEmailAuthDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        logo = #imageLiteral(resourceName: "NT Components Banner")
        titleLabel.text = "NTComponents"
        subtitleLabel.text = "Demo"
        
//        didLogIn()
    }
    
    override func loginLogic(sender: NTLoginButton) {
        
        let method = sender.loginMethod
        if method == .email {
            let vc = NTEmailAuthViewController()
            vc.delegate = self
            present(vc, animated: true, completion: nil)
        } else {
            thirdPartyLogin(sender)
        }
    }
    
    func didLogIn() {
        let tabVC = TabBarController(viewControllers: [
            StandardViewControllers().withTitle("Controllers"),
            TableViewController().withTitle("Table"),
            AlertsViewController().withTitle("Alerts"),
            FormViewController().withTitle("Form"),
            CalendarViewController().withTitle("Calendar"),
            TimelineTableViewController().withTitle("Timeline"),
            ViewController().withTitle("Magic View"),
            ColorsCollectionView().withTitle("Colors")
        ])
        tabVC.tabBarHeight = 44
        tabVC.tabBarItemWidth = 100
        tabVC.title = "NTComponents"
        tabVC.subtitle = "Demo"
        tabVC.tabBarPosition = .bottom
        let drawer = NTDrawerController(centerViewController: NTNavigationController(rootViewController: tabVC),
                                        leftViewController: DrawerViewController(side: .left),
                                        rightViewController: DrawerViewController(side: .right))
        present(drawer, animated: false, completion: nil)
    }
    
    func thirdPartyLogin(_ sender: NTLoginButton) {
        NTPing(type: .isSuccess, title: "Simulating Successful \(sender.title!)").show()
        DispatchQueue.executeAfter(1 , closure: {
            self.didLogIn()
        })
    }
    
    func authorize(_ controller: NTEmailAuthViewController, email: String, password: String) {
        
        controller.showActivityIndicator = true
        NTPing(type: .isSuccess, title: "Simulating Successful Login").show()
        DispatchQueue.executeAfter(1 , closure: {
            controller.showActivityIndicator = false
            self.didLogIn()
        })
    }
    
    func register(_ controller: NTEmailAuthViewController, email: String, password: String) {
        
        let alert = NTAlertViewController(title: "EULA", subtitle: "By registering with [App Name] you accept the End-User License Agreement", type: .isSuccess)
        alert.cancelButton.title = "View"
        alert.confirmButton.title = "Accept"
        alert.onCancel = {
            let vc = NTEULAController()
            vc.eula = Bundle.main.path(forResource: "EULA", ofType: "html")
            controller.present(vc, animated: true, completion: nil)
        }
        alert.onConfirm = {
            
            controller.showActivityIndicator = true
            
            controller.showActivityIndicator = true
            NTPing(type: .isSuccess, title: "Simulating Successful Sign Up").show()
            DispatchQueue.executeAfter(1 , closure: {
                controller.showActivityIndicator = false
                self.didLogIn()
            })
        }
        controller.present(alert, animated: true, completion: nil)
    }
}
