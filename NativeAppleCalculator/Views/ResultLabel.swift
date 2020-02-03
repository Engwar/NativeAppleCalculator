//
//  ResultLabel.swift
//  NativeAppleCalculator
//
//  Created by Igor Shelginskiy on 2/3/20.
//  Copyright © 2020 Igor Shelginskiy. All rights reserved.
//
import UIKit

final class Resultlabel: UILabel
{

	init() {
		super.init(frame: .zero)
		backgroundColor = .black
		textColor = .white
		adjustsFontSizeToFitWidth = true
		textAlignment = .right
		font = UIFont(name: "FiraSans-Light", size: 100)
		adjustsFontSizeToFitWidth = true
		text = "0"
		translatesAutoresizingMaskIntoConstraints = false
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
