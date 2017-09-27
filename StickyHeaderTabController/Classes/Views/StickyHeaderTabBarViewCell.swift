//
//  StickyHeaderTabBarViewCell.swift
//  Treble
//
//  Created by Benjamin Chrobot on 9/20/17.
//

import UIKit

open class StickyHeaderTabBarViewCell: UICollectionViewCell {

    // MARK: - Public Properties

    /// The tab's title
    public var title: String? {
        get {
            return titleLabel.text
        }
        set {
            titleLabel.text = newValue
        }
    }

    // MARK: - Propeties

    public var selectedBackgroundColor: UIColor? = nil {
        didSet {
            setNeedsDisplay()
        }
    }

    public var bottomBorderColor: UIColor? = nil {
        didSet {
            repaintElements()
        }
    }

    public var bottomBorderWidth: CGFloat = 1 {
        didSet {
            setNeedsLayout()
        }
    }

    public var textColor: UIColor? {
        didSet {
            repaintElements()
        }
    }

    public var selectedTextColor: UIColor? {
        didSet {
            repaintElements()
        }
    }

    public var font: UIFont = StickyHeaderTabBarViewCell.defaultTitleFont {
        didSet {
            repaintElements()
        }
    }

    public var selectedFont: UIFont = StickyHeaderTabBarViewCell.defaultSelectedTitleFont {
        didSet {
            repaintElements()
        }
    }

    // MARK: - Private Properties

    private static let defaultTitleFont = UIFont.systemFont(ofSize: 14)
    private static let defaultSelectedTitleFont = UIFont.boldSystemFont(ofSize: 14)

    // MARK: Views

    private let titleLabel = UILabel()

    private let bottomBorder = UIView()

    // MARK: - Initialization

    public override init(frame: CGRect) {
        super.init(frame: frame)

        commonInit()
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func commonInit() {
        addSubview(titleLabel)
        setUpTitleLabel()
        setUpBottomBorder()
    }

    private func setUpTitleLabel() {
        addSubview(titleLabel)
        titleLabel.font = StickyHeaderTabBarViewCell.defaultTitleFont
        titleLabel.textAlignment = .center
    }

    private func setUpBottomBorder() {
        insertSubview(bottomBorder, at: 0)
    }

    // Overrides

    override open func layoutSubviews() {
        // Title label
        titleLabel.frame = CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height)

        bottomBorder.frame = CGRect(x: 0,
                                    y: bounds.height - bottomBorderWidth,
                                    width: bounds.width,
                                    height: bottomBorderWidth)
    }

    override open var isSelected: Bool {
        didSet {
            repaintElements()
        }
    }

    // MARK: - Public Methods

    open static func cellSize(for text: String) -> CGSize {
        return text.size(attributes: [NSFontAttributeName: StickyHeaderTabBarViewCell.defaultTitleFont])
    }

    /// Called when cell needs to be repainted. Notably when the cell has been selected
    open func repaintElements() {
        titleLabel.font = isSelected ? selectedFont : font
        titleLabel.textColor = isSelected ? selectedTextColor : textColor

        bottomBorder.backgroundColor = isSelected ? bottomBorderColor : nil
    }
}
