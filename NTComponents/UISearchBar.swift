//
//  UISearchBar.swift
//  NTComponents
//
//  Created by Nathan Tannar on 4/20/17.
//  Copyright © 2017 Nathan Tannar. All rights reserved.
//

public extension UISearchBar {
    
    func addToolBar(withItems items: [UIBarButtonItem]){
        let toolBar = UIToolbar()
        toolBar.barStyle = .default
        toolBar.isTranslucent = true
        toolBar.tintColor = Color.Default.Tint.View
        toolBar.setItems(items, animated: false)
        toolBar.isUserInteractionEnabled = true
        toolBar.sizeToFit()
        self.inputAccessoryView = toolBar
    }
}
