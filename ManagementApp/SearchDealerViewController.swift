//
//  SearchDealerViewController.swift
//  ManagementApp
//
//  Created by Goldmedal on 06/06/19.
//  Copyright © 2019 Goldmedal. All rights reserved.
//

import UIKit

class SearchDealerViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate {
    
    //Outlets...
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var textField: UITextField!
    
    //Declarations...
    var dealerArray = [SearchDealersObj]()
    var tempDealersArr = [SearchDealersObj]()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    override func viewDidLoad() {
        super.viewDidLoad()
        addSlideMenuButton()
        dealerArray = appDelegate.dealerData
        for dealers in dealerArray{
            tempDealersArr.append(dealers)
        }
        textField.addTarget(self, action: #selector(searchRecords(_ :)), for: .editingChanged)
        
    }
    
    //Auto-Complete Function...
    @objc func searchRecords(_ textfield: UITextField){
        self.dealerArray.removeAll()
        if textfield.text?.count != 0{
            for dealers in tempDealersArr{
                let range = dealers.dealernm!.lowercased().range(of: textfield.text!, options: .caseInsensitive, range: nil, locale: nil)
                if range != nil{
                    dealerArray.append(dealers)
                }
            }
        }else{
            for dealers in tempDealersArr{
                dealerArray.append(dealers)
            }
        }
        tableView.reloadData()
    }
    
    //TableView Functions...
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dealerArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchCell", for: indexPath) 
        cell.textLabel?.text = dealerArray[indexPath.row].dealernm
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        appDelegate.sendCin = dealerArray[indexPath.row].cin!
//        weak var pvc = self.presentingViewController
//        self.dismiss(animated: false, completion: {
//            let OldDashboard =  self.storyboard?.instantiateViewController(withIdentifier: "OldDashboard") as! OldDashboardController
//            let navVc = UINavigationController(rootViewController: OldDashboard)
//            pvc?.present(navVc, animated: true, completion: nil)
//        })
        //self.navigationController?.popViewController(animated: true)
    }
    
    
    
}
