// Copyright © 2020 Pocket Radar. All rights reserved.

import ComposableArchitecture
import CoreMedia
import SwiftUI

// MARK: - Interface

@DependencyClient
struct ComputerVisionClient: DependencyKey {
  var delegate: @Sendable () async -> Channel<DelegateEvent> = { .init() }
  
  @CasePathable
  enum DelegateEvent {
    case newHittingMetric(Response)
  }
}

extension DependencyValues {
  var computerVision: ComputerVisionClient {
    get { self[ComputerVisionClient.self] }
    set { self[ComputerVisionClient.self] = newValue }
  }
}

// MARK: - Types

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

// MARK: - Implementation

extension ComputerVisionClient {
  static var liveValue: ComputerVisionClient {
    let events = Channel<DelegateEvent>()
    
    return ComputerVisionClient(
      delegate: {
        Task {
          while !Task.isCancelled {
            events.send(.newHittingMetric(.random()))
            try? await Task.sleep(for: .seconds(6))
          }
        }
        return events
      }
    )
  }
}

// MARK: Private helpers

fileprivate extension Result
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
