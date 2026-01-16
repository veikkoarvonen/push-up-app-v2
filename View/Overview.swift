//
//  ViewController.swift
//  Push Up App V2
//
//  Created by Veikko Arvonen on 12.1.2026.
//

import UIKit

class OverviewVC: UIViewController {
    
    var hasSetUIUp: Bool = false
    var uiElements = OverviewVCComponents()
    let builder = UIGrinder()
    let coreData = CoreDataManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        guard !hasSetUIUp else { return }
        hasSetUIUp = true
        print(coreData.getWeeklyPushUpData())
        setUpUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if UserDefaults.standard.bool(forKey: "shouldUpdateMainChart") {
            print("View did appear and the chart should be updated")
            updatePushUpColumns(animated: true, useTestData: false)
            UserDefaults.standard.set(false, forKey: "shouldUpdateMainChart")
        } else {
            print("View did appear but the chart should not be updated")
        }
    }


}


//MARK: - User interface
extension OverviewVC {
    
    private func setUpUI() {
        setBackGroundView()
        setHeader()
        setPushUpContainer()
        setPushUpChartLines()
        setPushUpColums()
        updatePushUpColumns(animated: true, useTestData: true)
    }
    
    private func setBackGroundView() {
        let bgView = UIView()
        bgView.backgroundColor = UIColor(named: "gray1")
        view.addSubview(bgView)
        bgView.frame = CGRect(x: 0.0, y: view.safeAreaInsets.top, width: view.frame.width, height: view.frame.height - view.safeAreaInsets.top - view.safeAreaInsets.bottom)
        uiElements.backgroundView = bgView
    }
    private func setHeader() {
        
        let header = UILabel()
        builder.styleHeader(header: header, text: "Overview")
        uiElements.backgroundView.addSubview(header)
        header.frame = CGRect(x: 30.0, y: 30.0, width: view.frame.width - 60.0, height: 40.0)
        uiElements.header = header
        if C.testUIwithColors { header.backgroundColor = .red }
        
        
    }
    private func setPushUpContainer() {
        
        let container = UIView()
        builder.styleContainerView(view: container)
        builder.implementContainerShadow(targetView: container)
        uiElements.backgroundView.addSubview(container)
        uiElements.pushUpChartContainer = container
        if C.testUIwithColors { container.backgroundColor = .yellow }
        container.frame = CGRect(x: 30.0, y: uiElements.header.frame.maxY + 20.0, width: view.frame.width - 60.0, height: view.frame.height * 0.3)
        
        let margin: CGFloat = 5.0
        
        let chartView = UIView()
        chartView.backgroundColor = C.testUIwithColors ? .red : .clear
        chartView.frame = CGRect(x: 5.0, y: 10.0, width: container.frame.width - margin * 2.0, height: container.frame.height - margin * 2 - 20.0 - 15.0)
        container.addSubview(chartView)
        uiElements.pushUpChartView = chartView
        
        
        let weekdayStrings: [String] = ["Mon","Tue","Wed","Thu","Fri","Sat","Sun"]
        let weekdayRowWidth = container.frame.width - margin * 2.0
        let weekdatRowHeigth: CGFloat = 20.0
        var xOffset: CGFloat = margin
        let yOffset: CGFloat = chartView.frame.maxY + 5.0
        
        for i in 0..<7 {
            let label = UILabel()
            label.textAlignment = .center
            label.textColor = .white
            label.font = UIFont(name: C.fonts.bold, size: 15.0)
            label.text = weekdayStrings[i]
            uiElements.pushUpChartContainer.addSubview(label)
            label.frame = CGRect(x: xOffset, y: yOffset, width: weekdayRowWidth / 7, height: weekdatRowHeigth)
            if C.testUIwithColors { label.backgroundColor = .green }
            xOffset += weekdayRowWidth / 7.0
        }
        
        
    }
    private func setPushUpChartLines() {
        
        var yOffset: CGFloat = 0.0
        let yInterval: CGFloat = uiElements.pushUpChartView.frame.height / 5.0
        
        for _ in 0...5 {
            let line = UIView()
            line.backgroundColor = C.testUIwithColors ? .green : UIColor(named: "gray1")
            uiElements.pushUpChartView.addSubview(line)
            
            line.frame = CGRect(x: 0.0, y: yOffset, width: uiElements.pushUpChartView.frame.width, height: 1.0)
            yOffset += yInterval
        }
        
    }
    private func setPushUpColums() {
        
        let columnSpaceWidth: CGFloat = uiElements.pushUpChartView.frame.width / 7.0
        let columnHeigth: CGFloat = uiElements.pushUpChartView.frame.height
        let columnWidth: CGFloat = columnSpaceWidth - 4.0
        var xOffset: CGFloat = 2.0
        
        var columnsToAdd: [UIView] = []
        var labelsToAdd: [UILabel] = []
        
        for _ in 0..<7 {
            let column = UIView()
            column.backgroundColor = UIColor(named: "orange1")?.withAlphaComponent(0.8)
            column.layer.cornerRadius = 5.0
            uiElements.pushUpChartView.addSubview(column)
            column.frame = CGRect(x: xOffset, y: 0, width: columnWidth, height: columnHeigth)
            columnsToAdd.append(column)
            
            let pushUpColumLabel = UILabel()
            pushUpColumLabel.textColor = .white
            pushUpColumLabel.textAlignment = .center
            pushUpColumLabel.font = UIFont(name: C.fonts.bold, size: 12.0)
            pushUpColumLabel.text = "22"
            column.addSubview(pushUpColumLabel)
            pushUpColumLabel.frame = CGRect(x: 0.0, y: 5.0, width: column.frame.width, height: 12.0)
            labelsToAdd.append(pushUpColumLabel)
            
            xOffset += columnSpaceWidth
        }
        
        uiElements.pushUpColums = columnsToAdd
        uiElements.pushUpColumLabels = labelsToAdd
        
    }
    private func updatePushUpColumns(animated: Bool, useTestData: Bool) {
        
        guard uiElements.pushUpColums.count == 7, uiElements.pushUpColumLabels.count == 7 else {
            print("Invalid push up column count")
            return }
        
        let pushUpData: [Int] = useTestData ? C.chartTestData : CoreDataManager.shared.getWeeklyPushUpData()
        
        guard !pushUpData.isEmpty else {
            print("No push up data available, exiting function")
            return
        }
        
        let maxPushUps = pushUpData.max() ?? 50
        var chartMaxValue: Int = 0
        while chartMaxValue < maxPushUps {
            chartMaxValue += 10
        }
        
        print("Push up chart max value set to \(chartMaxValue)")
        
        for i in 0..<7 {

            let targetColumn = uiElements.pushUpColums[i]
            let targetLabel = uiElements.pushUpColumLabels[i]
            
            if pushUpData[i] == 0 {
                print("Push up data for day \(i) is 0, not adding corresponding column")
                uiElements.pushUpColums[i].isHidden = true
                continue
            }
            
            targetLabel.text = "\(pushUpData[i])"
            let relativeHeigth = CGFloat(pushUpData[i]) / CGFloat(chartMaxValue)
            let sheetHeigth = uiElements.pushUpChartView.frame.height
            let yOffset = sheetHeigth - (sheetHeigth * relativeHeigth)
            let finalHeight: CGFloat = sheetHeigth * relativeHeigth
            
            if finalHeight < 20.0 { targetLabel.isHidden = true }
            
            targetColumn.frame.origin.y = animated ? sheetHeigth : yOffset
            targetColumn.frame.size.height = animated ? 0 : finalHeight
            
            if animated {
                UIView.animate(withDuration: 0.5, delay: 0.0, options: [.curveEaseOut]) {
                    targetColumn.frame.origin.y = yOffset
                    targetColumn.frame.size.height = finalHeight
                }
            }
            
            
            
            
            
        }
        
    }
}



struct OverviewVCComponents {
    var backgroundView = UIView()
    var header = UILabel()
    //Push up chart
    var pushUpChartContainer = UIView()
    var pushUpChartView = UIView()
    var pushUpColums = [UIView]()
    var pushUpColumLabels = [UILabel]()
}

