import ComposableArchitecture
import CoreMedia
import SwiftUI

// MARK: - ComputerVision

@DependencyClient
struct ComputerVisionClient: DependencyKey {
  var delegate: @Sendable () async -> Channel<DelegateEvent> = { .init() }
  
  @CasePathable
  enum DelegateEvent: Codable {
    case newHittingMetric(Response)
  }
}

extension DependencyValues {
  var computerVision: ComputerVisionClient {
    get { self[ComputerVisionClient.self] }
    set { self[ComputerVisionClient.self] = newValue }
  }
}

// MARK: - Firebase

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
