# Change log

## 2.1.4
Fix bug with delegating to assignment methods like `foo=`.

## 2.1.1
Fix bug preventing arguments from being forwarded to delegated methods.

## 2.1.0
Allow automatic delegation inspired by Golang's embedding.

## 2.0.0
Convert MethodObject to use inheritance and a class method for dynamic setup of class internals
  - Enables code editors to find declaration of MethodObject
  - Allows constants to be nested whereas previous implementation was based on a Struct which could not contain constants.
