//
//  SnagCaptureUITests.swift
//  SnaGCaptureUITests
//
//  UI tests for basic workflows
//

import XCTest

final class SnagCaptureUITests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }
    
    override func tearDownWithError() throws {
        app = nil
    }
    
    func testLaunchApp() throws {
        // Verify app launches successfully
        XCTAssertTrue(app.exists)
    }
    
    func testNavigationTabs() throws {
        #if os(iOS)
        // Test iOS tabs
        let snagTab = app.tabBars.buttons["Snags"]
        let settingsTab = app.tabBars.buttons["Settings"]
        let aboutTab = app.tabBars.buttons["About"]
        
        XCTAssertTrue(snagTab.exists)
        XCTAssertTrue(settingsTab.exists)
        XCTAssertTrue(aboutTab.exists)
        
        settingsTab.tap()
        XCTAssertTrue(app.navigationBars["Settings"].exists)
        
        aboutTab.tap()
        XCTAssertTrue(app.navigationBars["About"].exists)
        
        snagTab.tap()
        XCTAssertTrue(app.navigationBars["Snags"].exists)
        #endif
    }
    
    func testAddSnagWorkflow() throws {
        #if os(iOS)
        // Navigate to snags list
        let addButton = app.navigationBars["Snags"].buttons["Add Snag"]
        
        // If there are existing snags, button will be visible
        // If empty state, we need to tap the + button
        if addButton.exists {
            addButton.tap()
        }
        
        // Wait for the add sheet to appear
        let newSnagNavBar = app.navigationBars["New Snag"]
        XCTAssertTrue(newSnagNavBar.waitForExistence(timeout: 2))
        
        // Fill in snag details
        let titleField = app.textFields["Title"]
        XCTAssertTrue(titleField.exists)
        titleField.tap()
        titleField.typeText("UI Test Snag")
        
        let locationField = app.textFields["Location"]
        XCTAssertTrue(locationField.exists)
        locationField.tap()
        locationField.typeText("Test Location")
        
        // Save the snag
        let saveButton = app.navigationBars["New Snag"].buttons["Save"]
        XCTAssertTrue(saveButton.exists)
        saveButton.tap()
        
        // Verify we're back at the snags list
        XCTAssertTrue(app.navigationBars["Snags"].waitForExistence(timeout: 2))
        
        // Verify the snag appears in the list
        XCTAssertTrue(app.staticTexts["UI Test Snag"].waitForExistence(timeout: 2))
        #endif
    }
    
    func testSnagDetailView() throws {
        #if os(iOS)
        // First add a snag if none exists
        let addButton = app.navigationBars["Snags"].buttons["Add Snag"]
        if addButton.exists {
            addButton.tap()
            
            let titleField = app.textFields["Title"]
            titleField.tap()
            titleField.typeText("Detail Test Snag")
            
            let saveButton = app.navigationBars["New Snag"].buttons["Save"]
            saveButton.tap()
        }
        
        // Wait for the snag to appear and tap it
        let snagCell = app.staticTexts["Detail Test Snag"]
        if snagCell.waitForExistence(timeout: 2) {
            snagCell.tap()
            
            // Verify detail view elements
            XCTAssertTrue(app.navigationBars.element.exists)
            XCTAssertTrue(app.staticTexts["Basic Info"].exists)
            XCTAssertTrue(app.staticTexts["Status & Priority"].exists)
        }
        #endif
    }
    
    func testSettingsView() throws {
        #if os(iOS)
        // Navigate to settings
        app.tabBars.buttons["Settings"].tap()
        
        // Verify settings elements
        XCTAssertTrue(app.navigationBars["Settings"].exists)
        XCTAssertTrue(app.staticTexts["Photo Export"].exists)
        XCTAssertTrue(app.staticTexts["Storage"].exists)
        XCTAssertTrue(app.staticTexts["Storage Used"].exists)
        #endif
    }
    
    func testAboutView() throws {
        #if os(iOS)
        // Navigate to about
        app.tabBars.buttons["About"].tap()
        
        // Verify about elements
        XCTAssertTrue(app.navigationBars["About"].exists)
        XCTAssertTrue(app.staticTexts["SnaGCapture"].exists)
        XCTAssertTrue(app.staticTexts["Version 0.1"].exists)
        XCTAssertTrue(app.staticTexts["uk.kjdev.SnaGCapture"].exists)
        #endif
    }
    
    func testSearchFunctionality() throws {
        #if os(iOS)
        // Add a test snag first
        let addButton = app.navigationBars["Snags"].buttons["Add Snag"]
        if addButton.exists {
            addButton.tap()
            
            let titleField = app.textFields["Title"]
            titleField.tap()
            titleField.typeText("Searchable Snag")
            
            let saveButton = app.navigationBars["New Snag"].buttons["Save"]
            saveButton.tap()
        }
        
        // Test search
        if app.searchFields.firstMatch.exists {
            let searchField = app.searchFields.firstMatch
            searchField.tap()
            searchField.typeText("Searchable")
            
            // Verify snag appears
            XCTAssertTrue(app.staticTexts["Searchable Snag"].exists)
            
            // Clear search
            if app.buttons["Clear text"].exists {
                app.buttons["Clear text"].tap()
            }
        }
        #endif
    }
}
