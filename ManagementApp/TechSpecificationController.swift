//
//  TechSpecificationController.swift
//  DealorsApp
//
//  Created by Goldmedal on 5/5/18.
//  Copyright © 2018 Goldmedal. All rights reserved.
//

import UIKit
import SDWebImage
import FirebaseAnalytics

class TechSpecificationController: BaseViewController,UISearchBarDelegate{
    
    @IBOutlet weak var tableViewSpecification: UITableView!
    @IBOutlet weak var noDataView: NoDataView!
    var strSearchText = ""
    
    @IBOutlet weak var searchBar: RoundSearchBar!
    var TechSpecsElementMain = [TechSpecsElement]()
    var TechSpecsArray = [TechSpecsData]()
    var TechSpecsItems = [[TechSpecsData]]()
    var TechSpecsSection = [String]()
    var strCin = ""
    var techSpecsApi=""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        noDataView.hideView(view: noDataView)
        
        addSlideMenuButton()
        
//        Analytics.setScreenName("TECH SPECIFICATION SCREEN", screenClass: "TechSpecificationController")
//        SQLiteDB.instance.addAnalyticsData(ScreenName: "TECH SPECIFICATION SCREEN", ScreenId: Int64(GlobalConstants.init().TECH_SPECS))
//
        let loginData =  UserDefaults.standard.value(forKey: "loginData") as? Dictionary ?? [:]
        strCin = loginData["userlogid"] as? String ?? ""
        
        let initialData =  UserDefaults.standard.value(forKey: "initialData") as? Dictionary ?? [:]
        techSpecsApi = (initialData["baseApi"] as? String ?? "")+""+(initialData["subcatimgdivwise"] as? String ?? "")
        //techSpecsApi = "https://test2.goldmedalindia.in/api/getsubcatimgdivwise"
        
        // Do any additional setup after loading the view.
        if (Utility.isConnectedToNetwork()) {
            print("Internet connection available")
            self.apiTechSpecsList()
            self.noDataView.hideView(view: self.noDataView)
        }
        else{
            print("No internet connection available")
            
            var alert = UIAlertView(title: "No Internet Connection", message: "Make sure your device is connected to the internet.", delegate: nil, cancelButtonTitle: "OK")
            alert.show()
            self.noDataView.showView(view: self.noDataView, from: "NET")
        }
        
        self.tableViewSpecification.delegate = self;
        self.tableViewSpecification.dataSource = self;
        self.searchBar.delegate = self;
    }
    
    
    //search filter
    func filterSearch(){
        self.TechSpecsArray.removeAll()
        self.TechSpecsSection.removeAll()
        self.TechSpecsItems.removeAll()
        apiTechSpecsList()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.characters.count > 2 {
            strSearchText = searchText
            filterSearch()
        }
        
        if searchText == ""
        {
            strSearchText = ""
            filterSearch()
            searchBar.resignFirstResponder()
        }
    }
    
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    
    func apiTechSpecsList(){
        
        let json: [String: Any] = ["CIN":UserDefaults.standard.value(forKey: "userCIN"),"ClientSecret":"ClientSecret","Search":strSearchText]
        
        DataManager.shared.makeAPICall(url: techSpecsApi, params: json, method: .POST, success: { (response) in
            let data = response as? Data
            print("techSpecsApi - - - ",self.techSpecsApi,"------",json)
            
            DispatchQueue.main.async {
                do {
                    self.TechSpecsElementMain = try JSONDecoder().decode([TechSpecsElement].self, from: data!)
                    self.TechSpecsArray = self.TechSpecsElementMain[0].data
                    print("Tech Specs \(self.TechSpecsElementMain[0].data)")
                    let groupedDictionary = Dictionary(grouping: self.TechSpecsArray, by: { (techSpecs) -> String in
                        return techSpecs.division!
                    })
                    
                    
                    let keys = groupedDictionary.keys.sorted(by: {$0.count > $1.count})
                    
                    self.TechSpecsSection.append(contentsOf: keys)
                    
                    keys.forEach({ (key) in
                        self.TechSpecsItems.append(groupedDictionary[key]!)
                    })
                    
                } catch let errorData {
                    print(errorData.localizedDescription)
                }
                
                if(self.TechSpecsArray.count>0){
                    if(self.tableViewSpecification != nil)
                    {
                        self.tableViewSpecification.reloadData()
                    }
                    self.noDataView.hideView(view: self.noDataView)
                }else{
                    self.noDataView.showView(view: self.noDataView, from: "NDA")
                }
                
                ViewControllerUtils.sharedInstance.removeLoader()
                
            }
        }) { (Error) in
            ViewControllerUtils.sharedInstance.removeLoader()
            print(Error?.localizedDescription)
            self.noDataView.showView(view: self.noDataView, from: "ERR")
        }
        
        //            DispatchQueue.main.async {
        //            do {
        //                self.TechSpecsElementMain = try JSONDecoder().decode([TechSpecsElement].self, from: data!)
        //                self.TechSpecsArray = self.TechSpecsElementMain[0].data
        //
        //            } catch let errorData {
        //                print(errorData.localizedDescription)
        //            }
        //
        //
        //                    if(self.tableViewSpecification != nil)
        //                    {
        //                        self.tableViewSpecification.reloadData()
        //                    }
        //
        //                 if(self.TechSpecsArray.count>0){
        //                    self.noDataView.hideView(view: self.noDataView)
        //                }else{
        //                    self.noDataView.showView(view: self.noDataView, from: "NDA")
        //                }
        //            }
        //        }) { (Error) in
        //            self.noDataView.showView(view: self.noDataView, from: "ERR")
        //            ViewControllerUtils.sharedInstance.removeLoader()
        //            print(Error?.localizedDescription)
        //        }
        
    }
    
    
    //    func clickPdf(sender: UITapGestureRecognizer)
    //    {
    //        print("pdf name : \(sender.view!.tag)")
    //
    //        guard let url = URL(string: TechSpecsArray[sender.view!.tag].url ?? "") else {
    //
    //            var alert = UIAlertView(title: "Error", message: "Invalid Pdf", delegate: nil, cancelButtonTitle: "OK")
    //            alert.show()
    //
    //            return
    //        }
    //        if UIApplication.shared.canOpenURL(url) {
    //            UIApplication.shared.open(url, options: [:], completionHandler: nil)
    //        }
    //    }
    
    
    //    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    //        return TechSpecsArray.count
    //    }
    //
    //    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    //        return UITableViewAutomaticDimension
    //    }
    //
    //    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    //
    //        let cell = tableView.dequeueReusableCell(withIdentifier: "TechSpecsListCell", for: indexPath) as! TechSpecsRowCell
    //        if(TechSpecsArray.count > 0){
    //      cell.lblCode.text = TechSpecsArray[indexPath.row].code?.capitalized ?? "-"
    //      cell.lblName.text = TechSpecsArray[indexPath.row].name?.capitalized ?? "-"
    //
    //            let tap = UITapGestureRecognizer(target: self, action: #selector(self.clickPdf))
    //            cell.imvTechSpecs.addGestureRecognizer(tap)
    //            cell.imvTechSpecs.tag = indexPath.row
    //            cell.imvTechSpecs.isUserInteractionEnabled = true
    //
    //        if TechSpecsArray[indexPath.row].imgurl != ""
    //        {
    //            cell.imvTechSpecs.sd_setImage(with: URL(string: TechSpecsArray[indexPath.row].imgurl ?? ""), placeholderImage: UIImage(named: "no_image_icon.png"))
    //        }
    //
    //    }
    //
    //        return cell
    //    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

extension TechSpecificationController : UITableViewDelegate { }

extension TechSpecificationController : UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: 40))
        headerView.backgroundColor = UIColor.darkGray
        let label = UILabel()
        label.frame = CGRect.init(x: 0, y: 0, width: headerView.frame.width, height: headerView.frame.height)
        label.textAlignment = NSTextAlignment.center
        label.font = UIFont(name: "Roboto-Regular", size: 16.0)
        label.text = TechSpecsSection[section]
        label.textColor = UIColor.white
        
        headerView.addSubview(label)
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 195
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return TechSpecsSection.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TechSpecsListCell") as! TechSpecsRowCell
        let itemCategory = self.TechSpecsItems[indexPath.section]
        cell.updateCellWith(category:itemCategory)
        return cell
    }
}
