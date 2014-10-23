//
//  FeedItem.swift
//  ExchangeAGram
//
//  Created by Dave Arnoldi on 2014/10/23.
//  Copyright (c) 2014 Dave Arnoldi. All rights reserved.
//

import Foundation
import CoreData

@objc (FeedItem)

class FeedItem: NSManagedObject {

    @NSManaged var caption: String
    @NSManaged var image: NSData

}
