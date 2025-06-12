// Register service worker for push notifications
if ("serviceWorker" in navigator) {
  navigator.serviceWorker
    .register("/service-worker.js")
    .then(function (registration) {
      console.log("Service Worker registered with scope:", registration.scope);

      // Request notification permission
      if ("Notification" in window) {
        Notification.requestPermission().then(function (permission) {
          if (permission === "granted") {
            console.log("Notification permission granted");

            // Subscribe to push notifications
            registration.pushManager
              .subscribe({
                userVisibleOnly: true,
                applicationServerKey:
                  "BCDx2enWG-d0FqFaMg-U7FaMg-1ODxN1WxUlKx+hPmBkt3DrZJqxvzrxBXwuTVR3pH7DONgBf1oGvxlhlcLyPWk",
              })
              .then(function (subscription) {
                // Pass subscription details to Flutter
                if (window.flutter_inappwebview) {
                  window.flutter_inappwebview.callHandler(
                    "onPushSubscription",
                    {
                      endpoint: subscription.endpoint,
                      keys: {
                        p256dh: btoa(
                          String.fromCharCode.apply(
                            null,
                            new Uint8Array(subscription.getKey("p256dh"))
                          )
                        ),
                        auth: btoa(
                          String.fromCharCode.apply(
                            null,
                            new Uint8Array(subscription.getKey("auth"))
                          )
                        ),
                      },
                    }
                  );
                }
              });
          }
        });
      }
    })
    .catch(function (err) {
      console.log("Service Worker registration failed:", err);
    });
}
