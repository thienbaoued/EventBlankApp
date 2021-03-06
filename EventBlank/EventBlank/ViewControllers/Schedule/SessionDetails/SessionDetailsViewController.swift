//
//  SessionDetailsViewController.swift
//  EventBlank
//
//  Created by Marin Todorov on 6/25/15.
//  Copyright (c) 2015 Underplot ltd. All rights reserved.
//

import UIKit
import SQLite

class SessionDetailsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var session: Row! //set from previous view controller
    var favorites = [Int]()
    
    @IBOutlet weak var tableView: UITableView!
    
    var event: Row {
        return (UIApplication.sharedApplication().delegate as! AppDelegate).event
        }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //load favorites
        favorites = Favorite.allSessionFavoritesIDs()
        
        tableView.estimatedRowHeight = 100.0
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    //MARK: - table view methods
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            //speaker details
            
            let cell = tableView.dequeueReusableCellWithIdentifier("SessionDetailsCell") as! SessionDetailsCell

            //configure the cell
            cell.dateFormatter = shortStyleDateFormatter
            cell.isFavoriteSession = (find(favorites, session[Session.idColumn]) != nil)
            cell.indexPath = indexPath
            cell.mainColor = UIColor(hexString: event[Event.mainColor])
            
            //populate from the session
            cell.populateFromSession(session)
            
            //tap handlers
            if let twitter = session[Speaker.twitter] where count(twitter) > 0 {
                cell.didTapTwitter = {
                    let twitterUrl = NSURL(string: "https://twitter.com/" + twitter)!
                    let webVC = self.storyboard?.instantiateViewControllerWithIdentifier("WebViewController") as! WebViewController
                    webVC.initialURL = twitterUrl
                    self.navigationController!.pushViewController(webVC, animated: true)
                }
            } else {
                cell.didTapTwitter = nil
            }
            
            if session[Speaker.photo]?.imageValue != nil {
                cell.didTapPhoto = {
                    PhotoPopupView.showImage(self.session[Speaker.photo]!.imageValue!, inView: self.view)
                }
            }
            
            cell.didSetIsFavoriteTo = {setIsFavorite, indexPath in
                //TODO: update all this to Swift 2.0
                let id = self.session[Session.idColumn]
                
                let isInFavorites = find(self.favorites, id) != nil
                if setIsFavorite && !isInFavorites {
                    self.favorites.append(id)
                    Favorite.saveSessionId(id)
                } else if !setIsFavorite && isInFavorites {
                    self.favorites.removeAtIndex(find(self.favorites, id)!)
                    Favorite.removeSessionId(id)
                }
                
                self.notification(kFavoritesChangedNotification, object: nil)
            }
            
            cell.didTapURL = {tappedUrl in
                let webVC = self.storyboard?.instantiateViewControllerWithIdentifier("WebViewController") as! WebViewController
                webVC.initialURL = tappedUrl
                self.navigationController!.pushViewController(webVC, animated: true)
            }
            return cell
        }
        
        fatalError("out of section bounds")
    }
    
    func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
}