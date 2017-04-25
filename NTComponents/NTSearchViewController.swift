//
//  NTSearchViewController.swift
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

import UIKit

open class NTSearchViewController: NTTableViewController, UISearchBarDelegate {
    
    public var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.tintColor = Color.Default.Tint.NavigationBar
        searchBar.placeholder = "Search"
        return searchBar
    }()
    
    // MARK: - Standard Methods
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.delegate = self
        navigationItem.titleView = self.searchBar
        updateResults()
    }
    
    override open func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.endEditing(true)
    }
    
    // MARK: NTSearchViewController Methods
    
    open func updateResults() {
        Log.write(.warning, "You have not overridden the search results handler")
    }
    
    // MARK: - UISearchBar Delegate
    
    open func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        updateResults()
    }
    
    public func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        searchBarCancelled()
    }
    
    open func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
    }
    
    open func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    open func searchBarCancelled() {
        searchBar.text = String()
        searchBar.resignFirstResponder()
        updateResults()
    }
}

