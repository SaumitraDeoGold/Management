////
////  DashPendingOrderView.swift
////  DealorsApp
////
////  Created by Goldmedal on 8/8/18.
////  Copyright © 2018 Goldmedal. All rights reserved.
////
//
//import Foundation
//import UIKit
//import Charts
//@IBDesignable class DashPendingOrderView: BaseCustomView {
//
//    @IBOutlet var pendingOrderDivisionPieChart: PieChartView!
//    @IBOutlet var lblTotal: UILabel!
//    @IBOutlet var tblPendingOrder: IntrinsicTableView!
//    var strCin = ""
//    var strType = ""
//    var strTotalAmnt = "-"
//    var strCurrDate = ""
//    let cellIdentifier = "\(DashPendingOrderCell.self)"
//
//    @IBOutlet weak var noDataView: NoDataView!
//
//    let colorArray = [UIColor.red, UIColor.green, UIColor.blue, UIColor.orange, UIColor.brown, UIColor.cyan, UIColor.purple, UIColor.yellow, UIColor.magenta,UIColor.darkGray,UIColor.red, UIColor.green, UIColor.blue, UIColor.orange, UIColor.brown, UIColor.cyan, UIColor.purple, UIColor.yellow, UIColor.magenta,UIColor.darkGray]
//
//    @IBOutlet weak var btnItemWisePdf: RoundButton!
//    @IBOutlet weak var btnItemWisePending: RoundButton!
//    @IBOutlet weak var btnSummaryWisePending: RoundButton!
//    @IBOutlet weak var btnSummaryWisePdf: RoundButton!
//
//    var PendingOrderDivisionMain = [PendingOrderDivisionElement]()
//    var PendingOrderDivisionData = [PendingOrderDivisionObj]()
//
//    var PendingOrderDivisionArr = [Pendingdetail]()
//    var PendingOrderDivisionTotal = [Pendingtotal]()
//
//    var PendingOrderPdfMain = [PendingOrderPDFElement]()
//    var PendingOrderPdfData = [PendingOrderPdfObj]()
//
//    var pendingOrderValue = [String]()
//
//    var pendingOrderApi=""
//    var pendingOrdersPDFApi=""
//
//    override func xibSetup() {
//        super.xibSetup()
//
//        self.noDataView.hideView(view: self.noDataView)
//
//        // Do any additional setup after loading the view.
//        self.tblPendingOrder.delegate = self;
//        self.tblPendingOrder.dataSource = self;
//
//        btnItemWisePdf.imageView?.contentMode = .scaleAspectFit
//        btnSummaryWisePdf.imageView?.contentMode = .scaleAspectFit
//
//        let loginData =  UserDefaults.standard.value(forKey: "loginData") as? Dictionary ?? [:]
//        strCin = loginData["userlogid"] as? String ?? ""
//
//        let initialData =  UserDefaults.standard.value(forKey: "initialData") as? Dictionary ?? [:]
//        pendingOrderApi = (initialData["baseApi"] as? String ?? "")+""+(initialData["pendingOrderDivisionWise"] as? String ?? "")
//        pendingOrdersPDFApi = (initialData["baseApi"] as? String ?? "")+""+(initialData["pendingOrdersPDF"] as? String ?? "")
//
//        self.noDataView.hideView(view: self.noDataView)
//
//        strCurrDate = Utility.currDate()
//
//        tblPendingOrder.register(UINib(nibName: cellIdentifier, bundle: nil), forCellReuseIdentifier: cellIdentifier)
//
//
//        if (Utility.isConnectedToNetwork()) {
//            apiPendingOrderDivisionWise()
//        }
//        else{
//            self.noDataView.showView(view: self.noDataView, from: "NET")
//            self.tblPendingOrder.showNoData = true
//        }
//    }
//
//    func apiPendingOrderDivisionWise(){
//        self.noDataView.showView(view: self.noDataView, from: "LOADER")
//        self.tblPendingOrder.showNoDataPie = true
//
//        let json: [String: Any] = ["CIN":"999999","ClientSecret":"201020"]
//
//        DataManager.shared.makeAPICall(url: pendingOrderApi, params: json, method: .POST, success: { (response) in
//            let data = response as? Data
//
//            DispatchQueue.main.async {
//                do {
//                    self.PendingOrderDivisionMain = try JSONDecoder().decode([PendingOrderDivisionElement].self, from: data!)
//
//                    self.PendingOrderDivisionData = self.PendingOrderDivisionMain[0].data
//
//                    self.PendingOrderDivisionArr = self.PendingOrderDivisionData[0].pendingdetails
//
//                    self.PendingOrderDivisionTotal = self.PendingOrderDivisionData[0].pendingtotal
//
//                    let result = (self.PendingOrderDivisionMain[0].result ?? false)!
//
//                    if result
//                    {
//                        for i in self.PendingOrderDivisionArr {
//                            self.pendingOrderValue.append(i.pending ?? "-")
//                        }
//
//                        print(self.pendingOrderValue)
//
//                        self.setChart(dataPoints: [""], values: self.pendingOrderValue)
//
//                        if var pendingtotal = self.PendingOrderDivisionTotal[0].pendingtotal as? String {
//                            self.strTotalAmnt = Utility.formatRupee(amount: Double(pendingtotal)!)
//                            self.lblTotal.text = self.strTotalAmnt
//                        }
//
//                    }
//
//                } catch let errorData {
//                    print(errorData.localizedDescription)
//                }
//
//                if(self.tblPendingOrder != nil)
//                {
//                    self.tblPendingOrder.reloadData()
//                }
//
//                if(self.PendingOrderDivisionArr.count > 0){
//                    self.noDataView.hideView(view: self.noDataView)
//                    self.tblPendingOrder.showNoDataPie = false
//                }else{
//                    self.noDataView.showView(view: self.noDataView, from: "NDA")
//                    self.tblPendingOrder.showNoDataPie = true
//                }
//            }
//        }) { (Error) in
//            print(Error?.localizedDescription ?? "ERROR")
//            self.noDataView.showView(view: self.noDataView, from: "ERR")
//            self.tblPendingOrder.showNoDataPie = true
//        }
//    }
//
//
//    @IBAction func clicked_item_wise_pdf(_ sender: Any) {
//        apiDownloadPendingOrder(intOrderType: 1)
//    }
//
//    @IBAction func clicked_summary_wise_pdf(_ sender: Any) {
//        apiDownloadPendingOrder(intOrderType: 2)
//    }
//
//
//    @IBAction func clicked_summary_wise_pending(_ sender: Any) {
//        let pendingOrderSummary = parentViewController?.storyboard?.instantiateViewController(withIdentifier: "PendingOrder") as! PendingOrderController
//        pendingOrderSummary.intOrderType = 2
//        pendingOrderSummary.callFrom = 1
//        parentViewController?.navigationController?.pushViewController(pendingOrderSummary, animated: true)
//    }
//
//    @IBAction func clicked_item_wise_pending(_ sender: Any) {
//        let pendingOrderItem = parentViewController?.storyboard?.instantiateViewController(withIdentifier: "PendingOrder") as! PendingOrderController
//        pendingOrderItem.intOrderType = 1
//        pendingOrderItem.callFrom = 1
//        parentViewController?.navigationController?.pushViewController(pendingOrderItem, animated: true)
//    }
//
//
//    func apiDownloadPendingOrder(intOrderType: Int) {
//
//        let json: [String: Any] = ["CIN":"999999","ClientSecret":"ClientSecret","AsonDate":strCurrDate,"Type":intOrderType]
//
//
//        DataManager.shared.makeAPICall(url: pendingOrdersPDFApi, params: json, method: .POST, success: { (response) in
//            let data = response as? Data
//
//            DispatchQueue.main.async {
//                do {
//                    self.PendingOrderPdfMain = try JSONDecoder().decode([PendingOrderPDFElement].self, from: data!)
//                    self.PendingOrderPdfData = self.PendingOrderPdfMain[0].data
//
//                    guard let url = URL(string: self.PendingOrderPdfData[0].url ?? "") else {
//
//                        var alert = UIAlertView(title: "Error", message: "Invalid Pdf", delegate: nil, cancelButtonTitle: "OK")
//                        alert.show()
//
//                        return
//                    }
//                    if UIApplication.shared.canOpenURL(url) {
//                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
//                    }
//
//                } catch let errorData {
//                    print(errorData.localizedDescription)
//                }
//            }
//        }) { (Error) in
//            print(Error?.localizedDescription)
//        }
//    }
//
//
//
//    func setChart(dataPoints: [String], values: [String]){
//
//        var dataEntries: [PieChartDataEntry] = []
//
//        pendingOrderDivisionPieChart.drawHoleEnabled = true
//        pendingOrderDivisionPieChart.chartDescription?.text = ""
//        pendingOrderDivisionPieChart.rotationEnabled = false
//        pendingOrderDivisionPieChart.highlightPerTapEnabled = false
//        pendingOrderDivisionPieChart.legend.enabled = false
//        pendingOrderDivisionPieChart.holeRadiusPercent = 0.5
//
//
//        for i in 0..<values.count {
//            let dataEntry = PieChartDataEntry(value: Double(values[i])!, label: "")
//            dataEntries.append(dataEntry)
//        }
//
//        print("DATA ENTRIES ------------------------  ",dataEntries)
//
//        let chartDataSet = PieChartDataSet(values: dataEntries, label: "")
//        chartDataSet.drawValuesEnabled = false
//        chartDataSet.colors = colorArray
//
//        let chartData = PieChartData(dataSet: chartDataSet)
//        pendingOrderDivisionPieChart.data = chartData
//
//    }
//
//}
//
//
//extension DashPendingOrderView : UITableViewDelegate {
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 30
//    }
//}
//
//extension DashPendingOrderView : UITableViewDataSource {
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return (PendingOrderDivisionArr.count + 1)
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! DashPendingOrderCell
//        if indexPath.row == PendingOrderDivisionArr.count {
//            cell.lblCategory.text = "Total"
//            cell.lblAmount.text = strTotalAmnt
//            if PendingOrderDivisionArr.count > 0{
//                cell.lblPercentage.text = "100%"
//            }else{
//                cell.lblPercentage.text = "-"
//            }
//
//        } else {
//            cell.lblCategory.text = PendingOrderDivisionArr[indexPath.row].divisionnm?.capitalized ?? "-"
//
//            if var pendingAmnt = PendingOrderDivisionArr[indexPath.row].pending as? String {
//                cell.lblAmount.text = Utility.formatRupee(amount: Double(pendingAmnt)!)
//            }
//
//            if (Double(self.PendingOrderDivisionTotal[0].pendingtotal ?? "0.0")! > 0 && Double(self.PendingOrderDivisionTotal[0].pendingtotal ?? "0.0")! > 0)
//            {
//                cell.lblPercentage.text = String(format: "%.2f",Double(PendingOrderDivisionArr[indexPath.row].pending!)!/Double(self.PendingOrderDivisionTotal[0].pendingtotal!)!*100)+"%"
//            }else{
//                cell.lblPercentage.text = "-"
//            }
//            cell.vwColor.backgroundColor = colorArray[indexPath.row]
//        }
//
//        return cell
//
//    }
//
//}
//
//
//
