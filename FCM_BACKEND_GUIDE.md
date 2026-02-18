# FCM Backend Integration Guide

## ✅ Frontend Setup Complete

The Flutter app now:
1. ✅ Requests notification permissions
2. ✅ Gets FCM token automatically
3. ✅ Sends token to backend: `POST /api/notifications/device-token`
4. ✅ Refreshes token when needed
5. ✅ Deletes token on logout: `DELETE /api/notifications/device-token`

---

## 🔧 Backend Requirements

### 1. Create Laravel API Endpoints

#### A. Register Device Token
```php
// routes/api.php
Route::post('/notifications/device-token', [NotificationController::class, 'registerDeviceToken']);
```

```php
// app/Http/Controllers/NotificationController.php
public function registerDeviceToken(Request $request)
{
    $request->validate([
        'token' => 'required|string',
        'device_type' => 'nullable|string|in:ios,android,mobile',
    ]);

    // Store token for authenticated user
    $user = auth()->user();
    
    // Create or update device token
    $user->deviceTokens()->updateOrCreate(
        ['token' => $request->token],
        [
            'device_type' => $request->device_type ?? 'mobile',
            'last_used_at' => now(),
        ]
    );

    return response()->json([
        'status' => 'success',
        'message' => 'Device token registered',
    ]);
}
```

#### B. Delete Device Token
```php
public function deleteDeviceToken(Request $request)
{
    $request->validate([
        'token' => 'required|string',
    ]);

    auth()->user()->deviceTokens()->where('token', $request->token)->delete();

    return response()->json([
        'status' => 'success',
        'message' => 'Device token deleted',
    ]);
}
```

---

### 2. Database Migration

```php
// database/migrations/xxxx_create_device_tokens_table.php
Schema::create('device_tokens', function (Blueprint $table) {
    $table->id();
    $table->foreignId('user_id')->constrained()->onDelete('cascade');
    $table->string('token')->unique();
    $table->enum('device_type', ['ios', 'android', 'mobile'])->default('mobile');
    $table->timestamp('last_used_at')->nullable();
    $table->timestamps();
});
```

```php
// app/Models/User.php
public function deviceTokens()
{
    return $this->hasMany(DeviceToken::class);
}
```

---

### 3. Get Firebase Service Account Key

1. Go to: https://console.firebase.google.com
2. Select your project: **oja-ewa**
3. Click **⚙️ Settings** → **Service Accounts**
4. Click **"Generate new private key"**
5. Download the JSON file
6. Save it to your Laravel project: `storage/firebase-credentials.json`

---

### 4. Install Firebase Admin SDK (Laravel)

```bash
composer require kreait/firebase-php
```

---

### 5. Configure Firebase in Laravel

#### .env
```env
FIREBASE_CREDENTIALS=storage/firebase-credentials.json
```

#### config/services.php
```php
'firebase' => [
    'credentials' => env('FIREBASE_CREDENTIALS'),
],
```

---

### 6. Send Notifications from Backend

#### Create Notification Service
```php
// app/Services/FCMService.php
namespace App\Services;

use Kreait\Firebase\Factory;
use Kreait\Firebase\Messaging\CloudMessage;

class FCMService
{
    protected $messaging;

    public function __construct()
    {
        $factory = (new Factory)->withServiceAccount(config('services.firebase.credentials'));
        $this->messaging = $factory->createMessaging();
    }

    /**
     * Send notification to a specific user
     */
    public function sendToUser($user, $title, $body, $data = [])
    {
        $tokens = $user->deviceTokens()->pluck('token')->toArray();
        
        if (empty($tokens)) {
            return false;
        }

        return $this->sendToTokens($tokens, $title, $body, $data);
    }

    /**
     * Send notification to multiple tokens
     */
    public function sendToTokens(array $tokens, $title, $body, $data = [])
    {
        $message = CloudMessage::new()
            ->withNotification([
                'title' => $title,
                'body' => $body,
            ])
            ->withData($data);

        try {
            $report = $this->messaging->sendMulticast($message, $tokens);
            
            // Remove invalid tokens
            if ($report->hasFailures()) {
                foreach ($report->failures()->getItems() as $failure) {
                    $token = $failure->target()->value();
                    \App\Models\DeviceToken::where('token', $token)->delete();
                }
            }

            return true;
        } catch (\Exception $e) {
            \Log::error('FCM Error: ' . $e->getMessage());
            return false;
        }
    }

    /**
     * Send to topic
     */
    public function sendToTopic($topic, $title, $body, $data = [])
    {
        $message = CloudMessage::withTarget('topic', $topic)
            ->withNotification([
                'title' => $title,
                'body' => $body,
            ])
            ->withData($data);

        try {
            $this->messaging->send($message);
            return true;
        } catch (\Exception $e) {
            \Log::error('FCM Error: ' . $e->getMessage());
            return false;
        }
    }
}
```

---

### 7. Usage Examples

#### Send notification when order is placed
```php
// In your OrderController or event listener
use App\Services\FCMService;

$fcm = new FCMService();
$fcm->sendToUser(
    $order->user,
    'Order Confirmed',
    "Your order #${order->id} has been confirmed!",
    [
        'type' => 'order',
        'order_id' => $order->id,
        'action' => 'view_order',
    ]
);
```

#### Send notification to all users
```php
$users = User::whereHas('deviceTokens')->get();

foreach ($users as $user) {
    $fcm->sendToUser(
        $user,
        'New Promotion!',
        'Check out our latest deals',
        ['type' => 'promotion']
    );
}
```

#### Send to topic (broadcast)
```php
// Users subscribe to topics in app
$fcm->sendToTopic(
    'all_users',
    'Maintenance Notice',
    'App will be down for maintenance at 2 AM',
    ['type' => 'announcement']
);
```

---

## 📱 Testing

### 1. Test Token Registration
```bash
curl -X POST https://your-api.com/api/notifications/device-token \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "token": "test-fcm-token-here",
    "device_type": "ios"
  }'
```

### 2. Test Sending Notification
```php
// In tinker or controller
$user = User::find(1);
$fcm = new FCMService();
$fcm->sendToUser($user, 'Test', 'This is a test notification');
```

---

## 🔍 Troubleshooting

### iOS Not Receiving Notifications
1. ✅ APNs key uploaded to Firebase Console
2. ✅ Push Notifications capability enabled in Xcode
3. ✅ App installed on physical device (not simulator)
4. ✅ Permissions granted in app

### Android Not Receiving Notifications
1. ✅ google-services.json in android/app/
2. ✅ GCM enabled in Firebase Console
3. ✅ Internet permission in AndroidManifest.xml

### Backend Issues
1. Check Firebase credentials path in .env
2. Verify service account JSON is valid
3. Check Laravel logs: `tail -f storage/logs/laravel.log`

---

## 📝 Summary

**Frontend sends:**
- Token to: `POST /api/notifications/device-token`
- Data: `{ "token": "...", "device_type": "ios" }`

**Backend needs:**
1. Database table: `device_tokens`
2. API endpoints: register & delete token
3. Firebase Admin SDK installed
4. Service account JSON file
5. FCMService class to send notifications

**That's it! Your push notifications are ready to work!** 🎉
