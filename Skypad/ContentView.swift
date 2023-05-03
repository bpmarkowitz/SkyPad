import SwiftUI
import WebKit

struct ContentView: View {
    var body: some View {
        WebView(url: URL(string: "https://staging.bsky.app")!)
            .preferredColorScheme(.light)
    }
}

class Coordinator: NSObject, WKNavigationDelegate, UIGestureRecognizerDelegate, WKUIDelegate {
    let parent: WebView
    var webView: WKWebView?

    init(_ parent: WebView) {
        self.parent = parent
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        // Save a reference to the WKWebView instance
        self.webView = webView
        
        // Reset the refresh control
        parent.refreshControl.endRefreshing()
    }

    @objc func refreshWebView() {
        webView?.reload() // Use the saved reference to reload the WKWebView
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let targetURL = navigationAction.request.url {
            if targetURL.host == parent.url.host {
                decisionHandler(.allow)
            } else {
                decisionHandler(.cancel)
                UIApplication.shared.open(targetURL)
            }
        } else {
            decisionHandler(.cancel)
        }
    }

    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if let targetURL = navigationAction.request.url, targetURL.host != parent.url.host {
            UIApplication.shared.open(targetURL)
        }
        return nil
    }
    
    @objc func goBack(_ sender: UISwipeGestureRecognizer) {
        if let webView = webView, webView.canGoBack {
            webView.goBack()
        }
    }

    @objc func didTapWebView(_ sender: UITapGestureRecognizer) {
        guard let webView = sender.view as? WKWebView else { return }
        let point = sender.location(in: webView)
        let x = point.x
        let y = point.y

        webView.evaluateJavaScript("document.elementFromPoint(\(x), \(y)).href") { result, error in
            if let urlString = result as? String, let url = URL(string: urlString) {
                if url.host != self.parent.url.host {
                    UIApplication.shared.open(url)
                }
            }
        }
    }
}

struct WebView: UIViewRepresentable {
    let url: URL
    let refreshControl = UIRefreshControl()

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        webView.uiDelegate = context.coordinator
        webView.load(URLRequest(url: url))
        
        // Add refresh control
        refreshControl.addTarget(context.coordinator, action: #selector(Coordinator.refreshWebView), for: .valueChanged)
        webView.scrollView.addSubview(refreshControl)
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.didTapWebView(_:)))
        webView.addGestureRecognizer(tapGestureRecognizer)

        let swipeBackRecognizer = UISwipeGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.goBack(_:)))
        swipeBackRecognizer.direction = .right
        webView.addGestureRecognizer(swipeBackRecognizer)
        
        webView.scrollView.bounces = false
        
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        if uiView.url != url {
            uiView.load(URLRequest(url: url))
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
