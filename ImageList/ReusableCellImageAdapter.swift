import UIKit

final class ImageAdapter {
    var latestTaskId: String = ""
    var latestTask: URLSessionDataTask?
    
    private static let sessionConfiguration: URLSessionConfiguration = {
        let configuration = URLSessionConfiguration.default
       
        configuration.requestCachePolicy = .reloadIgnoringCacheData
       
        return configuration
    }()
    
    private static let session: URLSession = {
        let session =  URLSession(configuration: sessionConfiguration)
        return session
    }()
    
    static func cancelAllTasks() {
        session.invalidateAndCancel()
    }
    
   
    func configure(from imgPath: String,vc: UIViewController, completionHandler: @escaping ((UIImage?) -> ()) ) {
        guard let url = URL(string: imgPath) else { return }
       
        latestTaskId = UUID().uuidString
        let checkTaskId = latestTaskId
        
       
        (latestTask != nil) ? latestTask?.cancel() : ()

     
        latestTask = Self.session.dataTask(with: url) { (data, response, error) in
          
            if let err = error {
                DispatchQueue.main.async {
                    if(self.latestTaskId == checkTaskId) {
                        completionHandler(nil)
                    }
                }
                print(err)
                APIs.shared.showAPIResAlert(title: err.localizedDescription, msg: "", vc: vc)
                return
            }
            
           
            DispatchQueue.main.async {
                if let data = data,
                   let image = UIImage(data: data){
                    
                    if(self.latestTaskId == checkTaskId) {
                        completionHandler(image)
                    }
                }
                else {
                    if(self.latestTaskId == checkTaskId) {
                        APIs.shared.showAPIResAlert(title: "Something went wrong", msg: "", vc: vc)
                        completionHandler(nil)
                    }
                }
            }
        }
        latestTask?.resume()
    }
}
