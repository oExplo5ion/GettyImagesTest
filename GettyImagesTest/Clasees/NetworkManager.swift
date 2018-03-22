//
//  NetworkManager.swift
//  GettyImagesTest
//
//  Created by Mac on 3/21/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import Foundation

public class NetworkManager{
    
    enum NetworkError:Error{
        case dataNotFound
        case unknown
    }
    
    public static let sharedManager = NetworkManager()
    
    private let session = URLSession.init(configuration: URLSessionConfiguration.default)
    
    private let tokenUrl = URL.init(string: "https://api.gettyimages.com/oauth2/token")
    private let apiKey = "z999bvny4sv2uzd6eaqyjkdn"
    private let clientSecret = "bv7jp24UDHhE2uqVu39Cgu6YYhPSNjDgE7z3gbJG2Zpg2"
    
    private init(){}
    
    func registerUser(result: @escaping ((token:String, expires:Int)?, _ error:NetworkError?) -> Void){

            let post = "client_id=\(apiKey)&client_secret=\(clientSecret)&grant_type=client_credentials"
            let urlRequest:URLRequest = {
                var urlrequest = URLRequest(url: tokenUrl!)
                urlrequest.httpMethod = "POST"
                urlrequest.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
                urlrequest.httpBody = post.data(using: .utf8)
                return urlrequest
            }()

            let dataTask = NetworkManager.sharedManager.session.dataTask(with: urlRequest, completionHandler: { (data, responce, error) in
                if error != nil{
                    return result(nil, .unknown)
                }

                if data != nil{
                    do{
                        if let responceJson = try JSONSerialization.jsonObject(with: data!, options: []) as? [String:Any]{
                            if let token = responceJson["access_token"] as? String{
                                let tokenExpires = responceJson["expires_in"] as? String ?? "0"
                                result((token, Int(tokenExpires)!), nil)
                            }
                        }
                    }catch{}
                }else{
                    result(nil, .unknown)
                }

            })
            dataTask.resume()
        
    }
    
    func downloadGettyData(phrase:String, result: @escaping (_ data: [GettyData]?, _ error:NetworkError?) -> Void){
        
        let trimmedPhrase = phrase.trimmingCharacters(in: .whitespacesAndNewlines)
        let escapedPhrase = trimmedPhrase.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
        
        let url = "https://api.gettyimages.com/v3/search/images?ﬁelds=id,title,thumb&sort_order=best&phrase=\(escapedPhrase!)"
        let escapedUrl = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        let downloadUrl = URL(string: escapedUrl!)
        guard downloadUrl != nil else { return result(nil, .unknown) }
        
        let urlRequest:URLRequest = {
            var urlrequest = URLRequest(url: downloadUrl!)
            urlrequest.httpMethod = "GET"
            urlrequest.allHTTPHeaderFields = [
                "Authorization":PersistentStorage.sharedStorage.token!,
                "Api-Key":apiKey,
                "Accept":"application/json"]
            return urlrequest
        }()
        
        let task = NetworkManager.sharedManager.session.dataTask(with: urlRequest) { (data, responce, error) in
            if error != nil{
                return result(nil, .unknown)
            }
            
            if data != nil{
                
                do{
                if let responceJson = try JSONSerialization.jsonObject(with: data!, options: []) as? [String:Any]{
                    let images = responceJson["images"] as? Array<[String:Any]>
                    guard images != nil else { return result(nil, .dataNotFound) }
                    guard images!.count >= 1 else { return result(nil, .dataNotFound) }
                    
                    var returnData = [GettyData]()
                    for img in images!{
                        let collectionID = img["collection_id"] as? Int ?? 0
                        let displaySizes = img["display_sizes"] as? Array<[String:Any]>
                        let imgData = displaySizes![0]
                        let uri = imgData["uri"] as? String ?? ""
                        
                        let data = GettyData()
                        data.collectionID = String(collectionID)
                        data.imageUri = uri
                        data.phrase = phrase
                        returnData.append(data)
                    }
                    result(returnData, nil)
                }
                }catch{}
                
            }else{
                return result(nil, .unknown)
            }
        }
        task.resume()
        
    }
    
}


























