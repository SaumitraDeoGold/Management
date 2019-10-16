//
//  StarRewardsViewController.swift
//  DealorsApp
//
//  Created by Goldmedal on 8/10/18.
//  Copyright © 2018 Goldmedal. All rights reserved.
//

import UIKit
import Charts
import FirebaseAnalytics

class StarRewardsViewController: BaseViewController {
    
    @IBOutlet weak var lblFinancialYear: UILabel!
    @IBOutlet weak var lblSalesWiringPys: UILabel!
    @IBOutlet weak var lblSalesWiringCys: UILabel!
    @IBOutlet weak var lblSalesWiringTarget: UILabel!
    @IBOutlet weak var lblSalesWiringShortFall: UILabel!
    @IBOutlet weak var lblSalesLightPys: UILabel!
    @IBOutlet weak var lblSalesLightCys: UILabel!
    @IBOutlet weak var lblSalesLightTarget: UILabel!
    @IBOutlet weak var lblSalesLightShortFall: UILabel!
    @IBOutlet weak var lblRewardWiringBonus: UILabel!
    @IBOutlet weak var lblRewardWiringAddBonus: UILabel!
    @IBOutlet weak var lblRewardLightBonus: UILabel!
    @IBOutlet weak var lblRewardLightAddBonus: UILabel!
    @IBOutlet weak var lblRewardTotalBonus: UILabel!
    @IBOutlet weak var lblRewardTotalAddBonus: UILabel!
    @IBOutlet weak var lblRewardTotalAmount: UILabel!
    @IBOutlet weak var lblPys: UILabel!
    @IBOutlet weak var lblCys: UILabel!
    @IBOutlet weak var divisionWiseBarChart: BarChartView!
    @IBOutlet weak var btnViewInfo: UIButton!
    @IBOutlet weak var btnFinancialYear: RoundButton!
    @IBOutlet weak var noDataView: NoDataView!
    
    var StarRewardMain = [StarRewardElement]()
    var StarRewardDataMain = [StarRewardObj]()
    var StarRewardUrl = [StarRewardurl]()
    var StarRewardDetail = [SummaryDetail]()
    
    var divisionName = [String]()
    var divisionValuePre = [Float]()
    var divisionValueCurr = [Float]()
    var splitFinYear : [Substring] = []
    
    var strCin = ""
    var strInfoUrl = ""
    var finYear = ""
    
    var WiringPreSale = 0.0,WiringCurrSale = 0.0,PipesPreSale = 0.0,PipesCurrSale: Double = 0.0
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var starRewardsApi = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //addSlideMenuButton()
        
        finYear = Utility.currFinancialYear()
        btnFinancialYear.setTitle(finYear, for: .normal)
        
        lblCys.text = "CYS(\(finYear))"
        splitFinYear = finYear.split(separator: "-")
        lblPys.text = "PYS(\(String(Int(Int(splitFinYear[0] ?? "2016")! - 1)) + "-" + String(Int(Int(splitFinYear[1] ?? "2017")!  - 1)))"
        
        let loginData =  UserDefaults.standard.value(forKey: "loginData") as? Dictionary ?? [:]
        strCin = loginData["userlogid"] as? String ?? ""
        
        let initialData =  UserDefaults.standard.value(forKey: "initialData") as? Dictionary ?? [:]
        starRewardsApi = (initialData["baseApi"] as? String ?? "")+""+(initialData["salesSummary"] as? String ?? "")
        
        // Do any additional setup after loading the view.
        if (Utility.isConnectedToNetwork()) {
            print("Internet connection available")
            apiStarRewards()
        }
        else{
            var alert = UIAlertView(title: "No Internet Connection", message: "Make sure your device is connected to the internet.", delegate: nil, cancelButtonTitle: "OK")
            alert.show()
        }
        
        Analytics.setScreenName("STAR REWARDS SCREEN", screenClass: "StarRewardsViewController")
        //SQLiteDB.instance.addAnalyticsData(ScreenName: "STAR REWARDS SCREEN", ScreenId: Int64(GlobalConstants.init().STAR_REWARDS))
    }
    
    
    @IBAction func yearly_clicked(_ sender: UIButton) {
        let sb = UIStoryboard(name: "CustomYearPicker", bundle: nil)
        let popup = sb.instantiateInitialViewController()! as! CustomYearPickerController
        popup.showPicker = 3
        popup.delegate = self
        self.present(popup, animated: true)
    }
    
    func updatePositionValue(value: String, position: Int, from: String) {
        btnFinancialYear.setTitle(value, for: .normal)
        finYear = value
        apiStarRewards()
    }
    
    
    
    func apiStarRewards(){
        
        divisionName.removeAll()
        self.divisionValuePre.removeAll()
        self.divisionValueCurr.removeAll()
        
        lblCys.text = "CYS(\(finYear))"
        splitFinYear = finYear.split(separator: "-")
        lblPys.text = "PYS(\(String(Int(Int(splitFinYear[0] ?? "2016")! - 1)) + "-" + String(Int(Int(splitFinYear[1] ?? "2017")!  - 1)))"
        
        let json: [String: Any] = ["CIN":appDelegate.sendCin,"ClientSecret":"201020","FinYear":finYear]
        
        print("STAR - - - ",json)
        
        DataManager.shared.makeAPICall(url: starRewardsApi, params: json, method: .POST, success: { (response) in
            let data = response as? Data
            
            do {
                self.StarRewardMain = try JSONDecoder().decode([StarRewardElement].self, from: data!)
                self.StarRewardDataMain = self.StarRewardMain[0].data
                self.StarRewardDetail = self.StarRewardDataMain[0].summaryDetails
                self.StarRewardUrl = self.StarRewardDataMain[0].starRewardurl
                self.strInfoUrl = self.StarRewardUrl[0].url ?? ""
                
                OperationQueue.main.addOperation {
                    self.WiringPreSale = Double(self.StarRewardDetail[0].lstyrsales ?? "0.0")!
                    self.WiringCurrSale = Double(self.StarRewardDetail[0].curryrsales ?? "0.0")!
                    
                    self.PipesPreSale = Double(self.StarRewardDetail[1].lstyrsales ?? "0.0")!
                    self.PipesCurrSale = Double(self.StarRewardDetail[1].curryrsales ?? "0.0")!
                    
                    self.divisionName.append("WIRING DEVICES")
                    self.divisionName.append("WIRES,LIGHTS & PIPES")
                    
                    if(Int(self.StarRewardDetail[0].lstyrsales ?? "0")! > 0)
                    {
                        self.divisionValuePre.append(Float(Int(self.StarRewardDetail[0].lstyrsales!)!/100000))
                    }else{
                        self.divisionValuePre.append(0.0)
                    }
                    
                    if(Int(self.StarRewardDetail[0].curryrsales ?? "0")! > 0)
                    {
                        self.divisionValueCurr.append(Float(Int(self.StarRewardDetail[0].curryrsales!)!/100000))
                    }else{
                        self.divisionValueCurr.append(0.0)
                    }
                    
                    if(Int(self.StarRewardDetail[1].lstyrsales ?? "0")! > 0)
                    {
                        self.divisionValuePre.append(Float(Int(self.StarRewardDetail[1].lstyrsales!)!/100000))
                    }else{
                        self.divisionValuePre.append(0.0)
                    }
                    
                    if(Int(self.StarRewardDetail[1].curryrsales ?? "0")! > 0)
                    {
                        self.divisionValueCurr.append(Float(Int(self.StarRewardDetail[1].curryrsales!)!/100000))
                    }else{
                        self.divisionValueCurr.append(0.0)
                    }
                    
                    self.salesSummary()
                    self.gainSummary()
                    self.divisionWisePerformance()
                }
                
            } catch let errorData {
                print(errorData.localizedDescription)
            }
        }) { (Error) in
            ViewControllerUtils.sharedInstance.removeLoader()
            print(Error?.localizedDescription)
        }
        
    }
    
    @IBAction func clicked_view_info(_ sender: Any) {
        guard let url = URL(string: strInfoUrl) else {
            
            var alert = UIAlertView(title: "Error", message: "Invalid Pdf", delegate: nil, cancelButtonTitle: "OK")
            alert.show()
            
            return
        }
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    @IBAction func back_Button(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    func salesSummary() {
        
        //For Wiring devices sales summary
        lblSalesWiringPys.text = Utility.formatRupee(amount: Double(WiringPreSale))
        lblSalesWiringCys.text = Utility.formatRupee(amount: Double(WiringCurrSale))
        
        if (WiringPreSale >= 2500000) {
            var wiringShortFall = 0.0
            wiringShortFall = WiringCurrSale - (WiringPreSale + 1)
            
            lblSalesWiringTarget.text = Utility.formatRupee(amount: Double(WiringPreSale + 1))
            lblSalesWiringShortFall.text = Utility.formatRupee(amount: Double(wiringShortFall))
            
            if (wiringShortFall >= 0) {
                if #available(iOS 11.0, *) {
                    lblSalesWiringShortFall.textColor = UIColor(named: "ColorGreen")
                } else {
                    lblSalesWiringShortFall.textColor = UIColor.green
                }
            } else {
                if #available(iOS 11.0, *) {
                    lblSalesWiringShortFall.textColor = UIColor(named: "ColorRed")
                } else {
                    lblSalesWiringShortFall.textColor = UIColor.red
                }
            }
        } else {
            lblSalesWiringTarget.text = "-"
            lblSalesWiringShortFall.text = "-"
        }
        
        //For wires,lights & pipes sales summary
        lblSalesLightPys.text = Utility.formatRupee(amount: Double(PipesPreSale))
        lblSalesLightCys.text = Utility.formatRupee(amount: Double(PipesCurrSale))
        
        if (PipesPreSale >= 2500000) {
            var pipesShortFall = 0.0;
            pipesShortFall = PipesCurrSale - (PipesPreSale + 1);
            
            lblSalesLightTarget.text = Utility.formatRupee(amount: Double(PipesPreSale + 1))
            lblSalesLightShortFall.text = Utility.formatRupee(amount: Double(pipesShortFall))
            
            if (pipesShortFall >= 0) {
                if #available(iOS 11.0, *) {
                    lblSalesLightShortFall.textColor = UIColor(named: "ColorGreen")
                } else {
                    lblSalesLightShortFall.textColor = UIColor.green
                }
            } else {
                if #available(iOS 11.0, *) {
                    lblSalesLightShortFall.textColor = UIColor(named: "ColorRed")
                } else {
                    lblSalesLightShortFall.textColor = UIColor.red
                }
            }
        } else {
            lblSalesLightTarget.text = "-"
            lblSalesLightShortFall.text = "-"
        }
        
    }
    
    func gainSummary() {
        var addBonusWiring,addBonusPipes,BonusWiring,BonusPipes: Bool
        
        // if pre year sale is greater than 25 lacs and target is achieved then apply bonus and additional bonus
        if (WiringPreSale >= 2500000 && (WiringCurrSale - (WiringPreSale + 1)) / 50 > 0) {
            
            // Wiring Devices bonus
            lblRewardWiringBonus.text = Utility.formatRupee(amount: Double(WiringPreSale / 100))
            BonusWiring = true;
            
            // Wiring Devices additional bonus
            lblRewardWiringAddBonus.text = Utility.formatRupee(amount: Double((WiringCurrSale - (WiringPreSale + 1)) / 50))
            addBonusWiring = true;
            
        } else {
            
            // Wiring Devices bonus
            lblRewardWiringBonus.text = "-"
            BonusWiring = false;
            
            // Wiring Devices additional bonus
            lblRewardWiringAddBonus.text = "-"
            addBonusWiring = false;
        }
        
        
        if (PipesPreSale >= 2500000 && (PipesCurrSale - (PipesPreSale + 1)) / 100 > 0) {
            
            // Wires, lights & pipes bonus
            lblRewardLightBonus.text = Utility.formatRupee(amount: Double(PipesPreSale / 200))
            BonusPipes = true;
            
            // Wires, lights & pipes additional bonus
            lblRewardLightAddBonus.text = Utility.formatRupee(amount: Double((PipesCurrSale - (PipesPreSale + 1)) / 100))
            addBonusPipes = true;
        } else {
            // Wires, lights & pipes bonus
            lblRewardLightBonus.text = "-"
            BonusPipes = false;
            
            // Wires, lights & pipes additional bonus
            lblRewardLightAddBonus.text = "-"
            addBonusPipes = false;
        }
        
        //Total Additional Bonus
        var TotalGain = 0;
        if (addBonusPipes && addBonusWiring) {
            lblRewardTotalAddBonus.text = Utility.formatRupee(amount: Double((WiringCurrSale - (WiringPreSale + 1)) / 50 + (PipesCurrSale - (PipesPreSale + 1)) / 100))
            TotalGain = Int((WiringCurrSale - (WiringPreSale + 1)) / 50 + (PipesCurrSale - (PipesPreSale + 1)) / 100);
            
        } else if (addBonusPipes) {
            lblRewardTotalAddBonus.text = Utility.formatRupee(amount: Double((PipesCurrSale - (PipesPreSale + 1)) / 100))
            TotalGain = Int((PipesCurrSale - (PipesPreSale + 1)) / 100);
            
        } else if (addBonusWiring) {
            lblRewardTotalAddBonus.text = Utility.formatRupee(amount: Double((WiringCurrSale - (WiringPreSale + 1)) / 50))
            TotalGain = Int((WiringCurrSale - (WiringPreSale + 1)) / 50);
            
        } else {
            lblRewardTotalAddBonus.text = "-"
        }
        
        //Total bonus
        if (BonusWiring && BonusPipes) {
            lblRewardTotalBonus.text = Utility.formatRupee(amount: Double((WiringPreSale / 100) + (PipesPreSale / 200)))
            TotalGain += Int((WiringPreSale / 100) + (PipesPreSale / 200));
            
        } else if (BonusPipes) {
            lblRewardTotalBonus.text = Utility.formatRupee(amount: Double(PipesPreSale / 200))
            TotalGain += Int(PipesPreSale / 200);
            
        } else if (BonusWiring) {
            lblRewardTotalBonus.text = Utility.formatRupee(amount: Double(WiringPreSale / 100))
            TotalGain += Int(WiringPreSale / 100);
            
        } else {
            lblRewardTotalBonus.text = "-"
        }
        
        if (TotalGain != 0) {
            lblRewardTotalAmount.text = Utility.formatRupee(amount: Double(TotalGain))
        } else {
            lblRewardTotalAmount.text = "-"
        }
    }
    
    
    func divisionWisePerformance() {
        
        divisionWiseBarChart.noDataText = ""
        divisionWiseBarChart.chartDescription?.text = ""
        
        //legend
        let legend = divisionWiseBarChart.legend
        legend.enabled = true
        legend.horizontalAlignment = .left
        legend.verticalAlignment = .bottom
        legend.orientation = .horizontal
        legend.drawInside = false
        legend.yEntrySpace = 5.0;
        legend.xEntrySpace = 10.0
        
        
        let xaxis = divisionWiseBarChart.xAxis
        xaxis.drawGridLinesEnabled = false
        xaxis.labelPosition = .bottom
        xaxis.centerAxisLabelsEnabled = true
        xaxis.valueFormatter = IndexAxisValueFormatter(values: divisionName)
        xaxis.granularity = 1
        
        let format = NumberFormatter()
        format.numberStyle = .decimal
        
        let yaxis = divisionWiseBarChart.leftAxis
        yaxis.spaceTop = 0.35
        yaxis.axisMinimum = 0
        yaxis.drawGridLinesEnabled = true
        
        var dataEntries: [BarChartDataEntry] = []
        var dataEntries1: [BarChartDataEntry] = []
        
        for i in 0..<divisionName.count {
            let dataEntryPre = BarChartDataEntry(x: Double(i) , y: Double(divisionValuePre[i]))
            dataEntries.append(dataEntryPre)
            
            let dataEntryCurr = BarChartDataEntry(x: Double(i) , y: Double(divisionValueCurr[i]))
            dataEntries1.append(dataEntryCurr)
        }
        
        let chartDataSet = BarChartDataSet(entries: dataEntries, label: "Previous Year Sales")
        let chartDataSet1 = BarChartDataSet(entries: dataEntries1, label: "Current Year Sales")
        
        let dataSets: [BarChartDataSet] = [chartDataSet,chartDataSet1]
        chartDataSet.colors = [UIColor.red]
        chartDataSet1.colors = [UIColor.blue]
        
        let chartData = BarChartData(dataSets: dataSets)
        
        let groupSpace = 0.4
        let barSpace = 0.0
        let barWidth = 0.3
        
        let groupCount = divisionName.count
        
        chartData.barWidth = barWidth;
        divisionWiseBarChart.xAxis.axisMinimum = 0
        
        let gg = chartData.groupWidth(groupSpace: groupSpace, barSpace: barSpace)
        divisionWiseBarChart.xAxis.axisMaximum = 0 + gg * Double(groupCount)
        
        chartData.groupBars(fromX: 0, groupSpace: groupSpace, barSpace: barSpace)
        divisionWiseBarChart.notifyDataSetChanged()
        
        divisionWiseBarChart.rightAxis.enabled = false
        divisionWiseBarChart.data = chartData
        divisionWiseBarChart.highlightPerTapEnabled = false
        divisionWiseBarChart.pinchZoomEnabled = false
        divisionWiseBarChart.doubleTapToZoomEnabled = false
        
        //chart animation
        divisionWiseBarChart.animate(xAxisDuration: 2.0, yAxisDuration: 2.0)
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
