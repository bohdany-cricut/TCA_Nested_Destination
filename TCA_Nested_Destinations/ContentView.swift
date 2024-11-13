import ComposableArchitecture
import Foundation
import SwiftUI

@Reducer
struct ParentFeature {
@Reducer
struct Destination {
    @Reducer
    enum Navigation {
        case firstFeature(FirstFeature)
        case secondFeature(SecondFeature)
    }
    @Reducer
    enum Fullscreen {
        case firstFeature(FirstFeature)
        case secondFeature(SecondFeature)
    }
    enum State {
        case navigation(Navigation.State)
        case fullscreen(Fullscreen.State)
    }
    enum Action {
        case navigation(Navigation.Action)
        case fullscreen(Fullscreen.Action)
    }
    var body: some ReducerOf<Self> {
        Scope(state: \.navigation.firstFeature, action: \.navigation.firstFeature) {
            FirstFeature()
        }
        Scope(state: \.navigation.secondFeature, action: \.navigation.secondFeature) {
            SecondFeature()
        }
        Scope(state: \.fullscreen.firstFeature, action: \.fullscreen.firstFeature) {
            FirstFeature()
        }
        Scope(state: \.fullscreen.secondFeature, action: \.fullscreen.secondFeature) {
            SecondFeature()
        }
    }
}
    struct State {
        @PresentationState var destination: Destination.State?
    }
    enum Action {
        case onFullscreenFirstFeatureButtonTap
        case onNavigateFirstFeatureButtonTap
        case onNavigateSecondFeatureButtonTap
        case destination(PresentationAction<Destination.Action>)
    }

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onFullscreenFirstFeatureButtonTap:
                state.destination = .fullscreen(.firstFeature(FirstFeature.State()))
                return .none

            case .onNavigateFirstFeatureButtonTap:
                state.destination = .navigation(.firstFeature(FirstFeature.State()))
                return .none

            case .onNavigateSecondFeatureButtonTap:
                state.destination = .navigation(.secondFeature(SecondFeature.State(count: 10)))
                return .none

            case .destination(.presented(.fullscreen(.firstFeature(.onGoToSecondTap)))):
                state.destination = .fullscreen(.secondFeature(SecondFeature.State(count: 1)))
                print("### set second")
                return .none

            case .destination(.dismiss):
                print("### dismiss destination")
                return .none

            case .destination:
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination) {
            Destination()
        }
    }
}

struct ParentFeatureView: View {
    let store: StoreOf<ParentFeature>

    var body: some View {
        NavigationStack {
            VStack {
                Button {
                    store.send(.onFullscreenFirstFeatureButtonTap)
                } label: {
                    Text("Fullscreen first feature")
                }
                Button {
                    store.send(.onNavigateFirstFeatureButtonTap)
                } label: {
                    Text("Navigate to first feature")
                }
                Button {
                    store.send(.onNavigateSecondFeatureButtonTap)
                } label: {
                    Text("Navigate to second feature")
                }
            }
            .navigationDestination(store: store.scope(
                state: \.$destination.navigation,
                action: \.destination.navigation
            )) { store in
                switch store.case {
                case .firstFeature(let firstStore):
                    FirstFeatureView(store: firstStore)

                case .secondFeature(let secondStore):
                    SecondFeatureView(store: secondStore)
                }
            }
            .fullScreenCover(store: store.scope(
                state: \.$destination.fullscreen,
                action: \.destination.fullscreen
            )) { store in
                switch store.case {
                case .firstFeature(let firstStore):
                    FirstFeatureView(store: firstStore)

                case .secondFeature(let secondStore):
                    SecondFeatureView(store: secondStore)
                }
            }
        }
    }
}

#Preview {
    ParentFeatureView(store: .init(initialState: ParentFeature.State(), reducer: ParentFeature.init))
}

@Reducer
struct FirstFeature {
    struct State {

    }
    enum Action {
        case onGoToSecondTap
    }

    @Dependency(\.dismiss) var dismiss

    func reduce(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .onGoToSecondTap:
            return .run { _ in
                await dismiss()
                print("### dismiss first")
            }
        }
    }
}

struct FirstFeatureView: View {
    let store: StoreOf<FirstFeature>

    var body: some View {
        VStack {
            Text("First Feature")
                .font(.headline)
            Button {
                store.send(.onGoToSecondTap)
            } label: {
                Text("Go to second")
            }
        }
    }
}


@Reducer
struct SecondFeature {
    struct State: Equatable {
        var count: Int
    }
    enum Action {
        case onExitButtonTap
    }

    @Dependency(\.dismiss) var dismiss

    func reduce(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .onExitButtonTap:
            return .run { _ in
                await dismiss()
                print("### dismiss second")
            }
        }
    }
}

struct SecondFeatureView: View {
    let store: StoreOf<SecondFeature>

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            Text("Second Feature")
                .font(.headline)
            Text("\(viewStore.count)")
            Button {
                store.send(.onExitButtonTap)
            } label: {
                Text("Exit")
            }
        }
    }
}
