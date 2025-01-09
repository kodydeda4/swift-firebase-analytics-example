import Foundation

// MARK: - ComputerVision

extension ComputerVisionClient {
  typealias Response = Result<HittingOutput, Failure>
  
  struct HittingOutput: Identifiable, Equatable, Codable, Hashable {
    var id: UUID { measurementId }
    let measurementId: UUID
    let exitVelocity: Measurement<UnitSpeed>
    let launchAngle: Measurement<UnitAngle>
    let directionAngle: Measurement<UnitAngle>
    let distance: Measurement<UnitLength>
  }
  
  struct Failure: Error, Equatable, Hashable, Codable {
    let status: Int
    let error: String
    let message: String
  }
}

// MARK: - Firebase

extension FirebaseClient {
  typealias ComputerVisionResponse = Result<ComputerVisionSuccess, ComputerVisionFailure>
  
  struct ComputerVisionSuccess: Codable {
    let directionAngle: Double?
    let distance: Double?
    let exitVelocity: Double?
    let launchAngle: Double?
    let selectedSport: String?
    let cvComputationTime: Double
  }
  
  struct ComputerVisionFailure: Error, Codable {
    let statusCode: Int
  }
}
