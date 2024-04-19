//
//  ViewController.swift
//  ImageList
//
//  Created by Chandra Hasan on 17/04/24.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var img_gridView: UICollectionView!
    @IBOutlet weak var loader_activity: UIActivityIndicatorView!
    var img_arr = NSMutableArray()
    var pageNum = 1
    var isDataLoading = false
    let authentication_code = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let gridLayout = GridLayout()
        gridLayout.fixedDivisionCount = 3
        img_gridView.collectionViewLayout = gridLayout
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
       
        if(UserDefaults.standard.value(forKey: "access_token") != nil) {
            getPhotos(pageNum: pageNum)
        } else {
            loader_activity.startAnimating()
            APIs.shared.auth(auth_code: authentication_code, vc: self) { res, error in
                if(res != nil) {
                    if(res?.access_token != nil) {
                        UserDefaults.standard.setValue(res?.access_token, forKey: "access_token")
                        UserDefaults.standard.synchronize()
                        self.getPhotos(pageNum: self.pageNum)
                    } else {
                        APIs.shared.showAPIResAlert(title: "Please check the code and update", msg: "For new code load the given URL. You can find URL in README file.", vc: self)
                    }
                } else {
                   
                }
                self.loader_activity.stopAnimating()
            }
        }
    }
    
    func getPhotos(pageNum: Int) {
        loader_activity.isHidden = false
        loader_activity.startAnimating()
        APIs.shared.getImages(pageNum:pageNum, vc: self) { arr, error in
            if(arr.count > 0) {
                for index in 0..<arr.count {
                    let dict = arr[index] as! NSDictionary
                    let img_url = dict.value(forKey: "regular") as! String
                    let cellAdap = ImageAdapter()
                    cellAdap.configure(from: img_url, vc: self, completionHandler: { img in
                        let imageData:NSData = img!.jpegData(compressionQuality: 1.0)! as NSData
                        let strBase64 = imageData.base64EncodedString(options: .lineLength64Characters)
                        self.img_arr.add(strBase64)
                        self.img_gridView.reloadData()
                    })
                }
                self.isDataLoading = false
            }
            self.loader_activity.stopAnimating()
            self.loader_activity.isHidden = true
        }
    }
    
}

extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        img_arr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageViewCell", for: indexPath as IndexPath) as! ImageViewCell
        let strBase64 = img_arr[indexPath.row] as! String
        
        let dataDecoded : Data = Data(base64Encoded: strBase64, options: .ignoreUnknownCharacters)!
        let decodedimage = UIImage(data: dataDecoded)
        cell.imageView.image = decodedimage
        return cell
    }
    
    
    // Tell delegate when user start scroll
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let offSetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        
        if offSetY > contentHeight - scrollView.frame.height * 1 {
            
            if !isDataLoading{
                isDataLoading = true
                pageNum += 1
                getPhotos(pageNum: pageNum)
            }
        }
    }
}
