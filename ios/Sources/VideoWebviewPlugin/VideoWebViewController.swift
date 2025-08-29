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
    
    // Closure para notificar cuando se cierra
    public var onClose: (() -> Void)?

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

        let headerHeight: CGFloat = 50
        let statusBarHeight: CGFloat = UIApplication.shared.statusBarFrame.height

        let header = UIView(frame: CGRect(x: 0, y: statusBarHeight, width: view.frame.width, height: headerHeight))
        header.backgroundColor = UIColor(red: 60/255, green: 84/255, blue: 134/255, alpha: 1.0) // #3C5486
        view.addSubview(header)

        // 🔹 Título
        let titleLabel = UILabel(frame: CGRect(x: 50, y: 0, width: view.frame.width - 100, height: headerHeight))
        
        if #available(iOS 13.0, *) {
            titleLabel.overrideUserInterfaceStyle = .light
        }

        titleLabel.text = title
        titleLabel.textAlignment = .center
        titleLabel.textColor = UIColor.white
        titleLabel.backgroundColor = .clear
        titleLabel.layer.shadowColor = UIColor.clear.cgColor
        titleLabel.layer.shadowOpacity = 0
        titleLabel.layer.shadowOffset = .zero
        titleLabel.layer.shadowRadius = 0
        header.addSubview(titleLabel)

        // 🔹 Botón de regreso
        let backButton = UIButton(frame: CGRect(x: 10, y: 0, width: 40, height: headerHeight))
        let backImage = UIImage(systemName: "chevron.left")?.withRenderingMode(.alwaysTemplate)
        backButton.setImage(backImage, for: .normal)
        backButton.tintColor = .white
        backButton.setTitleColor(.white, for: .normal)
        backButton.backgroundColor = .clear
        backButton.adjustsImageWhenHighlighted = false
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        header.addSubview(backButton)
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
        
        // Agregar script para permitir cerrar desde JavaScript
        let closeScript = """
            window.closeVideoWebview = function() {
                window.webkit.messageHandlers.closeHandler.postMessage('close');
            };
        """
        let closeUserScript = WKUserScript(source: closeScript, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        config.userContentController.addUserScript(closeUserScript)
        config.userContentController.add(self, name: "closeHandler")

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
        if debugEnabled {
            if #available(iOS 16.4, *) {
                webView.isInspectable = true
            }
        }

        view.addSubview(webView)
        
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    @objc private func backButtonTapped() {
        print("🔙 VideoWebView: Back button tapped")
        
        // Verificar si el WebView puede ir hacia atrás en su historial
        if webView.canGoBack {
            print("🔙 VideoWebView: WebView can go back, navigating back")
            webView.goBack()
            return
        }
        
        // Si no puede ir hacia atrás en el WebView, cerrar el controlador
        print("🔙 VideoWebView: Closing WebView controller")
        
        // Ejecutar el closure de cierre si está definido
        onClose?()
        
        // Verificar si estamos en un navigation controller
        if let navController = self.navigationController {
            print("🔙 VideoWebView: Usando navigation controller")
            // Si hay más de un view controller en el stack, hacer pop
            if navController.viewControllers.count > 1 {
                navController.popViewController(animated: true)
            } else {
                // Si es el root view controller del navigation controller, dismiss todo
                navController.dismiss(animated: true, completion: nil)
            }
        } else {
            print("🔙 VideoWebView: Usando dismiss directo")
            // Si no hay navigation controller, hacer dismiss directo
            dismiss(animated: true, completion: nil)
        }
        
        // Método alternativo: intentar cerrar desde el presentingViewController
        if let presentingVC = self.presentingViewController {
            print("🔙 VideoWebView: Usando presentingViewController como fallback")
            presentingVC.dismiss(animated: true, completion: nil)
        }
    }
}

// MARK: - WKScriptMessageHandler
extension VideoWebViewController: WKScriptMessageHandler {
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "closeHandler" {
            print("🔙 VideoWebView: Close requested from JavaScript")
            backButtonTapped()
        }
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
    @available(iOS 15.0, *)
    public func webView(_ webView: WKWebView, requestMediaCapturePermissionFor origin: WKSecurityOrigin, initiatedByFrame frame: WKFrameInfo, type: WKMediaCaptureType, decisionHandler: @escaping (WKPermissionDecision) -> Void) {
        // Otorgar permisos automáticamente si la app tiene los permisos del sistema
        decisionHandler(.grant)
    }

    @available(iOS 15.0, *)
    public func webView(_ webView: WKWebView, requestDeviceOrientationAndMotionPermissionFor origin: WKSecurityOrigin, initiatedByFrame frame: WKFrameInfo, decisionHandler: @escaping (WKPermissionDecision) -> Void) {
        decisionHandler(.grant)
    }
    
    // Fallback para iOS 13-14
    public func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (String?) -> Void) {
        let alert = UIAlertController(title: nil, message: prompt, preferredStyle: .alert)
        alert.addTextField { textField in
            textField.text = defaultText
        }
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            completionHandler(alert.textFields?.first?.text)
        })
        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel) { _ in
            completionHandler(nil)
        })
        present(alert, animated: true)
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
