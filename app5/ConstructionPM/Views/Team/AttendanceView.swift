import SwiftUI

struct AttendanceView: View {
    @ObservedObject var viewModel: TeamViewModel
    @State private var selectedDate = Date()
    
    var body: some View {
        VStack(spacing: 16) {
            // Current Time Display
            CurrentTimeView()
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .shadow(radius: 1)
            
            // Date Picker
            DatePicker(
                "Select Date",
                selection: $selectedDate,
                displayedComponents: [.date]
            )
            .datePickerStyle(.graphical)
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(radius: 1)
            
            // Attendance List
            List {
                ForEach(viewModel.members.filter { $0.isActive }) { member in
                    AttendanceRow(
                        member: member,
                        attendance: attendanceFor(member),
                        onCheckIn: { viewModel.checkIn(memberId: member.id) },
                        onCheckOut: { viewModel.checkOut(memberId: member.id) }
                    )
                }
            }
        }
        .onChange(of: selectedDate) { oldValue, newValue in
            viewModel.selectedDate = newValue
        }
    }
    
    private func attendanceFor(_ member: TeamMember) -> Attendance? {
        viewModel.attendance.first {
            $0.memberId == member.id &&
            Calendar.current.isDate($0.date, inSameDayAs: selectedDate)
        }
    }
}

struct AttendanceRow: View {
    let member: TeamMember
    let attendance: Attendance?
    let onCheckIn: () -> Void
    let onCheckOut: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(member.name)
                    .font(.headline)
                Spacer()
                AttendanceStatusBadge(status: attendance?.status ?? .absent)
            }
            
            if let attendance = attendance {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Check In: \(attendance.checkInTime.formatted(date: .omitted, time: .shortened))")
                    if let checkOut = attendance.checkOutTime {
                        Text("Check Out: \(checkOut.formatted(date: .omitted, time: .shortened))")
                        Text("Total Hours: \(String(format: "%.1f", attendance.totalHours))")
                            .bold()
                    }
                }
                .font(.subheadline)
                .foregroundColor(.secondary)
            }
            
            HStack {
                Button(action: onCheckIn) {
                    Label("Check In", systemImage: "arrow.forward.circle.fill")
                }
                .disabled(attendance != nil)
                
                Spacer()
                
                Button(action: onCheckOut) {
                    Label("Check Out", systemImage: "arrow.backward.circle.fill")
                }
                .disabled(attendance?.checkOutTime != nil || attendance == nil)
            }
            .buttonStyle(.bordered)
        }
        .padding(.vertical, 4)
    }
}

struct AttendanceStatusBadge: View {
    let status: Attendance.Status
    
    var body: some View {
        Text(status.rawValue)
            .font(.caption)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(backgroundColor)
            .foregroundColor(foregroundColor)
            .cornerRadius(4)
    }
    
    private var backgroundColor: Color {
        switch status {
        case .present: return Color.green.opacity(0.2)
        case .absent: return Color.red.opacity(0.2)
        case .late: return Color.orange.opacity(0.2)
        case .leave: return Color.blue.opacity(0.2)
        }
    }
    
    private var foregroundColor: Color {
        switch status {
        case .present: return .green
        case .absent: return .red
        case .late: return .orange
        case .leave: return .blue
        }
    }
} 