import Foundation

extension ComputerVisionClient.Response {
  static func random() -> Self {
    Bool.random()
    
    ? .success(Success(
      measurementId: UUID(),
      exitVelocity: .init(value: .random(in: 1..<50), unit: .milesPerHour),
      launchAngle: .init(value: .random(in: 1..<50), unit: .degrees),
      directionAngle: .init(value: .random(in: 1..<50), unit: .degrees),
      distance: .init(value: .random(in: 1..<50), unit: .feet)
    ))
    
    : .failure(Failure(
      status: 0,
      error: "Something went wrong.",
      message: "The cv metrics could not be calculated."
    ))
  }
}
