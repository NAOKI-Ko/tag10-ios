import CoreMotion
import Foundation
import TAG10Core

/// Owns CoreMotion availability, sampling, and neutral-angle calibration.
/// `GameScene` consumes only the normalized input and read-only status.
final class MotionInputController {
    enum Status: Equatable {
        case idle
        case unavailable
        case calibrating
        case active
        case failed
    }

    private let motionManager: CMMotionManager
    private var mapper = TiltInputMapper()

    private(set) var status: Status = .idle
    private(set) var input: Vector2 = .zero

    init(motionManager: CMMotionManager = CMMotionManager()) {
        self.motionManager = motionManager
    }

    func start() {
        guard status == .idle || status == .failed else { return }
        guard motionManager.isDeviceMotionAvailable else {
            status = .unavailable
            input = .zero
            return
        }

        status = .calibrating
        input = .zero
        mapper.resetCalibration()
        motionManager.deviceMotionUpdateInterval = GameConfig.Input.motionUpdateInterval
        motionManager.startDeviceMotionUpdates(
            using: .xArbitraryZVertical,
            to: .main
        ) { [weak self] motion, error in
            guard let self else { return }
            if error != nil {
                self.status = .failed
                self.input = .zero
                return
            }
            guard let attitude = motion?.attitude else { return }
            let sample = MotionAttitude(roll: attitude.roll, pitch: attitude.pitch)
            if self.mapper.neutralAttitude == nil {
                self.mapper.calibrate(using: sample)
                self.status = .active
                self.input = .zero
            } else {
                self.input = self.mapper.input(for: sample)
            }
        }
    }

    func recalibrate() {
        guard motionManager.isDeviceMotionActive else {
            start()
            return
        }
        mapper.resetCalibration()
        input = .zero
        status = .calibrating
    }

    func stop() {
        motionManager.stopDeviceMotionUpdates()
        input = .zero
        status = .idle
    }

    deinit {
        motionManager.stopDeviceMotionUpdates()
    }
}
