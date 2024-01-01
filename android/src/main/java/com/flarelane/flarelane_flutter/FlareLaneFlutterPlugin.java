package com.flarelane.flarelane_flutter;

import android.content.Context;
import android.os.Handler;
import android.os.Looper;
import android.util.Log;

import androidx.annotation.NonNull;

import com.flarelane.FlareLane;
import com.flarelane.Notification;
import com.flarelane.NotificationClickedHandler;
import com.flarelane.NotificationForegroundReceivedHandler;
import com.flarelane.NotificationReceivedEvent;
import com.flarelane.SdkType;

import org.json.JSONObject;

import java.util.ArrayList;
import java.util.HashMap;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

/**
 * FlareLaneFlutterPlugin
 */
public class FlareLaneFlutterPlugin implements FlutterPlugin, MethodCallHandler {
  static Context mContext;

  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private MethodChannel channel;

  private HashMap<String, NotificationReceivedEvent> notificationEventCache = new HashMap<String, NotificationReceivedEvent>();

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    mContext = flutterPluginBinding.getApplicationContext();
    channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "com.flarelane.flutter/methods");
    channel.setMethodCallHandler(this);

    FlareLane.SdkInfo.type = SdkType.FLUTTER;
    FlareLane.SdkInfo.version = "1.5.0";
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    try {
      if (call.method.equals("initialize")) {
        final HashMap<String, Object> args = call.arguments();
        final String projectId = String.valueOf(args.get("projectId"));
        final Boolean requestPermissionOnLaunch = args.get("requestPermissionOnLaunch") instanceof Boolean ? (Boolean) args.get("requestPermissionOnLaunch") : false;
        FlareLane.initWithContext(mContext, projectId, requestPermissionOnLaunch);
        result.success(true);
      } else if (call.method.equals("setLogLevel")) {
        final int intLogLevel = call.arguments();
        FlareLane.setLogLevel(intLogLevel);
        result.success(true);
      } else if (call.method.equals("setUserId")) {
        final String userId = call.arguments();
        FlareLane.setUserId(mContext, userId);
        result.success(true);
      } else if (call.method.equals("getTags")) {
        FlareLane.getTags(mContext, new FlareLane.GetTagsHandler() {
          @Override
          public void onReceiveTags(JSONObject tags) {
            try {
              result.success(Utils.jsonToMap(tags));
            } catch (Exception e) {
              result.error("FlareLane Error", "The provided tags is invalid.", null);
            }
          }
        });
      } else if (call.method.equals("setTags")) {
        final HashMap<String, Object> tags = call.arguments();
        final JSONObject json = new JSONObject(tags);
        FlareLane.setTags(mContext, json);
        result.success(true);
      } else if (call.method.equals("deleteTags")) {
        final ArrayList<String> tags = call.arguments();
        FlareLane.deleteTags(mContext, tags);
        result.success(true);
      } else if (call.method.equals("subscribe")) {
        final Boolean fallbackToSettings = call.arguments();
        FlareLane.subscribe(mContext, fallbackToSettings, new FlareLane.IsSubscribedHandler() {
          @Override
          public void onSuccess(boolean isSubscribed) {
            result.success(isSubscribed);
          }
        });
      } else if (call.method.equals("unsubscribe")) {
        FlareLane.unsubscribe(mContext, new FlareLane.IsSubscribedHandler() {
          @Override
          public void onSuccess(boolean isSubscribed) {
            result.success(isSubscribed);
          }
        });
      } else if (call.method.equals("isSubscribed")) {
        final boolean isSubscribed = FlareLane.isSubscribed(mContext);
        result.success(isSubscribed);
      } else if (call.method.equals("setNotificationClickedHandler")) {
        FlareLane.setNotificationClickedHandler(new NotificationClickedHandler() {
          @Override
          public void onClicked(Notification notification) {
            invokeMethodOnUiThread("setNotificationClickedHandlerInvokeCallback", notification.toHashMap());
          }
        });

        result.success(true);
      } else if (call.method.equals("setNotificationForegroundReceivedHandler")) {
        FlareLane.setNotificationForegroundReceivedHandler(new NotificationForegroundReceivedHandler() {
          @Override
          public void onWillDisplay(NotificationReceivedEvent notificationReceivedEvent) {
            notificationEventCache.put(notificationReceivedEvent.getNotification().id, notificationReceivedEvent);
            invokeMethodOnUiThread("setNotificationForegroundReceivedHandlerInvokeCallback", notificationReceivedEvent.getNotification().toHashMap());
          }
        });

        result.success(true);
      } else if (call.method.equals("displayNotification")) {
        final HashMap<String, Object> args = call.arguments();
        final String notificationId = String.valueOf(args.get("notificationId"));
        NotificationReceivedEvent event = notificationEventCache.get(notificationId);

        if (event != null) event.display();
        result.success(true);
      } else if (call.method.equals("getDeviceId")) {
        result.success(FlareLane.getDeviceId(mContext));
      } else if (call.method.equals("trackEvent")) {
        final HashMap<String, Object> args = call.arguments();
        final String type = String.valueOf(args.get("type"));
        final Object _data = args.get("data");
        final JSONObject jsonData = _data instanceof HashMap ? new JSONObject((HashMap<String, Object>) _data) : null;

        FlareLane.trackEvent(mContext, type, jsonData);

        result.success(true);
      } else {
        result.notImplemented();
      }
    } catch (Exception e) {
      result.error("FlareLane Error", "Exception in onMethodCall", null);
    }
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    channel.setMethodCallHandler(null);
  }

  private void invokeMethodOnUiThread(final String methodName, final HashMap map) {
    new Handler(Looper.getMainLooper()).post(new Runnable() {
      @Override
      public void run() {
        channel.invokeMethod(methodName, map);
      }
    });
  }
}
