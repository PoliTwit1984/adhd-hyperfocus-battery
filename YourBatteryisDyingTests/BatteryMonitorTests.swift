import XCTest
@testable import Your_Battery_Is_Dying

@MainActor
final class BatteryMonitorTests: XCTestCase {
    func testNoAlertWhenBatteryAboveThreshold() {
        let monitor = BatteryMonitor()
        monitor.isOnBattery = true
        monitor.batteryLevel = 12

        XCTAssertFalse(monitor.shouldShowAlert(threshold: 7))
    }

    func testNoAlertWhenPluggedInEvenIfBelowThreshold() {
        let monitor = BatteryMonitor()
        monitor.isOnBattery = false
        monitor.batteryLevel = 3

        XCTAssertFalse(monitor.shouldShowAlert(threshold: 7))

        // Unplugging at the same level should alert again.
        monitor.isOnBattery = true
        XCTAssertTrue(monitor.shouldShowAlert(threshold: 7))
    }

    func testShouldShowAlertOnBatteryAndBelowThreshold() {
        let monitor = BatteryMonitor()
        monitor.isOnBattery = true
        monitor.batteryLevel = 7

        XCTAssertTrue(monitor.shouldShowAlert(threshold: 7))
        XCTAssertFalse(monitor.shouldShowAlert(threshold: 7))

        monitor.batteryLevel = 6
        XCTAssertTrue(monitor.shouldShowAlert(threshold: 7))
    }

    func testShouldShowAlertResetsWhenBackOnPower() {
        let monitor = BatteryMonitor()
        monitor.isOnBattery = true
        monitor.batteryLevel = 7

        XCTAssertTrue(monitor.shouldShowAlert(threshold: 7))

        monitor.isOnBattery = false
        XCTAssertFalse(monitor.shouldShowAlert(threshold: 7))

        monitor.isOnBattery = true
        XCTAssertTrue(monitor.shouldShowAlert(threshold: 7))
    }

    func testAlertSuppressionUntilBatteryDropsFurther() {
        let monitor = BatteryMonitor()
        monitor.isOnBattery = true
        monitor.batteryLevel = 5

        XCTAssertTrue(monitor.shouldShowAlert(threshold: 7))

        // Rising while still below threshold should not re-alert.
        monitor.batteryLevel = 6
        XCTAssertFalse(monitor.shouldShowAlert(threshold: 7))

        // Returning to the same level still should not re-alert.
        monitor.batteryLevel = 5
        XCTAssertFalse(monitor.shouldShowAlert(threshold: 7))

        // Dropping lower should re-alert.
        monitor.batteryLevel = 4
        XCTAssertTrue(monitor.shouldShowAlert(threshold: 7))
    }

    func testShouldShowAlertResetsAfterChargingAboveBuffer() {
        let monitor = BatteryMonitor()
        monitor.isOnBattery = true
        monitor.batteryLevel = 7

        XCTAssertTrue(monitor.shouldShowAlert(threshold: 7))

        monitor.batteryLevel = 11
        XCTAssertFalse(monitor.shouldShowAlert(threshold: 7))

        monitor.batteryLevel = 7
        XCTAssertTrue(monitor.shouldShowAlert(threshold: 7))
    }

    func testResetAlertStateBlocksDuplicateAtSameLevel() {
        let monitor = BatteryMonitor()
        monitor.isOnBattery = true
        monitor.batteryLevel = 7

        XCTAssertTrue(monitor.shouldShowAlert(threshold: 7))
        monitor.resetAlertState()

        // Same level should stay suppressed after explicit dismiss/reset.
        XCTAssertFalse(monitor.shouldShowAlert(threshold: 7))

        // Lower level should alert again.
        monitor.batteryLevel = 6
        XCTAssertTrue(monitor.shouldShowAlert(threshold: 7))
    }

    func testIsPluggedInMirrorsPowerState() {
        let monitor = BatteryMonitor()
        monitor.isOnBattery = true
        XCTAssertFalse(monitor.isPluggedIn)

        monitor.isOnBattery = false
        XCTAssertTrue(monitor.isPluggedIn)
    }

    func testThresholdEdgeCases() {
        let monitor = BatteryMonitor()
        monitor.isOnBattery = true

        monitor.batteryLevel = 1
        XCTAssertTrue(monitor.shouldShowAlert(threshold: 1))

        monitor.isOnBattery = false
        XCTAssertFalse(monitor.shouldShowAlert(threshold: 1))

        monitor.isOnBattery = true
        monitor.batteryLevel = 50
        XCTAssertTrue(monitor.shouldShowAlert(threshold: 50))
    }
}
