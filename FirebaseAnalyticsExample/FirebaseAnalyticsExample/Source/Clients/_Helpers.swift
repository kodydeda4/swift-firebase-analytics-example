import Foundation

extension Result
where Success == ComputerVisionClient.HittingOutput,
      Failure == ComputerVisionClient.Failure
{
  
  static func random() -> Self {
    
    if Bool.random() {
      return .success(
        Success(
          measurementId: UUID(),
          exitVelocity: .init(value: .random(in: 1..<50), unit: .milesPerHour),
          launchAngle: .init(value: .random(in: 1..<50), unit: .degrees),
          directionAngle: .init(value: .random(in: 1..<50), unit: .degrees),
          distance: .init(value: .random(in: 1..<50), unit: .feet)
        )
      )
    } else {
      return .failure(Failure(
        status: 0,
        error: "Something went wrong.",
        message: "The cv metrics could not be calculated."
      ))
    }
  }
}
