//
//  PlayingCardDec.swift
//  PlayingCard
//
//  Created by Chris Huang on 13/01/2018.
//  Copyright © 2018 Chris Huang. All rights reserved.
//

import Foundation

struct PlayingCardDeck {
	
	private(set) var cards = [PlayingCard]()
	
	init() {
		for suit in PlayingCard.Suit.all {
			for rank in PlayingCard.Rank.all {
				let card = PlayingCard(suit: suit, rank: rank)
				cards.append(card)
			}
		}
	}
	
	mutating func draw() -> PlayingCard? {
		if cards.count > 0 {
			return cards.remove(at: cards.count.arc4random)
		} else {
			return nil
		}
	}
}

extension Int {
	var arc4random: Int {
		if self > 0 {
			return Int(arc4random_uniform(UInt32(self)))
		} else if self < 0 {
			return -Int(arc4random_uniform(UInt32(abs(self))))
		} else {
			return 0
		}
	}
}
