package com.mparticle.mparticle_flutter_sdk

import androidx.annotation.NonNull
import android.util.Log

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

import com.mparticle.identity.AliasRequest;
import com.mparticle.identity.IdentityApi;
import com.mparticle.identity.IdentityApiRequest
import com.mparticle.identity.IdentityApiResult
import com.mparticle.identity.IdentityHttpResponse
import com.mparticle.identity.MParticleUser
import com.mparticle.identity.TaskFailureListener
import com.mparticle.identity.TaskSuccessListener
import com.mparticle.MParticle
import com.mparticle.MParticleOptions
import com.mparticle.MPEvent
import com.mparticle.UserAttributeListener

import org.json.JSONObject


/** MparticleFlutterSdkPlugin */
class MparticleFlutterSdkPlugin: FlutterPlugin, MethodCallHandler {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel: MethodChannel
  private val TAG = "MparticleFlutterSdkPlugin"

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "mparticle_flutter_sdk")
    channel.setMethodCallHandler(this)
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    when (call.method) {
      "isInitialized" -> result.success(MParticle.getInstance() != null)
      "getAppName" -> result.success("Android ${android.os.Build.VERSION.RELEASE}")
      "logEvent" -> this.logEvent(call, result)
      "logScreenEvent" -> this.logScreen(call, result)
      "logError" -> this.logError(call, result)
      "logPushRegistration" -> this.logPushRegistration(call, result)
      "setOptOut" -> this.setOptOut(call, result)
      "getOptOut" -> this.getOptOut(call, result)
      "upload" -> this.upload(call, result)
      "isKitActive" -> this.isKitActive(call, result)
      "identify" -> this.identify(call, result)
      "login" -> this.login(call, result)
      "logout" -> this.logout(call, result)
      "modify" -> this.modify(call, result)
      "getMPID" -> this.getCurrentUser(call, result).let { user ->
        result.success(user?.id?.toString())
      }
      "setUserAttribute" -> this.getUser(call, result).let { user ->
        val key: String? = call.argument("attributeKey")
        val value: String? = call.argument("attributeValue")
        key?.run {
          value?.run {
            result.success(user?.setUserAttribute(key, value))
          } ?: result.error(TAG, "Missing attributeValue", null)
        } ?: result.error(TAG, "Missing attributeKey", null)
      }
      "setUserAttributeArray" -> this.getUser(call, result).let { user ->
        val key: String? = call.argument("attributeKey")
        val value: List<String>? = call.argument("attributeValue")
        key?.run {
          value?.run {
            result.success(user?.setUserAttributeList(key, value))
          } ?: result.error(TAG, "Missing attributeValue", null)
        } ?: result.error(TAG, "Missing attributeKey", null)
      }
      "setUserTag" -> this.getUser(call, result).let { user ->
        val key: String? = call.argument("attributeKey")
        key?.let {
          result.success(user?.setUserTag(key))
        } ?: result.error(TAG, "Missing attributeKey", null)
      }
      "getUserAttributes" -> this.getUser(call, result)?.let {
        it.getUserAttributes(object : UserAttributeListener {
          override fun onUserAttributesReceived(
            userAttributes: Map<String, String>?,
            userAttributeLists: Map<String, List<String>>?, mpid: Long?
          ) {
            result.success(sanitizeMapToString(userAttributes))
          }
        })
        Unit
      } ?: result.success("")
      "getUserIdentities" -> this.getUser(call, result)?.let { user ->
        val identities: Map<MParticle.IdentityType, String> = user.getUserIdentities()
        result.success(sanitizeMapToString(ConvertToUserIdentities(identities)))
      } ?: result.success("")
      "getFirstSeen" -> this.getUser(call, result).let { user ->
        result.success(user?.getFirstSeenTime().toString() ?: "")
      }
      "getLastSeen" -> this.getUser(call, result).let { user ->
        result.success(user?.getLastSeenTime().toString() ?: "")
      }
      "removeUserAttribute" -> this.getUser(call, result).let { user ->
        val key: String? = call.argument("attributeKey")
        key?.run {
          result.success(user?.removeUserAttribute(key))
        } ?: result.error(TAG, "Missing attributeKey", null)
      }
      "incrementUserAttribute" -> this.getUser(call, result).let { user ->
        val key: String? = call.argument("attributeKey")
        val value: Int? = call.argument("attributeValue")
        key?.run {
          value?.run {
            result.success(user?.incrementUserAttribute(key, value))
          } ?: result.error(TAG, "Missing attributeValue", null)
        } ?: result.error(TAG, "Missing attributeKey", null)
      }
      "aliasUsers" -> this.aliasUsers(call, result)
      else -> {
        result.notImplemented()
      }
    }
  }

  private fun logEvent(call: MethodCall, result: Result) {
    try {
      val eventName: String? = call.argument("eventName")
      if (eventName == null) {
        return
      }
      val eventType: Int? = call.argument("eventType")
      val eventTypeEnum = MParticle.EventType.values().firstOrNull { it.ordinal == eventType }
      val customAttributes: HashMap<String, String?>? = call.argument("customAttributes")
      val customFlags: HashMap<String, String>? = call.argument("customFlags")

      val builder = if (eventTypeEnum != null) {
        MPEvent.Builder(eventName, eventTypeEnum)
      } else {
        MPEvent.Builder(eventName)
      }
        .customAttributes(customAttributes)

      if (customFlags != null) {
        for ((key, value) in customFlags) {
          builder.addCustomFlag(key, value)
        }
      }
      val event = builder.build()
      MParticle.getInstance()?.logEvent(event)

      result.success(true)
    } catch (e: Exception) {
      result.error(TAG, e.getLocalizedMessage(), null)
    }
  }

  private fun logScreen(call: MethodCall, result: Result) {
    try {
      val eventName: String? = call.argument("eventName")
      if (eventName == null) {
        return
      }

      val customAttributes: HashMap<String, String?>? = call.argument("customAttributes")
      val customFlags: HashMap<String, String>? = call.argument("customFlags")

      val builder = MPEvent.Builder(eventName).customAttributes(customAttributes)

      if (customFlags != null) {
        for ((key, value) in customFlags) {
          builder.addCustomFlag(key, value)
        }
      }
      val event = builder.build()
      MParticle.getInstance().let { instance ->
        instance?.logScreen(event)
        result.success(instance != null)
      }
    } catch (e: Exception) {
      result.error(TAG, e.getLocalizedMessage(), null)
    }
  }

  private fun logError(call: MethodCall, result: Result) {
    try {
      val eventName: String? = call.argument("eventName")
      if (eventName == null) {
        return
      }

      val customAttributes: HashMap<String, String?>? = call.argument("customAttributes")
      MParticle.getInstance().let { instance ->
        instance?.logError(eventName, customAttributes)
        result.success(instance != null)
      }
    } catch (e: Exception) {
      result.error(TAG, e.getLocalizedMessage(), null)
    }
  }

  private fun isKitActive(call: MethodCall, result: Result) {
    try {
        val kitId: Int? = call.argument("kitId")
        kitId?.let {
          result.success(MParticle.getInstance()?.isKitActive(kitId))
        } ?: result.error(TAG, "Missing kitId", null)
    } catch (e: Exception) {
      result.error(TAG, e.getLocalizedMessage(), null)
    }
  }

  private fun logPushRegistration(call: MethodCall, result: Result) {
    try {
        val pushToken: String? = call.argument("pushToken")
        val senderId: String? = call.argument("senderId")

        if (pushToken != null && senderId != null) {
          MParticle.getInstance()?.logPushRegistration(pushToken, senderId);
        }
        result.success(true)
    } catch (e: Exception) {
      result.error(TAG, e.getLocalizedMessage(), null)
    }
  }

  private fun getOptOut(call: MethodCall, result: Result) {
    try {
      val optOut = MParticle.getInstance()?.getOptOut()
      result.success(optOut)
    } catch (e: Exception) {
      result.error(TAG, e.getLocalizedMessage(), null)
    }
  }

  private fun setOptOut(call: MethodCall, result: Result) {
    try {
      val optOutBoolean: Boolean? = call.argument("optOutBoolean")
      if (optOutBoolean == null) {
        return
      }

      MParticle.getInstance().let { instance ->
        instance?.setOptOut(optOutBoolean)
        result.success(instance != null)
      }
    } catch (e: Exception) {
      result.error(TAG, e.getLocalizedMessage(), null)
    }
  }

  private fun upload(call: MethodCall, result: Result) {
    try {
      MParticle.getInstance().let { instance ->
        instance?.upload()
        result.success(instance != null)
      }
    } catch (e: Exception) {
      result.error(TAG, e.getLocalizedMessage(), null)
    }
  }

  private fun ConvertIdentityAPIRequest(map: HashMap<Int, String>?): IdentityApiRequest {
    val identityRequest: IdentityApiRequest.Builder = IdentityApiRequest.withEmptyUser()
    val userIdentities: Map<MParticle.IdentityType, String> = ConvertUserIdentities(map)
    identityRequest.userIdentities(userIdentities)
    return identityRequest.build()
  }

  private fun ConvertUserIdentities(readableMap: Map<Int, String>?): Map<MParticle.IdentityType, String> {
    val map = hashMapOf<MParticle.IdentityType, String>()
    readableMap?.forEach { (k, v) ->
      val identity = MParticle.IdentityType.parseInt(k)
      identity.let { map[identity] = v }
    }
    return map
  }

  private fun identify(call: MethodCall, result: Result) {
    try {
      val identitiesByString: HashMap<Int, String>? = call.argument("identityRequest")
      val request: IdentityApiRequest = ConvertIdentityAPIRequest(identitiesByString)
      MParticle.getInstance().let { instance ->
        when (instance) {
          null -> result.error(TAG, "No MParticle Instance", null)
          else -> {
            instance.Identity().identify(request)
              .addFailureListener { identityHttpResponse ->
                result.success(ConvertIdentityHttpResponseToString(identityHttpResponse))
              }
              .addSuccessListener { identityApiResult ->
                result.success(ConvertIdentityApiResultToString(identityApiResult))
              }
          }
        }
      }
    } catch (e: Exception) {
      result.error(TAG, e.getLocalizedMessage(), null)
    }
  }

  private fun login(call: MethodCall, result: Result) {
    try {
      val identitiesByString: HashMap<Int, String>? = call.argument("identityRequest")
      val request: IdentityApiRequest = ConvertIdentityAPIRequest(identitiesByString)
      MParticle.getInstance().let { instance ->
        when (instance) {
          null -> result.error(TAG, "No MParticle Instance", null)
          else -> {
            instance.Identity().login(request)
              .addFailureListener { identityHttpResponse ->
                result.success(ConvertIdentityHttpResponseToString(identityHttpResponse))
              }
              .addSuccessListener { identityApiResult ->
                result.success(ConvertIdentityApiResultToString(identityApiResult))
              }
          }
        }
      }
    } catch (e: Exception) {
      result.error(TAG, e.getLocalizedMessage(), null)
    }
  }

  private fun logout(call: MethodCall, result: Result) {
    try {
      val identitiesByString: HashMap<Int, String>? = call.argument("identityRequest")
      val request: IdentityApiRequest = ConvertIdentityAPIRequest(identitiesByString)
      MParticle.getInstance().let { instance ->
        when (instance) {
          null -> result.error(TAG, "No MParticle Instance", null)
          else -> {
            instance.Identity().logout(request)
              .addFailureListener { identityHttpResponse ->
                result.success(ConvertIdentityHttpResponseToString(identityHttpResponse))
              }
              .addSuccessListener { identityApiResult ->
                result.success(ConvertIdentityApiResultToString(identityApiResult))
              }
          }
        }
      }
    } catch (e: Exception) {
      result.error(TAG, e.getLocalizedMessage(), null)
    }
  }

  private fun modify(call: MethodCall, result: Result) {
    try {
      val identitiesByString: HashMap<Int, String>? = call.argument("identityRequest")
      val request: IdentityApiRequest = ConvertIdentityAPIRequest(identitiesByString)
      MParticle.getInstance().let { instance ->
        when (instance) {
          null -> result.error(TAG, "No MParticle Instance", null)
          else -> {
            instance.Identity().modify(request)
              .addFailureListener { identityHttpResponse ->
                result.success(ConvertIdentityHttpResponseToString(identityHttpResponse))
              }
              .addSuccessListener { identityApiResult ->
                result.success(ConvertIdentityApiResultToString(identityApiResult))
              }
          }
        }
      }
    } catch (e: Exception) {
      result.error(TAG, e.getLocalizedMessage(), null)
    }
  }

  private fun getCurrentUser(call: MethodCall, result: Result): MParticleUser? {
    try {
      MParticle.getInstance().let { instance ->
        when (instance) {
          null -> return null
          else -> {
            return (instance.Identity().getCurrentUser())
          }
        }
      }
    } catch (e: Exception) {
      result.error(TAG, e.getLocalizedMessage(), null)
    }
    return null
  }

  private fun getUser(call: MethodCall, result: Result): MParticleUser? {
    try {
      val mpid: String? = call.argument("mpid")
      MParticle.getInstance().let { instance ->
        when (instance) {
          null -> return null
          else -> {
            return (instance.Identity().getUser(parseMpid(mpid)))
          }
        }
      }
    } catch (e: Exception) {
      result.error(TAG, e.getLocalizedMessage(), null)
    }
    return null
  }

  private fun parseMpid(longString: String?): Long {
    return longString?.toLongOrNull() ?: 0L
  }

  private fun ConvertToUserIdentities(userIdentities: Map<MParticle.IdentityType, String>?): Map<String, String>? {
    val map = mutableMapOf<String, String>()
    userIdentities?.entries?.let {
      for ((key, value) in it) {
        map.put(key.value.toString(), value)
      }
    }
    return map
  }

  private fun sanitizeMapToString(userAttributes: Map<String, Any?>?): String {
    try {
      val tempMap = userAttributes ?: mapOf()
      return JSONObject(tempMap).toString()
    } catch (exception: Exception) {
      return JSONObject(mapOf<String, String>()).toString()
    }
  }

  fun aliasUsers(call: MethodCall, result: Result) {
    MParticle.getInstance()?.let { instance ->
      val identityApi: IdentityApi = instance.Identity()
      val aliasRequest: Map<String, Any?>? = call.argument("aliasRequest")

      if (aliasRequest == null) {
        result.error(TAG, "aliasRequest is required", null)
        return@let
      }

      val destinationMpid: Long? = aliasRequest.get("destinationMpid")?.toString()?.toLongOrNull()
      val sourceMpid: Long? = aliasRequest.get("sourceMpid")?.toString()?.toLongOrNull()
      val startTime: Long? = aliasRequest.get("startTime")?.toString()?.toLongOrNull()
      val endTime: Long? = aliasRequest.get("endTime")?.toString()?.toLongOrNull()

      if (sourceMpid == null || destinationMpid == null) {
        result.error(TAG, "source mpid and destination mpid are required", null)
        return@let
      }

      if (startTime == null && endTime == null) {
        val sourceUser: MParticleUser? = identityApi.getUser(sourceMpid)
        val destinationUser: MParticleUser? = identityApi.getUser(destinationMpid)

        if (sourceUser != null && destinationUser != null) {
          val request: AliasRequest = AliasRequest.builder(sourceUser, destinationUser).build()
          result.success(identityApi.aliasUsers(request))
        } else {
          result.error(
            TAG,
            "MParticleUser could not be found for provided sourceMpid and destinationMpid",
            null
          )
        }
      } else {
        val request: AliasRequest = AliasRequest.builder()
          .destinationMpid(destinationMpid)
          .sourceMpid(sourceMpid)
          .apply {
            startTime?.let { startTime(it) }
          }
          .apply {
            endTime?.let { endTime(it) }
          }
          .build()
        result.success(identityApi.aliasUsers(request))
      }
    } ?: result.error(TAG, "No mParticle instance exists", null)
  }

  private fun ConvertIdentityHttpResponseToString(response: IdentityHttpResponse?): String {
    val map = mutableMapOf<String, Any?>()

    response?.let {
      map.put("http_code", response.getHttpCode())
      if (response.getMpId() != 0L) {
        map.put("mpid", response.getMpId().toString())
      }

      response.getErrors()
        .map { error ->
          mapOf(
            "code" to error.code.toString(),
            "message" to error.message.toString()
          )
        }.let { map.put("errors", it) }

      map.put("platform", "android")
      map.put("mpid", response.mpId.toString())
    }

    return sanitizeMapToString(map)
  }

  private fun ConvertIdentityApiResultToString(response: IdentityApiResult): String {
    val map = mutableMapOf("mpid" to response.user.id.toString())
    response.previousUser?.let {
      map.put("previous_mpid", it.id.toString())
    }
    return sanitizeMapToString(map)
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }
}
