//
//  PlayingCardView.swift
//  PlayingCard
//
//  Created by Chris Huang on 14/01/2018.
//  Copyright © 2018 Chris Huang. All rights reserved.
//

import UIKit

class PlayingCardView: UIView {
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		setContentMode()
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		setContentMode()
	}
	
	// or set in Interface Builder for bounds change, eg. rotation
	private func setContentMode() { contentMode = .redraw }

	// Draw a circle with UIGraphicsGetCurrentContext() & UIBezierPath()
	override func draw(_ rect: CGRect) {
		
		// circle with UIGraphicsGetCurrentContext()
		if let context = UIGraphicsGetCurrentContext() {
			context.addArc(center: CGPoint(x: bounds.midX, y: bounds.midY),
						   radius: 100,
						   startAngle: 0,
						   endAngle: CGFloat.pi * 2,
						   clockwise: true)
			context.setLineWidth(5.0)
			UIColor.green.setFill()
			UIColor.red.setStroke()
			context.strokePath()
			context.fillPath() // won't run because path is consumed by strokePath()
		}
		
		// circle with UIBezierPath()
		let path = UIBezierPath()
		path.addArc(withCenter: CGPoint(x: bounds.midX, y: bounds.midY),
					radius: 100,
					startAngle: 0,
					endAngle: CGFloat.pi * 2,
					clockwise: false)
		path.lineWidth = 5.0
		UIColor.green.setFill()
		UIColor.red.setStroke()
		path.stroke()
		path.fill()
	}
}
