//
//  FFTBarView.swift
//  Neurorobot
//
//  Created by Djordje Jovic on 15.1.21..
//  Copyright © 2021 Backyard Brains. All rights reserved.
//

import UIKit
import Charts

final class FFTBarView: UIView {

    private let chartView = BarChartView()


    override init(frame: CGRect) {
        super.init(frame: frame)
        setpUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setpUI()
    }

    private func setpUI() {
        addSubview(chartView)
        chartView.fillSuperView()

        self.setup(barLineChartView: chartView)

        chartView.delegate = self

        chartView.drawBarShadowEnabled = false
        chartView.drawValueAboveBarEnabled = false
        chartView.maxVisibleCount = 60
        chartView.legend.enabled = false

        let bottomAxisFormatter = NumberFormatter()
        bottomAxisFormatter.minimumFractionDigits = 0
        bottomAxisFormatter.maximumFractionDigits = 1
        bottomAxisFormatter.positiveSuffix = "Hz"

        let xAxis = chartView.xAxis
        xAxis.labelPosition = .bottom
        xAxis.labelFont = .systemFont(ofSize: 10)
        xAxis.granularity = 1
        xAxis.labelCount = 7
        xAxis.valueFormatter = DefaultAxisValueFormatter(formatter: bottomAxisFormatter)

        let leftAxisFormatter = NumberFormatter()
        leftAxisFormatter.minimumFractionDigits = 0
        leftAxisFormatter.maximumFractionDigits = 1

        let leftAxis = chartView.leftAxis
        leftAxis.labelFont = .systemFont(ofSize: 10)
        leftAxis.labelCount = 6
        leftAxis.valueFormatter = DefaultAxisValueFormatter(formatter: leftAxisFormatter)
        leftAxis.labelPosition = .outsideChart
        leftAxis.spaceTop = 0.15
        leftAxis.axisMinimum = 0
        leftAxis.axisMaximum = 3
        leftAxis.maxWidth = 20
    }

    func setup(barLineChartView chartView: BarLineChartViewBase) {
        chartView.chartDescription?.enabled = false

        chartView.dragEnabled = true
        chartView.setScaleEnabled(true)
        chartView.pinchZoomEnabled = false

        // ChartYAxis *leftAxis = chartView.leftAxis;

        let xAxis = chartView.xAxis
        xAxis.labelPosition = .bottom

        chartView.rightAxis.enabled = false
    }

    func setData(spectrum: [Double: Double]) {
        
        let yVals = spectrum.map { (frequency: Double, amplitude: Double) -> BarChartDataEntry in
            return BarChartDataEntry(x: frequency, y: amplitude)
        }

        var set1: BarChartDataSet! = nil
        if let set = chartView.data as? BarChartDataSet {
            set1 = set
            set1.replaceEntries(yVals)
            chartView.data?.notifyDataChanged()
            chartView.notifyDataSetChanged()
        } else {
            set1 = BarChartDataSet(entries: yVals)
            set1.colors = [.lightGray]
            set1.drawValuesEnabled = false

            let data = BarChartData(dataSet: set1)
            data.setValueFont(.systemFont(ofSize: 10))
            data.barWidth = 50
            chartView.data = data
        }
    }
}

extension FFTBarView: ChartViewDelegate {


}
