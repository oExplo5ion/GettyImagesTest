//
//  MainView.swift
//  GettyImagesTest
//
//  Created by Mac on 3/21/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit
import RealmSwift

class MainView: UIView {
    
    public var searchBarDidEndEditing:(_ text:String)->Void = {_ in }
    
    private var gettyData:Results<GettyData>?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
//        self.setupLayout()
//
//        self.tableview.delegate = self
//        self.tableview.dataSource = self
//        self.searchBar.delegate = self
        
//        self.appendDataAndReload(data: GettyData.init(image: UIImage.init(named: "cat.jpg"), phrase: "hello"))
        
    }
    
    init(){
        super.init(frame: CGRect())
        self.setupLayout()
        self.tableview.delegate = self
        self.tableview.dataSource = self
        self.searchBar.delegate = self
        self.updateTableView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: UI controls
    let searchBar:UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.returnKeyType = .done
        searchBar.enablesReturnKeyAutomatically = false
        return searchBar
    }()
    
    let tableview:UITableView = {
        let tableview = UITableView()
        tableview.tableFooterView = UIView()
        return tableview
    }()
    
    let acitivityIndicatorView:UIView = {
        let acitivityIndicatorView = UIView()
        acitivityIndicatorView.isHidden = true
        
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.color = UIColor.red
        activityIndicator.startAnimating()
        
        acitivityIndicatorView.addSubview(activityIndicator)
        return acitivityIndicatorView
    }()

    public func addGettyData(data:GettyData){
        DispatchQueue.main.async {
            self.tableview.reloadData()
        }
    }
    
    public func updateTableView(){
        DispatchQueue.main.async {
            self.gettyData = PersistentStorage.sharedStorage.getSearchHistory()
            self.tableview.reloadData()
        }
    }
    
    public func displayActivityIndicator(){
        DispatchQueue.main.async {
            self.acitivityIndicatorView.isHidden = false
        }
    }
    
    public func hideActivityIndicator(){
        DispatchQueue.main.async {
            self.acitivityIndicatorView.isHidden = true
        }
    }
    
    private func setupLayout(){
        self.backgroundColor = UIColor.white
        
        // setup search bar
        self.addSubview(self.searchBar)
        self.searchBar.translatesAutoresizingMaskIntoConstraints = false
        self.searchBar.topAnchor.constraintEqualToSystemSpacingBelow(self.safeAreaLayoutGuide.topAnchor, multiplier: 0).isActive = true
        self.searchBar.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 0).isActive = true
        self.searchBar.rightAnchor.constraint(equalTo: self.rightAnchor, constant: 0).isActive = true
        
        // setup tableview
        self.addSubview(self.tableview)
        self.tableview.translatesAutoresizingMaskIntoConstraints = false
        self.tableview.topAnchor.constraint(equalTo: self.searchBar.bottomAnchor, constant: 0).isActive = true
        self.tableview.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 0).isActive = true
        self.tableview.rightAnchor.constraint(equalTo: self.rightAnchor, constant: 0).isActive = true
        self.tableview.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0).isActive = true
        
        // setup acitivityIndicatorView
        self.addSubview(self.acitivityIndicatorView)
        self.acitivityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        self.acitivityIndicatorView.centerXAnchor.constraint(equalTo: self.centerXAnchor, constant: 0).isActive = true
        self.acitivityIndicatorView.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: 0).isActive = true
        
    }

}

extension MainView: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.gettyData?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = MainTableVieCell(style: .default, reuseIdentifier: "mainCell")
        
        let imgUrl = URL.init(string: self.gettyData![indexPath.row].imageUri)
        DispatchQueue.main.async {
            if let imgData = try? Data.init(contentsOf: imgUrl!){
                if let img = UIImage(data: imgData){
                    cell.iconImageView.image = img
                }
            }
        }
        
        cell.phraseLabel.text = self.gettyData![indexPath.row].phrase
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
    
}

extension MainView:UISearchBarDelegate{
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.searchBarDidEndEditing(searchBar.text!)
        self.searchBar.resignFirstResponder()
    }
}

class MainTableVieCell: UITableViewCell{
    
    var imgUrl:URL?
    
    let iconImageView:UIImageView = {
        let iconImageView = UIImageView()
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.clipsToBounds = true
        iconImageView.layer.cornerRadius = 4
        return iconImageView
    }()
    
    var phraseLabel:UILabel = {
        let phraseLabel = UILabel()
        phraseLabel.textAlignment = .center
        return phraseLabel
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.clipsToBounds = true
        self.setupLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayout(){
        
        // setup iconImageView
        self.addSubview(self.iconImageView)
        self.iconImageView.translatesAutoresizingMaskIntoConstraints = false
        self.iconImageView.topAnchor.constraint(equalTo: self.topAnchor, constant: 8).isActive = true
        self.iconImageView.centerXAnchor.constraint(equalTo: self.centerXAnchor, constant: 0).isActive = true
        self.iconImageView.heightAnchor.constraint(equalToConstant: 150).isActive = true
        self.iconImageView.widthAnchor.constraint(equalToConstant: 150).isActive = true
        
        // setup phraseLabel
        self.addSubview(self.phraseLabel)
        self.phraseLabel.translatesAutoresizingMaskIntoConstraints = false
        self.phraseLabel.topAnchor.constraint(equalTo: self.iconImageView.bottomAnchor, constant: 8).isActive = true
        self.phraseLabel.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8).isActive = true
        self.phraseLabel.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -8).isActive = true
    }
    
}


















