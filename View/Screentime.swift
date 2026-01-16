//
//  Screentime.swift
//  Push Up App V2
//
//  Created by Veikko Arvonen on 12.1.2026.
//

import UIKit

class ScreentimeVC: UIViewController {
    
    private var hasSetUI: Bool = false
    private var cameraIsRunning: Bool = false
    private var uiElements: ScreentimeUIElements!
    private let cameraManager = CameraPreviewManager()
    private let coreData = CoreDataManager()
    
    private let pushUpDetector = PushUpDetector()
    private var lastVisionTime = CACurrentMediaTime()
    private let visionInterval: CFTimeInterval = 0.10 // ~10 FPS

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidLayoutSubviews() {
        if !hasSetUI {
            hasSetUI = true
            setUI()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        cameraManager.stopPreview()
    }

    
    @objc func handleCameraTap() {
        print("Camera tapped")
        if !cameraIsRunning {
            cameraManager.startPreview(in: uiElements.cameraPreviewView) { [weak self] result in
                switch result {
                case .success:
                    // optional: update UI (button title, status label, etc.)
                    guard let self else { return }
                    
                    self.cameraIsRunning.toggle()
                    pushUpDetector.reset()
                    self.self.updateUIState(cameraIsActive: self.cameraIsRunning)
                    print("Launching camera")
                    cameraManager.onFrame = { [weak self] pixelBuffer in
                        guard let self, self.cameraIsRunning else { return }

                        let now = CACurrentMediaTime()
                        guard now - self.lastVisionTime >= self.visionInterval else { return }
                        self.lastVisionTime = now

                        self.pushUpDetector.process(pixelBuffer: pixelBuffer)
                    }


                case .failure(let error):
                    self?.showError(title: "Camera", message: error.localizedDescription)
                }
            }
        } else {
            cameraManager.stopPreview()
            print("User did \(pushUpDetector.count) reps")
            if pushUpDetector.count > 0 {
                UserDefaults.standard.set(true, forKey: "shouldUpdateMainChart")
                coreData.createWorkout(reps: Int16(pushUpDetector.count), date: Date())
            }
            cameraIsRunning.toggle()
            updateUIState(cameraIsActive: cameraIsRunning)
        }
    }
    
    @objc func handleSosTap() {
        print("Sos tapped")
    }
    
    private func showError(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
}

//MARK: - Set user interface

extension ScreentimeVC {
    
    private func setUI() {
        
        let builder = UIBuilder(viewFrame: view.frame, safeAreaInsets: view.safeAreaInsets)
        
        let bgView = builder.generateBackgroundView()
        view.addSubview(bgView)
        
        let camPreviewView = UIView()
        camPreviewView.backgroundColor = .black
        camPreviewView.frame = view.bounds
        view.addSubview(camPreviewView)
        camPreviewView.isHidden = true
        
        let hLabel = builder.generateHeaderLabel(header: "Screentime")
        view.addSubview(hLabel)
        
//MARK: - Screentime container
        
        let screentimeContainer = UIView()
        screentimeContainer.backgroundColor = UIColor(named: "gray2")
        screentimeContainer.layer.cornerRadius = 10
        //screentimeContainer.layer.borderColor = C.Colors.brandOrangeCGValue
        //screentimeContainer.layer.borderWidth = 3.0
        let screentimeContainerX: CGFloat = 30.0
        let screenTimeContainerY: CGFloat = hLabel.frame.maxY + 30.0
        let screentimeContainerW: CGFloat = view.frame.width - 60.0
        let screentimeContainerH: CGFloat = 180.0
        screentimeContainer.frame = CGRect(x: screentimeContainerX, y: screenTimeContainerY, width: screentimeContainerW, height: screentimeContainerH)
        view.addSubview(screentimeContainer)
        addShadow(to: screentimeContainer)
        
        let screentimeHeader = UILabel()
        screentimeHeader.textAlignment = .center
        screentimeHeader.textColor = .white
        screentimeHeader.font = UIFont(name: C.fonts.bold, size: 18.0)
        screentimeHeader.text = "You have..."
        let screentimeHeaderX: CGFloat = 10.0
        let screentimeHeaderY: CGFloat = 10.0
        let screentimeHeaderW: CGFloat = screentimeContainer.frame.width - 20.0
        let screentimeHeaderH: CGFloat = 40.0
        screentimeHeader.frame = CGRect(x: screentimeHeaderX, y: screentimeHeaderY, width: screentimeHeaderW, height: screentimeHeaderH)
        screentimeContainer.addSubview(screentimeHeader)
        
        let screenTimeFooter = UILabel()
        screenTimeFooter.textAlignment = .center
        screenTimeFooter.textColor = .white
        screenTimeFooter.font = UIFont(name: C.fonts.bold, size: 18.0)
        screenTimeFooter.text = "...of screentime remaining"
        let screenTimeFooterX: CGFloat = 10.0
        let screenTimeFooterY: CGFloat = screentimeContainer.frame.height - 10.0 - 40.0
        let screenTimeFooterW: CGFloat = screentimeContainer.frame.width - 20.0
        let screenTimeFooterH: CGFloat = 40.0
        screenTimeFooter.frame = CGRect(x: screenTimeFooterX, y: screenTimeFooterY, width: screenTimeFooterW, height: screenTimeFooterH)
        screentimeContainer.addSubview(screenTimeFooter)
        
        let screentimeCounter = UILabel()
        screentimeCounter.textAlignment = .center
        screentimeCounter.textColor = .white
        screentimeCounter.font = UIFont(name: C.fonts.bold, size: 35.0)
        screentimeCounter.text = "109 min"
        let screentimeCounterX = 10.0
        let screenTimeCounterH = 50.0
        let screentimeCounterY: CGFloat = 90.0 - (screenTimeCounterH / 2)
        let screentimeCounterW: CGFloat = screentimeContainer.frame.width - 20.0
        screentimeCounter.frame = CGRect(x: screentimeCounterX, y: screentimeCounterY, width: screentimeCounterW, height: screenTimeCounterH)
        screentimeContainer.addSubview(screentimeCounter)
        
//MARK: - Camera button
        
        let cameraImageContainer = UIView()
        cameraImageContainer.backgroundColor = UIColor(named: "gray2")
        cameraImageContainer.layer.cornerRadius = 45.0
        let cameraImageContainerSize = 90.0
        let cameraImageContainerX: CGFloat = view.frame.width - 30.0 - cameraImageContainerSize
        let cameraImageContainerY: CGFloat = view.frame.height - view.safeAreaInsets.bottom - 30.0 - cameraImageContainerSize
        cameraImageContainer.frame = CGRect(x: cameraImageContainerX, y: cameraImageContainerY, width: cameraImageContainerSize, height: cameraImageContainerSize)
        view.addSubview(cameraImageContainer)
        addShadow(to: cameraImageContainer)
        
        let cameraImageView = UIImageView()
        cameraImageView.image = UIImage(named: "camera")
        cameraImageView.tintColor = .white
        cameraImageView.frame = CGRect(x: 15.0, y: 12.0, width: 60.0, height: 60.0)
        cameraImageContainer.addSubview(cameraImageView)
        
        let camTap = UITapGestureRecognizer(target: self, action: #selector(handleCameraTap))
        cameraImageView.addGestureRecognizer(camTap)
        cameraImageView.isUserInteractionEnabled = true
        
//MARK: - SOS button
        
        let sosImageContainer = UIView()
        sosImageContainer.backgroundColor = UIColor(named: "gray2")
        sosImageContainer.layer.cornerRadius = 45.0
        let sosImageContainerSize = 90.0
        let sosImageContainerX: CGFloat = 30.0
        let sosImageContainerY: CGFloat = view.frame.height - view.safeAreaInsets.bottom - 30.0 - sosImageContainerSize
        sosImageContainer.frame = CGRect(x: sosImageContainerX, y: sosImageContainerY, width: sosImageContainerSize, height: sosImageContainerSize)
        view.addSubview(sosImageContainer)
        addShadow(to: sosImageContainer)
        
        let sosImageView = UIImageView()
        sosImageView.image = UIImage(named: "sos")
        sosImageView.tintColor = .white
        sosImageView.frame = CGRect(x: 15.0, y: 15.0, width: 60.0, height: 60.0)
        sosImageContainer.addSubview(sosImageView)
        
        let sosTap = UITapGestureRecognizer(target: self, action: #selector(handleSosTap))
        sosImageView.addGestureRecognizer(sosTap)
        sosImageView.isUserInteractionEnabled = true
        
//MARK: - Unlock description
        
        let unlockLabel = UILabel()
        unlockLabel.textColor = .white
        unlockLabel.textAlignment = .center
        unlockLabel.font = UIFont(name: C.fonts.bold, size: 18.0)
        unlockLabel.numberOfLines = 0
        unlockLabel.text = "Unlock screentime by tapping camera and doing push ups"
        let unlockLabelX: CGFloat = 30.0
        let unlockLabelY: CGFloat = sosImageContainer.frame.minY - 20.0 - 80.0
        let unlockLabelW: CGFloat = view.frame.width - 60.0
        let unlockLabelH: CGFloat = 80.0
        unlockLabel.frame = CGRect(x: unlockLabelX, y: unlockLabelY, width: unlockLabelW, height: unlockLabelH)
        view.addSubview(unlockLabel)
        
        uiElements = ScreentimeUIElements(backgroundView: bgView, cameraPreviewView: camPreviewView, headerLabel: hLabel, screentimeContainer: screentimeContainer, screentimeHeaderLabel: screentimeHeader, screentimeCounterLabel: screentimeCounter, screentimeFooterLabel: screenTimeFooter, unlockDescriptionLabel: unlockLabel, cameraImageContainer: cameraImageContainer, sosImageContainer: sosImageContainer, cameraImageView: cameraImageView, sosImageView: sosImageView)
        
        pushUpDetector.onUpdate = { [weak self] count, status in
            DispatchQueue.main.async {
                // Add these labels to your UIElements struct if you haven’t yet
                // Example:
                // self?.uiElements.pushUpCountLabel.text = "\(count)"
                // self?.uiElements.statusLabel.text = status

                // If you don't have labels yet, at least print:
                print("Reps:", count, "Status:", status)
                self!.uiElements.headerLabel.text = "Push Ups: \(count)"
            }
        }

    }
    
    private func addShadow(to targetView: UIView) {
        targetView.layer.shadowColor = C.Colors.brandOrangeCGValue
        targetView.layer.shadowOpacity = 0.40
        targetView.layer.shadowOffset = CGSize(width: 0, height: 4)
        targetView.layer.shadowRadius = 15
        targetView.layer.masksToBounds = false
    }
    
    private func updateUIState(cameraIsActive: Bool) {
        uiElements.cameraPreviewView.isHidden = !cameraIsActive
        uiElements.screentimeContainer.isHidden = cameraIsActive
        uiElements.sosImageContainer.isHidden = cameraIsActive
        uiElements.unlockDescriptionLabel.isHidden = cameraIsActive
        uiElements.headerLabel.textAlignment = cameraIsActive ? .center : .left
        uiElements.headerLabel.text = cameraIsActive ? "Push Ups: 0" : "Screentime"
    }
    
}

struct ScreentimeUIElements {
    var backgroundView: UIView!
    var cameraPreviewView: UIView!
    var headerLabel: UILabel!
    var screentimeContainer: UIView!
    var screentimeHeaderLabel: UILabel!
    var screentimeCounterLabel: UILabel!
    var screentimeFooterLabel: UILabel!
    var unlockDescriptionLabel: UILabel!
    var cameraImageContainer: UIView!
    var sosImageContainer: UIView!
    var cameraImageView: UIImageView!
    var sosImageView: UIImageView!
}
