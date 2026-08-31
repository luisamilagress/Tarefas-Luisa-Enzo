import SwiftUI
import WebKit

struct DuoWebView: UIViewRepresentable {
    let user: String
    let onLogout: () -> Void

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        let controller = WKUserContentController()

        if let token = SharedSession.token {
            let script = """
            localStorage.setItem('tl_token', '\(token)');
            localStorage.setItem('tl_user', '\(user)');
            """
            controller.addUserScript(WKUserScript(source: script, injectionTime: .atDocumentStart, forMainFrameOnly: true))
        }
        config.userContentController = controller

        let web = WKWebView(frame: .zero, configuration: config)
        web.load(URLRequest(url: DuoConfig.siteURL))
        return web
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}
}
