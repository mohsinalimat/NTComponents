//
//  NTCollectionViewController.swift
//  NTComponents
//
//  Created by Nathan Tannar on 2/22/17.
//  Copyright © 2017 Nathan Tannar. All rights reserved.
//

import UIKit

open class NTCollectionViewController: DatasourceController {
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = Color.Default.Background.ViewController
        collectionView?.backgroundColor = Color.Default.Background.ViewController
       
        if let parent =  parent as? NTScrollableTabBarController {
            collectionView?.contentInset.top = parent.properties.tabHeight
            collectionView?.scrollIndicatorInsets.top = parent.properties.tabHeight
        }
    }
    
    open override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        collectionViewLayout.invalidateLayout()
    }
}
