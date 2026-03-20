import SwiftUI

struct WidgetCard: ViewModifier {
    var opacity: Double = AppSettings.shared.widgetOpacity

    func body(content: Content) -> some View {
        content
            .padding(16)
            .background(.ultraThinMaterial.opacity(opacity))
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.white.opacity(0.15), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.3), radius: 10, y: 5)
    }
}

extension View {
    func widgetCard(opacity: Double = AppSettings.shared.widgetOpacity) -> some View {
        modifier(WidgetCard(opacity: opacity))
    }
}
