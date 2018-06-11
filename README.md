
# react-native-mobilefirst-jsonstore

This plugin supports to store String,Integer and Boolean type data storage

## Getting started
// First need to register the application in mobilefirst
`$ npm install react-native-mobilefirst-jsonstore --save`

### Manual installation


#### iOS

1. In XCode, in the project navigator, right click `Libraries` ➜ `Add Files to [your project's name]`
2. Go to `node_modules` ➜ `react-native-mobilefirst-jsonstore` and add `RNMobilefirstJsonstore.xcodeproj`
3. In XCode, in the project navigator, select your project. Add `libRNMobilefirstJsonstore.a` to your project's `Build Phases` ➜ `Link Binary With Libraries`
4. Run your project (`Cmd+R`)<

#### Android

1. Open up `android/app/src/main/java/[...]/MainActivity.java`
  - Add `import com.reactlibrary.RNMobilefirstJsonstorePackage;` to the imports at the top of the file
  - Add `new RNMobilefirstJsonstorePackage()` to the list returned by the `getPackages()` method
2. Append the following lines to `android/settings.gradle`:
  	```
  	include ':react-native-mobilefirst-jsonstore'
  	project(':react-native-mobilefirst-jsonstore').projectDir = new File(rootProject.projectDir, 	'../node_modules/react-native-mobilefirst-jsonstore/android')
  	```
3. Insert the following lines inside the dependencies block in `android/app/build.gradle`:
  	```
      compile project(':react-native-mobilefirst-jsonstore')
      compile('com.ibm.mobile.foundation:ibmmobilefirstplatformfoundation:8.0.+') {
            exclude group: 'com.squareup.okio'
        }
  	```

## Usage
```javascript
import {WLcreateCollection,WLaddToCollection,WLfindFromCollection,WLreplaceFromCollection,WLremoveFromCollection,WLremoveCollection,WLdestroyAll,WLfindAllDirtyDocuments} from 'react-native-mobilefirst-jsonstore';

// For success, method will return as "Success" except in WLfindFromCollection
// WLfindFromCollection will return the object list
// Errors it will retun a object containing method,error,event as keys

async createCollection(){
  // For string type data need to add string type value
  // For integer type data need to add integer type value
  // For boolean type data need to add true/false as value
  var fields = {name: 'abc', age:0, isok: true};
try{
  var result  = await WLcreateCollection("collectionName",fields);
  return result;
}
catch(e){return e;}
}

async addToCollection(){
  var values = { name: 'James', age:25, isok: true };
try{
  var result  = await WLaddToCollection("collectionName",values);
  return result;
}
catch(e){return e;}
}

async findFromCollection(){
  // method also supports for and type filtering
  var values = { name: 'James' };
  var limit = 2;
try{
  var result  = await WLfindFromCollection("collectionName",values,limit);
  return result;
}
catch(e){return e;}
}

async replaceFromCollection(){
  var values = { name: 'James', age:56, isok: true };
  var id = 1;
try{
  var result  = await WLreplaceFromCollection("collectionName",values,id);
  return result;
}
catch(e){return e;}
}

async removeFromCollection(){
  var id = 1;
try{
  var result  = await WLremoveFromCollection("collectionName",id);
  return result;
}
catch(e){return e;}
}

async removeCollection(){
try{
  var result  = await WLremoveCollection("collectionName");
  return result;
}
catch(e){return e;}
}

async destroyAll(){
try{
  var result  = await WLdestroyAll();
  return result;
}
catch(e){return e;}
}

async findAllDirtyDocuments(){
try{
  var result  = await WLfindAllDirtyDocuments("collectionName");
  return result;
}
catch(e){return e;}
}

// TODO: What to do with the module?

```
