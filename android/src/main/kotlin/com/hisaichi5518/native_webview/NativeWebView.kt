package com.hisaichi5518.native_webview

import android.annotation.SuppressLint
import android.content.Context
import android.os.IBinder
import android.view.*
import android.widget.LinearLayout
import android.widget.TextView
import io.flutter.plugin.common.MethodChannel

class NativeWebView(context: Context, channel: MethodChannel, options: WebViewOptions) : InputAwareWebView(context, null as View?) {
    init {
        webViewClient = NativeWebViewClient(channel, options)
        webChromeClient = NativeWebChromeClient(channel)
        @SuppressLint("SetJavaScriptEnabled")
        settings.javaScriptEnabled = true
        settings.domStorageEnabled = true
        settings.javaScriptCanOpenWindowsAutomatically = true
        settings.useWideViewPort = true
        settings.loadWithOverviewMode = true
        addJavascriptInterface(JavascriptHandler(channel), NativeWebChromeClient.JAVASCRIPT_BRIDGE_NAME)
    }

    fun load(initialData: Map<String, String>?, initialFile: String?, initialURL: String, initialHeaders: Map<String, String>?) {
        initialData?.let {
            val data = it["data"]
            val mimeType = it["mimeType"]
            val encoding = it["encoding"]
            val baseUrl = it["baseUrl"]
            val historyUrl = it["historyUrl"]
            loadDataWithBaseURL(baseUrl, data, mimeType, encoding, historyUrl)
            return
        }

        initialFile?.let { path ->
            val filename = Locator.binding!!.flutterAssets.getAssetFilePathByName(path)
            loadUrl("file:///android_asset/${filename}", initialHeaders)
            return
        }

        loadUrl(initialURL, initialHeaders)
    }
}