# Shattuck Schedule App

A flutter app for the 2026 Shattuck Symposium. Delpoyed at https://akalustat.github.io/symposium-schedule/.

## Running the App
Flutter provides standard instructions for running the application in development mode via simulators: https://docs.flutter.dev/testing/build-modes#debug.

## Building The App

### Web
To build the App for the Web, run the following command in the root directory:
```
> flutter build web --release --base-href="/symposium-schedule/"          
```

The static web build in hosted in another git repository (https://github.com/AkalUstat/symposium-schedule) using GitHub Pages.\* To publish a new build, navigate to the web build folder, which is the location of a subrepo. Then, git add and commit, then push:
```
> cd build/web
> git add .
> git commit -m "Some Commit Message"
> git push
```

GitHub Pages takes about a minute to complete the deployment.


\*Note: This repository will be moved to the Shattuck Endowment GitHub Organization following the conclusion of the 2026 Symposium Schedule at an undetermined time. 

### iOS

Run the iOS build command:
```
> flutter build ipa
```

Then, navigate to `build/ios/ipa`. Upload the `.ipa` file to App Store Connect (ASC) via the Transporter App on macOS. To publish the app or send it for review, use App Store Connect. Future developers working on this project for a future Shattuck Symposium should work with Dr. Antonio Bly (antonio.bly@csus.edu) or contact Akal Ustat Singh (akalustat.singh@gmail.com) for ASC access.

### Android
At the time of the 2026 Symposium, the Google Play Store requires 14 days of testing from 12 testers. We did not have time to complete this process (although Dr. Bly has a Google Play Store account). Thus, we distributed an apk. 

Generate an APK using this command (if you have time, complete the regular Play Store process, for which you will instead generate an AAB; see more - https://docs.flutter.dev/deployment/android):
```
> flutter build apk
```

We hosted the APK using Dr. Bly's/Shattuck Endowment's OneDrive and a shareable link which was accessible using the link directory (https://github.com/AkalUstat/shattuck-symposium-links).\*

\*Note: This repository will be moved to the Shattuck Endowment GitHub Organization following the conclusion of the 2026 Symposium Schedule at an undetermined time. 

## Extending the Application for Future Symposiums

Most of the code should be future-proof (or as much as any framework can be). Components can be reused by simply changing the events in `assets/events.json`. It supports abstracts, descriptions, titles, and special markers (for 2026, this included a Badge and Border color for the semiquincentenary; there is also a badge for women, but this was not enabled). These special markers are controlled by the "isSpecial" tag, with the following values: null, "250", "women".
