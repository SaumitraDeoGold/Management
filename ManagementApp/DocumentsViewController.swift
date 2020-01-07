//
//  DocumentsViewController.swift
//  DealorsApp
//
//  Created by Goldmedal on 8/13/18.
//  Copyright © 2018 Goldmedal. All rights reserved.
//

import UIKit
import SDWebImage
import FirebaseAnalytics


class DocumentsViewController: BaseViewController,UITableViewDelegate,UITableViewDataSource  {

    @IBOutlet weak var menu: UIBarButtonItem!
    @IBOutlet weak var tblViewDocument: UITableView!
    @IBOutlet weak var noDataView: NoDataView!
    
    var DocumentElementMain = [DocumentElement]()
    var DocumentArr = [DocumentObj]()
    
    var strCin = ""
    var fromIndex = 0
    let batchSize = 10
    var ismore = true
    
    var documentsApi=""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addSlideMenuButton()
        
         self.noDataView.hideView(view: self.noDataView)
        
        let loginData =  UserDefaults.standard.value(forKey: "loginData") as? Dictionary ?? [:]
        strCin = loginData["userlogid"] as? String ?? ""
        
        let initialData =  UserDefaults.standard.value(forKey: "initialData") as? Dictionary ?? [:]
        documentsApi = (initialData["baseApi"] as? String ?? "")+""+(initialData["document"] as? String ?? "")
        

        // Do any additional setup after loading the view.
        if (Utility.isConnectedToNetwork()) {
            print("Internet connection available")
             self.apiDocument();
             self.noDataView.hideView(view: self.noDataView)
        }
        else {
            print("No internet connection available")
            var alert = UIAlertView(title: "No Internet Connection", message: "Make sure your device is connected to the internet.", delegate: nil, cancelButtonTitle: "OK")
            alert.show()
            self.noDataView.showView(view: self.noDataView, from: "NET")
        }

       self.tblViewDocument.delegate = self;
       self.tblViewDocument.dataSource = self;
       Analytics.setScreenName("DOCUMENTS SCREEN", screenClass: "DocumentsViewController")

    }
    
    func apiDocument(){
        
        let json: [String: Any] = ["CIN":strCin,"ClientSecret":"ClientSecret","Index":fromIndex,"Count":batchSize]
        
        DataManager.shared.makeAPICall(url: documentsApi, params: json, method: .POST, success: { (response) in
            let data = response as? Data
            
             DispatchQueue.main.async {
            do {
                
                self.DocumentElementMain = try JSONDecoder().decode([DocumentElement].self, from: data!)
                self.DocumentArr.append(contentsOf:self.DocumentElementMain[0].data)
              
            } catch let errorData {
                print(errorData.localizedDescription)
            }
                
                    if(self.tblViewDocument != nil)
                    {
                        self.tblViewDocument.reloadData()
                    }
                
                 if(self.DocumentArr.count>0){
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
        
        guard let url = URL(string: DocumentArr[sender.view!.tag].url ?? "") else {
            
            var alert = UIAlertView(title: "Error", message: "Invalid Pdf", delegate: nil, cancelButtonTitle: "OK")
            alert.show()
            
            return
        }
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return DocumentArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DocumentRowCell", for: indexPath) as! DocumentRowCell
        
                cell.lblFromDate.text = DocumentArr[indexPath.row].fromdt ?? "-"
                cell.lblDocumentName.text = DocumentArr[indexPath.row].schemename?.capitalized ?? "-"
                cell.lblToDate.text = DocumentArr[indexPath.row].todate ?? "-"
        
                if DocumentArr[indexPath.row].appurl != ""
                {
                    cell.imvDocument.sd_setImage(with: URL(string: DocumentArr[indexPath.row].appurl ?? ""), placeholderImage: UIImage(named: "no_image_icon.png"))
                }else{
                    cell.imvDocument.image = UIImage(named: "no_image_icon.png")
        }
        
                let tap = UITapGestureRecognizer(target: self, action: #selector(DocumentsViewController.clickPdf))
                cell.imvDocument.addGestureRecognizer(tap)
                cell.imvDocument.tag = indexPath.row
                cell.imvDocument.isUserInteractionEnabled = true
    
                return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
         return UITableViewAutomaticDimension
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
