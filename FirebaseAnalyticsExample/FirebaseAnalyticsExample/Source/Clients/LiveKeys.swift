import ComposableArchitecture

// MARK: - ComputerVision

extension ComputerVisionClient {
  static var liveValue: ComputerVisionClient {
    let log = Loggers.computerVisionClient
    let events = Channel<DelegateEvent>()
    
    return ComputerVisionClient(
      delegate: {
        Task {
          while !Task.isCancelled {
            let event = DelegateEvent.newHittingMetric(.random())
            events.send(event)
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

