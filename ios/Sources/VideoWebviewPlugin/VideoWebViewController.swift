import Foundation
import WebKit
import UIKit

public class VideoWebViewController: UIViewController {
    private var webView: WKWebView!
    private var url: String?
    private var userAgent: String?
    private var allowJavaScript = true
    private var allowGeolocation = true
    private var allowMediaPlayback = true
    private var debugEnabled = false
    private var webviewTitle = "Video WebView"
    private var toolbarColor: String?

    public func configure(
        url: String,
        userAgent: String?,
        allowJavaScript: Bool,
        allowGeolocation: Bool,
        allowMediaPlayback: Bool,
        debugEnabled: Bool,
        title: String,
        toolbarColor: String?
    ) {
        self.url = url
        self.userAgent = userAgent
        self.allowJavaScript = allowJavaScript
        self.allowGeolocation = allowGeolocation
        self.allowMediaPlayback = allowMediaPlayback
        self.debugEnabled = debugEnabled
        self.webviewTitle = title
        self.toolbarColor = toolbarColor
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupWebView()
        
        if let urlString = url, let url = URL(string: urlString) {
            let request = URLRequest(url: url)
            webView.load(request)
        }
    }

    private func setupUI() {
        title = webviewTitle
        view.backgroundColor = .systemBackground

        // Configurar barra de navegación
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .cancel,
            target: self,
            action: #selector(closeWebView)
        )

        if let colorString = toolbarColor, let color = UIColor(hex: colorString) {
            navigationController?.navigationBar.backgroundColor = color
        }
    }

    private func setupWebView() {
        let config = WKWebViewConfiguration()
        
        // Configurar preferencias
        let preferences = WKWebpagePreferences()
        preferences.allowsContentJavaScript = allowJavaScript
        config.defaultWebpagePreferences = preferences

        // Configurar para videollamadas (basado en Air Doctor)
        config.allowsInlineMediaPlayback = true
        config.mediaTypesRequiringUserActionForPlayback = allowMediaPlayback ? [] : .all
        
        // Configurar geolocalización
        if allowGeolocation {
            config.preferences.setValue(true, forKey: "allowFileAccessFromFileURLs")
        }

        // Obtener opciones adicionales de UserDefaults
        let allowZoom = UserDefaults.standard.bool(forKey: "VideoWebview_allowZoom")
        if !allowZoom {
            let source = """
                var meta = document.createElement('meta');
                meta.name = 'viewport';
                meta.content = 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no';
                var head = document.getElementsByTagName('head')[0];
                head.appendChild(meta);
            """
            let script = WKUserScript(source: source, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
            config.userContentController.addUserScript(script)
        }

        webView = WKWebView(frame: .zero, configuration: config)
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.navigationDelegate = self
        webView.uiDelegate = self

        // User Agent personalizado
        if let userAgent = userAgent {
            webView.customUserAgent = userAgent
        }

        // Debug
        if debugEnabled && #available(iOS 16.4, *) {
            webView.isInspectable = true
        }

        view.addSubview(webView)
        
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    @objc private func closeWebView() {
        dismiss(animated: true)
    }
}

// MARK: - WKNavigationDelegate
extension VideoWebViewController: WKNavigationDelegate {
    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let url = navigationAction.request.url else {
            decisionHandler(.allow)
            return
        }

        // Manejar esquemas especiales
        let scheme = url.scheme?.lowercased()
        if scheme == "tel" || scheme == "mailto" || scheme == "whatsapp" {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
                decisionHandler(.cancel)
                return
            }
        }

        decisionHandler(.allow)
    }
}

// MARK: - WKUIDelegate
extension VideoWebViewController: WKUIDelegate {
    public func webView(_ webView: WKWebView, requestMediaCapturePermissionFor origin: WKSecurityOrigin, initiatedByFrame frame: WKFrameInfo, type: WKMediaCaptureType, decisionHandler: @escaping (WKPermissionDecision) -> Void) {
        // Otorgar permisos automáticamente si la app tiene los permisos del sistema
        decisionHandler(.grant)
    }

    public func webView(_ webView: WKWebView, requestDeviceOrientationAndMotionPermissionFor origin: WKSecurityOrigin, initiatedByFrame frame: WKFrameInfo, decisionHandler: @escaping (WKPermissionDecision) -> Void) {
        decisionHandler(.grant)
    }

    public func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            completionHandler()
        })
        present(alert, animated: true)
    }

    public func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            completionHandler(true)
        })
        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel) { _ in
            completionHandler(false)
        })
        present(alert, animated: true)
    }
}

// MARK: - UIColor Extension
extension UIColor {
    convenience init?(hex: String) {
        let r, g, b, a: CGFloat

        if hex.hasPrefix("#") {
            let start = hex.index(hex.startIndex, offsetBy: 1)
            let hexColor = String(hex[start...])

            if hexColor.count == 8 {
                let scanner = Scanner(string: hexColor)
                var hexNumber: UInt64 = 0

                if scanner.scanHexInt64(&hexNumber) {
                    r = CGFloat((hexNumber & 0xff000000) >> 24) / 255
                    g = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
                    b = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
                    a = CGFloat(hexNumber & 0x000000ff) / 255

                    self.init(red: r, green: g, blue: b, alpha: a)
                    return
                }
            }

            if hexColor.count == 6 {
                let scanner = Scanner(string: hexColor)
                var hexNumber: UInt64 = 0

                if scanner.scanHexInt64(&hexNumber) {
                    r = CGFloat((hexNumber & 0xff0000) >> 16) / 255
                    g = CGFloat((hexNumber & 0x00ff00) >> 8) / 255
                    b = CGFloat((hexNumber & 0x0000ff)) / 255

                    self.init(red: r, green: g, blue: b, alpha: 1.0)
                    return
                }
            }
        }

        return nil
    }
}
