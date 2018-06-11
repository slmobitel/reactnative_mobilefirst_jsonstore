
import { NativeModules } from 'react-native';

//const { RNMobilefirstJsonstore } = NativeModules;

//export default RNMobilefirstJsonstore;


//import { NativeModules } from 'react-native';
var WLJSStore = NativeModules.WLJSStore;


//export default RNTestLibrary;

 async function destroyAll() {
	 var {response} = await WLJSStore.destroyAll();
	 return response;
  /*
  var response;
  WLJSStore.destroyAll((error) =>{
    response =  error;
  },
  (result)=>{
    response =  result;

  });
 return response;
 */
}



 async function createCollection(collectionName, fieldsandtypes) {
	  var {response} = await WLJSStore.createCollection(collectionName , fieldsandtypes);
	 return response;
	 /*
 WLJSStore.createCollection(collectionName , fieldsandtypes , (error) =>{
   return error;
  },
  (result)=>{
    return result;
	});
	*/
}

 async function addToCollection(collectionName,insertData) {
	 var {response} = await WLJSStore.addToCollection(collectionName , insertData);
	 return response;
  /*var response;
  WLJSStore.addToCollection(collectionName,insertData,(error) =>{
    response= error;
  },
  (result)=>{
    response = result;
});
  return response;
  */
}

 async function findFromCollection(collectionName,searchfieldandvalues,limit) {
	  var {response} = await WLJSStore.findFromCollection(collectionName , searchfieldandvalues,limit);
	 return response;
	 /*
  var response;
  WLJSStore.findFromCollection(collectionName,searchfieldandvalues,limit,(error) =>{
    response= error;
  },
  (result)=>{
    response = result;
});
  return response;
	*/
  }

async function replaceFromCollection(collectionName,replaceData,replaceID) {
	  var {response} = await WLJSStore.replaceFromCollection(collectionName , replaceData,replaceID);
	 return response;
	/*
  var response;
  WLJSStore.replaceFromCollection(collectionName,replaceData,replaceID,(error) =>{
    response= error;
  },
  (result)=>{
    response = result;
});
  return response;
  */
}

 async function removeFromCollection(collectionName,removeID) {
	   var {response} = await WLJSStore.removeFromCollection(collectionName ,removeID);
	 return response;
	 /*
  var response;
  WLJSStore.removeFromCollection(collectionName,removeID,(error) =>{
    response= error;
  },
  (result)=>{
    response = result;
});
  return response;
  */
}

 async function removeCollection(collectionName) {
	   var {response} = await WLJSStore.removeCollection(collectionName);
	 return response;
	 /*
  var response;
  WLJSStore.removeCollection(collectionName,(error) =>{
    response= error;
  },
  (result)=>{
    response = result;
});
  return response;
  */
}

async function findAllDirtyDocuments(collectionName) {
    var {response} = await WLJSStore.findAllDirtyDocuments(collectionName);
  return response;

}


function justFunction(){

	return "Hi";
}


export {justFunction as justFunction};
export {destroyAll as WLdestroyAll};
export {createCollection as WLcreateCollection};
export {addToCollection as WLaddToCollection};
export {findFromCollection as WLfindFromCollection};
export {replaceFromCollection as WLreplaceFromCollection};
export {removeFromCollection as WLremoveFromCollection};
export {removeCollection as WLremoveCollection};
export {findAllDirtyDocuments as WLfindAllDirtyDocuments};
