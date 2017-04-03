//
//  AppSettingsViewController.swift
//  lAyeR
//
//  Created by Yang Zhuohan on 2/4/17.
//  Copyright © 2017 nus.cs3217.layer. All rights reserved.
//

import UIKit

class AppSettingsViewController: UIViewController {

    
    @IBOutlet weak var settingTitle: UILabel!
    @IBOutlet weak var poiSubtitle: UILabel!
    @IBOutlet weak var detectionRadiusText: UILabel!
    @IBOutlet weak var radiusSlider: UISlider!
    @IBOutlet weak var detectionRadius: UILabel!
    @IBOutlet weak var numberOfMarkerText: UILabel!
    @IBOutlet weak var numberOfMarkerSlider: UISlider!
    @IBOutlet weak var numberOfMarker: UILabel!
    @IBOutlet weak var categoriesText: UILabel!
    @IBOutlet weak var categoriesTable: UITableView!
    @IBOutlet weak var doneButton: UIButton!
    
    var scrollContentView: UIScrollView!
    var appSettingsInstance = AppSettings.getInstance()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCategoriesTable()
        setupScrollView()
        addIntoScrollView()
        loadCurrentApplicationSetting()
    }
    
    private func setupScrollView() {
        scrollContentView = UIScrollView()
        scrollContentView.frame = view.bounds
        scrollContentView.contentSize = CGSize(width: view.bounds.width,
                                               height: categoriesTable.frame.origin.y + categoriesTable.frame.height)
        view.addSubview(scrollContentView)
    }
    
    private func setupCategoriesTable() {
        categoriesTable.delegate = self
        categoriesTable.dataSource = self
        categoriesTable.reloadData()
    }
    
    private func addIntoScrollView() {
        addToScrollView(settingTitle)
        addToScrollView(poiSubtitle)
        addToScrollView(detectionRadiusText)
        addToScrollView(radiusSlider)
        addToScrollView(detectionRadius)
        addToScrollView(numberOfMarkerSlider)
        addToScrollView(numberOfMarkerText)
        addToScrollView(numberOfMarker)
        addToScrollView(categoriesText)
        addToScrollView(categoriesTable)
        addToScrollView(doneButton)
    }
    
    private func addToScrollView(_ view: UIView) {
        let originalFrame = view.frame
        view.removeFromSuperview()
        view.frame = originalFrame
        scrollContentView.addSubview(view)
    }
    
    private func loadCurrentApplicationSetting() {
        loadCurrentSlider()
        loadCurrentCategoriesTable()
    }
    
    private func loadCurrentSlider() {
        radiusSlider.value = Float(appSettingsInstance.radiusOfDetection)
        numberOfMarkerSlider.value = Float(appSettingsInstance.maxNumberOfMarkers)
        updateSliderValueDisplay(radiusSlider, valueDisplay: detectionRadius)
        updateSliderValueDisplay(numberOfMarkerSlider, valueDisplay: numberOfMarker)
    }
    
    private func loadCurrentCategoriesTable() {
        for cell in categoriesTable.visibleCells {
            guard let categoriesCell = cell as? POICategoriesCell else {
                continue
            }
            if appSettingsInstance.selectedPOICategrories.contains(categoriesCell.categoryName.text!) {
                categoriesCell.accessoryType = .checkmark
                continue
            }
            categoriesCell.accessoryType = .none
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func radiusChanged(_ slider: UISlider) {
        updateSliderValueDisplay(slider, valueDisplay: detectionRadius)
        appSettingsInstance.updateRadiusOfDetection(with: Int(slider.value))
    }
    
    @IBAction func numberChanged(_ slider: UISlider) {
        updateSliderValueDisplay(slider, valueDisplay: numberOfMarker)
        appSettingsInstance.updateMaxNumberOfMarkers(with: Int(slider.value))
    }
    
    @IBAction func testAction(_ sender: Any) {
        print("aaaaaa")
    }
    
    private func updateSliderValueDisplay(_ slider: UISlider, valueDisplay: UILabel) {
        let value = Int(slider.value)
        valueDisplay.text = String(value)
    }

}

extension AppSettingsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryDictionary.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "categoryCell") as! POICategoriesCell
        cell.categoryName.text = categoryDictionary[indexPath.item][categoryIndex]
        let icon = UIImage(named: categoryDictionary[indexPath.item][categoryNameIndex] + imageExtension)
        let tintIcon = icon?.withRenderingMode(.alwaysTemplate)
        cell.categoryIcon.image = tintIcon
        cell.categoryIcon.tintColor = .black
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? POICategoriesCell else {
            return
        }
        if cell.accessoryType == .checkmark {
            cell.accessoryType = .none
            appSettingsInstance.removePOICategories(cell.categoryName.text!)
        } else {
            cell.accessoryType = .checkmark
            appSettingsInstance.addSelectedPOICategories(cell.categoryName.text!)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}
