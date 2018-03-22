//
//  MainViewController.swift
//  GettyImagesTest
//
//  Created by Mac on 3/21/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {
    
    var mainView:MainView!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupLayout()
        self.mainView.searchBarDidEndEditing = { (text) in  self.downloadGettyDataWith(phrase: text) }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if PersistentStorage.sharedStorage.token == nil{
            self.registerUser()
        }else{
            if let expiresDate = PersistentStorage.sharedStorage.tokenExpires{
                guard Date() < expiresDate else{
                    self.registerUser()
                    return
                }
            }
        }
    }
    
    private func setupLayout(){
        self.view.backgroundColor = UIColor.white
        self.mainView = MainView()
        self.view.addSubview(self.mainView)
        
        // setup mainViews contraints
        self.mainView.translatesAutoresizingMaskIntoConstraints = false
        self.mainView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor, constant: 0).isActive = true
        self.mainView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor, constant: 0).isActive = true
        self.mainView.widthAnchor.constraint(equalTo: self.view.widthAnchor, constant: 0).isActive = true
        self.mainView.heightAnchor.constraint(equalTo: self.view.heightAnchor, constant: 0).isActive = true
    }
    
    private func downloadGettyDataWith(phrase:String){
        guard phrase.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false else { return }
        self.mainView.displayActivityIndicator()
        
        NetworkManager.sharedManager.downloadGettyData(phrase: phrase) { (data, error) in
            self.mainView.hideActivityIndicator()
            
            if error != nil{
                switch error!{
                case .dataNotFound:
                    self.displayImageNotFoundAlert(phrase: phrase)
                    break
                case .unknown:
                    self.displayUnknownErrorAlert()
                    break
                }
                return
            }

            // download and save image to disk
            let imgData = try? Data(contentsOf: URL.init(string: data![0].imageUri)!, options: [])
            guard imgData != nil else { self.displayImageNotFoundAlert(phrase: phrase); return }
            
            if let img = UIImage(data: imgData!){
                let gettyData = data![0]
                PersistentStorage.sharedStorage.saveGettyData(data: gettyData, image: img, complition: { success in
                    guard success == true else { return }
                    self.mainView.updateTableView()
                })
            }else{
                self.displayImageNotFoundAlert(phrase: phrase)
                return
            }
        }
    }
    
    private func displayUnknownErrorAlert(){
        let unknownErrorAlert = UIAlertController(title: "Oops...",
                                                  message: "Uknown error has appeared",
                                                  preferredStyle: .alert)
        let okOption = UIAlertAction(title: "Ok",
                                     style: .default,
                                     handler: nil)
        
        unknownErrorAlert.addAction(okOption)
        DispatchQueue.main.async {
            self.present(unknownErrorAlert, animated: true, completion: nil)
        }
    }
    
    private func displayImageNotFoundAlert(phrase:String){
        let imgNotFoundAlert = UIAlertController(title: ":(",
                                                 message: "Search result for \"\(phrase)\" key is empty",
                                                 preferredStyle: .alert)
        let okOption = UIAlertAction(title: "Ok",
                                     style: .default,
                                     handler: nil)
        
        imgNotFoundAlert.addAction(okOption)
        DispatchQueue.main.async {
            self.present(imgNotFoundAlert, animated: true, completion: nil)
        }
    }

    private func registerUser(){
        NetworkManager.sharedManager.registerUser(result: { (tokenResult, error) in
            if error != nil{
                self.displayUnknownErrorAlert()
                return
            }
            PersistentStorage.sharedStorage.token = tokenResult?.token
            PersistentStorage.sharedStorage.tokenExpires = Date().addingTimeInterval(TimeInterval(tokenResult!.expires))
        })
    }
    
}





































