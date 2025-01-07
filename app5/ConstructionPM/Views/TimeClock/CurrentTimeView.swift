import SwiftUI

struct CurrentTimeView: View {
    @State private var currentTime = Date()
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        VStack(spacing: 8) {
            Text(currentTime.formatted(date: .complete, time: .omitted))
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text(currentTime.formatted(date: .omitted, time: .standard))
                .font(.system(size: 48, weight: .bold))
        }
        .onReceive(timer) { time in
            currentTime = time
        }
    }
}

#Preview {
    CurrentTimeView()
        .padding()
} 