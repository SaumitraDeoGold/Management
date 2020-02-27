//
//  CatPurchase.swift
//  ManagementApp
//
//  Created by Goldmedal on 25/01/20.
//  Copyright © 2020 Goldmedal. All rights reserved.
//

import Foundation
import UIKit
import Charts

//public typealias NSUIColor = UIColor

@IBDesignable class CatPurchase: BaseCustomView{
    @IBOutlet weak var lblCatName: UILabel!
    @IBOutlet weak var lblTotalCatSales: UILabel!
    @IBOutlet weak var tblCatSales: IntrinsicTableView!
    @IBOutlet var catPieChart: PieChartView!
    @IBOutlet var lineLabels: [UILabel]!
    @IBOutlet var tabButtons: [UIButton]!
    @IBOutlet weak var noDataView: UIView!
    @IBOutlet weak var loader: UIActivityIndicatorView!
    @IBOutlet weak var lblNoData: UILabel!
    @IBOutlet weak var imvNoData: UIImageView!
    
    let tabNames = [ "Wiring Devices", "Lights", "Wire & Cables",  "Pipes & Fitting","Mcb & Dbs"]
    let cellIdentifier = "\(CatSalesCell.self)"
//    let colorArray = [UIColor.red, UIColor.green, UIColor.blue, UIColor.orange, UIColor.brown, UIColor.cyan, UIColor.purple, UIColor.yellow, UIColor.magenta,UIColor.darkGray,UIColor.red, UIColor.green, UIColor.blue, UIColor.orange, UIColor.brown, UIColor.cyan, UIColor.purple, UIColor.yellow, UIColor.magenta,UIColor.darkGray]
    
    
    var colorArray = [UIColor]()
    
    var catWiseValue = [String]()
    
    var SalesCategoryMain = [SalesCategoryElement]()
    var SalesCategoryDataObj = [SalesCategoryData]()
    
    var SalesDivisionWiseData = [DivisionWiseSaleData]()
    var SalesDivisionWiseTotal = [DivisionWiseSaleTotal]()
    
    var vendorCatwise = [VendorCatwise]()
    var vendorCatwiseObj = [VendorCatwiseObj]()
    var total = 0.0
    
    var colors: [UIColor] = []
    var strCin = ""
    var strTotalAmnt = "-"
    var catSalesViewApi = ""
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let (fromdate, todate) = Utility.yearDate()
    
    override func xibSetup() {
        super.xibSetup()
        
        self.tblCatSales.delegate = self;
        self.tblCatSales.dataSource = self;
        
        hideView(view: self.noDataView)
        
        let loginData =  UserDefaults.standard.value(forKey: "loginData") as? Dictionary ?? [:]
        strCin = loginData["userlogid"] as? String ?? ""
        
        //let initialData =  UserDefaults.standard.value(forKey: "initialData") as? Dictionary ?? [:]
        catSalesViewApi = "https://test2.goldmedalindia.in/api/getcatwisepurchaseamt"
            //(initialData["baseApi"] as? String ?? "")+""+(initialData["divisionWiseYSA"] as? String ?? "")
        apiSalesCategoryWise()
        // Do any additional setup after loading the view.
        tblCatSales.register(UINib(nibName: cellIdentifier, bundle: nil), forCellReuseIdentifier: cellIdentifier)
        //tabAction(sender: tabButtons[0])
    }
    
    
//    @IBAction func tabAction(sender: UIButton) {
//        for (index, button) in tabButtons.enumerated() {
//            let labelLine = lineLabels[index]
//            labelLine.backgroundColor = (button == sender) ? UIColor.red : UIColor.clear
//        }
//
//        if (Utility.isConnectedToNetwork()) {
//            switch sender.tag {
//            case 0:
//                apiSalesCategoryWise(id: "1")
//                break
//            case 1:
//                apiSalesCategoryWise(id: "2")
//                break
//            case 2:
//                apiSalesCategoryWise(id: "4")
//                break
//            case 3:
//                apiSalesCategoryWise(id: "6")
//                break
//            case 4:
//                apiSalesCategoryWise(id: "7")
//                break
//            default:
//                break
//            }
//        } else {
//            showView(view: self.noDataView, from: "NET")
//            self.tblCatSales.showNoDataPie = true
//        }
//
//        lblCatName.text = tabNames[sender.tag]
//
//    }
    func random() -> CGFloat { return CGFloat(arc4random()) / CGFloat(UInt32.max) }
    
    func randomizer() -> UIColor { return UIColor(red: random(), green: random(), blue: random(), alpha: 1.0) }
    
    
    func apiSalesCategoryWise(){
        
        showView(view: self.noDataView, from: "LOADER")
        self.tblCatSales.showNoDataPie = true
        
        let json: [String: Any] = ["Cin":"sa@sa.com","Cat":"Management","fromdate":fromdate,"todate":todate,"ClientSecret":"ClientSecret","VendorId":appDelegate.sendCin]
        print("Params \(json) and APINAME \(catSalesViewApi)")
        self.catWiseValue.removeAll()
        self.SalesDivisionWiseData.removeAll()
        self.SalesDivisionWiseTotal.removeAll()
        
        DataManager.shared.makeAPICall(url: catSalesViewApi, params: json, method: .POST, success: { (response) in
            let data = response as? Data
            
            DispatchQueue.main.async {
                do {
                    self.vendorCatwise = try JSONDecoder().decode([VendorCatwise].self, from: data!)
                    print("API DATA \(self.vendorCatwise)")
                    self.vendorCatwiseObj = self.vendorCatwise[0].data
                    
                    //self.SalesDivisionWiseData = self.SalesCategoryDataObj[0].divisionWiseSale
                    
                    self.total = self.vendorCatwiseObj.reduce(0, { $0 + Double($1.amount!) })
                    
                    let result = (self.vendorCatwise[0].result ?? false)!
                    
                    if result
                    {
                        print(self.catWiseValue)
                        
                        for i in self.vendorCatwiseObj {
                            self.catWiseValue.append(String(i.amount!) )
                            self.colorArray.append(self.randomizer())
                        }
                        
                        //if let totalAmnt = self.SalesDivisionWiseTotal[0].totalSale {
                        self.strTotalAmnt = Utility.formatRupee(amount: Double(self.total))
                        //}
                        
                        self.lblTotalCatSales.text = self.strTotalAmnt
                    }
                    
                } catch let errorData {
                    print(errorData.localizedDescription)
                    self.strTotalAmnt = "-"
                    self.lblTotalCatSales.text = "-"
                }
                
                if(self.tblCatSales != nil)
                {
                    self.tblCatSales.reloadData()
                }
                
                if(self.catWiseValue.count > 0){
                    self.setChart(dataPoints: [""], values: self.catWiseValue)
                    self.hideView(view: self.noDataView)
                    self.tblCatSales.showNoDataPie = false
                }else{
                    self.showView(view: self.noDataView, from: "NDA")
                    self.tblCatSales.showNoDataPie = true
                }
                
            }
            
        }) { (Error) in
            print(Error?.localizedDescription ?? "ERROR")
            self.showView(view: self.noDataView, from: "ERR")
            self.tblCatSales.showNoDataPie = true
        }
        
    }
    
    func setChart(dataPoints: [String], values: [String]){
        
        var dataEntries: [PieChartDataEntry] = []
        
        catPieChart.drawHoleEnabled = true
        catPieChart.holeRadiusPercent = 0.5
        catPieChart.chartDescription?.text = ""
        catPieChart.rotationEnabled = false
        catPieChart.highlightPerTapEnabled = false
        catPieChart.legend.enabled = false
        catPieChart.animate(yAxisDuration: 1.5, easingOption: ChartEasingOption.easeOutBack)
        
        for i in 0..<values.count {
            let dataEntry = PieChartDataEntry(value: Double(values[i])!, label: "")
            dataEntries.append(dataEntry)
        }
        
        print("DATA ENTRIES ------------------------  ",dataEntries)
        
        let chartDataSet = PieChartDataSet(entries: dataEntries, label: "")
        chartDataSet.drawValuesEnabled = false
        chartDataSet.colors = colorArray
        
        let chartData = PieChartData(dataSet: chartDataSet)
        catPieChart.data = chartData
        
    }
    
}

extension CatPurchase : UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 30
    }
}

extension CatPurchase : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (vendorCatwiseObj.count + 1)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! CatSalesCell
        
        
        if indexPath.row == vendorCatwiseObj.count {
            cell.lblCategoryName.text = "Total"
            cell.vwColor.backgroundColor = UIColor.clear
            cell.lblAmount.text = strTotalAmnt
            
            if(vendorCatwiseObj.count>0)
            {
                cell.lblPercentage.text = "100%"
            }else{
                cell.lblPercentage.text = "-"
            }
            
        } else {
            cell.lblCategoryName.text = vendorCatwiseObj[indexPath.row].categoryName?.capitalized ?? "-"
            
            if let sale = vendorCatwiseObj[indexPath.row].amount {
                cell.lblAmount.text = Utility.formatRupee(amount: Double(sale))
            }
            
            if (Double(self.vendorCatwiseObj[indexPath.row].amount!) > 0 && Double(self.total) > 0)
            {
                cell.lblPercentage.text = String(format: "%.2f",(Double(vendorCatwiseObj[indexPath.row].amount!)) / Double(self.total)*100)+"%"
            }else{
                cell.lblPercentage.text = "-"
            }
            cell.vwColor.backgroundColor = colorArray[indexPath.row]
        }
        return cell
    }
    
    
    func showView(view:UIView,from:String){
        view.isHidden = false
        
        if(from.isEqual("NDA")){
            lblNoData.text = "No Data Available"
            imvNoData.image = UIImage(named:"icon_no_data")
            loader.isHidden = true
        }else if(from.isEqual("ERR")){
            lblNoData.text = "Server Error"
            imvNoData.image = UIImage(named:"icon_error")
            loader.isHidden = true
        }else if(from.isEqual("NET")){
            lblNoData.text = "No Internet Connection"
            imvNoData.image = UIImage(named:"icon_no_internet")
            loader.isHidden = true
        }else if(from.isEqual("LOADER")){
            loader.isHidden = false
            imvNoData.image = nil
            lblNoData.text = ""
        }
    }
    
    func hideView(view:UIView){
        view.isHidden = true
        loader.isHidden = true
    }
    
}
