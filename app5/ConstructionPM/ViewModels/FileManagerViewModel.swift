import SwiftUI
import SwiftyDropbox

class FileManagerViewModel: ObservableObject {
    @Published private(set) var isAuthenticated = false
    @Published private(set) var files: [DropboxFile] = []
    
    private var dropboxClient: DropboxClient? {
        if let client = DropboxClientsManager.authorizedClient {
            return client
        }
        return nil
    }
    
    func authenticate() {
        DropboxClientsManager.authorizeFromControllerV2(
            UIApplication.shared,
            controller: nil,
            loadingStatusDelegate: nil,
            openURL: { url in
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            },
            scopeRequest: ScopeRequest(scopeType: .user, scopes: ["files.content.read", "files.content.write"], includeGrantedScopes: false)
        )
    }
    
    func handleAuth(url: URL) {
        DropboxClientsManager.handleRedirectURL(url, includeBackgroundClient: true) { result in
            switch result {
            case .success:
                DispatchQueue.main.async {
                    self.isAuthenticated = true
                    self.fetchFiles()
                }
            case .error(_, let error):
                print("Auth error: \(String(describing: error))")
            case .none:
                print("Authentication cancelled")
            case .some(.cancel):
                print("User cancelled authentication")
            }
        }
    }
    
    func fetchFiles() {
        guard let client = dropboxClient else { return }
        
        client.files.listFolder(path: "").response { response, error in
            if let result = response {
                DispatchQueue.main.async {
                    self.files = result.entries.compactMap { entry in
                        guard let metadata = entry as? Files.FileMetadata,
                              let path = metadata.pathLower else { return nil }
                        
                        return DropboxFile(
                            id: path,
                            name: metadata.name,
                            path: path,
                            modifiedDate: metadata.clientModified
                        )
                    }
                }
            } else if let error = error {
                print("Fetch error: \(error)")
            }
        }
    }
    
    func uploadFile(_ url: URL) {
        guard let client = dropboxClient,
              let data = try? Data(contentsOf: url) else { return }
        
        let filename = url.lastPathComponent
        
        client.files.upload(path: "/\(filename)", input: data).response { response, error in
            if error == nil {
                DispatchQueue.main.async {
                    self.fetchFiles()
                }
            } else if let error = error {
                print("Upload error: \(error)")
            }
        }
    }
} 
