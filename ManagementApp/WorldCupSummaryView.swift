//
//  WorldCupSummaryView.swift
//  ManagementApp
//
//  Created by Goldmedal on 25/08/20.
//  Copyright © 2020 Goldmedal. All rights reserved.
//

import UIKit
import Charts

@IBDesignable class WorldCupSummaryView: BaseCustomView {
    
    @IBOutlet var summaryPieChart: PieChartView!
    let colorArray = [UIColor.red, UIColor.green]
    var summaryChartValue = [String]()
    
    @IBOutlet weak var lblTotalSale: UILabel!
    @IBOutlet weak var lblAmntEarned: UILabel!
    @IBOutlet weak var lblChancesToWin: UILabel!
    @IBOutlet weak var lblMatchesWon: UILabel!
    @IBOutlet weak var lblMatchesLost: UILabel!
    @IBOutlet weak var lblMatchesBal: UILabel!
    @IBOutlet weak var btnSummaryWisePdf: RoundButton!
    @IBOutlet weak var imageSlider: CPImageSlider!
    
    var strCin = ""
    var strWorldCupSummaryDetailsApi = ""
    
    var MatchSummaryElementMain = [MatchDetailSummaryElement]()
    var MatchSummaryDetailObjMain = [MatchDetailObj]()
    var MatchSummaryDetailObj = [DetailObj]()
    var MatchSummaryImgArr = [ImgArr]()
    var imgSummaryArr = [String]()
    
    var totalSale = "0"
   
    var totalAmountEarned = "0"
    var totalAmountEarnedPer = 0.0
    var totalChancesToWin = "0"
    var totalChancesToWinPer = 0.0
    
    var totalMatchWon = "0"
    var totalMatchLost = "0"
    var totalMatchBal = "0"
    var totalMatches = "0"
    
    var pdfLink = ""
     @IBOutlet weak var noDataView: NoDataView!
 
    
//    func refreshSummaryApi() {
//        // - - - - - Refresh API here - - - -  --
//        self.apiWorldCupSummary()
//         self.setNeedsDisplay()
//    }
    
    override func xibSetup() {
        super.xibSetup()
        
        self.noDataView.hideView(view: self.noDataView)
        
        let initialData =  UserDefaults.standard.value(forKey: "initialData") as? Dictionary ?? [:]
        strWorldCupSummaryDetailsApi = (initialData["baseApi"] as? String ?? "")+""+(initialData["saleWorldCup"] as? String ?? "")
        
      //  strWorldCupSummaryDetailsApi = "https://api.goldmedalindia.in/api/GetSaleWorldCup"
        
        let loginData =  UserDefaults.standard.value(forKey: "loginData") as? Dictionary ?? [:]
        strCin = loginData["userlogid"] as? String ?? ""
        
        
        if (Utility.isConnectedToNetwork()) {
            print("Internet connection available")
            OperationQueue.main.addOperation {
                self.apiWorldCupSummary()
            }
        }
        else{
            print("No internet connection available")
            
            var alert = UIAlertView(title: "No Internet Connection", message: "Make sure your device is connected to the internet.", delegate: nil, cancelButtonTitle: "OK")
            alert.show()
            
             self.noDataView.showView(view: self.noDataView, from: "NET")
            
        }
        
          imageSlider.autoSrcollEnabled = true
     
   
    }
  
    @IBAction func clicked_summaryWisePdf(_ sender: Any) {
        
        guard let url = URL(string: pdfLink) else {
            var alert = UIAlertView(title: "Coming Soon!!", message: "Yet to come", delegate: nil, cancelButtonTitle: "OK")
            alert.show()
            
            return
        }
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    
    
    // - - - - - -  Api to show summary of match details  - - - - - - - -
    func apiWorldCupSummary(){
         self.noDataView.showView(view: self.noDataView, from: "LOADER")
        let json: [String: Any] = ["CIN":strCin,"ClientSecret":"fefef"]
        
        DataManager.shared.makeAPICall(url: strWorldCupSummaryDetailsApi, params: json, method: .POST, success: { (response) in
            let data = response as? Data
            DispatchQueue.main.async {
                do {
                    self.MatchSummaryElementMain = try JSONDecoder().decode([MatchDetailSummaryElement].self, from: data!)
                    self.MatchSummaryDetailObjMain = self.MatchSummaryElementMain[0].data
                    self.MatchSummaryDetailObj = self.MatchSummaryDetailObjMain[0].detail
                    self.MatchSummaryImgArr = self.MatchSummaryDetailObjMain[0].img
                    
                    
                    if self.MatchSummaryImgArr.count > 0 {
                        for i in 0..<self.MatchSummaryImgArr.count {
                            self.imgSummaryArr.append(self.MatchSummaryImgArr[i].imgurl ?? "")
                        }
                        self.imageSlider.images = self.imgSummaryArr
                    }
                    
                    self.totalSale = (self.MatchSummaryDetailObj[0].sale ?? "0")!
                    
                    self.totalAmountEarned = (self.MatchSummaryDetailObj[0].amountEarned ?? "0")!
                    self.totalAmountEarnedPer = Double(self.MatchSummaryDetailObj[0].amountEarnedPer ?? "0")!
                    
                    self.totalChancesToWinPer = Double(self.MatchSummaryDetailObj[0].chancesToWinper ?? "0")!
                    self.totalChancesToWin = (self.MatchSummaryDetailObj[0].chancesToWin ?? "0")!
                    
                    self.totalMatches = (self.MatchSummaryDetailObj[0].totalmatch ?? "0")!
                    self.totalMatchWon = (self.MatchSummaryDetailObj[0].matchWon ?? "0")!
                    self.totalMatchLost = (self.MatchSummaryDetailObj[0].matchLost ?? "0")!
                    self.totalMatchBal = (self.MatchSummaryDetailObj[0].matchBal ?? "0")!
                    
                    self.pdfLink = (self.MatchSummaryDetailObj[0].pdfurl ?? "")!
                  
                    self.lblTotalSale.text = Utility.formatRupee(amount: Double(self.totalSale)!)
                    self.lblAmntEarned.text = Utility.formatRupee(amount: Double(self.totalAmountEarned)!) + " (\(String(self.totalAmountEarnedPer)+"%)")"
                    
                    self.lblChancesToWin.text = Utility.formatRupee(amount: Double(self.totalChancesToWin)!)  + " (\(String(self.totalChancesToWinPer)+"%)")"
                    
                    self.lblMatchesWon.text = String(self.totalMatchWon)
                    self.lblMatchesLost.text = String(self.totalMatchLost)
                    self.lblMatchesBal.text = String(self.totalMatchBal)
                    
                    var totalChancesToWinFig = 0.0
                    var totalAmntEarnedFig = 0.0
                    
                    if(self.totalChancesToWinPer > self.totalAmountEarnedPer)
                    {
                        totalAmntEarnedFig = ((self.totalAmountEarnedPer/self.totalChancesToWinPer)*100.0)
                        totalChancesToWinFig = (100.0 - totalAmntEarnedFig)
                    }else{
                        totalAmntEarnedFig = 100.0
                        totalChancesToWinFig = 0.0
                    }
                    
                    self.summaryChartValue.append(String(totalChancesToWinFig))
                    self.summaryChartValue.append(String(totalAmntEarnedFig))
                    
                    self.setChart(dataPoints: [""] , values: self.summaryChartValue)
                
                     self.noDataView.hideView(view: self.noDataView)
                    
                } catch let errorData {
                    print(errorData.localizedDescription)
                     self.noDataView.showView(view: self.noDataView, from: "NDA")
                }
                
            }
            
        }) { (Error) in
            print(Error?.localizedDescription)
             self.noDataView.showView(view: self.noDataView, from: "ERR")
        }
        
    }
    
    func setChart(dataPoints: [String], values: [String]){
        
        var dataEntries: [PieChartDataEntry] = []
        
        summaryPieChart.drawHoleEnabled = true
        summaryPieChart.holeRadiusPercent = 0.5
        summaryPieChart.chartDescription?.text = ""
        summaryPieChart.rotationEnabled = false
        summaryPieChart.highlightPerTapEnabled = false
        summaryPieChart.legend.enabled = false
        summaryPieChart.animate(yAxisDuration: 1.5, easingOption: ChartEasingOption.easeOutBack)
        
        
        for i in 0..<values.count {
            let dataEntry = PieChartDataEntry(value: Double(values[i])!, label: "")
            dataEntries.append(dataEntry)
        }
        
        print("DATA ENTRIES ------------------------  ",dataEntries)
        
        let chartDataSet = PieChartDataSet(entries: dataEntries, label: "")
        chartDataSet.drawValuesEnabled = false
        chartDataSet.colors = colorArray
        
        let chartData = PieChartData(dataSet: chartDataSet)
        summaryPieChart.data = chartData
        
    }
    
}

