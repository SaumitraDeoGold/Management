//
//  ShowRoomController.swift
//  DealorsApp
//
//  Created by Goldmedal on 15/11/18.
//  Copyright © 2018 Goldmedal. All rights reserved.
//

import UIKit
import FirebaseAnalytics

class ShowRoomController:  BaseViewController,UITableViewDelegate,UITableViewDataSource{
   
    var ShowRoomElementMain = [ShowRoomElement]()
    var ShowRoomArray = [ShowRoomData]()
    @IBOutlet weak var menuShowRoom: UIBarButtonItem!
    @IBOutlet weak var noDataView: NoDataView!
    @IBOutlet weak var tableView: UITableView!
    
    var strCin = ""
    var showRoomApi = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        self.noDataView.hideView(view: self.noDataView)
        
        // Do any additional setup after loading the view.
        addSlideMenuButton()
        
        Analytics.setScreenName("SHOW ROOM SCREEN", screenClass: "ShowRoomController")
        
        let loginData =  UserDefaults.standard.value(forKey: "loginData") as? Dictionary ?? [:]
        strCin = loginData["userlogid"] as? String ?? ""
        
        //        let initialData =  UserDefaults.standard.value(forKey: "initialData") as? Dictionary ?? [:]
        //        notiListApi = (initialData["baseApi"] as? String ?? "")+""+(initialData["activeScheme"] as? String ?? "")
        
        showRoomApi = "https://api.goldmedalindia.in/api/getShowRoom"
        if (Utility.isConnectedToNetwork()) {
            print("Internet connection available")
            OperationQueue.main.addOperation {
                //                self.ActiveSchemeArray.removeAll()
                self.apiShowRoom()
            }
            self.noDataView.hideView(view: self.noDataView)
        }
        else {
            print("No internet connection available")
            
            var alert = UIAlertView(title: "No Internet Connection", message: "Make sure your device is connected to the internet.", delegate: nil, cancelButtonTitle: "OK")
            alert.show()
            self.noDataView.showView(view: self.noDataView, from: "NET")
        }
        
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        
        tableView.tableFooterView = UIView()
    }
    

    
    
    func apiShowRoom() -> Void {
        
        
        
        let json: [String: Any] = ["CIN":"999999","ClientSecret":"ClientSecret"]
        
        DataManager.shared.makeAPICall(url: showRoomApi, params: json, method: .POST, success: { (response) in
            let data = response as? Data
            
            DispatchQueue.main.async {
                do {
                    self.ShowRoomElementMain = try JSONDecoder().decode([ShowRoomElement].self, from: data!)
                    
                    self.ShowRoomArray = self.ShowRoomElementMain[0].data
                    
                    
                    let bookiesData = try! PropertyListEncoder().encode(self.ShowRoomArray)
                    UserDefaults.standard.set(bookiesData, forKey: "bookies")
                
                    
                }
                catch let errorData {
                    print(errorData.localizedDescription)
                }
                
                
                if(self.tableView != nil)
                {
                    self.tableView.reloadData()
                }
                
                if(self.ShowRoomArray.count>0){
                    self.noDataView.hideView(view: self.noDataView)
                }else{
                    self.noDataView.showView(view: self.noDataView, from: "NDA")
                }
                
            }
            
        }) { (Error) in
            ViewControllerUtils.sharedInstance.removeLoader()
            print(Error?.localizedDescription)
            self.noDataView.showView(view: self.noDataView, from: "ERR")
        }
        
        
        
        
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ShowRoomArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ShowRoomCell", for: indexPath) as! ShowRoomCell
        
        cell.lblShowRoomName.text = ShowRoomArray[indexPath.row].name?.capitalized ?? "-"
        cell.lblShowRoomAddress.text = ShowRoomArray[indexPath.row].address ?? "-"
        
        
        if ShowRoomArray[indexPath.row].image != ""
        {
            cell.imvShowRoom.sd_setImage(with: URL(string: ShowRoomArray[indexPath.row].image ?? ""), placeholderImage: UIImage(named: "no_image_icon.png"))
        }
        //cell.lblDateTime.text = NotificationArray[indexPath.row].date ?? "-"
        
        
        return cell
    }
}
