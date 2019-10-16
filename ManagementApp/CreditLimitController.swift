//
//  CreditLimitController.swift
//  DealorsApp
//
//  Created by Goldmedal on 4/2/18.
//  Copyright © 2018 Goldmedal. All rights reserved.
//

import UIKit
import Charts

class CreditLimitController: UIViewController {

    @IBOutlet weak var pieChart: PieChartView!
    @IBOutlet weak var imvBack: UIImageView!
    
    var days : [String]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        days = ["Mon","Tue","Wed","Thurs","Fri","Sat","Sun"]
        
        let tasks = [1.0,1.0,1.5,2.0,3.0,2.5,1.5]
        
        setChart(dataPoints: days , values: tasks)
        
        let tabBack = UITapGestureRecognizer(target: self, action: #selector(CreditLimitController.tapFunction))
        imvBack.addGestureRecognizer(tabBack)
    }
    
    @objc func tapFunction(sender:UITapGestureRecognizer) {
        print("back")
        self.dismiss(animated: true, completion: nil)
    }
    
    func setChart(dataPoints: [String], values: [Double]){
        
        var dataEntries: [PieChartDataEntry] = []
        
        for i in 0..<dataPoints.count{
            let dataEntry = PieChartDataEntry(value: values[i], label: dataPoints[i])
            dataEntries.append(dataEntry)
        }
        
        let chartDataSet = PieChartDataSet(values: dataEntries, label: "")
        chartDataSet.colors = ChartColorTemplates.material()
        chartDataSet.sliceSpace = 2
        chartDataSet.selectionShift = 5
        
        let chartData = PieChartData(dataSet: chartDataSet)
        
        pieChart.data = chartData
     
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */

}
