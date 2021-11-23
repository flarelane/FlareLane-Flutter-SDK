package com.flarelane.flarelane_flutter;

import android.content.Context;
import android.os.Handler;
import android.os.Looper;
import android.util.Log;

import androidx.annotation.NonNull;

import com.flarelane.FlareLane;
import com.flarelane.Notification;
import com.flarelane.NotificationConvertedHandler;
import com.flarelane.SdkType;

import org.json.JSONObject;

import java.util.ArrayList;
import java.util.HashMap;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

/** FlareLaneFlutterPlugin */
public class FlareLaneFlutterPlugin implements FlutterPlugin, MethodCallHandler {
  static Context mContext;

  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private MethodChannel channel;

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    mContext = flutterPluginBinding.getApplicationContext();
    channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "com.flarelane.flutter/methods");
    channel.setMethodCallHandler(this);
    FlareLane.sdkType = SdkType.FLUTTER;
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    try {
      if (call.method.equals("initialize")) {
        final String projectId = call.arguments();
        FlareLane.initWithContext(mContext, projectId);
        result.success(true);
      } else if (call.method.equals("setLogLevel")) {
        result.success(true);
      } else if (call.method.equals("setUserId")) {
        final String userId = call.arguments();
        FlareLane.setUserId(mContext, userId);
        result.success(true);
      } else if (call.method.equals("setTags")) {
        final HashMap<String, Object> tags = call.arguments();
        final JSONObject json = new JSONObject(tags);
        FlareLane.setTags(mContext, json);
        result.success(true);
      } else if (call.method.equals("deleteTags")) {
        final ArrayList<String> tags = call.arguments();
        FlareLane.deleteTags(mContext, tags);
        result.success(true);
      } else if (call.method.equals("setIsSubscribed")) {
        final Boolean isSubscribed = call.arguments();
        FlareLane.setIsSubscribed(mContext, isSubscribed);
        result.success(true);
      } else if (call.method.equals("setNotificationConvertedHandler")) {
        FlareLane.setNotificationConvertedHandler(new NotificationConvertedHandler() {

          @Override
          public void onConverted(Notification notification) {
            HashMap<String, Object> hash = new HashMap<>();
            hash.put("id", notification.id);
            hash.put("title", notification.title);
            hash.put("body", notification.body);
            hash.put("url", notification.url);

            invokeMethodOnUiThread("setNotificationConvertedHandlerInvokeCallback", hash);
          }
        });

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
