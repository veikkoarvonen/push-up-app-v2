//
//  UIBuilder.swift
//  Push Up App V2
//
//  Created by Veikko Arvonen on 12.1.2026.
//

import UIKit

struct UIBuilder {
    
    var viewFrame: CGRect
    var safeAreaInsets: UIEdgeInsets
  
//MARK: - Universal elements
    
    func generateBackgroundView() -> UIView {
        let view = UIView()
        view.backgroundColor = UIColor(named: "gray1")
        view.frame = CGRect(x: 0.0, y: safeAreaInsets.top, width: viewFrame.width, height: viewFrame.height - safeAreaInsets.top - safeAreaInsets.bottom)
        return view
    }
    
    func generateHeaderLabel(header: String) -> UILabel {
        let margin: CGFloat = 30.0
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .left
        label.font = UIFont(name: C.fonts.bold, size: 35.0)
        let x = margin
        let y = margin + safeAreaInsets.top
        let width = viewFrame.width - margin * 2.0
        let height: CGFloat = 50.0
        label.frame = CGRect(x: x, y: y, width: width, height: height)
        label.text = header
        return label
    }
    
    func styleHeader(header: UILabel, text: String) {
        header.text = text
        header.textColor = .white
        header.textAlignment = .left
        header.font = UIFont(name: C.fonts.bold, size: 35.0)
    }
    
    func styleContainerView(view: UIView) {
        view.backgroundColor = UIColor(named: "gray2")
        view.layer.cornerRadius = 10
    }
    
    func implementContainerShadow(targetView: UIView) {
        targetView.layer.shadowColor = C.Colors.brandOrangeCGValue
        targetView.layer.shadowOpacity = 0.40
        targetView.layer.shadowOffset = CGSize(width: 0, height: 4)
        targetView.layer.shadowRadius = 15
        targetView.layer.masksToBounds = false
    }
    
}

struct UIGrinder {
    
    func styleHeader(header: UILabel, text: String) {
        header.text = text
        header.textColor = .white
        header.textAlignment = .left
        header.font = UIFont(name: C.fonts.bold, size: 35.0)
    }
    
    func styleContainerView(view: UIView) {
        view.backgroundColor = UIColor(named: "gray2")
        view.layer.cornerRadius = 10
    }
    
    func implementContainerShadow(targetView: UIView) {
        targetView.layer.shadowColor = C.Colors.brandOrangeCGValue
        targetView.layer.shadowOpacity = 0.40
        targetView.layer.shadowOffset = CGSize(width: 0, height: 4)
        targetView.layer.shadowRadius = 15
        targetView.layer.masksToBounds = false
    }
    
}
