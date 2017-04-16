//
//  RouteDesignerViewController_UIInteraction.swift
//  lAyeR
//
//  Created by BillStark on 4/11/17.
//  Copyright © 2017 nus.cs3217.layer. All rights reserved.
//

import UIKit

/**
 this is an extension of the view controller that defines UI interactions
 */
extension RouteDesignerViewController {

    /// Defines the action when save button is pressed.
    @IBAction func saveButtonPressed(_ sender: Any) {
        let alertSize = CGSize(width: HighLevelMiscConstants.suggestedPopupWidth,
                               height: HighLevelMiscConstants.suggestedPopupHeight)
        storeRoutePopupController = BasicAlertController(title: "Store Your Route", size: alertSize)
        addInnerViewToStorePopup()
        storeRoutePopupController.addButtonToAlert(createCloseStoreButton())
        storeRoutePopupController.presentAlert(within: view)
    }
    
    @IBAction func optionsIsPressed(_ sender: Any) {
        let alertSize = CGSize(width: HighLevelMiscConstants.suggestedPopupWidth,
                               height: HighLevelMiscConstants.suggestedPopupHeight)
        optionsPopupController = BasicAlertController(title: "Options", size: alertSize)
        addInnerViewToOptionPopup()
        optionsPopupController.addButtonToAlert(createCloseOptionButton())
        optionsPopupController.presentAlert(within: view)
    }
    
    /// Adds inner view to the popup
    private func addInnerViewToStorePopup() {
        let innerView = InformativeInnerView(width: infoPanelBounds.width,
                                             height: infoPanelBounds.height,
                                             subtitle: "Choose a method to store route")
        storeRoutePopupController.addViewToAlert(innerView)
        innerView.insertSubInfo(createSaveButton())
        innerView.insertSubInfo(createExportButton())
    }
    
    private func addInnerViewToOptionPopup() {
        let innerView = InformativeInnerView(width: infoPanelBounds.width,
                                             height: infoPanelBounds.height,
                                             subtitle: "Click to change mode")
        optionsPopupController.addViewToAlert(innerView)
        innerView.insertSubInfo(createToggleMapButton())
        innerView.insertSubInfo(createSwitcher())
    }
    
    private func createToggleMapButton() -> UIButton {
        let mapTypeButton = UIButton()
        if mapView.mapType == .normal {
            mapTypeButton.setTitle(RouteDesignerConstants.mapViewText, for: .normal)
        } else if mapView.mapType == .satellite {
            mapTypeButton.setTitle(RouteDesignerConstants.satelliteViewText, for: .normal)
        } else {
            mapTypeButton.setTitle(RouteDesignerConstants.hybridViewText, for: .normal)
        }
        stylizeButton(mapTypeButton)
        mapTypeButton.addTarget(self, action: #selector(toggleMapType(_:)), for: .touchUpInside)
        return mapTypeButton
    }
    
    private func createSwitcher() -> UIButton {
        let routeTypeButton = UIButton()
        if manualRouteType {
            routeTypeButton.setTitle(RouteDesignerConstants.manualRouteText, for: .normal)
        } else {
            routeTypeButton.setTitle(RouteDesignerConstants.googleRouteText, for: .normal)
        }
        stylizeButton(routeTypeButton)
        routeTypeButton.addTarget(self, action: #selector(toggleRouteType(_:)), for: .touchUpInside)
        return routeTypeButton
    }
    
    /// Creates a close button
    /// - Returns: a close button which will close the popup if it is clicked
    private func createCloseStoreButton() -> UIButton {
        let newButton = UIButton()
        newButton.setTitle("Cancel", for: .normal)
        newButton.titleLabel?.font = UIFont(name: UIBasicConstants.defaultFontRegular,
                                            size: HighLevelMiscConstants.buttonFontSize)
        newButton.addTarget(self, action: #selector(closeStoreRoutePopup), for: .touchUpInside)
        return newButton
    }
    
    private func createCloseOptionButton() -> UIButton {
        let newButton = UIButton()
        newButton.setTitle("Close", for: .normal)
        newButton.titleLabel?.font = UIFont(name: UIBasicConstants.defaultFontRegular,
                                            size: HighLevelMiscConstants.buttonFontSize)
        newButton.addTarget(self, action: #selector(closeOptionPopup), for: .touchUpInside)
        return newButton
    }
    
    /// Creates a save button
    /// - Returns: a save button which will close the popup if it is clicked
    private func createSaveButton() -> UIButton {
        let saveButton = UIButton()
        saveButton.setTitle(RouteDesignerConstants.saveText, for: .normal)
        stylizeButton(saveButton)
        saveButton.addTarget(self, action: #selector(saveRoute), for: .touchUpInside)
        return saveButton
    }
    
    /// Creates a export button
    /// - Returns: a export button which will close the popup if it is clicked
    private func createExportButton() -> UIButton {
        let exportButton = UIButton()
        exportButton.setTitle(RouteDesignerConstants.exportGPSText, for: .normal)
        stylizeButton(exportButton)
        exportButton.addTarget(self, action: #selector(exportRoute), for: .touchUpInside)
        return exportButton
    }
    
    /// defines the styling of the button
    /// - Parameter button: the button that is to add styling
    private func stylizeButton(_ button: UIButton) {
        button.titleLabel?.font = UIFont(name: UIBasicConstants.defaultFontRegular,
                                         size: HighLevelMiscConstants.buttonFontSize)
        button.titleLabel?.textColor = UIColor.white
        button.frame = CGRect(x: 0, y: 0,
                              width: infoPanelBounds.width - InnerViewConstants.innerViewSidePadding * 2,
                              height: 50)
        button.layer.cornerRadius = InnerViewConstants.infoBlockCornerRadius
        button.layer.masksToBounds = true
        button.backgroundColor = UIColor.lightGray
    }
    
    /// Closes the popup
    func closeStoreRoutePopup() {
        storeRoutePopupController.closeAlert()
    }
    
    func closeOptionPopup() {
        optionsPopupController.closeAlert()
    }
    
    /// Calculates info panel bounds
    private var infoPanelBounds: CGRect {
        guard storeRoutePopupController != nil else {
            return optionsPopupController.alert.infoPanel.bounds
        }
        return storeRoutePopupController.alert.infoPanel.bounds
    }

}
