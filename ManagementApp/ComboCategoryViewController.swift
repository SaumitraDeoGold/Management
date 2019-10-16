//
//  ComboCategoryViewController.swift
//  DealorsApp
//
//  Created by Goldmedal on 10/29/18.
//  Copyright © 2018 Goldmedal. All rights reserved.
//

import UIKit

class ComboCategoryViewController: UIViewController , UITableViewDelegate , UITableViewDataSource {

    @IBOutlet weak var imvClose: UIImageView!
    @IBOutlet weak var vwClose: UIView!
    @IBOutlet weak var categoryTableView: UITableView!
    @IBOutlet weak var viewHeight: NSLayoutConstraint!
    var ComboCategoryItems = [[ComboSchemeDetail]]()
    var ComboSchemeSection = [String]()
    var ComboSchemeSectionCount = [String]()
   
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.categoryTableView.delegate = self;
        self.categoryTableView.dataSource = self;
        
        var count = 0
        for items in self.ComboCategoryItems{
           count = 0
            for index in 1...(items.count) {
                count = items.count
                self.ComboSchemeSection.append(items[1].combogrpname ?? "-")
                self.ComboSchemeSectionCount.append(String(count))
                break
            }
        }
        
        if(self.categoryTableView != nil)
        {
            self.categoryTableView.reloadData()
            self.viewHeight.constant = CGFloat((ComboSchemeSection.count*35)+90)
        }
        
        let tabClose = UITapGestureRecognizer(target: self, action: #selector(self.tapFunction))
        vwClose.addGestureRecognizer(tabClose)
    }
    
    @objc func tapFunction(sender:UITapGestureRecognizer) {
        print("tap working")
        dismiss(animated: true)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ComboCategoryCell", for: indexPath) as! ComboCategoryCell
        cell.lblCategory.text = ComboSchemeSection[indexPath.row]
        cell.lblCount.text = ComboSchemeSectionCount[indexPath.row]
        
        return cell
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ComboSchemeSection.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 35
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
