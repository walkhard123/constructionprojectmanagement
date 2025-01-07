import SwiftUI

struct SettingsView: View {
    @StateObject private var settingsManager = SettingsManager()
    @State private var showingResetAlert = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Notifications")) {
                    Toggle("Enable Notifications", isOn: Binding(
                        get: { settingsManager.settings.notificationsEnabled },
                        set: { newValue in
                            var updatedSettings = settingsManager.settings
                            updatedSettings.notificationsEnabled = newValue
                            settingsManager.updateSettings(updatedSettings)
                        }
                    ))
                    
                    DatePicker(
                        "Daily Reminder Time",
                        selection: Binding(
                            get: { settingsManager.settings.reminderTime },
                            set: { newValue in
                                var updatedSettings = settingsManager.settings
                                updatedSettings.reminderTime = newValue
                                settingsManager.updateSettings(updatedSettings)
                            }
                        ),
                        displayedComponents: .hourAndMinute
                    )
                }
                
                Section(header: Text("Project View")) {
                    Picker("Default View", selection: Binding(
                        get: { settingsManager.settings.defaultProjectView },
                        set: { newValue in
                            var updatedSettings = settingsManager.settings
                            updatedSettings.defaultProjectView = newValue
                            settingsManager.updateSettings(updatedSettings)
                        }
                    )) {
                        Text("List").tag(AppSettings.ProjectViewType.list)
                        Text("Grid").tag(AppSettings.ProjectViewType.grid)
                        Text("Timeline").tag(AppSettings.ProjectViewType.timeline)
                    }
                }
                
                Section(header: Text("Task Management")) {
                    Toggle("Auto-check Overdue Tasks", isOn: Binding(
                        get: { settingsManager.settings.autoCheckOverdueTasks },
                        set: { newValue in
                            var updatedSettings = settingsManager.settings
                            updatedSettings.autoCheckOverdueTasks = newValue
                            settingsManager.updateSettings(updatedSettings)
                        }
                    ))
                }
                
                Section {
                    Button("Reset to Defaults", role: .destructive) {
                        showingResetAlert = true
                    }
                }
            }
            .navigationTitle("Settings")
            .alert("Reset Settings", isPresented: $showingResetAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Reset", role: .destructive) {
                    settingsManager.updateSettings(.default)
                }
            } message: {
                Text("Are you sure you want to reset all settings to their default values?")
            }
        }
    }
} 