# SkyPad
SkyPad is simple app for using the Bluesky web app on an iPad that is enough better than using it in the browser to make it worth it. 

I don't like using Bluesky in the browser on my iPad. I made SkyPad which is a simple wrapper for the Bluesky web app (http://staging.bsky.app). It required a few tweaks such as making sure all the links work and adding some basic pull to refresh functionality that isn't inhernitly in the web app. 

## How do I use it?
- You will need XCode and an iPad (obviously) and a developer account
- Download the Repo
- Make sure you select your dev account and give it a bundle identifier
- Follow Steps [outlined here](https://developer.apple.com/documentation/xcode/running-your-app-in-simulator-or-on-a-device)

## What won't this app do?
- Provide anything near a native expereince
- Send alerts and notifications
- No dark mode support (not in the web app)

## What will it to?
- Let you run the Bluesky web app full screen, split view, and slide over
- Pull down anywhere other than the main feed to refresh the page
- Opens external links directly in the system browser
