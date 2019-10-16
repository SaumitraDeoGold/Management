//
//  OutStandingController.swift
//  DealorsApp
//
//  Created by Goldmedal on 4/2/18.
//  Copyright © 2018 Goldmedal. All rights reserved.
//

import UIKit
import Charts
import AMPopTip
import FirebaseAnalytics

class OutStandingController: BaseViewController , ChartViewDelegate {

    @IBOutlet weak var pieChart: PieChartView!
    @IBOutlet weak var vwOutstandingAmount: UIView!
    @IBOutlet weak var lblOutstandingAmnt: UILabel!
    @IBOutlet weak var lblDue: UILabel!
    @IBOutlet weak var lblOverDue: UILabel!
    @IBOutlet weak var imvInfo: UIImageView!
    @IBOutlet weak var btnDetail: UIButton!
     @IBOutlet weak var noDataView: NoDataView!
    
    var colorArray = [NSUIColor]()
    var outstandingValue = [String]()
    
    var outstandingMain = [OutstandingElement]()
    var outstandingData = [Outstanding]()
    
    var outstandingName = ["DUE","OVERDUE"]
    
    var txtToolTip = "Due amount is below 60 days & Overdue amount is above 60 days"
    let popTip = PopTip()
    
    var strCin = ""
    var outstandingAmnt = ""
    var outstandingApi=""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.pieChart.delegate = self
        
        if #available(iOS 11.0, *) {
            colorArray = [NSUIColor.init(named: "ColorGreen")!, NSUIColor.init(named: "ColorRed")!]
        } else {
           colorArray = [NSUIColor.green, NSUIColor.red]
        }
        
        // Do any additional setup after loading the view.
         addSlideMenuButton()
        
        self.noDataView.hideView(view: self.noDataView)
        
        let loginData =  UserDefaults.standard.value(forKey: "loginData") as? Dictionary ?? [:]
        strCin = loginData["userlogid"] as? String ?? ""
        
        let initialData =  UserDefaults.standard.value(forKey: "initialData") as? Dictionary ?? [:]
        outstandingApi = (initialData["baseApi"] as? String ?? "")+""+(initialData["outstanding"] as? String ?? "")
        
        let tapInfo = UITapGestureRecognizer(target: self, action: #selector(self.tapFunction))
        imvInfo.addGestureRecognizer(tapInfo)
        imvInfo.isUserInteractionEnabled = true
   
        
        if (Utility.isConnectedToNetwork()) {
            print("Internet connection available")
            self.apiOutStanding()
             self.noDataView.hideView(view: self.noDataView)
        }
        else{
            print("No internet connection available")
            
            var alert = UIAlertView(title: "No Internet Connection", message: "Make sure your device is connected to the internet.", delegate: nil, cancelButtonTitle: "OK")
            alert.show()
             self.noDataView.showView(view: self.noDataView, from: "NET")
        }
        
        Analytics.setScreenName("OUTSTANDING SCREEN", screenClass: "OutStandingController")
    }
    
    
    @objc func tapFunction(sender:UITapGestureRecognizer) {
        
        popTip.bubbleColor = UIColor.black
        popTip.show(text: txtToolTip, direction: .none, maxWidth: 300, in: view, from: vwOutstandingAmount.frame)
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.popTip.hide()
        }
    }
    
    
    @IBAction func onClick(_ sender: UIButton) {
//        let vcOutstandingReport  = self.storyboard?.instantiateViewController(withIdentifier: "OutstandingReport") as! OutstandingReportController
//        self.present(vcOutstandingReport, animated: true, completion: nil)
    }
    
    func apiOutStanding(){
        ViewControllerUtils.sharedInstance.showLoader()
        
        let json: [String: Any] = ["CIN":strCin,"ClientSecret":"201020","Division":"0"]
        
        DataManager.shared.makeAPICall(url: outstandingApi, params: json, method: .POST, success: { (response) in
            let data = response as? Data
            
            do {
                self.outstandingMain = try JSONDecoder().decode([OutstandingElement].self, from: data!)
                
                 self.outstandingData = self.outstandingMain[0].data
                
                   let result = (self.outstandingMain[0].result ?? false)!
                
                      if result
                      {
                      
                        self.outstandingValue.append(self.outstandingData[0].due ?? "0")
                        self.outstandingValue.append(self.outstandingData[0].overDue ?? "0")
                        
                        print(self.outstandingName,"--------------------",self.outstandingValue)
                        
                          OperationQueue.main.addOperation {
                           self.setChart(dataPoints: self.outstandingName , values: self.outstandingValue)
                            if(self.outstandingData[0].outstandings != "")
                            {
                                if var OutstandingAmnt = self.outstandingData[0].outstandings as? String {
                                     self.lblOutstandingAmnt.text = "Outstanding Amount : "+Utility.formatRupee(amount: Double(OutstandingAmnt)!)+" Lacs"
                                }
                               
                            }
                            self.lblDue.text = self.outstandingData[0].due
                            self.lblOverDue.text = self.outstandingData[0].overDue
                          }
                 }
                ViewControllerUtils.sharedInstance.removeLoader()
                
                if(self.outstandingValue.count>0){
                    self.noDataView.hideView(view: self.noDataView)
                }else{
                    self.noDataView.showView(view: self.noDataView, from: "NDA")
                }
                
            } catch let errorData {
                print(errorData.localizedDescription)
                ViewControllerUtils.sharedInstance.removeLoader()
                self.noDataView.showView(view: self.noDataView, from: "NDA")
            }
        }) { (Error) in
            ViewControllerUtils.sharedInstance.removeLoader()
            print(Error?.localizedDescription)
             self.noDataView.showView(view: self.noDataView, from: "ERR")
        }
        
    }
    
    
    func setChart(dataPoints: [String], values: [String]){
        
        var dataEntries: [PieChartDataEntry] = []
        
        pieChart.drawHoleEnabled = false
        pieChart.chartDescription?.text = ""
        pieChart.rotationEnabled = false
        pieChart.highlightPerTapEnabled = false
 
        
      for i in 0..<dataPoints.count {
       
            let dataEntry = PieChartDataEntry(value: Double(values[i])!, label: dataPoints[i])
            dataEntries.append(dataEntry)
   }
        
        print("DATA ENTRIES ------------------------  ",dataEntries)
        
        let chartDataSet = PieChartDataSet(entries: dataEntries, label: "")
       // chartDataSet.colors = ChartColorTemplates.material()
        chartDataSet.colors = colorArray as! [NSUIColor]
        chartDataSet.sliceSpace = 2
    
        let chartData = PieChartData(dataSet: chartDataSet)
        
        pieChart.data = chartData
        
    }

   
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}




