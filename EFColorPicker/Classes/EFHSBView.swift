//
//  EFHSBView.swift
//  EFColorPicker
//
//  Created by EyreFree on 2017/9/29.
//
//  Copyright (c) 2017 EyreFree <eyrefree@eyrefree.org>
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

import UIKit

// The view to edit HSB color components.
public class EFHSBView: UIView, EFColorView, UITextFieldDelegate {

    let EFColorSampleViewHeight: CGFloat = 30.0
    let EFViewMargin: CGFloat = 40
    let EFColorWheelDimension: CGFloat = 200.0

    private let colorWheel = EFColorWheelView()
    public let brightnessView: EFColorComponentView = {
        let view = EFColorComponentView()
        view.title = NSLocalizedString("Brightness", comment: "")
        view.maximumValue = EFHSBColorComponentMaxValue
        view.format = "%.2f"
//        view.translatesAutoresizingMaskIntoConstraints = false
        view.setColors(colors: [.black, .white])
        return view
    }()
    
    private let textLabel: UILabel = {
       let label = UILabel()
        label.text = "小水印"
        label.font = .systemFont(ofSize: 20)
        label.textAlignment = .center
        return label
    }()
    
    private let colorSample: UIView = {
        let view = UIView()
        view.accessibilityLabel = "color_sample"
        view.layer.borderColor = UIColor.black.cgColor
        view.layer.borderWidth = 0.5
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    private var colorComponents = HSB(1, 1, 1, 1)
    private var layoutConstraints: [NSLayoutConstraint] = []

    weak public var delegate: EFColorViewDelegate?

    public var isTouched: Bool {
        if self.colorWheel.isTouched {
            return true
        }
        if self.brightnessView.isTouched {
            return true
        }
        return false
    }

    public var color: UIColor {
        get {
            return UIColor(
                hue: colorComponents.hue,
                saturation: colorComponents.saturation,
                brightness: colorComponents.brightness,
                alpha: colorComponents.alpha
            )
        }
        set {
            colorComponents = EFRGB2HSB(rgb: EFRGBColorComponents(color: newValue))
            self.reloadData()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.ef_baseInit()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.ef_baseInit()
    }

    func reloadData() {
        textLabel.textColor = color
        colorSample.backgroundColor = color
        colorSample.accessibilityValue = EFHexStringFromColor(color: color)
        self.ef_reloadViewsWithColorComponents(colorComponents: colorComponents)
        self.colorWheel.display(colorWheel.layer)
    }
    override public func updateConstraints() {
        super.updateConstraints()
    }

    // MARK: - Private methods
    private func ef_baseInit() {
        accessibilityLabel = "hsb_view"
        addSubview(colorSample)
        addSubview(textLabel)
        addSubview(colorWheel)
        addSubview(brightnessView)
        
        if let string = UserDefaults.standard.value(forKey: "currentTextContent") as? String {
            textLabel.text = string
        }

        if let string = UserDefaults.standard.value(forKey: "currentTextColor") as? String {
            Delays(0.3) {
                self.color = UIColor(hexStrings: string)!
            }
        }

        colorWheel.addTarget(
            self, action: #selector(ef_colorDidChangeValue(sender:)), for: UIControl.Event.valueChanged
        )
        brightnessView.addTarget(
            self, action: #selector(ef_brightnessDidChangeValue(sender:)), for: UIControl.Event.valueChanged
        )
        let width = UIScreen.main.bounds.width
        textLabel.frame = CGRect(x: 20, y: 20, width: UIScreen.main.bounds.width - 40, height: 30)
        colorSample.frame = CGRect(x: 20, y: textLabel.frame.maxY + 15, width: UIScreen.main.bounds.width - 40, height: 40)
        
        colorWheel.frame = CGRect(x: 30, y: colorSample.frame.maxY + 15 , width: width - 60 , height: width - 60)
        brightnessView.frame = CGRect(x: 30, y: colorWheel.frame.maxY + 15 , width: width - 60 , height: 40)
    }


    private func ef_reloadViewsWithColorComponents(colorComponents: HSB) {
        colorWheel.hue = colorComponents.hue
        colorWheel.saturation = colorComponents.saturation
        colorWheel.brightness = colorComponents.brightness
        self.ef_updateSlidersWithColorComponents(colorComponents: colorComponents)
    }

    private func ef_updateSlidersWithColorComponents(colorComponents: HSB) {
        brightnessView.value = colorComponents.brightness
    }

    @objc private func ef_colorDidChangeValue(sender: EFColorWheelView) {
        colorComponents.hue = sender.hue
        colorComponents.saturation = sender.saturation
        self.delegate?.colorView(self, didChangeColor: self.color)
        self.reloadData()
    }

    @objc private func ef_brightnessDidChangeValue(sender: EFColorComponentView) {
        colorComponents.brightness = sender.value
        self.colorWheel.brightness = sender.value
        self.delegate?.colorView(self, didChangeColor: self.color)
        self.reloadData()
    }
    
    public func Delays(_ time: TimeInterval, queue: DispatchQueue = .main, closure: @escaping () -> Void) {
        queue.asyncAfter(deadline: .now() + time) { closure() }
    }
}
