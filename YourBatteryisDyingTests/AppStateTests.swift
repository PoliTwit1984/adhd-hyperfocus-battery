import XCTest
@testable import Your_Battery_Is_Dying

@MainActor
final class AppStateTests: XCTestCase {
    final class FakeBatteryMonitor: BatteryMonitor {
        var startMonitoringCallCount = 0
        var stopMonitoringCallCount = 0
        var shouldShowAlertCallCount = 0
        var shouldShowAlertResult = false

        override func startMonitoring() {
            startMonitoringCallCount += 1
        }

        override func stopMonitoring() {
            stopMonitoringCallCount += 1
        }

        override func shouldShowAlert(threshold: Int) -> Bool {
            shouldShowAlertCallCount += 1
            return shouldShowAlertResult
        }
    }

    final class FakeAlertManager: AlertManager {
        var showAlertCallCount = 0
        var dismissAllAlertsCallCount = 0

        override func showAlert(
            batteryLevel: Int,
            onSnooze: @escaping @MainActor () -> Void,
            onDismiss: @escaping @MainActor () -> Void
        ) {
            showAlertCallCount += 1
            isShowingAlert = true
        }

        override func dismissAllAlerts() {
            dismissAllAlertsCallCount += 1
            isShowingAlert = false
        }
    }

    private func makeState(
        isRunningTestsOverride: Bool = false
    ) -> (AppState, FakeBatteryMonitor, FakeAlertManager) {
        let monitor = FakeBatteryMonitor()
        let alerts = FakeAlertManager()
        let state = AppState(
            batteryMonitor: monitor,
            alertManager: alerts,
            isRunningTestsOverride: isRunningTestsOverride,
            syncLaunchAtLoginOnInit: false
        )
        state.playSoundWithAlert = false
        return (state, monitor, alerts)
    }

    func testStartStartsMonitorOnlyOnceAndWiresBatteryCallback() {
        let (state, monitor, _) = makeState()
        XCTAssertNil(monitor.onBatteryUpdate)

        state.start()
        state.start()

        XCTAssertEqual(monitor.startMonitoringCallCount, 1)
        XCTAssertNotNil(monitor.onBatteryUpdate)
    }

    func testStartDoesNothingWhenRunningTestsMode() {
        let (state, monitor, _) = makeState(isRunningTestsOverride: true)
        state.start()
        XCTAssertEqual(monitor.startMonitoringCallCount, 0)
    }

    func testStopCallsBatteryMonitorStop() {
        let (state, monitor, _) = makeState()
        state.start()
        state.stop()
        XCTAssertEqual(monitor.stopMonitoringCallCount, 1)
    }

    func testCheckBatteryAndAlertShowsWhenMonitorSignalsLowBattery() {
        let (state, monitor, alerts) = makeState()
        monitor.isOnBattery = true
        monitor.shouldShowAlertResult = true

        state.checkBatteryAndAlert()

        XCTAssertEqual(alerts.showAlertCallCount, 1)
    }

    func testCheckBatteryAndAlertDoesNotShowWhenMonitorSaysNo() {
        let (state, monitor, alerts) = makeState()
        monitor.isOnBattery = true
        monitor.shouldShowAlertResult = false

        state.checkBatteryAndAlert()

        XCTAssertEqual(alerts.showAlertCallCount, 0)
    }

    func testCheckBatteryAndAlertDismissesExistingAlertWhenPluggedIn() {
        let (state, monitor, alerts) = makeState()
        alerts.isShowingAlert = true
        monitor.isOnBattery = false
        monitor.shouldShowAlertResult = true

        state.checkBatteryAndAlert()

        XCTAssertEqual(alerts.dismissAllAlertsCallCount, 1)
        XCTAssertEqual(alerts.showAlertCallCount, 0)
    }

    func testSnoozeDismissesCurrentAlertImmediately() {
        let (state, _, alerts) = makeState()
        state.snoozeAlert()
        XCTAssertEqual(alerts.dismissAllAlertsCallCount, 1)
    }

    func testBatteryUpdateCallbackTriggersCheckAndAlert() {
        let (state, monitor, alerts) = makeState()
        state.start()

        monitor.isOnBattery = true
        monitor.shouldShowAlertResult = true
        monitor.onBatteryUpdate?()

        XCTAssertEqual(alerts.showAlertCallCount, 1)
    }
}
