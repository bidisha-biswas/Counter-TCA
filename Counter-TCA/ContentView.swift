import ComposableArchitecture
import SwiftUI

struct CounterFeature: Reducer {
    struct State: Equatable {
        var count = 0
        var fact: String?
        var isLoading: Bool = false
        var isTimerOn: Bool = false
    }

    // Actions that user can do in this view such as button taps, gestures, etc. It can also include other actions (such as API calls, corelocation updates, etc that can change the State

    enum Action {

        // User Actions
        case decrementButtonTapped
        case incrementButtonTapped
        case toggleTimerButtonTapped
        case getFactButtonTapped

        // Others
        case getFactResponse(String)
    }

    // Reduce takes a closure that is given the current state of the feature as an inout parameter, the action that was sent into the system, and must return what is called an Effect.

    // Return ans instance of the Effect type, which represents a side effect that can be executed out in the real world and feed data back into the system. The most typical examples of this are API requests.

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .decrementButtonTapped:
                state.fact = nil
                state.count -= 1
                return .none

            case .incrementButtonTapped:
                state.fact = nil
                state.count += 1
                return .none

            case .getFactButtonTapped:
                state.fact = nil
                state.isLoading = true

                return .run { [count = state.count] send in
                    try await Task.sleep(for: .seconds(1)) // simulate for loading indicator
                    
                    let url = URL(string: "http://numbersapi.com/\(count)")!
                    let (data, _) = try await URLSession.shared.data(from: url)
                    let fact = String(decoding: data, as: UTF8.self)
                    
                    await send(.getFactResponse(fact))
                }

            case let .getFactResponse(fact):
                state.isLoading = false
                state.fact = fact
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
                    Button {
                        viewStore.send(.getFactButtonTapped)
                    } label: {
                        HStack {
                            Text("Get Fact")
                            if viewStore.isLoading {
                                Spacer()
                                ProgressView()
                            }
                        }
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
    ContentView(store: .init(initialState: CounterFeature.State()) {
        CounterFeature()
        //    ._printChanges() // For Debugging
    })
}
