// Register event listener for the 'push' event.
self.addEventListener("push", function (event) {
  // Keep the service worker alive until the notification is created.
  event.waitUntil(
    // Show a notification with title and body
    self.registration.showNotification("Story App", {
      body: event.data.text(),
      icon: "/icons/Icon-192.png",
      badge: "/icons/Icon-192.png",
      vibrate: [200, 100, 200],
    })
  );
});
