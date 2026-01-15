//
//  PushUpDetector.swift
//  Push Up App V2
//
//  Created by Veikko Arvonen on 13.1.2026.
//

import Vision
import CoreGraphics

final class PushUpDetector {

    enum State { case up, down }

    // Tune these after testing
    var downThreshold: CGFloat = 90
    var upThreshold: CGFloat = 145
    var minConfidence: Float = 0.3

    private let sequenceHandler = VNSequenceRequestHandler()
    private var state: State = .up
    private(set) var count: Int = 0

    var onUpdate: ((Int, String) -> Void)?

    func reset() {
        count = 0
        state = .up
        onUpdate?(count, "Detecting…")
    }

    func process(pixelBuffer: CVPixelBuffer) {
        let request = VNDetectHumanBodyPoseRequest { [weak self] request, error in
            guard let self else { return }

            if let error {
                self.onUpdate?(self.count, "Vision error")
                print("Vision error:", error)
                return
            }

            guard let obs = request.results?.first as? VNHumanBodyPoseObservation else {
                self.onUpdate?(self.count, "No body detected")
                return
            }

            self.handle(obs)
        }

        do {
            try sequenceHandler.perform([request], on: pixelBuffer)
        } catch {
            onUpdate?(count, "Vision perform failed")
        }
    }

    private func handle(_ obs: VNHumanBodyPoseObservation) {
        if let angle = elbowAngle(obs, side: .left) ?? elbowAngle(obs, side: .right) {
            updateState(with: angle)
        } else {
            onUpdate?(count, "Body not fully visible")
        }
    }

    private enum Side { case left, right }

    private func elbowAngle(_ obs: VNHumanBodyPoseObservation, side: Side) -> CGFloat? {
        let shoulderKey: VNHumanBodyPoseObservation.JointName = (side == .left) ? .leftShoulder : .rightShoulder
        let elbowKey: VNHumanBodyPoseObservation.JointName = (side == .left) ? .leftElbow : .rightElbow
        let wristKey: VNHumanBodyPoseObservation.JointName = (side == .left) ? .leftWrist : .rightWrist

        guard
            let shoulder = try? obs.recognizedPoint(shoulderKey),
            let elbow = try? obs.recognizedPoint(elbowKey),
            let wrist = try? obs.recognizedPoint(wristKey)
        else { return nil }

        guard shoulder.confidence >= minConfidence,
              elbow.confidence >= minConfidence,
              wrist.confidence >= minConfidence else { return nil }

        let a = CGPoint(x: shoulder.location.x, y: shoulder.location.y)
        let b = CGPoint(x: elbow.location.x, y: elbow.location.y)
        let c = CGPoint(x: wrist.location.x, y: wrist.location.y)

        let ba = CGPoint(x: a.x - b.x, y: a.y - b.y)
        let bc = CGPoint(x: c.x - b.x, y: c.y - b.y)

        let dot = ba.x * bc.x + ba.y * bc.y
        let magBA = sqrt(ba.x * ba.x + ba.y * ba.y)
        let magBC = sqrt(bc.x * bc.x + bc.y * bc.y)
        let denom = max(magBA * magBC, 0.0001)

        var cosTheta = dot / denom
        cosTheta = max(-1, min(1, cosTheta))

        return acos(cosTheta) * 180 / .pi
    }

    private func updateState(with angle: CGFloat) {
        if angle < downThreshold {
            state = .down
            onUpdate?(count, "DOWN (\(Int(angle))°)")
        } else if angle > upThreshold {
            if state == .down {
                state = .up
                count += 1
                onUpdate?(count, "UP (\(Int(angle))°) • Rep +1")
            } else {
                onUpdate?(count, "UP (\(Int(angle))°)")
            }
        } else {
            onUpdate?(count, "Moving (\(Int(angle))°)")
        }
    }
}

