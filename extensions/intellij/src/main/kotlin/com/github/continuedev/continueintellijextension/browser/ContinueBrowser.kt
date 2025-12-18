package com.github.continuedev.continueintellijextension.browser

import com.github.continuedev.continueintellijextension.constants.MessageTypes
import com.github.continuedev.continueintellijextension.services.ContinuePluginService
import com.github.continuedev.continueintellijextension.utils.uuid
import com.google.gson.Gson
import com.intellij.openapi.Disposable
import com.intellij.openapi.components.service
import com.intellij.openapi.diagnostic.Logger
import com.intellij.openapi.project.Project
import com.intellij.openapi.util.Disposer
import com.intellij.ui.jcef.*
import org.cef.CefApp
import org.cef.browser.CefBrowser
import org.cef.handler.CefLoadHandlerAdapter
import org.cef.handler.CefDisplayHandlerAdapter
import org.cef.browser.CefMessageRouter
import javax.swing.JComponent

class ContinueBrowser(private val project: Project): Disposable {

    private val log = Logger.getInstance(ContinueBrowser::class.java.simpleName)
    private val browser: JBCefBrowser = JBCefBrowser.createBuilder().setOffScreenRendering(true).build()
    private val myJSQueryOpenInBrowser = JBCefJSQuery.create(browser as JBCefBrowserBase)
    
    // VaultAI: Queue messages until page is loaded
    private var isPageLoaded = false
    private val messageQueue = mutableListOf<Triple<String, Any?, String>>()

    init {
        CefApp.getInstance().registerSchemeHandlerFactory("http", "continue", CustomSchemeHandlerFactory())
        browser.jbCefClient.setProperty(JBCefClient.Properties.JS_QUERY_POOL_SIZE, 200)
        myJSQueryOpenInBrowser.addHandler { msg: String? ->
            val json = Gson().fromJson(msg, BrowserMessage::class.java)
            val messageType = json.messageType
            val data = json.data
            val messageId = json.messageId

            if (MessageTypes.PASS_THROUGH_TO_CORE.contains(messageType)) {
                project.service<ContinuePluginService>().coreMessenger?.request(messageType, data, messageId) { data ->
                    sendToWebview(messageType, data, messageId ?: uuid())
                }
                return@addHandler null
            }

            // If not pass through, then put it in the status/content/done format for webview
            // Core already sends this format
            if (msg != null) {
                project.service<ContinuePluginService>().ideProtocolClient?.handleMessage(msg) { data ->
                    sendToWebview(
                        messageType,
                        mapOf(
                            "status" to "success",
                            "content" to data,
                            "done" to true
                        ),
                        messageId ?: uuid()
                    )
                }
            }

            null
        }

        // Add console message handler to see webview logs
        browser.jbCefClient.addDisplayHandler(object : CefDisplayHandlerAdapter() {
            override fun onConsoleMessage(
                browser: CefBrowser?,
                level: org.cef.CefSettings.LogSeverity?,
                message: String?,
                source: String?,
                line: Int
            ): Boolean {
                println("[WEBVIEW CONSOLE] $message")
                return false
            }
        }, browser.cefBrowser)
        
        browser.jbCefClient.addLoadHandler(OnPageLoad {
            System.err.println("[VAULTAI DEBUG] Page loaded! Executing init JavaScript")
            executeJavaScript(myJSQueryOpenInBrowser)
            // VaultAI: Mark page as loaded and flush queued messages
            isPageLoaded = true
            System.err.println("[VAULTAI DEBUG] Flushing ${messageQueue.size} queued messages")
            synchronized(messageQueue) {
                messageQueue.forEach { (messageType, data, messageId) ->
                    System.err.println("[VAULTAI DEBUG] Flushing queued message: $messageType")
                    sendToWebviewDirect(messageType, data, messageId)
                }
                messageQueue.clear()
            }
            System.err.println("[VAULTAI DEBUG] All messages flushed")
        }, browser.cefBrowser)

        // Load the url only after the protocolClient is initialized,
        // otherwise some messages will be lost, which are some configurations when the page is loaded.
        // Moreover, we should add LoadHandler before loading the url.
        project.service<ContinuePluginService>().onProtocolClientInitialized {
            browser.loadURL(getGuiUrl())
        }

        browser.createImmediately()
    }

    fun getComponent(): JComponent =
        browser.component

    fun focusOnInput() {
        browser.component.components?.get(0)?.requestFocus()
    }

    fun openDevTools() {
        browser.openDevtools()
    }

    fun sendToWebview(messageType: String, data: Any? = null, messageId: String = uuid()) {
        System.err.println("[VAULTAI DEBUG] sendToWebview called: messageType=$messageType, isPageLoaded=$isPageLoaded")
        // VaultAI: Queue messages if page is not loaded yet
        if (!isPageLoaded) {
            synchronized(messageQueue) {
                messageQueue.add(Triple(messageType, data, messageId))
            }
            log.info("Queued message $messageType (page not loaded yet)")
            System.err.println("[VAULTAI DEBUG] Message queued (page not loaded): $messageType")
            return
        }
        sendToWebviewDirect(messageType, data, messageId)
    }
    
    private fun sendToWebviewDirect(messageType: String, data: Any? = null, messageId: String = uuid()) {
        val json = Gson().toJson(BrowserMessage(messageType, messageId, data))
        System.err.println("[VAULTAI DEBUG] Sending to webview: $json")
        val jsCode = """window.postMessage($json, "*");""" 
        try {
            browser.executeJavaScriptAsync(jsCode)
            System.err.println("[VAULTAI DEBUG] JavaScript executed successfully")
        } catch (error: IllegalStateException) {
            System.err.println("[VAULTAI DEBUG] Failed to execute JavaScript: $error")
            log.warn(error)
        }
    }

    private fun executeJavaScript(myJSQueryOpenInBrowser: JBCefJSQuery) {
        val script = """
            window.postIntellijMessage = function(messageType, data, messageId) {
                const msg = JSON.stringify({messageType, data, messageId});
                ${myJSQueryOpenInBrowser.inject("msg")}
            }
            """
        browser.cefBrowser.executeJavaScript(script, getGuiUrl(), 0)
    }

    override fun dispose() {
        Disposer.dispose(myJSQueryOpenInBrowser)
        Disposer.dispose(browser)
    }

    // todo: remove and use types.Message
    private data class BrowserMessage(
        val messageType: String,
        val messageId: String?,
        val data: Any?
    )

    private class OnPageLoad(
        private val onLoad: () -> Unit
    ) : CefLoadHandlerAdapter() {
        override fun onLoadingStateChange(
            browser: CefBrowser?,
            isLoading: Boolean,
            canGoBack: Boolean,
            canGoForward: Boolean
        ) {
            if (!isLoading)
                onLoad()
        }
    }

    private companion object {

        private fun getGuiUrl() =
            System.getenv("GUI_URL") ?: "http://continue/index.html"

    }

}