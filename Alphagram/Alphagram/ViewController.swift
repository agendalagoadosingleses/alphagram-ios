import UIKit
import WebKit

class ViewController: UIViewController, WKNavigationDelegate, WKUIDelegate {

    var webView: WKWebView!
    var activityIndicator: UIActivityIndicatorView!

    override func loadView() {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        config.mediaTypesRequiringUserActionForPlayback = []

        webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = self
        webView.uiDelegate = self
        webView.allowsBackForwardNavigationGestures = true
        webView.scrollView.bounces = true
        view = webView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Spinner de carregamento
        activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.center = view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.color = UIColor(red: 0.106, green: 0.176, blue: 0.310, alpha: 1) // navy
        view.addSubview(activityIndicator)

        loadApp()
    }

    func loadApp() {
        guard let url = URL(string: "https://alphagram.com.br") else { return }
        let request = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: 30)
        webView.load(request)
    }

    // ── WKNavigationDelegate ───────────────────────────────────────────────────

    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        activityIndicator.startAnimating()
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        activityIndicator.stopAnimating()
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        activityIndicator.stopAnimating()
        showOfflinePage()
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        activityIndicator.stopAnimating()
        showOfflinePage()
    }

    func showOfflinePage() {
        let html = """
        <html>
        <head>
          <meta name="viewport" content="width=device-width, initial-scale=1">
          <style>
            body { font-family: -apple-system; display: flex; flex-direction: column;
                   align-items: center; justify-content: center; height: 100vh; margin: 0;
                   background: #1B2D4F; color: white; text-align: center; padding: 20px; }
            h2 { font-size: 22px; margin-bottom: 8px; }
            p { font-size: 15px; opacity: 0.7; margin-bottom: 24px; }
            button { background: #C9A84C; color: #1B2D4F; border: none; padding: 14px 32px;
                     border-radius: 12px; font-size: 16px; font-weight: bold; cursor: pointer; }
          </style>
        </head>
        <body>
          <h2>Sem conexão</h2>
          <p>Verifique sua internet e tente novamente.</p>
          <button onclick="window.location.reload()">Tentar novamente</button>
        </body>
        </html>
        """
        webView.loadHTMLString(html, baseURL: nil)
    }

    // Abre links externos no Safari
    func webView(_ webView: WKWebView,
                 decidePolicyFor navigationAction: WKNavigationAction,
                 decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let url = navigationAction.request.url,
           navigationAction.navigationType == .linkActivated,
           !url.absoluteString.contains("alphagram.com.br") {
            UIApplication.shared.open(url)
            decisionHandler(.cancel)
            return
        }
        decisionHandler(.allow)
    }

    // Suporte a alert/confirm/prompt do JavaScript
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String,
                 initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in completionHandler() })
        present(alert, animated: true)
    }
}
