//
//  HighScore.swift
//  Zombie Attack
//
//  Created by Frank du Plessis on 2015/07/10.
//  Copyright (c) 2015 James Tyner. All rights reserved.
//

import Foundation

class HighScore: NSObject, NSCoding {
    var score:Int;
    let dateOfScore:NSDate;
    var name: String;
    
    init(score:Int, dateOfScore:NSDate, name: String) {
        self.score = score;
        self.dateOfScore = dateOfScore;
        self.name = name
    }
    
    required init(coder: NSCoder) {
        self.score = coder.decodeObjectForKey("score")! as! Int;
        self.dateOfScore = coder.decodeObjectForKey("dateOfScore")! as! NSDate;
        self.name = coder.decodeObjectForKey("name")! as! String
        super.init()
        
    }
    
    func encodeWithCoder(coder: NSCoder) {
        coder.encodeObject(self.score, forKey: "score")
        coder.encodeObject(self.dateOfScore, forKey: "dateOfScore")
        coder.encodeObject(self.name, forKey: "name")
    }
    func getScore() -> Int{
        return self.score
    }
    func getName() -> String{
        return self.name
    }
    func getDate() -> NSDate{
        return self.dateOfScore
    }
    func Score(score: Int){
        self.score = score
    }
}