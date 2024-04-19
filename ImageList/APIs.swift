//
//  APIs.swift
//  ImageList
//
//  Created by Chandra Hasan on 17/04/24.
//

import Foundation
import Alamofire

class APIs {
    static let shared = APIs()
    init(){}
    
    var base_url = "https://unsplash.com/"
    var base_url2 = "https://api.unsplash.com/"
    var authToken_url = "oauth/token"
    
    func auth(auth_code: String, vc:UIViewController, _ completionHandler: @escaping (AuthResModel?, Error?) -> ())  {
        let headers = [
            "Content-Type": "application/json"
        ] as HTTPHeaders
        let url = base_url+authToken_url+"?client_id=VaoPX4XWVCGbe2l84tkVkQPwgAcpd3c65r2Vf13isOg&client_secret=Aw1jFKmDp0Z5H9tZ0f7zK7X_ktHzHwq-9sWYIXN7ARo&redirect_uri=urn:ietf:wg:oauth:2.0:oob&code=\(auth_code)&grant_type=authorization_code"
        AF.request(url, method: .post, encoding: JSONEncoding.default, headers: headers).responseDecodable(of: AuthResModel.self) { (response) in
            switch(response.result) {
            case.success(_):
                guard let json = response.value else {
                    return
                }
                completionHandler(json,nil)
            case.failure(_):
                UserDefaults.standard.removeObject(forKey: "access_token")
                UserDefaults.standard.synchronize()
                self.showAPIResAlert(title: response.error!.localizedDescription, msg: "", vc: vc)
                completionHandler(nil,response.error)
            }
        }
    }
    
    func getImages(pageNum: Int, vc:UIViewController, _ completionHandler: @escaping (NSMutableArray, Error?) -> ())  {
        let access_token = UserDefaults.standard.value(forKey: "access_token") as! String
        let headers = [
            "Content-Type": "application/json",
            "Authorization": "Bearer \(access_token)"
        ] as HTTPHeaders
        
        let url = base_url2+"photos?page=\(pageNum)&per_page=30"
        AF.request(url, method: .get,encoding: JSONEncoding.default, headers: headers).responseString(completionHandler: { response in
            let array = NSMutableArray()
            switch response.result {
            case .success:
                let arr = self.jsonStrToJsonArr(vc: vc, str: response.value!)
                for index in 0..<arr.count {
                    let dict = arr[index] as! NSDictionary
                    let url_dict = dict.value(forKey: "urls") as! NSDictionary
                    array.add(url_dict)
                }
                completionHandler(array,response.error)
            default:
                self.showAPIResAlert(title: response.error!.localizedDescription, msg: "", vc: vc)
                completionHandler(array,response.error)
            }
        })
    }
    
    func jsonStrToJsonArr(vc:UIViewController, str: String)-> NSArray {
        if let data = str.data(using: .utf8) {
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: []) as? NSArray
                return json!
            } catch {
                self.showAPIResAlert(title: error.localizedDescription, msg: "", vc: vc)
            }
        }
        let arr = NSArray()
        return arr
    }
    
    func showAPIResAlert(title: String, msg: String, vc: UIViewController) {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (_) in
        }))
        vc.present(alert, animated: true, completion: {
        })
    }
}
