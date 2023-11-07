import ComposableArchitecture
import SwiftUI

struct CounterFeature: Reducer {
    struct State: Equatable {
        var count = 0
        var fact: String?
        var isTimerOn: Bool = false
    }

    // Actions that user can do in this view such as button taps, gestures, etc.
    enum Action {
        case decrementButtonTapped
        case incrementButtonTapped
        case toggleTimerButtonTapped
        case getFactButtonTapped
    }

    // Reduce takes a closure that is given the current state of the feature as an inout parameter, the action that was sent into the system, and must return what is called an Effect.

    // Return ans instance of the Effect type, which represents a side effect that can be executed out in the real world and feed data back into the system. The most typical examples of this are API requests.

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .decrementButtonTapped:
                state.count -= 1
                return .none

            case .incrementButtonTapped:
                state.count += 1
                return .none

            case .getFactButtonTapped:
                return .none

            case .toggleTimerButtonTapped:
                state.isTimerOn.toggle()
                return .none
            }
        }
    }
}

struct ContentView: View {
    let store: StoreOf<CounterFeature>
    // Same as Store<CounterFeature.State, CounterFeature.Action>

    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            Form {
                Section {
                    Text("\(viewStore.count)")
                    Button("Decrement") {
                        viewStore.send(.decrementButtonTapped)
                    }
                    Button("Increment") {
                        viewStore.send(.incrementButtonTapped)
                    }
                }
                Section {
                    Button("Get Fact") {
                        viewStore.send(.getFactButtonTapped)
                    }
                    if let fact = viewStore.fact {
                        Text(fact)
                    }
                }
                Section {
                    if viewStore.isTimerOn {
                        Button("Stop timer") {
                            viewStore.send(.toggleTimerButtonTapped)
                        }
                    }
                    else {
                        Button("Start timer") {
                            viewStore.send(.toggleTimerButtonTapped)
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView(store: .init(initialState: CounterFeature.State(),
                             reducer: {
        CounterFeature()
    }))
}
