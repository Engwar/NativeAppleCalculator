//
//  CalculatorScreen.swift
//  NativeAppleCalculator
//
//  Created by Igor Shelginskiy on 2/3/20.
//  Copyright © 2020 Igor Shelginskiy. All rights reserved.
//

import Foundation
import SnapKit

final class CalculatorScreen: UIView
{
	let resultLabel = Resultlabel()
	let buttonsView = StackButtons()

	init() {
		super.init(frame: .zero)
		backgroundColor = .black
		addSubview(resultLabel)
		addSubview(buttonsView)
		makeConstraint()
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	func makeConstraint() {
		buttonsView.snp.makeConstraints { maker in
			maker.bottom.equalToSuperview().offset(-10)
			maker.leading.equalToSuperview().offset(8)
			maker.trailing.equalToSuperview().offset(-8)
			maker.height.equalTo(buttonsView.snp.width).multipliedBy(1.25)
		}
		resultLabel.snp.makeConstraints { maker in
			maker.leading.equalToSuperview().offset(16)
			maker.trailing.equalToSuperview().offset(-16)
			maker.height.equalTo(113)
			maker.bottom.equalTo(buttonsView.snp.top).offset(-8)
		}
	}
}
