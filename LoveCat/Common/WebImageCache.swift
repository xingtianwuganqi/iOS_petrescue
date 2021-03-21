//
//  WebImageCache.swift
//  LoveCat
//
//  Created by jingjun on 2020/12/28.
//

import Foundation


extension UITableView: ETExtensionCompatible {}
extension UICollectionView: ETExtensionCompatible{}

extension ET where Base: UITableView {
    
    func reloadDataWith(imageUrl: String) {
        let reloadState = WebImageSizeCache.shard.reloadStateFromCache(for: imageUrl)
        if !reloadState {
            base.reloadData()
            WebImageSizeCache.shard.cacheReloadState(true, for: imageUrl, completion: nil)
        }
    }
    
    func reloadDataWith(imageUrl: String, atIndexPaths indexPaths: [IndexPath], rowAnimation: UITableView.RowAnimation) {
        let reloadState = WebImageSizeCache.shard.reloadStateFromCache(for: imageUrl)
        if !reloadState {
            base.reloadRows(at: indexPaths, with: rowAnimation)
            WebImageSizeCache.shard.cacheReloadState(true, for: imageUrl, completion: nil)
        }
    }
}

extension ET where Base: UICollectionView {
    func reloadDataWith(imageUrl: String) {
        let reloadState = WebImageSizeCache.shard.reloadStateFromCache(for: imageUrl)
        if !reloadState {
            base.reloadData()
            WebImageSizeCache.shard.cacheReloadState(true, for: imageUrl, completion: nil)
        }
    }
    
    func reloadDataWith(imageUrl: String, atIndexPaths indexPaths: [IndexPath], rowAnimation: UITableView.RowAnimation) {
        let reloadState = WebImageSizeCache.shard.reloadStateFromCache(for: imageUrl)
        if !reloadState {
            base.reloadItems(at: indexPaths)
            WebImageSizeCache.shard.cacheReloadState(true, for: imageUrl, completion: nil)
        }
    }
}

final class WebImageSizeCache {
    
    static let shard = WebImageSizeCache()
    
    fileprivate lazy var memCache = NSCache<AnyObject, AnyObject>()
    fileprivate lazy var fileManager = FileManager()
    
    private init() {
        
    }
    
    /**
     *  缓存图片的真实尺寸到内存和磁盘中
     *
     *  @param image 缓存尺寸的图片
     *  @param key   唯一的imageSize缓存键，通常是图像绝对URL
     *  @param completion An block that should be executed after the imageSize has been saved (optional)
     */
    func cacheImageSizeBy(image: UIImage, for key: String, completion: ((_ isSuccess: Bool) -> Void)?) {
        DispatchQueue.global(qos: .default).async {
            let isSuccess = self.cacheImageSizeBy(image: image, for: key)
            DispatchQueue.main.async {
                if let completion = completion {
                    completion(isSuccess)
                }
            }
        }
    }
    
    private func cacheImageSizeBy(image: UIImage, for key: String) -> Bool {
        
        let imgSize = image.size
        let sizeDict = ["width": imgSize.width, "height": imgSize.height]
        if let data = self.dataBy(dict: sizeDict) {
            let keyName = "sizeKeyName:\(key)".et.md5String
            self.memCache.setObject(data as AnyObject, forKey: keyName as AnyObject)
            return self.fileManager.createFile(atPath: imageSizeCachePathFor(key: keyName), contents: data, attributes: nil)
        }
        return false
    }
    
    /**
     *  查找缓存中存储的图片尺寸，先从内存中查找，内存中没有时从磁盘读取
     *
     *  @param key  用于存储所需图像大小的唯一键
     *
     *  @return imageSize 图片的尺寸
     */
    func imageSizeFromCacheFor(key: String) -> CGSize {
        let keyName = "sizeKeyName:\(key)".et.md5String
        var data = dataFromMemCacheFor(key: keyName)
        if data == nil {
            data = dataFromDiskCacheFor(key: keyName, isSizeCache: true)
        }
        if let data = data {
            let sizeDict = dictBy(data: data)
            let width = sizeDict?["width"] as? CGFloat ?? 0.0
            let height = sizeDict?["height"] as? CGFloat ?? 0.0
            return CGSize(width: width, height: height)
        }
        return .zero
    }
    
    /**
     *  将刷新状态存储到给定key的内存和磁盘缓存中
     *
     *  @param state 刷新视图的状态
     *  @param key   用于存储所需图像大小的唯一键
     *  @param completion An block that should be executed after the reloadState has been saved (optional)
     */
    fileprivate func cacheReloadState(_ state: Bool, for key: String, completion: ((_ isSuccess: Bool) -> Void)?) {
        
        DispatchQueue.global(qos: .default).async {
            let isSuccess = self.cacheReloadState(state, for: key)
            DispatchQueue.main.async {
                if let completion = completion {
                    completion(isSuccess)
                }
            }
        }
    }
    private func cacheReloadState(_ state: Bool, for key: String) -> Bool {
        
        let stateDict = ["reloadSate": state]
        guard let data = dataBy(dict: stateDict) else {
            return false
        }
        let keyName = "reloadKeyName:\(key)".et.md5String
        self.memCache.setObject(data as NSData, forKey: keyName as NSString)
        return self.fileManager.createFile(atPath: imageSizeCachePathFor(key: keyName), contents: data, attributes: nil)
    }
    
    /**
     *  从缓存中查找当前key的刷新状态
     *
     *  @param key The unique key used to store the wanted reloadState
     *
     *  @return reloadState
     */
    func reloadStateFromCache(for key: String) -> Bool {
        let keyName = "reloadKeyName:\(key)".et.md5String
        var data = dataFromMemCacheFor(key: keyName)
        if data == nil {
            data = dataFromDiskCacheFor(key: keyName, isSizeCache: false)
        }
        if let data = data, let reloadDict = dictBy(data: data)  {
            if let state = reloadDict["reloadSate"] as? Int, state == 1 {
                return true
            }
        }
        
        return false
    }
    
    private func dataFromMemCacheFor(key: String) -> Data? {
        return self.memCache.object(forKey: key as NSString) as? Data
    }
    
    private func dataFromDiskCacheFor(key: String, isSizeCache: Bool = false) -> Data? {
        var path: String!
        if isSizeCache == true {
            path = imageSizeCachePathFor(key: key)
        }
        else {
            path = reloadCachePathFor(key: key)
        }
        if self.fileManager.fileExists(atPath: path, isDirectory: nil) == true {
            return self.fileManager.contents(atPath: path)
        }
        return nil
    }
    
    
    ///  获取图片在布局中的缩放高度
    ///  @param: url 图片URL
    ///  @param: layoutWidth imageView 宽度
    ///  @param: estimateHeight 预估高度,(此高度仅在图片尚未加载出来前起作用,不影响真实高度)
    func imageHeightBy(url: String, layoutWidth: CGFloat, estimateHeight: CGFloat = 200.0) -> CGFloat {
        var showHeight = estimateHeight
        if url.count == 0 || layoutWidth <= 0.01 {
            return showHeight
        }
        let size = imageSizeFromCacheFor(key: url)
        let imgWidth = size.width
        let imgHeight = size.height
        if imgWidth > 0 && imgHeight > 0 {
            showHeight = layoutWidth / imgWidth * imgHeight
        }
        return showHeight
    }
}

extension WebImageSizeCache {
    fileprivate func imageSizeCachePathFor(key: String) -> String {
        cachePathFor(key: key, atPath: sizeCacheDirectory())
    }
    
    fileprivate func sizeCacheDirectory() -> String {
        var path = baseCacheDirectory()
        if path.hasSuffix("/") == false {
            path += "/"
        }
        path += "SizeCache"
        return path
    }
    
    fileprivate func baseCacheDirectory() -> String {
        var pathOfLibrary = NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true).first!
        if pathOfLibrary.hasSuffix("/") == false {
            pathOfLibrary += "/"
        }
        pathOfLibrary += "RTWebImageSizeCache"
        return pathOfLibrary
    }
    
    fileprivate func reloadCacheDirectory() -> String {
        var path = baseCacheDirectory()
        if path.hasSuffix("/") == false {
            path += "/"
        }
        path += "ReloadCache"
        return path
    }
    
    fileprivate func reloadCachePathFor(key: String) -> String {
        cachePathFor(key: key, atPath: reloadCacheDirectory())
    }
    
    fileprivate func cachePathFor(key: String, atPath path: String) -> String {
        checkDirectory(path: path)
        var newPath = path
        if newPath.hasSuffix("/") == false {
            newPath += "/"
        }
        newPath += key
        return newPath
    }
    
    fileprivate func createBaseDirectory(atPath path: String) {
        do {
            try self.fileManager.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
            // 此路径不做备份
            if var url = URL(string: path) {
                var resources: URLResourceValues = URLResourceValues()
                resources.isExcludedFromBackup = true
                try url.setResourceValues(resources)
            }
        } catch {
            printLog("create cache directory failed")
        }
    }
    
    fileprivate func checkDirectory(path: String) {
        var isDirectory = ObjCBool(false)
        if self.fileManager.fileExists(atPath: path, isDirectory: &isDirectory) == false {
            createBaseDirectory(atPath: path)
        }
        if isDirectory.boolValue == false {
            do {
                try self.fileManager.removeItem(atPath: path)
                createBaseDirectory(atPath: path)
            } catch {
                
            }
        }
    }
    
    fileprivate func dataBy(dict: [String: Any]) -> Data? {
        do {
            let data = try JSONSerialization.data(withJSONObject: dict, options: [.prettyPrinted])
            return data
        } catch let error {
            printLog(error.localizedDescription)
        }
        return nil
    }
    
    fileprivate func dictBy(data: Data) -> [String: Any]? {
        do {
            let dict = try JSONSerialization.jsonObject(with: data, options: [.mutableContainers]) as? [String: Any]
            return dict
        } catch let error {
            printLog(error.localizedDescription)
        }
        return nil
    }
}
