import SwiftUI
import WebKit
import UniformTypeIdentifiers

struct WebView: UIViewRepresentable {
    let url: URL
    @Binding var isLoading: Bool
    @Binding var canGoBack: Bool
    var webViewStore: WebViewStore

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        config.mediaTypesRequiringUserActionForPlayback = []
        config.defaultWebpagePreferences.allowsContentJavaScript = true

        let webView = WKWebView(frame: .zero, configuration: config)
        webView.customUserAgent = (webView.value(forKey: "userAgent") as? String ?? "") + " SferaIOS/1.0"
        webView.navigationDelegate = context.coordinator
        webView.uiDelegate = context.coordinator
        webView.allowsBackForwardNavigationGestures = true
        webView.scrollView.contentInsetAdjustmentBehavior = .never
        webView.isOpaque = false
        webView.backgroundColor = UIColor(red: 0.12, green: 0.12, blue: 0.13, alpha: 1)

        webViewStore.webView = webView
        webView.load(URLRequest(url: url))
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        if context.coordinator.loadedURL != url.absoluteString {
            context.coordinator.loadedURL = url.absoluteString
            webView.load(URLRequest(url: url))
        }
    }

    final class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate {
        private let parent: WebView
        var loadedURL: String?

        init(_ parent: WebView) {
            self.parent = parent
        }

        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            parent.isLoading = true
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            parent.isLoading = false
            parent.canGoBack = webView.canGoBack
            injectMobileHints(webView)
        }

        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            parent.isLoading = false
        }

        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            parent.isLoading = false
        }

        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            parent.canGoBack = webView.canGoBack
            if let url = navigationAction.request.url,
               let scheme = url.scheme?.lowercased(),
               scheme != "http", scheme != "https" {
                UIApplication.shared.open(url)
                decisionHandler(.cancel)
                return
            }
            decisionHandler(.allow)
        }

        @available(iOS 15.0, *)
        func webView(_ webView: WKWebView, requestMediaCapturePermissionFor origin: WKSecurityOrigin, initiatedByFrame frame: WKFrameInfo, type: WKMediaCaptureType, decisionHandler: @escaping (WKPermissionDecision) -> Void) {
            decisionHandler(.grant)
        }

        func webView(_ webView: WKWebView, runOpenPanelWith parameters: WKOpenPanelParameters, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping ([URL]?) -> Void) {
            let picker = UIDocumentPickerViewController(forOpeningContentTypes: [.item, .image, .movie, .pdf], asCopy: true)
            DocumentPickerBridge.shared.present(picker) { urls in
                completionHandler(urls)
            }
        }

        private func injectMobileHints(_ webView: WKWebView) {
            let js = """
            (function() {
              document.documentElement.classList.add('sfera-ios');
              if (document.body) document.body.classList.add('is-mobile');
              var meta = document.querySelector('meta[name=viewport]');
              if (!meta) {
                meta = document.createElement('meta');
                meta.name = 'viewport';
                document.head.appendChild(meta);
              }
              meta.content = 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no, viewport-fit=cover';
            })();
            """
            webView.evaluateJavaScript(js, completionHandler: nil)
        }
    }
}

final class WebViewStore: ObservableObject {
    weak var webView: WKWebView?

    func reload() { webView?.reload() }
    func goBack() { webView?.goBack() }
}

/// Helper for document picker from WKUIDelegate
final class DocumentPickerBridge: NSObject, UIDocumentPickerDelegate {
    static let shared = DocumentPickerBridge()
    private var completion: (([URL]?) -> Void)?

    func present(_ picker: UIDocumentPickerViewController, completion: @escaping ([URL]?) -> Void) {
        self.completion = completion
        picker.delegate = self
        picker.allowsMultipleSelection = false
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let root = scene.windows.first?.rootViewController else {
            completion(nil)
            return
        }
        var top = root
        while let presented = top.presentedViewController { top = presented }
        top.present(picker, animated: true)
    }

    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        completion?(urls)
        completion = nil
    }

    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        completion?(nil)
        completion = nil
    }
}
