//
//  TodayPaymentViewController.swift
//  ManagementApp
//
//  Created by Goldmedal on 18/03/19.
//  Copyright © 2019 Goldmedal. All rights reserved.
//

import UIKit
import Charts
class TodayPaymentViewController: UIViewController {

    @IBOutlet weak var barChart: BarChartView!
    override func viewDidLoad() {
        super.viewDidLoad()
        //setChart(dataPoints: self.chartTitleArray , values: self.chartValuesArray)
        // Do any additional setup after loading the view.
    }
    var chartTitleArray = ["Total Sales","Monthly Sales","Quarterly Sales","Yearly Sales"]
    var chartValuesArray = ["4.1","3.2","2.1","1.9"]
    
    
    
//    func setChart(dataPoints: [String], values: [String]){
//
//        barChart.noDataText=""
//        barChart.chartDescription?.text = ""
//
//        var dataEntries: [BarChartDataEntry] = []
//
//        for i in 0..<dataPoints.count{
//            let dataEntry = BarChartDataEntry(x: Double(i), y: Double(values[i])!)
//            dataEntries.append(dataEntry)
//        }
//
//        let chartDataSet = BarChartDataSet(values: dataEntries, label:"")
//        chartDataSet.drawValuesEnabled = true
//        if #available(iOS 11.0, *) {
//            chartDataSet.colors = [UIColor.init(named: "ColorRed")!]
//        } else {
//            chartDataSet.colors = [UIColor.red]
//        }
//
//        let chartData = BarChartData()
//        chartData.addDataSet(chartDataSet)
//        chartData.barWidth = 0.8
//        barChart.data = chartData
//
//        let format = NumberFormatter()
//        format.numberStyle = .decimal
//
//        let formatter = DefaultValueFormatter(formatter: format)
//        chartData.setValueFormatter(formatter)
//
//        barChart.animate(xAxisDuration: 2.0, yAxisDuration: 2.0)
//
//        barChart.xAxis.labelPosition = .bottom
//        barChart.xAxis.drawGridLinesEnabled = false
//        barChart.xAxis.granularityEnabled = true
//        barChart.xAxis.centerAxisLabelsEnabled = false
//        barChart.xAxis.granularity = 1
//        barChart.xAxis.drawLimitLinesBehindDataEnabled = true
//        barChart.xAxis.valueFormatter = IndexAxisValueFormatter(values:chartTitleArray)
//
//        barChart.drawValueAboveBarEnabled = true
//
//
//        let yaxis = barChart.leftAxis
//        yaxis.spaceTop = 0.35
//        yaxis.axisMinimum = 0
//        yaxis.drawGridLinesEnabled = true
//
//        barChart.fitBars = true
//        barChart.setExtraOffsets(left: 10, top: 5, right: 10, bottom: 5)
//        barChart.rightAxis.enabled = false
//        barChart.highlightPerTapEnabled = false
//        barChart.legend.enabled = false
//        barChart.pinchZoomEnabled = false
//        barChart.doubleTapToZoomEnabled = false
//        barChart.highlightFullBarEnabled = false
//
//    }
    
    
}


//extension TodayPaymentViewController: IAxisValueFormatter{
//    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
//        return chartTitleArray[ Int(value) % chartTitleArray.count]
//    }
//}

