import ComposableArchitecture
import SwiftUI

@main
struct Counter_TCAApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView(store: .init(initialState: CounterFeature.State()) {
                CounterFeature() // Reducer
            })
        }
    }
}
