package com.parking.findmycar;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.graphics.Color;
import android.os.Bundle;
import android.view.View;
import android.view.WindowInsets;
import android.webkit.WebResourceError;
import android.webkit.WebResourceRequest;
import android.webkit.WebSettings;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import android.widget.FrameLayout;

/**
 * 내 차 찾기 앱.
 * 앱에 넣어 둔 PWA 화면(web/index.html)을 띄우고,
 * 「내 차 찾으러 가기」를 누르면 주차장 웹을 앱 안에서 그대로 연다.
 */
public class MainActivity extends Activity {

    private static final String HOME = "file:///android_asset/index.html";
    private static final String OFFLINE = "file:///android_asset/offline.html";

    private WebView webView;

    @SuppressLint("SetJavaScriptEnabled")
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        FrameLayout root = new FrameLayout(this);
        root.setBackgroundColor(Color.parseColor("#0F2A44"));

        webView = new WebView(this);
        webView.setBackgroundColor(Color.parseColor("#EEF2F6"));
        root.addView(webView, new FrameLayout.LayoutParams(
                FrameLayout.LayoutParams.MATCH_PARENT,
                FrameLayout.LayoutParams.MATCH_PARENT));

        // 상태바·내비게이션바 아래로 화면이 들어가지 않게 여백을 준다 (Android 15 화면 끝까지 그리기 대응)
        root.setOnApplyWindowInsetsListener((View v, WindowInsets insets) -> {
            v.setPadding(
                    insets.getSystemWindowInsetLeft(),
                    insets.getSystemWindowInsetTop(),
                    insets.getSystemWindowInsetRight(),
                    insets.getSystemWindowInsetBottom());
            return insets;
        });

        WebSettings s = webView.getSettings();
        s.setJavaScriptEnabled(true);
        s.setDomStorageEnabled(true);
        s.setDatabaseEnabled(true);
        s.setLoadWithOverviewMode(true);
        s.setUseWideViewPort(true);
        s.setSupportZoom(false);
        s.setMediaPlaybackRequiresUserGesture(false);

        webView.setWebViewClient(new WebViewClient() {
            @Override
            public boolean shouldOverrideUrlLoading(WebView view, WebResourceRequest request) {
                // 모든 주소를 앱 안에서 연다
                return false;
            }

            @Override
            public void onReceivedError(WebView view, WebResourceRequest request, WebResourceError error) {
                // 화면 전체를 못 불러왔을 때만 오프라인 안내로 바꾼다 (글꼴·이미지 실패는 무시)
                if (request.isForMainFrame()) {
                    view.loadUrl(OFFLINE);
                }
            }
        });

        setContentView(root);
        root.requestApplyInsets();

        if (savedInstanceState != null) {
            webView.restoreState(savedInstanceState);
        } else {
            webView.loadUrl(HOME);
        }
    }

    @Override
    protected void onSaveInstanceState(Bundle outState) {
        super.onSaveInstanceState(outState);
        webView.saveState(outState);
    }

    @SuppressWarnings("deprecation")
    @Override
    public void onBackPressed() {
        // 뒤로가기: 주차장 화면에서 이전 화면으로, 첫 화면이면 앱 종료
        if (webView.canGoBack()) {
            webView.goBack();
        } else {
            super.onBackPressed();
        }
    }

    @Override
    protected void onDestroy() {
        if (webView != null) {
            webView.destroy();
        }
        super.onDestroy();
    }
}
