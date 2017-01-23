//
//  ServerProvider.swift
//  IDTube
//
//  Created by igor on 1/16/17.
//
//

import Alamofire;

let kIDTubeBaseUrlPrefix:String = "youtube/v3/"
let consumerKey = "AIzaSyAC5VbNBAKrEpiTGoZSkQvuqfG1sXzQauE"


protocol ResponseObjectSerializable {
    init?(response: HTTPURLResponse, representation: Any)
}

class ServerProvider {
    class func baseURL() -> URL {
        return URL(string: "https://www.googleapis.com")!
    }
    
    class func url(for path:String) -> URL {
        let fullPath = kIDTubeBaseUrlPrefix.appending(path)
        return URL.init(fileURLWithPath: fullPath, relativeTo: self.baseURL())
    }
    
    class func performRequest<T: ResponseObjectSerializable>(request: URLRequest, type: T.Type, successCompletion:@escaping (_ result: AnyObject?) -> Void, failureCompletion:@escaping (_ error: AnyObject?) -> Void)  {
        
        Alamofire.request(request).responseObject { (response: DataResponse<T>) in
            if let value = response.result.value {
                successCompletion(value as AnyObject?)
            } else {
                failureCompletion(response.result as AnyObject?)
            }
        }
    }

    class func getVideos(page: Int, successCompletion:@escaping (_ result: AnyObject?) -> Void, failureCompletion:@escaping (_ error: AnyObject?) -> Void) {
        let params = ["key": consumerKey,"page": "\(page)", "part":"snippet,contentDetails,statistics,status", "chart":"mostPopular", "maxResults":"50"]
        do {
            let req = try URLEncoding.default.encode(URLRequest(url: ServerProvider.url(for: "/videos")), with: params)
            
            self.performRequest(request: req, type: VideoItems.self, successCompletion: { (result) in
                successCompletion(result)
                debugPrint(result as Any)
            }, failureCompletion: { (error) in
                debugPrint(error as Any)
                failureCompletion(error)
            })
        } catch {
            failureCompletion(error as AnyObject?)
        }
    }
}

enum BackendError: Error {
    case network(error: Error)
    case dataSerialization(error: Error)
    case jsonSerialization(error: Error)
    case xmlSerialization(error: Error)
    case objectSerialization(reason: String)
}

extension DataRequest {
    func responseObject<T: ResponseObjectSerializable>(
        queue: DispatchQueue? = nil,
        completionHandler: @escaping (DataResponse<T>) -> Void) -> Self {
        let responseSerializer = DataResponseSerializer<T> { request, response, data, error in
            guard error == nil else { return .failure(BackendError.network(error: error!)) }
            
            let jsonResponseSerializer = DataRequest.jsonResponseSerializer(options: .allowFragments)
            let result = jsonResponseSerializer.serializeResponse(request, response, data, nil)
            
            guard case let .success(jsonObject) = result else {
                return .failure(BackendError.jsonSerialization(error: result.error!))
            }
            
            guard let response = response, let responseObject = T(response: response, representation: jsonObject) else {
                return .failure(BackendError.objectSerialization(reason: "JSON could not be serialized: \(jsonObject)"))
            }
            
            return .success(responseObject)
        }
        
        return response(queue: queue, responseSerializer: responseSerializer, completionHandler: completionHandler)
    }
}

struct Thumbnail: ResponseObjectSerializable {
    let url: String
    let width: UInt
    let height: UInt
    
    init?(response: HTTPURLResponse, representation: Any) {
        guard let representation = representation as? [String: Any],
            let url = representation["url"] as? String,
            let width = representation["width"] as? UInt,
            let height = representation["height"] as? UInt
            else { return nil }
        self.url = url
        self.width = width
        self.height = height
    }
}

enum ThumbnailKey: String {
    case Default = "default"
    case Medium = "medium"
    case High = "high"
    case Standard = "standard"
    case MaxRes = "maxres"
}

struct Snippet: ResponseObjectSerializable {
    let title: String
    let thumbnails:[ThumbnailKey: Thumbnail]
    let channelTitle: String?
    let channelId: String?
    
    init?(response: HTTPURLResponse, representation: Any) {
        guard let representation = representation as? [String: Any],
            let title = representation["title"] as? String,
            let thumbnailsRepresentation = representation["thumbnails"] as? [String: Any]
            else { return nil }
        self.title = title
        self.channelTitle = representation["channelTitle"] as? String
        self.channelId = representation["channelId"] as? String
        var thumbnails:[ThumbnailKey: Thumbnail] = [:];
        thumbnailsRepresentation.forEach { (thumbnailItem) in
            if let thumbnail = Thumbnail(response: response, representation: thumbnailItem.value), let key = ThumbnailKey(rawValue: thumbnailItem.key) {
                thumbnails[key] = thumbnail
            }
        }
        self.thumbnails = thumbnails;
    }
}

struct VideoItem: ResponseObjectSerializable {
    let id: String
    let snippet: Snippet
    
    init?(response: HTTPURLResponse, representation: Any) {
        guard let representation = representation as? [String: Any],
            let id = representation["id"] as? String,
            let snippetRepresentation = representation["snippet"] as? [String: Any]
            else { return nil }
        self.id = id
        self.snippet = Snippet(response: response, representation: snippetRepresentation)!
    }
}

struct VideoItems: ResponseObjectSerializable {
    let items: [VideoItem]
    
    init?(response: HTTPURLResponse, representation: Any) {
        var collection: [VideoItem] = []
        let representation = representation as? [String: Any]
        if let items = representation?["items"] as? [[String: Any]] {
            for item in items {
                if let videoItem = VideoItem(response: response, representation: item) {
                    collection.append(videoItem)
                }
            }
        }
        self.items = collection;
    }
}
