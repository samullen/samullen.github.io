--- 
title: "Mobile Apps - Web vs. Native (Part 2): Why the Natives are Restless"
date: "2010-11-26"
comments: false
post: true
categories: [mobile, web]
---

In part 1 of [Mobile Apps - Web vs. Native](http://blog.phalanxit.com/mobile-apps-web-vs-native-part-1-definitions), we looked at the two types of application which are available for mobile devices: native and web-based, I attempted to provide some clear definitions for the two, and hinted that there might be some middle ground between the two.

In this post, we are going to look more closely at the pros and cons of creating both web and native applications for mobile devices, and I'll expand on the ups and downs as necessary.

## Native Applications
Remember, native applications are those apps which are installed from a "market" and onto the device, they take up physical space on the device, and they can access the device's hardware.

###Pros
* Native apps reside very close to the hardware which provides the following features:
	* Access to all the device's features (camera, accellerometer, compass, LEDs, etc.)</li>
	* More responsive to a user's interactions</li>
	* Do not necessarily need internet access in order to function</li>

* Have application icons which provide added branding
* Purchases through the application are greatly simplified
* There is generally a single place to find and purchase applications, the app markets (iTunes, Android Market, Blackberry, etc.)

###Cons
* Developers have to pay for the "privelege" of selling through the markets
* Developers are subject to the market approval process
* Applications may still be censored after previously being approved
* Apps only operate on the platform they were created for (iPhone only, Blackberry only, etc.)
* Developers must know the programming language for each platform developerd for (Java, Objective-C, etc.)
* iPhone developers can only develop on the Mac platform
* Bug fixes are subject to the market approval process
* "The development cycle is slow (develop, compile, deploy, repeat)"
* Unless users upgrade the application which each revision, developers are forced to support numerous versions
* Applications must be created for each platform. If an organization supports three platforms, the application will need to be written three times
* App development is very expensive
* Hard to find good developers

## Web Applications

Whereas native apps reside on the device, web apps reside on remote servers. Access to web applications is performed through a web browser and the application does not have direct access to the device's hardware.

###Pros
* Development is performed through easily accessible languages (HTML, CSS, and JavaScript)
* You are not constrained by the limitations of a platform's User Interface (UI)
* Write once, access from any device, i.e. you can reach everyone
* Bugs can be fixed according to your schedule
* Deployments automatically upgrade everyone
* Releases are not subject to a market's approval process
* Abundance of developers

###Cons
* Access to the devices hardware is limited
* "You have to 'roll your own' payment system if you want to charge for the app."
* Access to the application requires an Internet connection
* The app will not have a presence in a "market"
* Generally less responsive to a user's interactions

###A Happy Middle Ground

Wouldn't it be great if there was someway we could take advantage of all the "pros" of both native and web applications? What if we could mitigate as many "cons" as possible? Not surprisingly, we can.

There are currently several products available which "allow web developers to take a web app and package it as a native app for the iPhone and other mobile platforms." Applications can be initiated and ran as a mobile website. When, or as, the application reaches certain milestones, it can then be released as a native application. Those users which want to have the "latest and greatest" can still access the web version, while those who require less can utilize the native application. Instead of waiting on the approval process of the markets, the application can always be available online.

Jonathan Stark, author of "[Building Android Apps with HTML, CSS, and Javascript](http://www.amazon.com/gp/product/1449383262?ie=UTF8&amp;tag=dumpgrou-20&amp;linkCode=as2&amp;camp=1789&amp;creative=390957&amp;creativeASIN=1449383262)" states this best,

>For me, this is the perfect blend. I can write in my native language, release a product as a pure web app (for the iPhone and any other devices that have a modern browser) without going through Apple’s approval process, and use the same codebase to create an enhanced native version that can access the device hardware and potentially be sold in the App Store. And if Apple rejects it? No big deal, because I still have my online version. I can keep working on the native version while customers use the web app.

Today's web browsers are powerful and crazy fast and the mobile browser is no different. What you can do with a little Javascript, HTML, and CSS today as compared to five years ago is astounding. Look through some of the examples on [Google's Chrome Experiments](http://www.chromeexperiments.com/) and you will see my point. And now, with the advent of HTML5 and the many "real time" protocols which are in use, web sites are catching up, if not eclipsing, traditional native applications. Why waste the time, money, and human resources necessary to build two or more of the same applications when you could just as easily build one application and deploy it to all the platforms?

##Further Reading
###Web vs. Native
* [http://people.w3.org/%7Edom/archives/2010/03/native-apps-vs-mobile-web/](http://people.w3.org/~dom/archives/2010/03/native-apps-vs-mobile-web/)
* [http://spin.atomicobject.com/2010/08/24/native-app-vs-mobile-friendly-web-application](http://spin.atomicobject.com/2010/08/24/native-app-vs-mobile-friendly-web-application)
* [http://www.blueglass.com/blog/phone-wars-mobile-web-apps-vs-native-apps/](http://www.blueglass.com/blog/phone-wars-mobile-web-apps-vs-native-apps/)
* [http://www.readwriteweb.com/mobile/2010/09/native-apps-account-for-half-of-mobile-internet-traffic.php](http://www.readwriteweb.com/mobile/2010/09/native-apps-account-for-half-of-mobile-internet-traffic.php)
* [http://www.readwriteweb.com/archives/will_mobile_web_apps_eventually_replace_native_apps.php](http://www.readwriteweb.com/archives/will_mobile_web_apps_eventually_replace_native_apps.php)

###Middle Ground
* [PhoneGap](http://www.phonegap.com/)
* [http://www.appcelerator.com/products/titanium-mobile-application-development/](http://www.appcelerator.com/products/titanium-mobile-application-development)
* [http://avinashkaza.com/blog/?p=197](http://avinashkaza.com/blog/?p=197)
* [http://stackoverflow.com/questions/1482586/comparison-between-corona-phonegap-titanium](http://stackoverflow.com/questions/1482586/comparison-between-corona-phonegap-titanium)
* [http://www.mayerdan.com/2010/07/mobile_development_and_my_reco.php](http://www.mayerdan.com/2010/07/mobile_development_and_my_reco.php)
