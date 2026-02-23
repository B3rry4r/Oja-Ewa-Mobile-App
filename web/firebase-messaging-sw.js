// Firebase Messaging Service Worker
// Required for FCM push notifications on web

importScripts('https://www.gstatic.com/firebasejs/10.7.1/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/10.7.1/firebase-messaging-compat.js');

// Initialize Firebase in the service worker
// These values must match your firebase_options.dart web config
firebase.initializeApp({
  apiKey: 'AIzaSyB1ZvZsIq0QvUNFjXqKqPsYUDb0SZ5PqlY',
  authDomain: 'oja-ewa.firebaseapp.com',
  projectId: 'oja-ewa',
  storageBucket: 'oja-ewa.firebasestorage.app',
  messagingSenderId: '443526782067',
  appId: '1:443526782067:web:d3991b0df971e699f1de06',
  measurementId: 'G-X9XKB4K3EC',
});

const messaging = firebase.messaging();

// Handle background messages
messaging.onBackgroundMessage(function(payload) {
  console.log('[firebase-messaging-sw.js] Received background message:', payload);

  const notificationTitle = payload.notification?.title || 'Ojaewa';
  const notificationOptions = {
    body: payload.notification?.body || '',
    icon: '/icons/Icon-192.png',
    badge: '/icons/Icon-192.png',
  };

  self.registration.showNotification(notificationTitle, notificationOptions);
});
