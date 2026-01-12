// Import and configure the Firebase SDK
// These scripts are made available when the app is served or deployed on Firebase Hosting
// Using Firebase v10 for better compatibility
importScripts('https://www.gstatic.com/firebasejs/10.7.1/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/10.7.1/firebase-messaging-compat.js');

// Initialize the Firebase app in the service worker by passing in
// your app's Firebase config object.
// https://firebase.google.com/docs/web/setup#config-object
firebase.initializeApp({
  apiKey: 'AIzaSyAHAhCUE1lv93PJ_tAIHAol-iXQYrIFeAk',
  appId: '1:608702054226:web:8874b451e1bec42d18848b',
  messagingSenderId: '608702054226',
  projectId: 'scout-app-bf566',
  authDomain: 'scout-app-bf566.firebaseapp.com',
  storageBucket: 'scout-app-bf566.firebasestorage.app',
  measurementId: 'G-55SZ8EH5ZB',
});

// Retrieve an instance of Firebase Messaging so that it can handle background
// messages.
const messaging = firebase.messaging();

// Optional: Handle background messages
messaging.onBackgroundMessage((payload) => {
  console.log('[firebase-messaging-sw.js] Received background message ', payload);
  // Customize notification here
  const notificationTitle = payload.notification?.title || 'Nouvelle notification';
  const notificationOptions = {
    body: payload.notification?.body || 'Vous avez reçu une nouvelle notification',
    icon: '/icons/Icon-192.png',
  };

  self.registration.showNotification(notificationTitle, notificationOptions);
});
