//
//  Notification Name Extention.swift
//  TaRest
//
//  Created by Hartwig Hopfenzitz on 12.05.21.
//

// holds the extentions of Notification.Name to ensure an error free name schema


import Foundation

// -------------------------------------------------------------------------------------------------
// MARK: -
// MARK: - extension Notification.Name
// -------------------------------------------------------------------------------------------------

extension Notification.Name {
    
    
    // ---------------------------------------------------------------------------------------------
    // MARK: -
    // MARK: - Error List
    // ---------------------------------------------------------------------------------------------

    // Event: New error was stored (ErrorList.add())
    static let TaRest_NewErrorListed = Notification.Name(rawValue: "org.HoBrink.TaRest.NewErrorListed")

    // ---------------------------------------------------------------------------------------------
    // MARK: -
    // MARK: - Global Data
    // ---------------------------------------------------------------------------------------------

    // Event: GlobalData() has restored the permanently stored vaules
    static let TaRest_GlobalDataRestored = Notification.Name(rawValue: "org.HoBrink.TaRest.GlobalDataRestored")


    
}
