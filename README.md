# cordova-qdc-baidu-push

-- 2016.06.06 Updated iOS SDK 1.4.5, Android 5.0.0
-- 2015.06.17 IOS SDK
-- 2015.06.15 Android SDK【L2-4.4.1】

# Installation

	$ ionic plugin add https://github.com/mrwutong/cordova-qdc-baidu-push.git

# Usage

```js
var api_key = 'SJI7BJ4hg8k5BUJ6LWVXit35' // your api key

document.addEventListener("deviceready", function () {

  window.baidu_push.onMessage(function (result) {
    console.log('onMessage success', result);
  }, function () {
    console.error('onMessage fail', error);
  })

  window.baidu_push.onNotificationClicked(function (result) {
    console.log('onNotificationClicked success', result);
  }, function (error) {
    console.error('onNotificationClicked fail', error);
  })

  window.baidu_push.onNotificationArrived(function (result) {
    console.log('onNotificationArrived success', resultj);
  }, function (error) {
    console.error('onNotificationArrived fail', error);
  })

  window.baidu_push.startWork(api_key, function (result) {
    console.log('startWork success', resultj);
  }, function (error) {
    console.error('startWork fail', error);
  })
}, false);
```

# API

baidu_push.startWork

	baidu_push.startWork(api_key, cb_success);
	# api_key: Baidu cloud push api_key
	# cb_success: callback method call succeeds, will not consider callback call fails, the return value is structured as follows:
	  #json: {
	    type: 'onbind', // method of the corresponding Android Service
	    data: {
	      appId: 'xxxxxxxx',
	      userId: 'yyyyy',
	      channelId: 'zzzzzz'
	    }
	  }

baidu_push.stopWork

	baidu_push.startWork(cb_success);
	# cb_success: callback method call succeeds, will not consider callback call fails, the return value is structured as follows:
	  #json: {
	    type: 'onunbind', // method of the corresponding Android Service
	    errorCode: 'xxxxxx', // error code corresponding to Baidu's request
	    data: {
	      requestId: 'yyyyyy', // request ID corresponding to Baidu
	    }
	  }

baidu_push.resumeWork

	baidu_push.resumeWork(cb_success);
	# cb_success: callback method can call succeeds, the return value is structured as follows: Method with baidu_push.startWork

baidu_push.setTags

	baidu_push.setTags(tags, cb_success);
	# tags[]: tag name you want to set
	# cb_success: callback method call succeeds, will not consider callback call fails, the return value is structured as follows:
	  #json: {
	    type: 'onsettags',
	    errorCode: 'xxxxxxxx',
	    data: {
	      requestId: 'yyyyy',
	      channelId: 'zzzzzz'
	      sucessTags: ['aaa', 'bbb', 'ccc'], // set success tag list
	      failTags: ['ddd', 'eee', 'fff'] // tag list settings failed
	    }
	  }

baidu_push.delTags

	baidu_push.delTags(tags, cb_success);
	# tags[]: tag name you want to remove
	# cb_success: callback method call succeeds, will not consider callback call fails, the return value is structured as follows:
	  #json: {
	    type: 'ondeltags',
	    errorCode: 'xxxxxxxx',
	    data: {
	      requestId: 'yyyyy',
	      channelId: 'zzzzzz'
	      sucessTags: ['aaa', 'bbb', 'ccc'], // set success tag list
	      failTags: ['ddd', 'eee', 'fff'] // tag list settings failed
	    }
	  }

## onMessage

	baidu_push.onMessage(cb_success, failureCallback)

## onNotificationClicked

	baidu_push.onNotificationClicked(successCallback, failureCallback)
	# successCallback: callback method call succeeds, will not consider callback call fails, the return value is structured as follows:
	  #json: {
		  "data": {
		    "title": "foo",
		    "description": "bar",
		    "customContentString": "{\"Additional Field Key\":\"Additional Field Value\"}"
		  },
		  "type": "onNotificationClicked"
		}

## onNotificationArrived

	baidu_push.onNotificationArrived(successCallback, failureCallback)
	# successCallback: callback method call succeeds, will not consider callback call fails, the return value is structured as follows:
	  #json: {
		  "data": {
		    "title": "foo",
		    "description": "bar",
		    "customContentString": "{\"Additional Field Key\":\"Additional Field Value\"}"
		  },
		  "type": "onNotificationArrived"
		}

# Other instructions:

1. Json Parameters on the type of callback method can return the following values ​​that correspond Android's Service of Baidu cloud push callback method onbind, onunbind, onsettags, ondeltags, onlisttags, onmessage, onnotificationclicked, onnotificationarrived

2. Since Baidu applications different android and ios, APP client can use the following method to determined it:

```js
ionic.Platform.isIOS()
ionic.Platform.isAndroid()
```
