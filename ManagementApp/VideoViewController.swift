//
//  VideoViewController.swift
//  DealorsApp
//
//  Created by Goldmedal on 9/5/18.
//  Copyright © 2018 Goldmedal. All rights reserved.
//

import UIKit
import youtube_ios_player_helper
import FirebaseAnalytics

class VideoViewController: BaseViewController,UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet weak var playerView: YTPlayerView!
    @IBOutlet weak var tblVideoList: UITableView!
    @IBOutlet var tabButtons: [UIButton]!
    @IBOutlet var lineLabels: [UILabel]!
    @IBOutlet weak var noDataView: NoDataView!
    
    var VideoListElementMain = [VideoDetailElement]()
    var VideoListDataMain = [VideoObj]()
    
    var eventArr = [Advertisement]()
    var adsArr = [Advertisement]()
    var productArr = [Advertisement]()
    
    var VideoListArray = [Advertisement]()
    
    var strCin = ""
    var strVideoApi = ""

    let playvarsDic = ["controls": 1, "playsinline": 1, "autohide": 1, "showinfo": 1, "autoplay": 1, "modestbranding": 1]
 
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addSlideMenuButton()
        // Do any additional setup after loading the view.
        
        Analytics.setScreenName("VIDEO LIST SCREEN", screenClass: "VideoViewController")
        
        let loginData =  UserDefaults.standard.value(forKey: "loginData") as? Dictionary ?? [:]
        strCin = loginData["userlogid"] as? String ?? ""
        
        let initialData =  UserDefaults.standard.value(forKey: "initialData") as? Dictionary ?? [:]
        strVideoApi = (initialData["baseApi"] as? String ?? "")+""+(initialData["youtubeVideo"] as? String ?? "")
        
        self.tblVideoList.delegate = self;
        self.tblVideoList.dataSource = self;
        
        //self.playerView.load(withVideoId: arrLinks[0], playerVars: playvarsDic)
      
        if (Utility.isConnectedToNetwork()) {
            print("Internet connection available")
            apiVideoList()
            self.noDataView.hideView(view: self.noDataView)
        }
        else{
            print("No internet connection available")
            var alert = UIAlertView(title: "No Internet Connection", message: "Make sure your device is connected to the internet.", delegate: nil, cancelButtonTitle: "OK")
            alert.show()
            self.noDataView.showView(view: self.noDataView, from: "NET")
        }
        
        Analytics.setScreenName("VIDEO VIEW SCREEN", screenClass: "VideoViewController")
    }
    
    @IBAction func tabAction(sender: UIButton) {
        for (index, button) in tabButtons.enumerated() {
            let labelLine = lineLabels[index]
            labelLine.backgroundColor = (button == sender) ? UIColor.red : UIColor.clear
        }
        
        if (Utility.isConnectedToNetwork()) {
            switch sender.tag {
            case 0:
                 loadVideoData(arrayList: eventArr)
                break
            case 1:
                loadVideoData(arrayList: adsArr)
                break
            case 2:
                 loadVideoData(arrayList: productArr)
                break
            case 3:
                self.noDataView.showView(view: self.noDataView, from: "NDA")
                break
            default:
                break
            }
            
        }
        else{
            self.noDataView.showView(view: self.noDataView, from: "NET")
        }
        
    }
    
    
    func loadVideoData(arrayList:[Advertisement]){
        VideoListArray.removeAll()
        VideoListArray = arrayList
        print(VideoListArray,"-- --- --- ",arrayList)
        
        if(self.VideoListArray.count>0){
            self.noDataView.hideView(view: self.noDataView)
            
            self.playerView.load(withVideoId: VideoListArray[0].videolink ?? "", playerVars: playvarsDic)
            
            if(self.tblVideoList != nil)
            {
                self.tblVideoList.reloadData()
            }
            
        }else{
            self.noDataView.showView(view: self.noDataView, from: "NDA")
        }
        
        
    }
    
    func apiVideoList(){
        
        let json: [String: Any] = ["CIN":strCin,"ClientSecret":"201020","FinYear":"2018-2019"]
        
        DataManager.shared.makeAPICall(url: strVideoApi, params: json, method: .POST, success: { (response) in
            let data = response as? Data
            DispatchQueue.main.async {
                do {
                    self.VideoListElementMain = try JSONDecoder().decode([VideoDetailElement].self, from: data!)
                    
                    self.VideoListDataMain = self.VideoListElementMain[0].data
                    
                    self.eventArr.append(contentsOf:self.VideoListDataMain[0].events)
                    self.adsArr.append(contentsOf:self.VideoListDataMain[0].advertisement)
                    self.productArr.append(contentsOf:self.VideoListDataMain[0].product)
                    
                     self.tabAction(sender: self.tabButtons[0])
                    
                } catch let errorData {
                    print(errorData.localizedDescription)
                }
                
                
                if(self.tblVideoList != nil)
                {
                    self.tblVideoList.reloadData()
                }
                
            }
            
        }) { (Error) in
            ViewControllerUtils.sharedInstance.removeLoader()
            print(Error?.localizedDescription)
            self.noDataView.showView(view: self.noDataView, from: "ERR")
        }
    }
        
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return VideoListArray.count
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "VideoCell", for: indexPath) as! VideoViewCell
            
            var hrs = VideoListArray[indexPath.row].hour ?? "-"
            var mins = VideoListArray[indexPath.row].minute ?? "-"
            var seconds = VideoListArray[indexPath.row].second ?? "-"
            
            cell.lblVideoName.text = VideoListArray[indexPath.row].subject ?? "-"
            cell.lblVideoDetail.text = VideoListArray[indexPath.row].details ?? "-"
            cell.lblVideoDuration.text = hrs+" : "+mins+" : "+seconds
            
            if VideoListArray[indexPath.row].images != ""
            {
                cell.imvThumbnail.sd_setImage(with: URL(string: VideoListArray[indexPath.row].images ?? ""), placeholderImage: UIImage(named: "no_image_icon.png"))
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
            
            self.playerView.load(withVideoId: VideoListArray[(indexPath?.row)!].videolink ?? "", playerVars: playvarsDic)
        }
        
        
        
        override func didReceiveMemoryWarning() {
            super.didReceiveMemoryWarning()
            // Dispose of any resources that can be recreated.
        }
        
        
}
