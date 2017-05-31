//
//  AuthorViewController.swift
//  NTComponents
//
//  Created by Nathan Tannar on 5/30/17.
//  Copyright © 2017 Nathan Tannar. All rights reserved.
//

import NTComponents

class AuthorViewController: NTTableViewController, NTTableViewImageDataSource {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "About the Developer"
        tableView.imageDataSource = self
        stretchyHeaderHeight = 250
        addTopGradientToStretchyImage()
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = NTTableViewHeaderFooterView()
        header.textLabel.text = "About the Developer"
        return header
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 30
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NTTableViewCell", for: indexPath) as! NTTableViewCell
        cell.textLabel?.text = String.random(ofLength: 10)
        cell.detailTextLabel?.text = String.random(ofLength: 30)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        navigationController?.pushViewController(NTViewController(), animated: true)
    }
    
    func imageForStretchyView(in tableView: NTTableView) -> UIImage? {
        return UIImage(named: "Background")
    }
}
