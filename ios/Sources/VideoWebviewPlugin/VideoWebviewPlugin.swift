import Foundation
import Capacitor
import WebKit
import AVFoundation

@objc(VideoWebviewPlugin)
public class VideoWebviewPlugin: CAPPlugin {
    private let implementation = VideoWebview()
    private var webViewNavigationController: UINavigationController?

    @objc func openVideoWebview(_ call: CAPPluginCall) {
        guard let url = call.getString("url") else {
            call.reject("URL es requerida")
            return
        }

        DispatchQueue.main.async {
            let userAgent = call.getString("userAgent")
            let allowJavaScript = call.getBool("allowJavaScript", true)
            let allowGeolocation = call.getBool("allowGeolocation", true)
            let allowMediaPlayback = call.getBool("allowMediaPlayback", true)
            let debugEnabled = call.getBool("debugEnabled", false)
            let title = call.getString("title") ?? "Video WebView"
            let toolbarColor = call.getString("toolbarColor")

            let videoWebViewController = VideoWebViewController()
            videoWebViewController.configure(
                url: url,
                userAgent: userAgent,
                allowJavaScript: allowJavaScript,
                allowGeolocation: allowGeolocation,
                allowMediaPlayback: allowMediaPlayback,
                debugEnabled: debugEnabled,
                title: title,
                toolbarColor: toolbarColor
            )

            let navigationController = UINavigationController(rootViewController: videoWebViewController)
            navigationController.modalPresentationStyle = .fullScreen
            self.webViewNavigationController = navigationController

            self.bridge?.viewController?.present(navigationController, animated: true)
            call.resolve()
        }
    }

    @objc func closeVideoWebview(_ call: CAPPluginCall) {
        DispatchQueue.main.async {
            self.webViewNavigationController?.dismiss(animated: true) {
                self.webViewNavigationController = nil
            }
            call.resolve()
        }
    }

    @objc public override func checkPermissions(_ call: CAPPluginCall) {
        let cameraStatus = AVCaptureDevice.authorizationStatus(for: .video)
        let microphoneStatus = AVCaptureDevice.authorizationStatus(for: .audio)

        let result: [String: String] = [
            "camera": authorizationStatusToString(cameraStatus),
            "microphone": authorizationStatusToString(microphoneStatus)
        ]

        call.resolve(result)
    }

    @objc public override func requestPermissions(_ call: CAPPluginCall) {
        let group = DispatchGroup()
        var cameraResult = "denied"
        var microphoneResult = "denied"

        // Solicitar permiso de cámara
        group.enter()
        AVCaptureDevice.requestAccess(for: .video) { granted in
            cameraResult = granted ? "granted" : "denied"
            group.leave()
        }

        // Solicitar permiso de micrófono
        group.enter()
        AVCaptureDevice.requestAccess(for: .audio) { granted in
            microphoneResult = granted ? "granted" : "denied"
            group.leave()
        }

        group.notify(queue: .main) {
            let result: [String: String] = [
                "camera": cameraResult,
                "microphone": microphoneResult
            ]
            call.resolve(result)
        }
    }

    @objc func setWebviewOptions(_ call: CAPPluginCall) {
        let allowThirdPartyCookies = call.getBool("allowThirdPartyCookies", true)
        let allowLocalStorage = call.getBool("allowLocalStorage", true)
        let allowPopups = call.getBool("allowPopups", false)
        let allowZoom = call.getBool("allowZoom", false)

        // Guardar opciones en UserDefaults
        UserDefaults.standard.set(allowThirdPartyCookies, forKey: "VideoWebview_allowThirdPartyCookies")
        UserDefaults.standard.set(allowLocalStorage, forKey: "VideoWebview_allowLocalStorage")
        UserDefaults.standard.set(allowPopups, forKey: "VideoWebview_allowPopups")
        UserDefaults.standard.set(allowZoom, forKey: "VideoWebview_allowZoom")

        call.resolve()
    }

    private func authorizationStatusToString(_ status: AVAuthorizationStatus) -> String {
        switch status {
        case .authorized:
            return "granted"
        case .denied, .restricted:
            return "denied"
        case .notDetermined:
            return "prompt"
        @unknown default:
            return "prompt"
        }
    }
}
