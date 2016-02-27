//
//  SpeakersModel.swift
//  EventBlank2-iOS
//
//  Created by Marin Todorov on 2/22/16.
//  Copyright © 2016 Underplot ltd. All rights reserved.
//

import UIKit
import RealmSwift

import RxSwift

class SpeakersModel {
    
    //favorites
    let favoritesNames = RealmProvider.appRealm.objects(FavoriteSpeaker).asObservableArray()
        .map { $0.map {speaker in speaker.name} }

    //filtering
    func isFavorite(speaker: Speaker, matchNames: [String]) -> Bool {
        return matchNames.contains(speaker.name)
    }

    //loading speakers
    func speakers(searchTerm term: String = "", showOnlyFavorites: Bool = false) -> Observable<[Speaker]> {
        
        
        func filterSpeakers(speakers: [Speaker], matchNames: [String]) -> [Speaker] {
            return speakers.filter { speaker -> Bool in
                return matchNames.contains(speaker.name)
            }
        }
        
        //sorting
        func sortSpeakers(speakers: [Speaker], order: NSComparisonResult = .OrderedAscending) -> [Speaker] {
            return speakers.sort({s1, s2 in
                return s1.name.compare(s2.name) == order
            })
        }
        
        //speakers
        let speakersList = RealmProvider.eventRealm.objects(Speaker)
            .filter("name contains[c] %@", term)
            .asObservableArray()
        
        //the filtered/sorted speakers list
        return Observable.combineLatest(speakersList, favoritesNames, resultSelector: {speakers, favorites in
            guard showOnlyFavorites else {
                return speakers
            }

            return speakers.filter { favorites.contains($0.name) }
        })
        .map { sortSpeakers($0) }
    }
}