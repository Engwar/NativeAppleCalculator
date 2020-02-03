//
//  CalculatorViewController.swift
//  NativeAppleCalculator
//
//  Created by Igor Shelginskiy on 2/3/20.
//  Copyright © 2020 Igor Shelginskiy. All rights reserved.
//

import UIKit

final class CalculatorViewController: UIViewController
{
	private var brain = LogicOperations()
	var calculatorScreen = CalculatorScreen()
	var buttons = [UIButton]()
	var resultLabel = UILabel()
	var typingBegan = false
	let formatter: NumberFormatter = {
		let formatter = NumberFormatter()
		formatter.numberStyle = .decimal
		formatter.maximumFractionDigits = 9
		formatter.notANumberSymbol = "Ошибка"
		formatter.groupingSeparator = " "
		formatter.locale = Locale.current
		return formatter
	}()
	var displayValue: Double? {
		get {
			if let text = resultLabel.text, let value = Double(text.replacingOccurrences(of: ",", with: ".")){
				return value
			}
			else {
				return nil
			}
		}
		set {
			if let value = newValue {
				guard value.isInfinite == false else { return resultLabel.text = "Ошибка" }
				resultLabel.text = formatter.string(from: NSNumber(value: value))?.replacingOccurrences(of: ".", with: ",")
			}
			else {
				resultLabel.text = "0"
			}
			changeACButton()
		}
	}

	override var preferredStatusBarStyle: UIStatusBarStyle {
		return .lightContent
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		accessToElements()
		addTarget()
		let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(swipToDeleteNumber(_:)))
		let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(swipToDeleteNumber(_:)))
		leftSwipe.direction = .left
		rightSwipe.direction = .right
		self.view.addGestureRecognizer(leftSwipe)
		self.view.addGestureRecognizer(rightSwipe)
	}

	override func loadView() {
		self.view = calculatorScreen
	}
	func accessToElements() {
		buttons = calculatorScreen.buttonsView.buttons
		resultLabel = calculatorScreen.resultLabel
	}
	@objc func pressNumber(_ sender: UIButton) {
		guard let buttonTitle = sender.titleLabel?.text, let displayedText = resultLabel.text else { return }
		if typingBegan {
			if buttonTitle != "," || (buttonTitle == "," && displayedText.contains(",") == false) {
				if displayedText != "0" {
					resultLabel.text = displayedText + buttonTitle
				}
				else {
					resultLabel.text = (buttonTitle == "," ? "0," : buttonTitle)
				}
			}
		}
		else {
			resultLabel.text = (buttonTitle == "," ? "0," : buttonTitle)
		}
		typingBegan = true
		changeACButton()
	}
	@objc func pressOperator(_ sender: UIButton) {
		guard let buttonTitle = sender.titleLabel?.text else { return }
		let needCalculation = typingBegan
		if typingBegan, let value = displayValue {
			brain.setOperand(operand: value)
			typingBegan = false
		}
		brain.performOperation(symbol: buttonTitle, getBothOperandsForBinaryOperation: needCalculation)
		displayValue = brain.result
	}
	@objc func pressAC(_ sender: UIButton) {
		if sender.currentTitle == "C" {
			brain.clear()
			displayValue = 0
			typingBegan = false
			changeACButton()
		}
	}
	@objc func swipToDeleteNumber(_ sender: UISwipeGestureRecognizer) {
		if typingBegan, var typingText = resultLabel.text {
			if typingText.count > 0 {
				typingText.removeLast()
				guard typingText.isEmpty == false else { return resultLabel.text = "0" }
				resultLabel.text = typingText
			}
			else {
				resultLabel.text = "0"
				typingBegan = false
			}
		}
	}
	func addTarget() {
		for button in buttons {
			if let text = button.currentTitle {
				if Int(text) != nil || text == "," {
					button.addTarget(self, action: #selector(self.pressNumber(_:)), for: .touchUpInside)
				}
				else if text == "AC" {
					button.addTarget(self, action: #selector(self.pressAC(_:)), for: .touchUpInside)
				}
				else {
					button.addTarget(self, action: #selector(self.pressOperator(_:)), for: .touchUpInside)
				}
			}
		}
	}
	func changeACButton() {
		let text = resultLabel.text
		for button in buttons {
			if button.currentTitle == "AC", text != "0" {
				button.setTitle("C", for: .normal)
			}
			else if button.currentTitle == "C", text == "0" {
				button.setTitle("AC", for: .normal)
			}
		}
	}
}
