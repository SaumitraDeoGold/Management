//
//  QwikpayDocsController.swift
//  DealorsApp
//
//  Created by Goldmedal on 8/19/19.
//  Copyright © 2019 Goldmedal. All rights reserved.
//



import UIKit
import SDWebImage
import FirebaseAnalytics

class QwikpayDocsController: BaseViewController, UITableViewDelegate , UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noDataView: NoDataView!
    
    var QwikpayElementMain = [DhanbarseQwikPayDocsElement]()
    var QwikpayDataMain = [DhanbarseQwikPayDocsObj]()
    var QwikpayArray = [DhanbarseQwikPayDocsArr]()
    
    var fromIndex = 0
    let batchSize = 10
    var ismore = true
    var strCin = ""
    var QwikpayApi=""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addSlideMenuButton()
        
//        Analytics.setScreenName("QWIKPAY DOCS SCREEN", screenClass: "QwikpayDocsController")
//        SQLiteDB.instance.addAnalyticsData(ScreenName: "QWIKPAY DOCS SCREEN", ScreenId: Int64(GlobalConstants.init().QWIKPAY_DOCS))
        
        let loginData =  UserDefaults.standard.value(forKey: "loginData") as? Dictionary ?? [:]
        strCin = loginData["userlogid"] as? String ?? ""
        
        let initialData =  UserDefaults.standard.value(forKey: "initialData") as? Dictionary ?? [:]
         QwikpayApi = (initialData["baseApi"] as? String ?? "")+""+(initialData["dhanbarseQwikpayPriceList"] as? String ?? "")
      // QwikpayApi = "https://api.goldmedalindia.in/api/GetDhanbarseQwikpayPriceList"
        
        // Do any additional setup after loading the view.
        if (Utility.isConnectedToNetwork()) {
            print("Internet connection available")
            self.apiQwikpay()
            self.noDataView.hideView(view: self.noDataView)
        }
        else{
            print("No internet connection available")
            var alert = UIAlertView(title: "No Internet Connection", message: "Make sure your device is connected to the internet.", delegate: nil, cancelButtonTitle: "OK")
            alert.show()
            self.noDataView.showView(view: self.noDataView, from: "NET")
        }
        
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
    }
    
    
    
    func apiQwikpay(){
        
        let json: [String: Any] = ["CIN":UserDefaults.standard.value(forKey: "userCIN"),"ClientSecret":"clientsecret","Type":2,"index":fromIndex,"Count":batchSize]
        
        DataManager.shared.makeAPICall(url: QwikpayApi, params: json, method: .POST, success: { (response) in
            let data = response as? Data
            print("QwikpayApi - - - ",self.QwikpayApi,"------",json)
            
            DispatchQueue.main.async {
                do {
                    self.QwikpayElementMain = try JSONDecoder().decode([DhanbarseQwikPayDocsElement].self, from: data!)
                    
                    self.QwikpayDataMain = self.QwikpayElementMain[0].data
                    
                    self.QwikpayArray.append(contentsOf:self.QwikpayDataMain[0].pricelistdata)
                    
                    self.ismore = (self.QwikpayDataMain[0].ismore ?? false)!
                    
                } catch let errorData {
                    print(errorData.localizedDescription)
                }
                
                
                if(self.tableView != nil)
                {
                    self.tableView.reloadData()
                }
                
                if(self.QwikpayArray.count>0){
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
    
    
    func clickPdf(sender: UITapGestureRecognizer)
    {
        print("pdf name : \(sender.view!.tag)")
        
        guard let url = URL(string: QwikpayArray[sender.view!.tag].fileURL ?? "") else {
            var alert = UIAlertView(title: "Error", message: "Invalid Pdf", delegate: nil, cancelButtonTitle: "OK")
            alert.show()
            
            return
        }
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return QwikpayArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 140
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      
        let cell = tableView.dequeueReusableCell(withIdentifier: "DocumentRowCell", for: indexPath) as! DocumentRowCell
        
        cell.lblFromDate.text = QwikpayArray[indexPath.row].fromDate ?? "-"
        cell.lblDocumentName.text = QwikpayArray[indexPath.row].policyName?.capitalized ?? "-"
        cell.lblToDate.text = QwikpayArray[indexPath.row].toDate ?? "-"
        
        if QwikpayArray[indexPath.row].imgurl != ""
        {
            cell.imvDocument.sd_setImage(with: URL(string: QwikpayArray[indexPath.row].imgurl ?? ""), placeholderImage: UIImage(named: "no_image_icon.png"))
        }else{
             cell.imvDocument.image = UIImage(named: "no_image_icon.png")
        }
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(DocumentsViewController.clickPdf))
        cell.imvDocument.addGestureRecognizer(tap)
        cell.imvDocument.tag = indexPath.row
        cell.imvDocument.isUserInteractionEnabled = true
        
        print(indexPath.row," --------------------------------------",QwikpayArray.count)
        
        if indexPath.row == QwikpayArray.count - 1 {
            
            if self.ismore {
                fromIndex = fromIndex + 10// last cell
                apiQwikpay()
            }else{
                print("No More data")
            }
        }
        
        return cell
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
