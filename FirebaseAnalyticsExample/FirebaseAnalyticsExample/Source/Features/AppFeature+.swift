import Foundation

internal extension FirebaseClient.ComputerVisionResponse {
  /// `ComputerVisionClient.Response` -> `FirebaseClient.ComputerVisionResponse`
  init(
    _ result: ComputerVisionClient.Response,
    _ selectedSport: String?,
    _ cvComputationTime: Double
  ) {
    self = result.map { success in
      FirebaseClient.ComputerVisionSuccess(
        directionAngle: success.directionAngle.value,
        distance: success.distance.value,
        exitVelocity: success.exitVelocity.value,
        launchAngle: success.launchAngle.value,
        selectedSport: selectedSport,
        cvComputationTime: cvComputationTime
      )
    }
    .mapError { error in
      FirebaseClient.ComputerVisionFailure(
        statusCode: error.status
      )
    }
  }
}
