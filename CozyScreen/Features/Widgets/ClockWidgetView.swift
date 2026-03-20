import SwiftUI

struct ClockWidgetView: View {
    @State private var now = Date()
    @StateObject private var settings = AppSettings.shared

    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack(spacing: 4) {
            Text(timeString)
                .font(.system(size: 72, weight: .thin, design: .rounded))
                .foregroundColor(.white)
                .monospacedDigit()

            Text(dateString)
                .font(.system(size: 18, weight: .medium, design: .rounded))
                .foregroundColor(.white.opacity(0.7))

            Text(dayOfWeekString)
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(.white.opacity(0.5))
        }
        .onReceive(timer) { _ in
            now = Date()
        }
    }

    private var timeString: String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "ko_KR")
        f.dateFormat = settings.use24HourClock ? "HH:mm" : "h:mm a"
        return f.string(from: now)
    }

    private var dateString: String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "ko_KR")
        f.dateFormat = "yyyy년 M월 d일"
        return f.string(from: now)
    }

    private var dayOfWeekString: String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "ko_KR")
        f.dateFormat = "EEEE"
        return f.string(from: now)
    }
}
