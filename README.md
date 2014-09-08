Locksmith
=====

Locksmith is a simple app that will replace text as you type. It is comprised of a system preferences pane and a small helper application to prevent any unsightly icons in your dock or menubar.

## Getting Started

Clone the repo and open Locksmith.xcodeproj in the latest **Xcode 6** beta. There will be two targets, the preferences pane `Locksmith (Objective-C)` and the helper application `LocksmithHelper (Swift)`. Building the preferences will also build and embed the helper application. When you build the preferences pane it will be installed into `~/Library/PreferencePanes`.

## Project Structure

```
.
├── Locksmith.xcodeproj   The Locksmith Xcode project
├── Locksmith             Preferences pane
├── LocksmithHelper       Helper application
└── LocksmithHelperTests  Helper application tests (someday...)
```
