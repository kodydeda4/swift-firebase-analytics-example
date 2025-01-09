import SwiftUI
import ComposableArchitecture

@MainActor
@Observable
final class AppModel {
  var selectedSport: String? = "Baseball"
  var cvComputationTime: TimeInterval = 0
  
  @ObservationIgnored
  @Dependency(\.computerVision) var computerVision
  
  @ObservationIgnored
  @Dependency(\.firebase) var firebase
  
  func task() async {
    await withTaskGroup(of: Void.self) { taskGroup in
      taskGroup.addTask {
        for await event in await self.computerVision.delegate() {
          await self.handle(event: event)
        }
      }
    }
  }
  
  private func handle(event: ComputerVisionClient.DelegateEvent) {
    switch event {
      
    case let .newHittingMetric(response):
      self.handle(response: response)
    }
  }
  
  private func handle(response: ComputerVisionClient.Response) {
    Task {
      try await Task.sleep(for: .seconds(1))
      
      // grayson this is the line you are adding
      self.firebase.log(.computerVisionResponse(FirebaseClient.ComputerVisionResponse(
        response,
        selectedSport,
        cvComputationTime
      )))
    }
  }
}

// MARK: SwiftUI

struct AppView: View {
  @Bindable var model = AppModel()
  
  var body: some View {
    Text("App")
      .task { await self.model.task() }
  }
}

// MARK: SwiftUI Previews

#Preview {
  AppView()
}
