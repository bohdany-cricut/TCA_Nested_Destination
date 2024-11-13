import ComposableArchitecture
import SwiftUI

@main
struct TCA_Nested_DestinationsApp: App {
    var body: some Scene {
        WindowGroup {
            ParentFeatureView(store: Store(initialState: ParentFeature.State(), reducer: ParentFeature.init))
        }
    }
}
