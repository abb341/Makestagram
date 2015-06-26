//
//  Post.swift
//  Makestagram
//
//  Created by Aaron Brown on 6/26/15.
//  Copyright (c) 2015 Make School. All rights reserved.
//

import Foundation
import Parse

//To create a custom Parse class you need to inherit from PFObject and implement the PFSubclassing protocol
class Post : PFObject, PFSubclassing {
    
    //Next, define each property that you want to access on this Parse class. For our Post class that's the user and the imageFile of a post. That will allow you to change the code that accesses properties through strings: post["imageFile"] = imageFile Into code that uses Swift properties: post.imageFile = imageFile
    @NSManaged var imageFile: PFFile?
    @NSManaged var user: PFUser?
    var image: UIImage?
    var photoUploadTask:UIBackgroundTaskIdentifier?
    
    //MARK: PFSubclassing Protocol
    
    //By implementing the parseClassName you create a connection between the Parse class and your Swift class.
    static func parseClassName() -> String {
        return "Post"
    }
    
    //init and initialize are pure boilerplate code - copy these two into any custom Parse class that you're creating.
    override init () {
        super.init()
    }
    
    override class func initialize() {
        var onceToken: dispatch_once_t = 0;
        dispatch_once(&onceToken) {
            // inform Parse about this subclass
            self.registerSubclass()
        }
    }
    
    func uploadPost() {
        // 1 Whenever the uploadPost method is called, we grab the photo that shall be uploaded from the image property; turn it into a PFFile and upload it.
        let imageData = UIImageJPEGRepresentation(image, 0.8)
        let imageFile = PFFile(data: imageData)
        
        photoUploadTask = UIApplication.sharedApplication().beginBackgroundTaskWithExpirationHandler { () -> Void in
            UIApplication.sharedApplication().endBackgroundTask(self.photoUploadTask!)
        }
        
        imageFile.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
            UIApplication.sharedApplication().endBackgroundTask(self.photoUploadTask!)
        }
        
        // 2 Once we have saved the imageFile we assign it to self (which is the Post that's being uploaded). Then we call save() to store the Post. Also any uploaded post should be associated with the current user
        user = PFUser.currentUser()
        self.imageFile = imageFile
        saveInBackgroundWithBlock(nil)
    }
}
