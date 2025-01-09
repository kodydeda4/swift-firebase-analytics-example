import ComposableArchitecture
import AsyncAlgorithms

// MARK: - ComputerVision

extension ComputerVisionClient {
  static var liveValue: ComputerVisionClient {
    let log = Loggers.computerVisionClient
    let events = AsyncChannel<DelegateEvent>()
    
    return ComputerVisionClient(
      delegate: {
        Task {
          while !Task.isCancelled {
            let event = DelegateEvent.newHittingMetric(.random())
            await events.send(event)
            log.info("\(prettyPrintDescription(event))")
            try? await Task.sleep(for: .seconds(60))
          }
        }
        return events
      }
    )
  }
}

// MARK: - Firebase

extension FirebaseClient {
  static var liveValue: Self {
    let log = Loggers.firebaseClient
    
    return Self { event in
      log.info("\(prettyPrintDescription(event))")
    }
  }
}

