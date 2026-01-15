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

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setUI()
        
        let coreData = CoreDataManager()
        //print(coreData.getDatesForThisWeek())
        
        let now = Date()
        print(now)
        let startOfNow = Calendar.current.startOfDay(for: now)
        print(startOfNow)
        
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        guard !hasSetUIUp else { return }
        hasSetUIUp = true
        view.layoutIfNeeded()
        addDynamicUI()
        updatePushUpColums()
    }


}

extension OverviewVC {
    
    private func setUI() {
        
        let builder = UIBuilder(viewFrame: view.frame, safeAreaInsets: view.safeAreaInsets)
        
        //Background view
        let bgView = UIView()
        bgView.backgroundColor = UIColor(named: "gray1")
        bgView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bgView)
        uiElements.backgroundView = bgView
        
        NSLayoutConstraint.activate([
            bgView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            bgView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bgView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bgView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        //Header label
        let header = UILabel()
        builder.styleHeader(header: header, text: "Overview")
        header.translatesAutoresizingMaskIntoConstraints = false
        bgView.addSubview(header)
        uiElements.header = header
        
        NSLayoutConstraint.activate([
            header.topAnchor.constraint(equalTo: bgView.topAnchor, constant: 30.0),
            header.leadingAnchor.constraint(equalTo: bgView.leadingAnchor, constant: 30.0),
            header.trailingAnchor.constraint(equalTo: bgView.trailingAnchor, constant: -30.0),
            header.heightAnchor.constraint(equalToConstant: 50.0)
        ])
        
        //Push up chart container
        let pushUpChartView = UIView()
        pushUpChartView.translatesAutoresizingMaskIntoConstraints = false
        builder.styleContainerView(view: pushUpChartView)
        builder.implementContainerShadow(targetView: pushUpChartView)
        bgView.addSubview(pushUpChartView)
        uiElements.pushUpChartView = pushUpChartView
        
        NSLayoutConstraint.activate([
            pushUpChartView.topAnchor.constraint(equalTo: header.bottomAnchor, constant: 30.0),
            pushUpChartView.leadingAnchor.constraint(equalTo: bgView.leadingAnchor, constant: 30.0),
            pushUpChartView.trailingAnchor.constraint(equalTo: bgView.trailingAnchor, constant: -30.0),
            pushUpChartView.heightAnchor.constraint(equalTo: bgView.heightAnchor, multiplier: 0.4)
        ])
        
        //Weekday row
        let weekdayRowView = UIStackView()
        weekdayRowView.axis = .horizontal
        weekdayRowView.distribution = .fillEqually
        weekdayRowView.spacing = 0.0
        weekdayRowView.translatesAutoresizingMaskIntoConstraints = false
        pushUpChartView.addSubview(weekdayRowView)
        uiElements.weekdayStackView = weekdayRowView
        
        let weekdayStrings: [String] = ["Mon","Tue","Wed","Thu","Fri","Sat","Sun"]
        
        for i in 0..<7 {
            let label = UILabel()
            label.textAlignment = .center
            label.textColor = .white
            label.font = UIFont(name: C.fonts.bold, size: 15.0)
            label.text = weekdayStrings[i]
            //label.backgroundColor = .yellow
            weekdayRowView.addArrangedSubview(label)
        }
        
        NSLayoutConstraint.activate([
            weekdayRowView.leadingAnchor.constraint(equalTo: pushUpChartView.leadingAnchor, constant: 5.0),
            weekdayRowView.trailingAnchor.constraint(equalTo: pushUpChartView.trailingAnchor, constant: -5.0),
            weekdayRowView.bottomAnchor.constraint(equalTo: pushUpChartView.bottomAnchor, constant: -5.0),
            weekdayRowView.heightAnchor.constraint(equalToConstant: 20.0)
        ])

        
        
    }
    
    private func addDynamicUI() {
        
        
        
        //Chart lines
        let margin: CGFloat = 5.0
        let weekdayStackHeigth: CGFloat = 20.0
        let lineWidth: CGFloat = uiElements.pushUpChartView.frame.width - margin * 2
        var lineY: CGFloat = margin + 5.0
        let totalChartHeigth: CGFloat = uiElements.pushUpChartView.frame.height - weekdayStackHeigth - 20.0
        let yInterval: CGFloat = totalChartHeigth / 5.0
        for _ in 0...5 {
            let line = UIView()
            line.backgroundColor = UIColor(named: "gray1")
            uiElements.pushUpChartView.addSubview(line)
            
            line.frame = CGRect(x: margin, y: lineY, width: lineWidth, height: 1.0)
            lineY += yInterval
        }
        
        let pushUpColumGap: CGFloat = 2.0
        let totalPushUpColumSpace: CGFloat = uiElements.pushUpChartView.bounds.width - margin * 2.0
        let pushUpColumWidth: CGFloat = totalPushUpColumSpace / 7.0 - pushUpColumGap
        let pushUpColumnHeigth: CGFloat = uiElements.pushUpChartView.bounds.height - weekdayStackHeigth - 20.0
        var pushUpColumX: CGFloat = margin + 1.0
        
        var colums: [UIView] = []
        var columLabels: [UILabel] = []
        
        for _ in 0..<7 {
            let pushUpColum = UIView()
            pushUpColum.backgroundColor = UIColor(named: "orange1")?.withAlphaComponent(0.8)
            pushUpColum.layer.cornerRadius = 3.0
            uiElements.pushUpChartView.addSubview(pushUpColum)
            pushUpColum.frame = CGRect(x: pushUpColumX, y: 10.0, width: pushUpColumWidth, height: pushUpColumnHeigth)
            pushUpColumX += totalPushUpColumSpace / 7.0
            
            let pushUpColumLabel = UILabel()
            pushUpColumLabel.textColor = .white
            pushUpColumLabel.textAlignment = .center
            pushUpColumLabel.font = UIFont(name: C.fonts.bold, size: 12.0)
            pushUpColumLabel.text = "22"
            pushUpColum.addSubview(pushUpColumLabel)
            pushUpColumLabel.frame = CGRect(x: 0.0, y: 5.0, width: pushUpColum.frame.width, height: 12.0)
            
            colums.append(pushUpColum)
            columLabels.append(pushUpColumLabel)
        }
        
        uiElements.pushUpColums = colums
        uiElements.pushUpColumLabels = columLabels
        
        
        
    }
    
    private func updatePushUpColums() {
        guard uiElements.pushUpColums.count == 7, uiElements.pushUpColumLabels.count == 7 else {
            print("Invalid push up colums count!")
            return
            
        }
        
        let testData: [Int] = [12, 24, 23, 54, 35, 26, 7]
        
        let maxPushUps = testData.max() ?? 50
        let chartHeigth: CGFloat = uiElements.pushUpChartView.bounds.height - uiElements.weekdayStackView.bounds.height - 20.0
        
        var chartMaxValue: Int = 0
        while chartMaxValue < maxPushUps {
            chartMaxValue += 10
        }
        
        //print("Chart max value: \(chartMaxValue)")
        

        
        for i in 0..<uiElements.pushUpColums.count {
            
            let newHeightPercentage: CGFloat = CGFloat(testData[i]) / CGFloat(chartMaxValue)
            let newHeight = chartHeigth * newHeightPercentage
            
            let column = uiElements.pushUpColums[i]
            let label = uiElements.pushUpColumLabels[i]
            
            label.text = testData[i].description
            
            let yOffset: CGFloat = chartHeigth * (1.0 - newHeightPercentage) + 10.0
            
            // Animate bar growth
            UIView.animate(withDuration: 0.6,
                           delay: Double(i) * 0.05,
                           options: [.curveEaseOut]) {
                column.frame.size.height = newHeight
                column.frame.origin.y = yOffset
            }
            
        }
    }
    
}

struct OverviewVCComponents {
    var backgroundView = UIView()
    var header = UILabel()
    var pushUpChartView = UIView()
    var weekdayStackView = UIStackView()
    var pushUpColums = [UIView]()
    var pushUpColumLabels = [UILabel]()
}

