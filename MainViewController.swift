//
//  MainViewController.swift
//  test
//
//  Created by Lee on 2017/5/16.
//  Copyright © 2017年 Lee. All rights reserved.
//

import UIKit
import WebKit
class MainViewController: ViewController {
    
    
    lazy var webView:WKWebView = {
        //创建webview的一个配置项
        let configuration = WKWebViewConfiguration()
        //webview的偏好设置
        
        
        configuration.userContentController = WKUserContentController()
        configuration.preferences = WKPreferences()
        configuration.preferences.minimumFontSize = 10
        configuration.preferences.javaScriptEnabled = true
        //默认是不能通过js自动打开窗口的,必须通过用户交互才能打开
        configuration.preferences.javaScriptCanOpenWindowsAutomatically = true
        //创建webview
        let width = UIScreen.main.bounds.size.width
        let height = UIScreen.main.bounds.size.height
        let webView:WKWebView = WKWebView(frame: CGRect(x: 0, y: 20, width: width, height: height - 20), configuration: configuration)
        webView.navigationDelegate = self
        webView.uiDelegate = self
        return webView
    }()
    


    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(webView)
        let path:String = Bundle.main.path(forResource: "index", ofType: "html")!
        let url:URL = URL(fileURLWithPath: path)
        webView.load(URLRequest(url: url))

        
        // Do any additional setup after loading the view.
    }
    
    func goback() {
        if webView.canGoBack {
            webView.goBack()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}


extension MainViewController:WKNavigationDelegate{
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        //适配打电话 发短信 邮件
        let url = navigationAction.request.url
        let scheme = url?.scheme
        guard let schemeStr = scheme else { return  }
        switch schemeStr {
        case "tel":
            UIApplication.shared.open(url!, options: [String : Any](), completionHandler: nil)
            break
        case "sms":
            guard let description = url?.description else { return  }
            let tel:String = description.components(separatedBy: "?").first!
            let msg:String = (description.components(separatedBy: "body=").last?.removingPercentEncoding!)!
            print(msg)
            let sendMsg:String = "sms:\(tel)"
            //短信内容 自动填充暂时 还没发现
            UIApplication.shared.open(URL(string: sendMsg)!, options: [String:Any](), completionHandler: nil)
            break
        case "mailto":
            guard let description = url?.description else { return  }
            print(description)
            UIApplication.shared.open(url!, options: [String : Any](), completionHandler: nil)
            break
        default: break
            
        }

        
        
        if navigationAction.targetFrame == nil {
            webView.load(navigationAction.request)
        }
        
        /*
        if navigationAction.targetFrame == nil {
            webView.evaluateJavaScript("var a = document.getElementsByTagName('a');for(var i=0;i<a.length;i++){a[i].setAttribute('target','');}" , completionHandler: { (objc, error) in
                        
            })
        }
        */


        decisionHandler(.allow)
    }
    
    /*
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if navigationAction.targetFrame == nil {
            let url = navigationAction.request.url
            if url?.description.lowercased().range(of: "http://") != nil || url?.description.lowercased().range(of: "https://") != nil || url?.description.lowercased().range(of: "mailto:") != nil  {
                webView.load(URLRequest(url: url!))
            }
        }
        return nil
    }
    */
}

extension MainViewController:WKUIDelegate{
    
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        let alertController:UIAlertController = UIAlertController(title: "提示", message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "确认", style: .default, handler: { (action) in
            completionHandler()
        }))
        self.present(alertController, animated: true) {
            
        }
    }
    
    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        let alertController:UIAlertController = UIAlertController(title: "提示", message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "确认", style: .default, handler: { (action) in
            completionHandler(true)
        }))
        alertController.addAction(UIAlertAction(title: "取消", style: .default, handler: { (action) in
            completionHandler(false)
        }))
        self.present(alertController, animated: true) {
            
        }
    }
    
    func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (String?) -> Void) {
        let alertController:UIAlertController = UIAlertController(title: prompt, message: "", preferredStyle: .alert)
        alertController.addTextField { (textField) in
            textField.text = defaultText
        }
        alertController.addAction(UIAlertAction(title: "完成", style: .default, handler: { (action) in
            completionHandler(alertController.textFields?.first?.text)
        }))
    }

}
