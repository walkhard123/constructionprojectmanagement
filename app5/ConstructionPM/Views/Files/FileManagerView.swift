import SwiftUI
import SwiftyDropbox

struct FileManagerView: View {
    @StateObject private var viewModel = FileManagerViewModel()
    @State private var showingDropboxAuth = false
    @State private var showingDocumentPicker = false
    
    var body: some View {
        VStack {
            if viewModel.isAuthenticated {
                // File List
                List {
                    ForEach(viewModel.files) { file in
                        FileRow(file: file)
                    }
                }
                
                // Upload Button
                Button(action: { showingDocumentPicker = true }) {
                    Label("Upload File", systemImage: "arrow.up.doc")
                }
                .padding()
            } else {
                // Connect to Dropbox Button
                Button(action: { showingDropboxAuth = true }) {
                    HStack {
                        Image(systemName: "link")
                        Text("Connect to Dropbox")
                    }
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
            }
        }
        .navigationTitle("Files")
        .sheet(isPresented: $showingDropboxAuth) {
            DropboxAuthView(viewModel: viewModel)
        }
        .sheet(isPresented: $showingDocumentPicker) {
            DocumentPicker(viewModel: viewModel)
        }
    }
}

struct FileRow: View {
    let file: DropboxFile
    
    var body: some View {
        HStack {
            Image(systemName: file.icon)
                .foregroundColor(.blue)
            VStack(alignment: .leading) {
                Text(file.name)
                Text(file.modifiedDate.formatted())
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
            Button(action: { }) {
                Image(systemName: "arrow.down.circle")
            }
        }
        .padding(.vertical, 4)
    }
} 