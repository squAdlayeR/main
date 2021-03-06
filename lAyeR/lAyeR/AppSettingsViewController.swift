//
//  AppSettingsViewController.swift
//  lAyeR
//
//  Created by Yang Zhuohan on 2/4/17.
//  Copyright © 2017 nus.cs3217.layer. All rights reserved.
//

import UIKit

/**
 The view controller that is defined for application settings
 Currently the settings only include:
 - change number of visible pois
 - change radius of poi detection
 - change desired display of categories
 */
class AppSettingsViewController: UIViewController {
    
    @IBOutlet weak var topbanner: UIView!
    
    // Connects the scroll view panel
    @IBOutlet weak var scrollView: UIScrollView!
    
    // Connects the main title of the settings
    @IBOutlet weak var settingTitle: UILabel!
    
    // Connects the subtitle of `Poi settings`
    @IBOutlet weak var poiSubtitle: UILabel!
    
    // Connects the radius setting label, slider and number
    @IBOutlet weak var detectionRadiusText: UILabel!
    @IBOutlet weak var radiusSlider: UISlider!
    @IBOutlet weak var detectionRadius: UILabel!
    
    // Connects the number of visible markers, slider and number display
    @IBOutlet weak var numberOfMarkerText: UILabel!
    @IBOutlet weak var numberOfMarkerSlider: UISlider!
    @IBOutlet weak var numberOfMarker: UILabel!
    
    // Connects the categories label and display table
    @IBOutlet weak var categoriesText: UILabel!
    @IBOutlet weak var categoriesTable: UITableView!
    
    // Connects the done button
    @IBOutlet weak var doneButton: UIButton!
    
    // Defines the scroll view
    var scrollContentView: UIScrollView!
    
    // Gets the app settings
    var appSettingsInstance = AppSettings.getInstance()
    
    // Gets the geo manager instance
    var geoManager = GeoManager.getInstance()
    
    /// Initialization
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCategoriesTable()
        setupTopBanner()
        loadCurrentApplicationSetting()
    }
    
    /// Adjusts auto layout.
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let contentSize = CGSize(width: categoriesTable.frame.width,
                                 height: categoriesTable.frame.origin.y + categoriesTable.rowHeight * CGFloat(AppSettingsConstants.poiCategories.count))
        scrollView.contentSize = contentSize
        
    }
    
    /// Sets up the categrories table for selection
    private func setupCategoriesTable() {
        categoriesTable.delegate = self
        categoriesTable.dataSource = self
        categoriesTable.tableFooterView = UIView(frame: .zero)
        categoriesTable.reloadData()
    }
    
    private func setupTopBanner() {
        topbanner.addSubview(doneButton)
        topbanner.addSubview(settingTitle)
        view.addSubview(topbanner)
    }
    
    /// Loads the current application settings from storage
    private func loadCurrentApplicationSetting() {
        //RealmLocalStorageManager.getInstance().loadAppSettings()
        loadCurrentSlider()
        loadCurrentCategoriesTable()
    }
    
    /// Sets the sliders to fit the current setting data
    private func loadCurrentSlider() {
        radiusSlider.value = Float(appSettingsInstance.radiusOfDetection)
        numberOfMarkerSlider.value = Float(appSettingsInstance.maxNumberOfMarkers)
        updateSliderValueDisplay(radiusSlider, valueDisplay: detectionRadius)
        updateSliderValueDisplay(numberOfMarkerSlider, valueDisplay: numberOfMarker)
    }
    
    /// Sets the categories to fit the current setting data
    private func loadCurrentCategoriesTable() {
        for cell in categoriesTable.visibleCells {
            guard let categoriesCell = cell as? POICategoriesCell else { continue }
            let category = categoriesCell.category
            if appSettingsInstance.selectedPOICategrories.contains(category.rawValue) {
                categoriesCell.accessoryType = .checkmark
                continue
            }
            categoriesCell.accessoryType = .none
        }
    }

    /// Defines the action that when slider for radius is changed. The number
    /// text label should display number accordingly
    @IBAction func radiusChanged(_ slider: UISlider) {
        updateSliderValueDisplay(slider, valueDisplay: detectionRadius)
        appSettingsInstance.updateRadiusOfDetection(with: Int(slider.value))
    }
    
    /// Defines the action that when slider for number of visible pois is changed. 
    /// The number text label should display number accordingly
    @IBAction func numberChanged(_ slider: UISlider) {
        updateSliderValueDisplay(slider, valueDisplay: numberOfMarker)
        appSettingsInstance.updateMaxNumberOfMarkers(with: Int(slider.value))
    }
    
    /// Defines the action that when `done` is clicked, the settings should be saved
    /// and the query should be updated
    @IBAction func doneIsPressed(_ sender: Any) {
        RealmLocalStorageManager.getInstance().saveAppSettings()
        geoManager.forceUpdateUserNearbyPOIS()
    }
    
    /// Updates the slider values for display
    /// - Parameters:
    ///     - slider: the sender
    ///     - valueDisplay: the label for value display
    private func updateSliderValueDisplay(_ slider: UISlider, valueDisplay: UILabel) {
        let value = Int(slider.value)
        valueDisplay.text = String(value)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}

/**
 An extension that is used to define categories table datasource and delegate
 */
extension AppSettingsViewController: UITableViewDelegate, UITableViewDataSource {
    
    /// Defines the number of cells in the table
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return AppSettingsConstants.poiCategories.count
    }
    
    /// Defines the diplay of cells.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: AppSettingsConstants.categoriesReusableIdentifier)
        guard let categoryCell = cell as? POICategoriesCell else { return cell! }
        let specificCategory = AppSettingsConstants.poiCategories[indexPath.item]
        categoryCell.prepareDisplay(with: specificCategory)
        return categoryCell
    }
    
    /// Defines the interaction when user click on certain cells. should check that cell
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath)
            as? POICategoriesCell else { return }
        let cellCategroy = cell.category
        if cell.accessoryType == .checkmark {
            cell.accessoryType = .none
            appSettingsInstance.removePOICategories(cellCategroy.rawValue)
        } else {
            cell.accessoryType = .checkmark
            appSettingsInstance.addSelectedPOICategories(cellCategroy.rawValue)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}
