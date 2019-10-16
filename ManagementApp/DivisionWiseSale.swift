//
//  DivisionWiseSale.swift
//  DealorsApp
//
//  Created by Goldmedal on 3/29/18.
//  Copyright © 2018 Goldmedal. All rights reserved.
//

import UIKit
import Charts
import FirebaseAnalytics

class DivisionWiseSale: BaseViewController,UITableViewDelegate,UITableViewDataSource {

    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    @IBOutlet weak var btnFinancialYear: RoundButton!
    @IBOutlet weak var tblDivisionWise: UITableView!
    @IBOutlet weak var menuDivisionWiseSales: UIBarButtonItem!
    @IBOutlet weak var barChart: BarChartView!
    @IBOutlet weak var lblReportDetail: UILabel!
    @IBOutlet weak var lblTotalSales: UILabel!
    @IBOutlet weak var vwContainer: UIView!
    @IBOutlet weak var imvNoData: UIImageView!
    
    @IBOutlet weak var btnYearly: UIButton!
    @IBOutlet weak var btnMonthly: UIButton!
    @IBOutlet weak var btnQuarterly: UIButton!
    
    var DivisionData = [DivisionWiseSaleElement]()
    var DivisionObj = [DivisionWiseData]()
    var DivisionArray = [DivisionSalesReport]()
    
    var divisionNameArray = [String]()
    var divisionAmntArray = [String]()
    var divisionSalesReportApi=""
    
    @IBOutlet weak var noDataView: NoDataView!
 
    var finYear = "";
    var opType = 3;
    var opValue = 0;
    var currPosition = 0;
    
    var callFrom = 0
    var strCin = ""
    var strTotalAmnt = "-"
    
    @IBAction func monthly_clicked(_ sender: UIButton) {
            let sb = UIStoryboard(name: "CustomYearPicker", bundle: nil)
            let popup = sb.instantiateInitialViewController()! as! CustomYearPickerController
            popup.delegate = self
            popup.showPicker = 1
            self.present(popup, animated: true)
            callFrom = 1
            opType = 1
    }
    
    
    @IBAction func quarterly_clicked(_ sender: UIButton) {
        let sb = UIStoryboard(name: "CustomYearPicker", bundle: nil)
        let popup = sb.instantiateInitialViewController()! as! CustomYearPickerController
        popup.delegate = self
        popup.showPicker = 2
        self.present(popup, animated: true)
        callFrom = 2
        opType = 2
    }
    
    
    @IBAction func yearly_clicked(_ sender: UIButton) {
        let sb = UIStoryboard(name: "CustomYearPicker", bundle: nil)
        let popup = sb.instantiateInitialViewController()! as! CustomYearPickerController
        popup.delegate = self
        popup.showPicker = 3
        self.present(popup, animated: true)
        callFrom = 3
        opType = 3
        opValue = 0
    }
    
    @IBAction func clicked_year(_ sender: UIButton)
    {
        lblReportDetail.text = finYear
        
         opType = 3
         opValue = 0
        
         apiDivisionWiseSales()
        
        btnYearly.titleLabel?.font = UIFont(name:"Roboto-Bold", size: 12.0)
        btnMonthly.titleLabel?.font = UIFont(name:"Roboto-Regular", size: 12.0)
        btnQuarterly.titleLabel?.font = UIFont(name:"Roboto-Regular", size: 12.0)
    }
    
    func updatePositionValue(value: String, position: Int, from: String) {
        if(callFrom == 3){
            btnFinancialYear.setTitle(value, for: .normal)
            finYear = value
             opValue = 0
        }else if(callFrom == 2) {
            currPosition = position + 1
            opValue = currPosition
        }else{
            currPosition = position + 1
            
            if(currPosition < 4){
                currPosition = (position+1) + 9
            }else{
                currPosition = (position+1) - 3
            }
            opValue = currPosition
        }
        
        lblReportDetail.text = value
        apiDivisionWiseSales()
        
        if(opType == 1){
            btnYearly.titleLabel?.font = UIFont(name:"Roboto-Regular", size: 12.0)
            btnMonthly.titleLabel?.font = UIFont(name:"Roboto-Bold", size: 12.0)
            btnQuarterly.titleLabel?.font = UIFont(name:"Roboto-Regular", size: 12.0)
        }else if(opType == 2){
            btnYearly.titleLabel?.font = UIFont(name:"Roboto-Regular", size: 12.0)
            btnMonthly.titleLabel?.font = UIFont(name:"Roboto-Regular", size: 12.0)
            btnQuarterly.titleLabel?.font = UIFont(name:"Roboto-Bold", size: 12.0)
        }else if(opType == 3){
            btnYearly.titleLabel?.font = UIFont(name:"Roboto-Bold", size: 12.0)
            btnMonthly.titleLabel?.font = UIFont(name:"Roboto-Regular", size: 12.0)
            btnQuarterly.titleLabel?.font = UIFont(name:"Roboto-Regular", size: 12.0)
        }
        
    }
 

    override func viewDidLoad() {
        super.viewDidLoad()
        
         noDataView.hideView(view: noDataView)
      
        let date = Date()
        let calendar = Calendar.current
        
        let year = calendar.component(.year, from: date)
        let month = calendar.component(.month, from: date)
  
        if (month >= 4) {
            finYear = String(String(year) + "-" + String(year + 1))
        } else {
            finYear = String(String(year - 1) + "-" + String(year))
        }


        self.tblDivisionWise.delegate = self;
        self.tblDivisionWise.dataSource = self;
        
        barChart.drawBarShadowEnabled = false
        barChart.drawValueAboveBarEnabled = false
        
        barChart.maxVisibleCount = 60
        
         addSlideMenuButton()
        
         Analytics.setScreenName("DIVISION WISE SCREEN", screenClass: "DivisionWiseSale")
        
        let loginData =  UserDefaults.standard.value(forKey: "loginData") as? Dictionary ?? [:]
        strCin = loginData["userlogid"] as? String ?? ""
        
        let initialData =  UserDefaults.standard.value(forKey: "initialData") as? Dictionary ?? [:]
        divisionSalesReportApi = (initialData["baseApi"] as? String ?? "")+""+(initialData["divisionSalesReport"] as? String ?? "")
     
        if (Utility.isConnectedToNetwork()) {
            print("Internet connection available")
            self.apiDivisionWiseSales()
            noDataView.hideView(view: noDataView)
        }
        else {
            print("No internet connection available")
            
            var alert = UIAlertView(title: "No Internet Connection", message: "Make sure your device is connected to the internet.", delegate: nil, cancelButtonTitle: "OK")
            alert.show()
            noDataView.showView(view: noDataView, from: "NET")
        }
        
        
        btnYearly.titleLabel?.font = UIFont(name:"Roboto-Bold", size: 12.0)
        btnMonthly.titleLabel?.font = UIFont(name:"Roboto-Regular", size: 12.0)
        btnQuarterly.titleLabel?.font = UIFont(name:"Roboto-Regular", size: 12.0)
    }
    
    func apiDivisionWiseSales() {
        ViewControllerUtils.sharedInstance.showLoader()
       
       let json: [String: Any] = ["CIN":strCin,"ClientSecret":"test","FinYear":finYear,"ReportType":opType,"ReportValue":opValue]
        
        print("DIVISION WISE --- -- ",json)
        
        self.DivisionArray.removeAll()
        self.divisionNameArray.removeAll()
        self.divisionAmntArray.removeAll()
        
        DataManager.shared.makeAPICall(url: divisionSalesReportApi, params: json, method: .POST, success: { (response) in
            let data = response as? Data
            
            DispatchQueue.main.async {
            do {
                self.DivisionData = try JSONDecoder().decode([DivisionWiseSaleElement].self, from: data!)
            
                 self.DivisionObj = self.DivisionData[0].data
                
                 self.DivisionArray.append(contentsOf: self.DivisionObj[0].divisionSalesReport)
                
                 let result = (self.DivisionData[0].result ?? false)!
                
                
                     if result
                    {
                        
                        for i in self.DivisionArray {
              
                            self.divisionNameArray.append(i.division ?? "-")
                            self.divisionAmntArray.append(String(format: "%.2f",Double(i.amount!)!/100000))
                      
                        }
                        
                        
                    print(self.divisionNameArray,"---------------",self.divisionAmntArray)
                                        //on success of api
                
                        
                       
                        if var TotalAmnt = self.DivisionObj[0].totalAmt as? String {
                            self.strTotalAmnt = Utility.formatRupee(amount: Double(TotalAmnt)!)
                            self.lblTotalSales.text = "Total Sales: "+String(format: "%.2f",Double(TotalAmnt)!/100000)
                        }else{
                            self.lblTotalSales.text = "Total Sales: -"
                        }
                    
                }
                ViewControllerUtils.sharedInstance.removeLoader()
             
            } catch let errorData {
                 self.strTotalAmnt = "-"
                 self.lblTotalSales.text = "Total Sales: -"
                
                ViewControllerUtils.sharedInstance.removeLoader()
                print(errorData.localizedDescription)
                
            }
                if(self.DivisionArray.count > 0){
                    if(self.tblDivisionWise != nil)
                    {
                        self.tblDivisionWise.reloadData()
                        self.heightConstraint.constant = CGFloat(((self.DivisionArray.count+1) * 30) + 10)
                    }
                    self.setChart(dataPoints: self.divisionNameArray , values: self.divisionAmntArray)
                    self.noDataView.hideView(view: self.noDataView)
                }else{
                    self.noDataView.showView(view: self.noDataView,from: "NDA")
                }
            }
        }) { (Error) in
            ViewControllerUtils.sharedInstance.removeLoader()
            print(Error?.localizedDescription)
            self.noDataView.showView(view: self.noDataView,from: "ERR")
        }
    
}
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 30
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return DivisionArray.count+1
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DivisionWiseCell", for: indexPath) as! DivisionWiseCell
       
        if indexPath.row == DivisionArray.count {
            cell.lblDivision.text = "Total"
            cell.lblAmount.text = strTotalAmnt
            if(DivisionArray.count > 0){
                cell.lblPercentage.text = "100%"
            }else{
                cell.lblPercentage.text = "-"
            }
            
        }else{
            cell.lblDivision.text = DivisionArray[indexPath.row].division?.capitalized ?? "-"
            
            if var invoiceAmnt = DivisionArray[indexPath.row].amount as? String {
                 cell.lblAmount.text = Utility.formatRupee(amount: Double(invoiceAmnt)!)
            }
      
        if (Double(DivisionArray[0].amount ?? "0.0")! > 0 && Double(DivisionObj[0].totalAmt ?? "0.0")! > 0)
        {
            cell.lblPercentage.text = String(format: "%.2f",Double(DivisionArray[indexPath.row].amount!)!/Double(DivisionObj[0].totalAmt!)!*100)+"%"
        }else{
            cell.lblPercentage.text = "-"
        }
    }

        return cell
    }
    
    

    func setChart(dataPoints: [String], values: [String]){
        
        barChart.noDataText=""
        barChart.chartDescription?.text = ""
        
        var dataEntries: [BarChartDataEntry] = []
     
        for i in 0..<dataPoints.count{
            let dataEntry = BarChartDataEntry(x: Double(i), y: Double(values[i])!)
            dataEntries.append(dataEntry)
        }
        
        let chartDataSet = BarChartDataSet(entries: dataEntries, label:"")
        chartDataSet.drawValuesEnabled = true
        if #available(iOS 11.0, *) {
            chartDataSet.colors = [UIColor.init(named: "ColorRed")!]
        } else {
            chartDataSet.colors = [UIColor.red]
        }
        
        let chartData = BarChartData()
        chartData.addDataSet(chartDataSet)
        chartData.barWidth = 0.8
        barChart.data = chartData
        
        let format = NumberFormatter()
        format.numberStyle = .decimal
        
        let formatter = DefaultValueFormatter(formatter: format)
        chartData.setValueFormatter(formatter)
        
        barChart.animate(xAxisDuration: 2.0, yAxisDuration: 2.0)
        
        barChart.xAxis.labelPosition = .bottom
        barChart.xAxis.drawGridLinesEnabled = false
        barChart.xAxis.granularityEnabled = true
        barChart.xAxis.centerAxisLabelsEnabled = false
        barChart.xAxis.granularity = 1
        barChart.xAxis.drawLimitLinesBehindDataEnabled = true
        barChart.xAxis.valueFormatter = IndexAxisValueFormatter(values:divisionNameArray)
        
        barChart.drawValueAboveBarEnabled = true
        
        
        let yaxis = barChart.leftAxis
        yaxis.spaceTop = 0.35
        yaxis.axisMinimum = 0
        yaxis.drawGridLinesEnabled = true
        
        barChart.fitBars = true
        barChart.setExtraOffsets(left: 10, top: 5, right: 10, bottom: 5)
        barChart.rightAxis.enabled = false
        barChart.highlightPerTapEnabled = false
        barChart.legend.enabled = false
        barChart.pinchZoomEnabled = false
        barChart.doubleTapToZoomEnabled = false
        barChart.highlightFullBarEnabled = false
       
    }
    
}

extension DivisionWiseSale: IAxisValueFormatter{
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        return divisionNameArray[ Int(value) % divisionNameArray.count]
    }
}
