// Copyright © 2020 Pocket Radar. All rights reserved.

import ComposableArchitecture
import DependenciesMacros

// MARK: - Interface

@DependencyClient
struct FirebaseClient: DependencyKey {
  var log: @Sendable (AnalyticsEvent) -> Void = { _ in }
  
  enum AnalyticsEvent: Codable {
    case computerVisionResponse(ComputerVisionResponse)
  }
}

extension DependencyValues {
  var firebase: FirebaseClient {
    get { self[FirebaseClient.self] }
    set { self[FirebaseClient.self] = newValue }
  }
}

// MARK: - Types

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

// MARK: - Implementation

extension FirebaseClient {
  static var liveValue: Self {
    let log = Loggers.firebaseClient
    
    return Self { event in
      log.info("\(prettyPrintDescription(event))")
    }
  }
}
