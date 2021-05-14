//
//  String Extension.swift
//  TaRest
//
//  Created by Hartwig Hopfenzitz on 14.05.21.
//

import Foundation
import UIKit

// -------------------------------------------------------------------------------------------------
// MARK: -
// MARK: - String Extension
// -------------------------------------------------------------------------------------------------


extension String {

    // ---------------------------------------------------------------------------------------------
    // MARK: -
    // MARK: - highlightText
    //
    // taken from https://stackoverflow.com/questions/33542905/highlighting-search-result-in-uitableview-cell-ios-swift
    // answer from user henrik-dmg
    //
    // modified to meet project needs
    //
    // ---------------------------------------------------------------------------------------------

    func highlightText(
        _ text: String,
        foregroundColor: UIColor,
        backgroundColor: UIColor,
        font: UIFont) -> NSAttributedString
    {
        // get the original string from self
        let attrString = NSMutableAttributedString(string: self)
        
        // finds the string part to highlight
        let range = (self as NSString).range(of: text, options: .caseInsensitive)
        
        // change foreground color attribut
        attrString.addAttribute(
            .foregroundColor,
            value: foregroundColor,
            range: range)
        
        // change background color attribut
        attrString.addAttribute(
            .backgroundColor,
            value: backgroundColor,
            range: range)

        // change font for the whole string
        attrString.addAttribute(
            .font,
            value: font,
            range: NSRange(location: 0, length: attrString.length))
        
        // return the highlighted string
        return attrString
    }

}
