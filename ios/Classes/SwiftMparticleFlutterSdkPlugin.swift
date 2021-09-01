import Flutter
import UIKit
import mParticle_Apple_SDK

public class SwiftMparticleFlutterSdkPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "mparticle_flutter_sdk", binaryMessenger: registrar.messenger())
    let instance = SwiftMparticleFlutterSdkPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "isInitialized":
        result(MParticle.sharedInstance() != nil)
    case "getAppName":
        result(Bundle.main.infoDictionary?[kCFBundleNameKey as String] as? String)
    case "getOptOut":
        result(MParticle.sharedInstance().optOut)
    case "isKitActive":
        if let callArguments = call.arguments as? [String: Any],
           let kitId = callArguments["kitId"] as? NSNumber {
            result(MParticle.sharedInstance().isKitActive(kitId))
        } else {
            print("Incorrect argument for \(call.method) iOS method")
        }
    case "logError":
        if let callArguments = call.arguments as? [String: Any],
           let eventName = callArguments["eventName"] as? String {
            let customAttributes = callArguments["customAttributes"] as? [String: Any]
            MParticle.sharedInstance().logError(eventName, eventInfo: customAttributes)
        } else {
            print("Incorrect argument for \(call.method) iOS method")
        }
    case "logEvent":
        if let callArguments = call.arguments as? [String: Any],
           let eventName = callArguments["eventName"] as? String,
           let rawEventType = callArguments["eventType"] as? NSNumber,
           let eventType = MPEventType(rawValue:UInt(truncating: rawEventType)),
           let event = MPEvent(name: eventName, type: eventType) {
            let customAttributes = callArguments["customAttributes"] as? [String: Any]
            event.customAttributes = customAttributes
            if let customFlags = callArguments["customFlags"] as? [String: String] {
                for (key, value) in customFlags {
                    event.addCustomFlag(value, withKey: key)
                }
            }
            MParticle.sharedInstance().logEvent(event)
        } else {
            print("Incorrect argument for \(call.method) iOS method")
        }
    case "logPushRegistration":
        if let callArguments = call.arguments as? [String: Any],
            let iosToken = callArguments["pushToken"] as? String,
            let iosTokenData = iosToken.data(using: .utf8) {
             MParticle.sharedInstance().pushNotificationToken = iosTokenData
        } else {
            print("Incorrect argument for \(call.method) iOS method")
        }
    case "logScreenEvent":
        if let callArguments = call.arguments as? [String: Any],
           let eventName = callArguments["eventName"] as? String,
           let type = MPEventType(rawValue:1),
           let event = MPEvent(name: eventName, type: type) {
            let customAttributes = callArguments["customAttributes"] as? [String: Any];
            event.customAttributes = customAttributes
            if let customFlags = callArguments["customFlags"] as? [String: String] {
                for (key, value) in customFlags {
                    event.addCustomFlag(value, withKey: key)
                }
            }

            MParticle.sharedInstance().logScreenEvent(event)
        } else {
            print("Incorrect argument for \(call.method) iOS method")
        }
    case "setATTStatus":
        if let callArguments = call.arguments as? [String: Any],
           let rawATTStatus = callArguments["attStatus"] as? NSNumber,
           let attStatus = MPATTAuthorizationStatus(rawValue:UInt(truncating: rawATTStatus)) {
            let timestamp = callArguments["timestampInMillis"] as? NSNumber
            MParticle.sharedInstance().setATTStatus(attStatus, withATTStatusTimestampMillis: timestamp)
        } else {
            print("Incorrect argument for \(call.method) iOS method")
        }
    case "setOptOut":
        if let callArguments = call.arguments as? [String: Any],
           let optOutVal = callArguments["optOutBoolean"] as? Bool {
            MParticle.sharedInstance().optOut = optOutVal
        } else {
            print("Incorrect argument for \(call.method) iOS method")
        }
    case "upload":
        MParticle.sharedInstance().upload()
    // identity methods:
    case "identify":
      if let callArguments = call.arguments as? [String: Any],
         let requestDictionary = callArguments["identityRequest"] as? [NSNumber: String] {
        let identityRequest = createIdentityRequest(identitiesKeyedOnType: requestDictionary);
          MParticle.sharedInstance().identity.identify(identityRequest, completion: {(identityResult: MPIdentityApiResult?, error: Error?) in
            result(convertToIdentityResultJson(result: identityResult, error: error))
          })
      }
      break;
    case "login":
      if let callArguments = call.arguments as? [String: Any],
         let requestDictionary = callArguments["identityRequest"] as? [NSNumber: String] {
        let identityRequest = createIdentityRequest(identitiesKeyedOnType: requestDictionary)
          MParticle.sharedInstance().identity.login(identityRequest, completion: {(identityResult: MPIdentityApiResult?, error: Error?) in
            result(convertToIdentityResultJson(result: identityResult, error: error))
          })
      }
      break;
    case "logout":
      if let callArguments = call.arguments as? [String: Any],
         let requestDictionary = callArguments["identityRequest"] as? [NSNumber: String] {
        let identityRequest = createIdentityRequest(identitiesKeyedOnType: requestDictionary)
          MParticle.sharedInstance().identity.logout(identityRequest, completion: {(identityResult: MPIdentityApiResult?, error: Error?) in
            result(convertToIdentityResultJson(result: identityResult, error: error))
          })
      }
      break;
    case "modify":
      if let callArguments = call.arguments as? [String: Any],
         let requestDictionary = callArguments["identityRequest"] as? [NSNumber: String] {
        let identityRequest = createIdentityRequest(identitiesKeyedOnType: requestDictionary)
          MParticle.sharedInstance().identity.modify(identityRequest, completion: {(identityResult: MPIdentityApiResult?, error: Error?) in
            result(convertToIdentityResultJson(result: identityResult, error: error))
          })
      }
      break;
    // user methods
    case "getMPID":
        if let user = MParticle.sharedInstance().identity.currentUser {
            result(user.userId.stringValue)
        } else {
            result("0")
        }
    case "getFirstSeen":
        if let callArguments = call.arguments as? [String: Any],
           let mpidString = callArguments["mpid"] as? String,
           let mpid = Int(mpidString),
           let user = MParticle.sharedInstance().identity.getUser(NSNumber(value:mpid)) {
            // TimeInterval is provided in seconds while Dart expects epoch time in ms
            result(String(user.firstSeen.timeIntervalSince1970 * 1000))
        } else {
            result("0")
        }
    case "getLastSeen":
        if let callArguments = call.arguments as? [String: Any],
           let mpidString = callArguments["mpid"] as? String,
           let mpid = Int(mpidString),
           let user = MParticle.sharedInstance().identity.getUser(NSNumber(value:mpid)) {
            // TimeInterval is provided in seconds while Dart expects epoch time in ms
            result(String(user.lastSeen.timeIntervalSince1970 * 1000))
        } else {
            result("0")
        }
    case "getUserAttributes":
        if let callArguments = call.arguments as? [String: Any],
           let mpidString = callArguments["mpid"] as? String,
           let mpid = Int(mpidString),
           let user = MParticle.sharedInstance().identity.getUser(NSNumber(value:mpid)) {
            result(asStringForStringKey(jsonDictionary: user.userAttributes))
        } else {
            result("")
        }
    case "getUserIdentities":
        if let callArguments = call.arguments as? [String: Any],
           let mpidString = callArguments["mpid"] as? String,
           let mpid = Int(mpidString),
           let user = MParticle.sharedInstance().identity.getUser(NSNumber(value:mpid)) {
            result(asStringForNumberKey(numberDictionary: user.identities))
        } else {
            result("")
        }
    case "incrementUserAttribute":
        if let callArguments = call.arguments as? [String: Any],
           let attributeKey = callArguments["attributeKey"] as? String,
           let attributeValue = callArguments["attributeValue"] as? NSNumber,
           let mpidString = callArguments["mpid"] as? String,
           let mpid = Int(mpidString),
           let user = MParticle.sharedInstance().identity.getUser(NSNumber(value:mpid)) {
            user.incrementUserAttribute(attributeKey, byValue: attributeValue)
        }
    case "removeUserAttribute":
        if let callArguments = call.arguments as? [String: Any],
           let attributeKey = callArguments["attributeKey"] as? String,
           let mpidString = callArguments["mpid"] as? String,
           let mpid = Int(mpidString),
           let user = MParticle.sharedInstance().identity.getUser(NSNumber(value:mpid)) {
            user.removeAttribute(attributeKey)
        }
    case "setUserAttribute":
        if let callArguments = call.arguments as? [String: Any],
           let attributeKey = callArguments["attributeKey"] as? String,
           let attributeValue = callArguments["attributeValue"] as? Any,
           let mpidString = callArguments["mpid"] as? String,
           let mpid = Int64(mpidString),
           let user = MParticle.sharedInstance().identity.getUser(NSNumber(value:mpid)) {
            user.setUserAttribute(attributeKey, value: attributeValue)
        }
    case "setUserAttributeArray":
        if let callArguments = call.arguments as? [String: Any],
           let attributeKey = callArguments["attributeKey"] as? String,
           let attributeValue = callArguments["attributeValue"] as? [String],
           let mpidString = callArguments["mpid"] as? String,
           let mpid = Int64(mpidString),
           let user = MParticle.sharedInstance().identity.getUser(NSNumber(value:mpid)) {
            user.setUserAttributeList(attributeKey, values: attributeValue)
        }
    case "setUserTag":
        if let callArguments = call.arguments as? [String: Any],
           let attributeKey = callArguments["attributeKey"] as? String,
           let mpidString = callArguments["mpid"] as? String,
           let mpid = Int64(mpidString),
           let user = MParticle.sharedInstance().identity.getUser(NSNumber(value:mpid)) {
            user.setUserTag(attributeKey)
        }
    case "aliasUsers":
        if let callArguments = call.arguments as? [String: Any],
           let aliasRequestArguments = callArguments["aliasRequest"] as? [String: Any],
           let sourceMPIDString = aliasRequestArguments["sourceMpid"] as? String,
           let destinationMPIDString = aliasRequestArguments["destinationMpid"] as? String,
           let sourceMPIDInteger = Int64(sourceMPIDString),
           let destinationMPIDInteger = Int64(destinationMPIDString) {
            // TimeInterval is expected to be seconds while Dart provide epoch time as ms
            if let startTimeNumber = aliasRequestArguments["startTime"] as? NSNumber,
               let endTimeNumber = aliasRequestArguments["endTime"] as? NSNumber {
                let startTime = Date(timeIntervalSince1970: startTimeNumber.doubleValue/1000)
                let endTime = Date(timeIntervalSince1970: endTimeNumber.doubleValue/1000)
                let request = MPAliasRequest(sourceMPID: NSNumber(value:sourceMPIDInteger),
                                             destinationMPID: NSNumber(value:destinationMPIDInteger),
                                             startTime: startTime,
                                             endTime: endTime)
                
                MParticle.sharedInstance().identity.aliasUsers(request)
            } else {
                if let sourceUser = MParticle.sharedInstance().identity.getUser(NSNumber(value:sourceMPIDInteger)),
                   let destinationUser = MParticle.sharedInstance().identity.getUser(NSNumber(value:destinationMPIDInteger)) {
                    let request = MPAliasRequest(sourceUser:sourceUser, destinationUser:destinationUser)
                    
                    MParticle.sharedInstance().identity.aliasUsers(request)
                }
            }
        }
    case "logCommerceEvent":
        if let callArguments = call.arguments as? [String: Any],
           let commerceArguments = callArguments["commerceEvent"] as? [String: Any] {
            let event: MPCommerceEvent
            if let rawActionType = commerceArguments["productActionType"] as? NSNumber,
               let actionType = MPCommerceEventAction(rawValue:UInt(truncating: rawActionType)) {
                event = MPCommerceEvent.init(action: actionType)
            } else if let rawActionType = commerceArguments["promotionActionType"] as? NSNumber,
                      let actionType = MPPromotionAction(rawValue:UInt(truncating: rawActionType)) {
                let container = MPPromotionContainer.init(action: actionType, promotion: nil)

                if let rawPromotions = commerceArguments["promotions"] as? [[String: Any]] {
                    for rawPromotion in rawPromotions {
                        let promotion = MPPromotion.init()
                        promotion.promotionId = rawPromotion["promotionId"] as? String
                        promotion.creative = rawPromotion["creative"] as? String
                        promotion.name = rawPromotion["name"] as? String
                        promotion.position = rawPromotion["position"] as? String

                        container .addPromotion(promotion)
                    }
                }

                event = MPCommerceEvent.init(promotionContainer: container)
            } else {
                event = MPCommerceEvent.init(impressionName: nil, product: nil)
            }
            // Optional Products on Commerce Event
            if let rawProducts = commerceArguments["products"] as? [[String: Any]] {
                for rawProduct in rawProducts {
                    if let name = rawProduct["name"] as? String,
                       let sku = rawProduct["sku"] as? String,
                       let price = rawProduct["price"] as? NSNumber {
                        let newProduct = MPProduct.init()
                        newProduct.name = name
                        newProduct.sku = sku
                        newProduct.price = price
                        if let quantity = rawProduct["quantity"] as? NSNumber {
                            newProduct.quantity = quantity
                        }

                        event.addProduct(newProduct)
                    }
                }
            }

            // Optional Transaction Attributes
            if let rawTransactionAttributes = commerceArguments["transactionAttributes"] as? [String: Any] {
                let attributes = MPTransactionAttributes.init()
                if let affiliation = rawTransactionAttributes["affiliation"] as? String {
                    attributes.affiliation = affiliation
                }
                if let couponCode = rawTransactionAttributes["couponCode"] as? String {
                    attributes.couponCode = couponCode
                }
                if let shipping = rawTransactionAttributes["shipping"] as? NSNumber {
                    attributes.shipping = shipping
                }
                if let tax = rawTransactionAttributes["tax"] as? NSNumber {
                    attributes.tax = tax
                }
                if let revenue = rawTransactionAttributes["revenue"] as? NSNumber {
                    attributes.revenue = revenue
                }
                if let transactionId = rawTransactionAttributes["transactionId"] as? String {
                    attributes.transactionId = transactionId
                }

                event.transactionAttributes = attributes
            }

            let customAttributes = commerceArguments["customAttributes"] as? [String: Any]
            event.customAttributes = customAttributes
            if let customFlags = commerceArguments["customFlags"] as? [String: String] {
                for (key, value) in customFlags {
                    event.addCustomFlag(value, withKey: key)
                }
            }

            if let rawImpressions = commerceArguments["impressions"] as? [[String: Any]] {
                for rawImpression in rawImpressions {
                    if let listName = rawImpression["impressionListName"] as? String,
                       let rawProducts = rawImpression["products"] as? [[String: Any]] {
                        for rawProduct in rawProducts {
                            if let name = rawProduct["name"] as? String,
                               let sku = rawProduct["sku"] as? String,
                               let quantity = rawProduct["quantity"] as? NSNumber,
                               let price = rawProduct["price"] as? NSNumber {
                                let newProduct = MPProduct.init(name: name,
                                                                sku: sku,
                                                                quantity: quantity,
                                                                price: price)
                                event.addImpression(newProduct, listName: listName)
                            }
                        }
                    }
                }
            }

            // Optionable Properties on MPCommerceEvent
            if let checkoutOptions = commerceArguments["checkoutOptions"] as? String {
                event.checkoutOptions = checkoutOptions
            }
            if let currency = commerceArguments["currency"] as? String {
                event.currency = currency
            }
            if let productListName = commerceArguments["productListName"] as? String {
                event.productListName = productListName
            }
            if let productListSource = commerceArguments["productListSource"] as? String {
                event.productListSource = productListSource
            }
            if let screenName = commerceArguments["screenName"] as? String {
                event.screenName = screenName
            }
            // ??? checkoutStep is deprecated for iOS
            if let checkoutStep = commerceArguments["checkoutStep"] as? NSNumber {
                event.checkoutStep = checkoutStep.intValue
            }
            if let nonInteractive = commerceArguments["nonInteractive"] as? Bool {
                event.nonInteractive = nonInteractive
            }

            MParticle.sharedInstance().logEvent(event)
        } else {
            print("Incorrect argument for \(call.method) iOS method")
        }
    default:
        print("mParticle flutter SDK for iOS does not support \(call.method)")
    }
  }
}

private func asStringForStringKey(jsonDictionary: [String : Any]) -> String {
  do {
    let data = try JSONSerialization.data(withJSONObject: jsonDictionary, options: .prettyPrinted)
    return String(data: data, encoding: String.Encoding.utf8) ?? ""
  } catch {
    return ""
  }
}

private func asStringForNumberKey(numberDictionary: [NSNumber : Any]) -> String {
    var jsonDictionary: [String: Any] = [:]
    for (key,value) in numberDictionary {
        jsonDictionary[key.stringValue] = value
    }
    
    return asStringForStringKey(jsonDictionary: jsonDictionary)
}

private func createIdentityRequest(identitiesKeyedOnType: [NSNumber: String]) -> MPIdentityApiRequest {
    let identityRequest = MPIdentityApiRequest.withEmptyUser()

  for (key,value) in identitiesKeyedOnType {
    if let identityType = MPIdentity(rawValue:UInt(truncating: key)) {
      identityRequest.setIdentity(value, identityType: identityType)
    }
  }

  return identityRequest
}

private func convertToIdentityResultJson(result: MPIdentityApiResult?, error: Error?) -> String {
    let responseDict = NSMutableDictionary()
    if let nsError = error as? NSError {
      let code = nsError.code
      responseDict.setValue(code, forKey: "http_code")
      let errorDict = NSMutableDictionary()
      errorDict.setValue(String(code), forKey: "code")
      errorDict.setValue(nsError.localizedDescription, forKey: "message")
      responseDict.setValue([errorDict], forKey: "errors")
      responseDict.setValue("ios", forKey: "platform")
    }
    if let result = result {
       responseDict.setValue(String(describing: result.user.userId), forKey: "mpid")
       if let previousUser = result.previousUser {
        responseDict.setValue(String(describing: previousUser.userId), forKey: "previous_mpid")
       }
    }
    if (responseDict["mpid"] == nil) {
        let mpid = MParticle.sharedInstance().identity.currentUser?.userId ?? 0
        responseDict.setValue(String(describing: mpid), forKey: "mpid")
    }
    do {
        let jsonData = try JSONSerialization.data(withJSONObject: responseDict, options: JSONSerialization.WritingOptions()) as NSData
        let jsonString: String = String(data: jsonData as Data, encoding: String.Encoding.utf8) ?? "" as String
        return jsonString
    } catch _ {
        return "{\"errors\": [{\"code\": 0, \"message\": \"error serializing Identity response\"]}"
    }
}
