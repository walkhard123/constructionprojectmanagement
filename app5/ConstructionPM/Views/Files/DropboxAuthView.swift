import SwiftUI
import SwiftyDropbox

struct DropboxAuthView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: FileManagerViewModel
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "icloud.and.arrow.up")
                .font(.system(size: 60))
                .foregroundColor(.blue)
            
            Text("Connect to Dropbox")
                .font(.title2)
            
            Text("Sign in to your Dropbox account to access and manage your files.")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding()
            
            Button(action: {
                viewModel.authenticate()
                dismiss()
            }) {
                Text("Sign in with Dropbox")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding(.horizontal)
            
            Button("Cancel", role: .cancel) {
                dismiss()
            }
        }
        .padding()
    }
} 