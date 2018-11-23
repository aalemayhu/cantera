//
//  FavoriteButton.swift
//  cantera
//
//  Created by Alexander Alemayhu on 23/11/2018.
//  Copyright © 2018 Alexander Alemayhu. All rights reserved.
//

import UIKit

protocol FavoriteButtonDelegate {
    func selectorForPressedFavorite() -> Selector
}

class FavoriteButton: UIButton {
    init(delegate: FavoriteButtonDelegate) {
        super.init(frame: .zero)
        setup()
        addTarget(delegate, action: delegate.selectorForPressedFavorite(), for: .touchUpInside)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Private

    private func setup() {
        setImage(UIImage(imageLiteralResourceName: "unselected"), for: .normal)
        setImage(UIImage(imageLiteralResourceName: "selected"), for: .selected)
        translatesAutoresizingMaskIntoConstraints = false
        layer.masksToBounds = true
        layer.cornerRadius = 6
    }
}
