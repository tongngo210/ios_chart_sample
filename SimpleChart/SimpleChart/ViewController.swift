//
//  ViewController.swift
//  SimpleChart
//
//  Created by macbook on 09/01/2024.
//

import Charts
import UIKit

class ChartValueData {
    let value: (x: Double, y: Double)
    let label: String
    let hexColorString: String
    
    init(value: (x: Double, y: Double), label: String, hexColorString: String) {
        self.value = value
        self.label = label
        self.hexColorString = hexColorString
    }
}

class ViewController: UIViewController, ChartViewDelegate {

    @IBOutlet private weak var chartView: ScatterChartView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        chartView.backgroundColor = .white
        chartView.delegate = self

        chartView.dragEnabled = true
        chartView.setScaleEnabled(true)
        chartView.pinchZoomEnabled = true
        
        setupUI()
        setupData(listChartValues: [
            ChartValueData(value: (10, 101.3), label: "Amber", hexColorString: "#355E3B")
        ])
    }
    
    func setupUI() {
        setupLegend()
        setupLeftAxis(isShownLine: false, color: .black, maxValue: 108, minValue: 90, labelMaxCount: 10 )
        
        let rightAxis = chartView.rightAxis
        rightAxis.labelFont = .systemFont(ofSize: 10, weight: .light)
        rightAxis.labelTextColor = .black
        rightAxis.valueFormatter = RightAxisFormatter()
        rightAxis.labelCount = 13
        rightAxis.granularity = 1
        rightAxis.axisMinimum = 0
        rightAxis.axisMaximum = 27
        rightAxis.axisLineColor = .clear
        rightAxis.drawGridLinesEnabled = false
        
        addLimitLine(value: 102.2, label: "Moderate Fever(102.2)", color: .red)
        addLimitLine(value: 100.4, label: "Low grade Fever(100.4)", color: .orange)
        addLimitLine(value: 99.5, label: "Mild Fever(99.5)", color: .blue)
        addLimitLine(value: 96, label: "Hypothermia(95)", color: .gray)
        
        let xAxis = chartView.xAxis
        xAxis.yOffset = 16
        xAxis.labelPosition = .bottom
        xAxis.labelTextColor = .black
        xAxis.axisMinimum = 0
        xAxis.axisMaximum = 24
        xAxis.valueFormatter = XAxisNameFormatter(dateString: "01-05")
        xAxis.axisLineColor = .clear
        xAxis.labelFont = .systemFont(ofSize: 10, weight: .light)
    }
    
    func setupLegend() {
        let legend = chartView.legend
        legend.horizontalAlignment = .center
        legend.verticalAlignment = .bottom
        legend.orientation = .vertical
        legend.drawInside = false
        legend.form = .circle
        legend.textColor = .black
        legend.font = .systemFont(ofSize: 12, weight: .light)
        legend.formSize = 12
    }
    
    func setupLeftAxis(isShownLine: Bool, lineColor: UIColor = .clear, color: UIColor,
                       maxValue: Double, minValue: Double, labelMaxCount: Int) {
        let leftAxis = chartView.leftAxis
        leftAxis.labelFont = .systemFont(ofSize: 10, weight: .light)
        leftAxis.labelTextColor = color
        leftAxis.valueFormatter = LeftAxisFormatter()
        leftAxis.labelCount = labelMaxCount
        leftAxis.granularity = 1
        leftAxis.axisMinimum = minValue
        leftAxis.axisMaximum = maxValue
        leftAxis.axisLineColor = lineColor
        leftAxis.drawGridLinesEnabled = isShownLine
    }
    
    func addLimitLine(value: Double, label: String, color: UIColor) {
        let limitLine = ChartLimitLine(limit: value, label: label)
        limitLine.labelPosition = .leftTop
        limitLine.valueTextColor = color
        limitLine.valueFont = .systemFont(ofSize: 10, weight: .regular)
        limitLine.lineColor = color
        limitLine.lineWidth = 0.5
        limitLine.xOffset = -3
        limitLine.yOffset = 8
        chartView.leftAxis.addLimitLine(limitLine)
    }
    
    func setupData(listChartValues: [ChartValueData]) {
        var listDataSet = [ScatterChartDataSet]()
        for chartValue in listChartValues {
            let listEntries = ChartDataEntry(x: chartValue.value.x, y: chartValue.value.y)
            let dataSet = ScatterChartDataSet(entries: [listEntries], label: chartValue.label)
            dataSet.setDrawHighlightIndicators(false)
            dataSet.setScatterShape(.circle)
            dataSet.scatterShapeHoleColor = ChartColorTemplates.colorFromString("#FFFFFF")
            dataSet.scatterShapeHoleRadius = 1.5
            dataSet.setColor(ChartColorTemplates.colorFromString(chartValue.hexColorString))
            dataSet.scatterShapeSize = 6
            listDataSet.append(dataSet)
        }
        let data = ScatterChartData(dataSets: listDataSet)
        data.setValueFont(.systemFont(ofSize: 10, weight: .regular))
        data.setValueFormatter(DataValueFormatter())
        data.setValueTextColor(.black)
        chartView.data = data
    }
}

class DataValueFormatter: NSObject, ValueFormatter {
    func stringForValue(_ value: Double, entry: Charts.ChartDataEntry, dataSetIndex: Int, viewPortHandler: Charts.ViewPortHandler?) -> String {
        return String(format: "%.1f", value)
    }
}

class LeftAxisFormatter: NSObject, AxisValueFormatter {
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        return "\(Int(value))°F"
    }
}

class RightAxisFormatter: NSObject, AxisValueFormatter {
    var shownValues = [0, 2, 4, 6, 8, 10]
    
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        if shownValues.contains(Int(value)) {
            return "\(Int(value))ml"
        }
        return ""
    }
}

class XAxisNameFormatter: NSObject, AxisValueFormatter {
    init(dateString: String) {
        self.dateString = dateString
    }
    
    let dateString: String
    
    var labels: [Int : String] = [
        0 : "0:00",
        4 : "4:00",
        8 : "8:00",
        12 : "12:00",
        16 : "16:00",
        20 : "20:00",
        24 : "0:00"
    ]
    
    func stringForValue( _ value: Double, axis _: AxisBase?) -> String {
        if let value = labels[Int((value).rounded())] {
            return "\(dateString)\n\(value)\n"
        }
        return ""
    }
}
