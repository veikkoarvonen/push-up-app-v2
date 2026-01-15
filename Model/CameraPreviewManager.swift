//
//  CameraPreviewManager.swift
//  Push Up App V2
//
//  Created by Veikko Arvonen on 13.1.2026.
//

import AVFoundation
import UIKit

final class CameraPreviewManager: NSObject {

    private let session = AVCaptureSession()
    private var previewLayer: AVCaptureVideoPreviewLayer?

    // NEW: video output for frames
    private let videoOutput = AVCaptureVideoDataOutput()
    private let videoQueue = DispatchQueue(label: "camera.video.queue")

    // This is how your VC will receive frames
    var onFrame: ((CVPixelBuffer) -> Void)?

    func startPreview(in view: UIView, completion: @escaping (Result<Void, Error>) -> Void) {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            configureAndStart(in: view, completion: completion)

        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    if granted {
                        self.configureAndStart(in: view, completion: completion)
                    } else {
                        completion(.failure(NSError(domain: "Camera", code: 1, userInfo: [NSLocalizedDescriptionKey: "Camera permission denied."])))
                    }
                }
            }

        default:
            completion(.failure(NSError(domain: "Camera", code: 2, userInfo: [NSLocalizedDescriptionKey: "Camera permission denied. Enable it in Settings."])))
        }
    }

    func stopPreview() {
        if session.isRunning { session.stopRunning() }
    }

    func updatePreviewFrame(_ frame: CGRect) {
        previewLayer?.frame = frame
    }

    private func configureAndStart(in view: UIView, completion: @escaping (Result<Void, Error>) -> Void) {

        session.beginConfiguration()
        session.sessionPreset = .high

        // Clear old inputs & outputs
        session.inputs.forEach { session.removeInput($0) }
        session.outputs.forEach { session.removeOutput($0) }

        // Camera input
        guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front)
                ?? AVCaptureDevice.default(for: .video) else {
            session.commitConfiguration()
            completion(.failure(NSError(domain: "Camera", code: 3)))
            return
        }

        do {
            let input = try AVCaptureDeviceInput(device: camera)
            guard session.canAddInput(input) else {
                session.commitConfiguration()
                completion(.failure(NSError(domain: "Camera", code: 4)))
                return
            }
            session.addInput(input)
        } catch {
            session.commitConfiguration()
            completion(.failure(error))
            return
        }

        // NEW: Video output for Vision frames
        videoOutput.alwaysDiscardsLateVideoFrames = true
        videoOutput.videoSettings = [
            kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA
        ]
        videoOutput.setSampleBufferDelegate(self, queue: videoQueue)

        guard session.canAddOutput(videoOutput) else {
            session.commitConfiguration()
            completion(.failure(NSError(domain: "Camera", code: 5)))
            return
        }
        session.addOutput(videoOutput)

        if let conn = videoOutput.connection(with: .video), conn.isVideoOrientationSupported {
            conn.videoOrientation = .portrait
        }

        session.commitConfiguration()

        // Preview layer (visual)
        let layer = AVCaptureVideoPreviewLayer(session: session)
        layer.videoGravity = .resizeAspectFill
        layer.frame = view.bounds
        view.layer.insertSublayer(layer, at: 0)
        self.previewLayer = layer

        session.startRunning()
        completion(.success(()))
    }
}

extension CameraPreviewManager: AVCaptureVideoDataOutputSampleBufferDelegate {

    func captureOutput(_ output: AVCaptureOutput,
                       didOutput sampleBuffer: CMSampleBuffer,
                       from connection: AVCaptureConnection) {

        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        onFrame?(pixelBuffer)
    }
}
