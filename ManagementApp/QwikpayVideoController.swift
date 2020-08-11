//
//  QwikpayController.swift
//  DealorsApp
//
//  Created by Goldmedal on 8/19/19.
//  Copyright © 2019 Goldmedal. All rights reserved.
//

import UIKit
import YoutubePlayer_in_WKWebView
import FirebaseAnalytics

class QwikpayVideoController: BaseViewController,UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet weak var playerView: WKYTPlayerView!
    @IBOutlet weak var tblQwikpay: UITableView!
    @IBOutlet weak var noDataView: NoDataView!
    
    var QwikpayVideoElementMain = [DhanbarseQwikPayVideoElement]()
    var QwikpayVideoDataMain = [DhanbarseQwikPayObj]()
    
    var strCin = ""
    var strQwikpayApi = ""
    var finYear = ""
    
    let playvarsDic = ["controls": 1, "playsinline": 1, "autohide": 1, "showinfo": 1, "autoplay": 1, "modestbranding": 1]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addSlideMenuButton()
        // Do any additional setup after loading the view.
        
        finYear = Utility.currFinancialYear()
        
        //Analytics.setScreenName("QWIKPAY VIDEO SCREEN", screenClass: "QwikpayVideoController")
        //SQLiteDB.instance.addAnalyticsData(ScreenName: "QWIKPAY SCREEN", ScreenId: Int64(GlobalConstants.init().QWIKPAY_VIDEO))
        
        let loginData =  UserDefaults.standard.value(forKey: "loginData") as? Dictionary ?? [:]
        strCin = loginData["userlogid"] as? String ?? ""
        
        let initialData =  UserDefaults.standard.value(forKey: "initialData") as? Dictionary ?? [:]
          strQwikpayApi = (initialData["baseApi"] as? String ?? "")+""+(initialData["dhanbarseQwikpayVideo"] as? String ?? "")
       // strQwikpayApi = "https://api.goldmedalindia.in/api/getDhanbarseQwikpayVideo"
        
        self.tblQwikpay.delegate = self;
        self.tblQwikpay.dataSource = self;
        
        
        if (Utility.isConnectedToNetwork()) {
            print("Internet connection available")
            apiQwikpayVideo()
            self.noDataView.hideView(view: self.noDataView)
        }
        else{
            print("No internet connection available")
            var alert = UIAlertView(title: "No Internet Connection", message: "Make sure your device is connected to the internet.", delegate: nil, cancelButtonTitle: "OK")
            alert.show()
            self.noDataView.showView(view: self.noDataView, from: "NET")
        }
        
    }
    
    
    
    func apiQwikpayVideo(){
        
        let json: [String: Any] = ["CIN":strCin,"ClientSecret":"ClientSecret","Type":2]
        
        DataManager.shared.makeAPICall(url: strQwikpayApi, params: json, method: .POST, success: { (response) in
            let data = response as? Data
            print("strQwikpayApi - - - ",self.strQwikpayApi,"------",json)
            
            DispatchQueue.main.async {
                do {
                    self.QwikpayVideoElementMain = try JSONDecoder().decode([DhanbarseQwikPayVideoElement].self, from: data!)
                    
                    self.QwikpayVideoDataMain.append(contentsOf: self.QwikpayVideoElementMain[0].data)
                    
                    if(self.QwikpayVideoDataMain.count > 0){
                        self.playerView.load(withVideoId: self.QwikpayVideoDataMain[0].videolink ?? "", playerVars: self.playvarsDic)
                        
                        if(self.tblQwikpay != nil)
                        {
                            self.tblQwikpay.reloadData()
                        }
                        
                    }else{
                         self.noDataView.showView(view: self.noDataView, from: "NDA")
                    }
                  
                    
                } catch let errorData {
                    print(errorData.localizedDescription)
                     self.noDataView.showView(view: self.noDataView, from: "NDA")
                }
                
            }
            
        }) { (Error) in
            ViewControllerUtils.sharedInstance.removeLoader()
            print(Error?.localizedDescription)
            self.noDataView.showView(view: self.noDataView, from: "ERR")
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.QwikpayVideoDataMain.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "VideoCell", for: indexPath) as! VideoViewCell
        
        var hrs = self.QwikpayVideoDataMain[indexPath.row].hour ?? "-"
        var mins = self.QwikpayVideoDataMain[indexPath.row].minute ?? "-"
        var seconds = self.QwikpayVideoDataMain[indexPath.row].second ?? "-"
        
        cell.lblVideoName.text = self.QwikpayVideoDataMain[indexPath.row].subject ?? "-"
        cell.lblVideoDetail.text = self.QwikpayVideoDataMain[indexPath.row].details ?? "-"
        cell.lblVideoDuration.text = hrs+" : "+mins+" : "+seconds
        
        if self.QwikpayVideoDataMain[indexPath.row].images != ""
        {
            cell.imvThumbnail.sd_setImage(with: URL(string: self.QwikpayVideoDataMain[indexPath.row].images ?? ""), placeholderImage: UIImage(named: "no_image_icon.png"))
        }else{
            cell.imvThumbnail.image = UIImage(named: "no_image_icon.png")
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let indexPath = tableView.indexPathForSelectedRow
        
        //getting the current cell from the index path
        let currentCell = tableView.cellForRow(at: indexPath!)! as! VideoViewCell
        
        self.playerView.load(withVideoId: self.QwikpayVideoDataMain[(indexPath?.row)!].videolink ?? "", playerVars: playvarsDic)
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
