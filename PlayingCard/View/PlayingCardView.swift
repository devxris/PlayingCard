//
//  PlayingCardView.swift
//  PlayingCard
//
//  Created by Chris Huang on 14/01/2018.
//  Copyright © 2018 Chris Huang. All rights reserved.
//

import UIKit

class PlayingCardView: UIView {
	
	// MARK: Properties
	
	// setNeedsDisplay() is for calling draw(_ rect); setNeedsLayout() is for sub view calling layoutSubviews()
	var rank: Int = 5 { didSet { setNeedsDisplay(); setNeedsLayout() } }
	var suit: String = "♥️" { didSet { setNeedsDisplay(); setNeedsLayout() } }
	var isFaceUp: Bool = true { didSet { setNeedsDisplay(); setNeedsLayout() } }
	
	// MARK: Private properties and funcs
	
	// draw corner symbols by UILabel() (subView) with NSAttributedString
	private lazy var upperLeftCornerLabel: UILabel = createCornerLabel()
	private lazy var lowerRightCornerLabel: UILabel = createCornerLabel()
	
	private func createCornerLabel() -> UILabel {
		let label = UILabel()
		label.numberOfLines = 0
		addSubview(label)
		return label
	}
	
	private func configureCornerLabel(_ label: UILabel ) {
		label.attributedText = cornerString
		label.frame.size = .zero // clear out its size
		label.sizeToFit()        // size label to fit its content
		label.isHidden = !isFaceUp
	}
	
	// corner labels helper properties
	private var cornerString: NSAttributedString {
		return centeredAttributedString(rankString+"\n"+suit, fontSize: cornerFontSize)
	}
	
	// corner labels helper funcs
	private func centeredAttributedString(_ string: String, fontSize: CGFloat) -> NSAttributedString {
		var font = UIFont.preferredFont(forTextStyle: .body).withSize(fontSize)
		font = UIFontMetrics(forTextStyle: .body).scaledFont(for: font) // adapt dynamic type and accessibility
		let paragraphStyle = NSMutableParagraphStyle()
		paragraphStyle.alignment = .center
		return NSAttributedString(string: string, attributes: [.font: font, .paragraphStyle: paragraphStyle])
	}
	
	// MARK: Position Labels
	override func layoutSubviews() {
		super.layoutSubviews()
		
		configureCornerLabel(upperLeftCornerLabel)
		upperLeftCornerLabel.frame.origin = bounds.origin.offsetBy(dx: cornerOffset, dy: cornerOffset)
		
		configureCornerLabel(lowerRightCornerLabel)
		lowerRightCornerLabel.transform = CGAffineTransform.identity
			.rotated(by: CGFloat.pi) // rotation is anchored at upperleft corner, origin
			.translatedBy(x: lowerRightCornerLabel.frame.size.width,
						  y: lowerRightCornerLabel.frame.size.height)
		lowerRightCornerLabel.frame.origin = CGPoint(x: bounds.maxX, y: bounds.maxY)
			.offsetBy(dx: -cornerOffset, dy: -cornerOffset)
			.offsetBy(dx: -lowerRightCornerLabel.frame.size.width, dy: -lowerRightCornerLabel.frame.size.height)
	}
	
	// for dyanmic type and accessibility to reflect setting changes immediately
	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)
		setNeedsDisplay()
		setNeedsLayout()
	}
	
	// MARK: Draw
	
	override func draw(_ rect: CGRect) {
		// draw rounded rect card
		let roundedRect = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius)
		roundedRect.addClip() // draw inside clipping area
		UIColor.white.setFill() // default is white as well, so set clear color in storyboard
		roundedRect.fill()
	}
}

extension PlayingCardView {
	private struct SizeRatio {
		static let cornerFontSizeToBoundsHeight: CGFloat = 0.085
		static let cornerRadiusToBoundsHeight: CGFloat = 0.06
		static let cornerOffsetToCornerRadius: CGFloat = 0.33
		static let faceCardImageSizeToBoundsSize: CGFloat = 0.75
		static let cardBackImageSizeToBoundsSize: CGFloat = 1.2
	}
	private var cornerRadius: CGFloat { return bounds.size.height * SizeRatio.cornerRadiusToBoundsHeight }
	private var cornerOffset: CGFloat { return cornerRadius * SizeRatio.cornerOffsetToCornerRadius }
	private var cornerFontSize: CGFloat { return bounds.size.height * SizeRatio.cornerFontSizeToBoundsHeight }
	private var rankString: String {
		switch rank {
		case 1     : return "A"
		case 2...10: return String(rank)
		case 11	   : return "J"
		case 12    : return "Q"
		case 13    : return "K"
		default    : return "?"
		}
	}
}

extension CGRect {
	var leftHalf: CGRect { return CGRect(x: minX, y: minY, width: width/2, height: height) }
	var rightHalf: CGRect { return CGRect(x: midX, y: minY, width: width/2, height: height) }
	func inset(by size: CGSize) -> CGRect { return insetBy(dx: size.width, dy: size.height) }
	func sized(to size: CGSize) -> CGRect { return CGRect(origin: origin, size: size) }
	func zoom(by scale: CGFloat) -> CGRect {
		let newWidth = width * scale
		let newHeight = height * scale
		return insetBy(dx: (width - newWidth) / 2, dy: (height - newHeight) / 2)
	}
}

extension CGPoint {
	func offsetBy(dx: CGFloat, dy: CGFloat) -> CGPoint { return CGPoint(x: x + dx, y: y + dy) }
}
