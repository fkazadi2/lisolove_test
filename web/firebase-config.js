// Firebase configuration
const firebaseConfig = {
  apiKey: "API_KEY_REMOVED",
  authDomain: "lisolove-8bf12.firebaseapp.com",
  projectId: "lisolove-8bf12",
  storageBucket: "lisolove-8bf12.firebasestorage.app",
  messagingSenderId: "${FIREBASE_GCM_SENDER_ID}",
  appId: "${FIREBASE_GOOGLE_APP_ID}",
};

// Initialize Firebase
firebase.initializeApp(firebaseConfig); 