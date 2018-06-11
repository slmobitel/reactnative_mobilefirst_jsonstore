package com.reactmfjslibrary.jsonstore;

import com.reactmfjslibrary.RNJSONUtils;

import android.util.Log;
import android.widget.Toast;

import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.Promise;

import com.facebook.react.bridge.Callback;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.bridge.WritableArray;

import com.facebook.react.bridge.ReadableMapKeySetIterator;
import com.worklight.jsonstore.api.JSONStoreAddOptions;
import com.worklight.jsonstore.api.JSONStoreCollection;
import com.worklight.jsonstore.api.JSONStoreFindOptions;
import com.worklight.jsonstore.api.JSONStoreQueryPart;
import com.worklight.jsonstore.api.JSONStoreQueryParts;
import com.worklight.jsonstore.api.JSONStoreRemoveOptions;
import com.worklight.jsonstore.api.JSONStoreReplaceOptions;
import com.worklight.jsonstore.api.WLJSONStore;
import com.worklight.jsonstore.database.SearchFieldType;
import com.worklight.jsonstore.exceptions.JSONStoreAddException;
import com.worklight.jsonstore.exceptions.JSONStoreDatabaseClosedException;
import com.worklight.jsonstore.exceptions.JSONStoreFilterException;
import com.worklight.jsonstore.exceptions.JSONStoreFindException;
import com.worklight.jsonstore.exceptions.JSONStoreInvalidSchemaException;
import com.worklight.jsonstore.exceptions.JSONStoreSyncException;

import com.worklight.wlclient.api.WLClient;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.LinkedList;
import java.util.List;


/**
 * Created by janithah on 5/28/2018.
 */

public class WLJSStore extends ReactContextBaseJavaModule {

    private static final String JSONSTORE_SUCCESS = "Success";
    private static final String JSONSTORE_CREATE_ERROR = "jsonstore creation failed";
    private static final String JSONSTORE_ADDITION_ERROR = "jsonstore addition failed";
    private static final String JSONSTORE_FIND_ERROR = "jsonstore finding failed";
    private static final String JSONSTORE_REPLACE_ERROR = "jsonstore replacing failed";
    private static final String JSONSTORE_REMOVE_ERROR = "jsonstore removing failed";
    private static final String JSONSTORE_REMOVE_COLLECTION_ERROR = "jsonstore collection removing failed";
    private static final String JSONSTORE_DESTROY_ALL_ERROR = "jsonstore destroy failed";
    private static final String JSONSTORE_FIND_DIRTY_ERROR = "jsonstore find dirty documents failed";


    private JSONObject sendErrorDetails(String method,String error,String occuredevent){
        JSONObject error_object = new JSONObject();
        try {
            error_object.put("method",method);
            error_object.put("error",error);
            error_object.put("event",occuredevent);
        } catch (Exception e) {
            error_object = new JSONObject();
        }
        return  error_object;
    }

    private JSONStoreCollection setCollectionFields(JSONStoreCollection collection,ReadableMap readableMap){
        ReadableMapKeySetIterator iterator = readableMap.keySetIterator();
        while (iterator.hasNextKey()) {
            String key = iterator.nextKey();
            switch (readableMap.getType(key)) {

                case Boolean:
                    collection.setSearchField(key, SearchFieldType.BOOLEAN);

                    break;
                case Number:
                   collection.setSearchField(key, SearchFieldType.INTEGER);
                    break;
                case String:
                    collection.setSearchField(key, SearchFieldType.STRING);
                    break;
                default:
                    break;
            }
        }
        return  collection;
    }

    private JSONStoreQueryParts getSearchFileds(ReadableMap readableMap){
        JSONStoreQueryParts query = new JSONStoreQueryParts();
        JSONStoreQueryPart queryPart = new JSONStoreQueryPart();
        ReadableMapKeySetIterator iterator = readableMap.keySetIterator();
        while (iterator.hasNextKey()) {
            String key = iterator.nextKey();
            switch (readableMap.getType(key)) {
                case Boolean:
                    queryPart.addEqual(key,readableMap.getBoolean(key));

                    break;
                case Number:
                    queryPart.addEqual(key,readableMap.getInt(key));

                    break;
                case String:
                    queryPart.addEqual(key,readableMap.getString(key));
                    break;
                default:
                    break;
            }
        }
        query.addQueryPart(queryPart);
        return query;
    }

    public WLJSStore(ReactApplicationContext reactContext) {

        super(reactContext);
		 //WLClient.createInstance(reactContext);
    }

    @Override
    public String getName() {
        return "WLJSStore";
    }

    @ReactMethod
    public void createCollection(String collectionName, ReadableMap filedsandtypes,Promise promise){
		//final Callback errorCallback,final Callback successCallback
			Log.e("createCollection","createCollection");
			WritableMap map = Arguments.createMap();
        try {
            JSONStoreCollection j_collection = new JSONStoreCollection(collectionName);
            Log.e("*****val", String.valueOf(filedsandtypes));
            j_collection = setCollectionFields(j_collection,filedsandtypes);
            List<JSONStoreCollection> collections = new LinkedList<JSONStoreCollection>();
            collections.add(j_collection);
            WLJSONStore.getInstance(getReactApplicationContext()).openCollections(collections);

			map.putString("response", JSONSTORE_SUCCESS);
			promise.resolve(map);
         //   successCallback.invoke(JSONSTORE_SUCCESS);
        } catch (Exception e) {

			map.putString("response", sendErrorDetails(JSONSTORE_CREATE_ERROR,e.getMessage(),collectionName).toString());
			promise.resolve(map);
         //   errorCallback.invoke(sendErrorDetails(JSONSTORE_CREATE_ERROR,e.getMessage(),collectionName).toString());
          //  e.printStackTrace();
        }
    }

    @ReactMethod
    public void addToCollection(String collectionName, ReadableMap insertdata,Promise promise){
		//final Callback errorCallback,final Callback successCallback
		WritableMap map = Arguments.createMap();
        try {
            JSONObject data = new JSONObject(insertdata.toHashMap());
            JSONStoreCollection collection = WLJSONStore.getInstance(getReactApplicationContext()).getCollectionByName(collectionName);
            JSONStoreAddOptions options = new JSONStoreAddOptions();
            options.setMarkDirty(true);

            collection.addData(data, options);
			map.putString("response", JSONSTORE_SUCCESS);
			promise.resolve(map);
           // successCallback.invoke(JSONSTORE_SUCCESS);
        }catch (Exception e) {
			map.putString("response", sendErrorDetails(JSONSTORE_ADDITION_ERROR,e.getMessage(),collectionName).toString());
			promise.resolve(map);
            //errorCallback.invoke(sendErrorDetails(JSONSTORE_ADDITION_ERROR,e.getMessage(),collectionName).toString());
        }
    }

    @ReactMethod
    public void findFromCollection(String collectionName, ReadableMap searchfieldsandvalues,int limit,Promise promise){
		//final Callback errorCallback,final Callback successCallback
		WritableMap map = Arguments.createMap();
        try {
        JSONStoreQueryParts query = getSearchFileds(searchfieldsandvalues);
        JSONStoreFindOptions options = new JSONStoreFindOptions();
        options.setLimit(limit);
        JSONStoreCollection collection = WLJSONStore.getInstance(getReactApplicationContext()).getCollectionByName(collectionName);
        List<JSONObject> results = collection.findDocuments(query, options);
		 JSONArray j_array = new JSONArray(results);
          WritableArray warray = RNJSONUtils.convertJsonToArray(j_array);
		  map.putArray("response", warray);
			promise.resolve(map);
           // JSONArray j_results = new JSONArray(results);
        //successCallback.invoke(results);
        } catch (Exception e) {
			map.putString("response", sendErrorDetails(JSONSTORE_FIND_ERROR,e.getMessage(),collectionName).toString());
			promise.resolve(map);
           // errorCallback.invoke(sendErrorDetails(JSONSTORE_FIND_ERROR,e.getMessage(),collectionName).toString());
           // e.printStackTrace();
        }
    }

    @ReactMethod
    public void replaceFromCollection(String collectionName, ReadableMap replaceData,int replaceID,Promise promise){
		//final Callback errorCallback,final Callback successCallback
		WritableMap map = Arguments.createMap();
        try {

            JSONStoreCollection collection = WLJSONStore.getInstance(getReactApplicationContext()).getCollectionByName(collectionName);
            JSONStoreReplaceOptions options = new JSONStoreReplaceOptions();
            options.setMarkDirty(true);

            JSONObject replacement = new JSONObject();
            JSONObject t = new JSONObject(replaceData.toHashMap());
            replacement.put("_id",replaceID);
            replacement.put("json",t);
            Log.e("replacement",replacement.toString());
            collection.replaceDocument(replacement,options);
			map.putString("response", JSONSTORE_SUCCESS);
			promise.resolve(map);
           // successCallback.invoke(JSONSTORE_SUCCESS);
        } catch (Exception e) {
			map.putString("response", sendErrorDetails(JSONSTORE_REPLACE_ERROR,e.getMessage(),collectionName).toString());
			promise.resolve(map);
            //errorCallback.invoke(sendErrorDetails(JSONSTORE_REPLACE_ERROR,e.getMessage(),collectionName).toString());

        }
    }

    @ReactMethod
    public void removeFromCollection(String collectionName, int removeID,Promise promise){
		//final Callback errorCallback,final Callback successCallback
		WritableMap map = Arguments.createMap();
        try {
            JSONStoreCollection collection = WLJSONStore.getInstance(getReactApplicationContext()).getCollectionByName(collectionName);
            JSONStoreRemoveOptions options = new JSONStoreRemoveOptions();
            options.setMarkDirty(true);
            collection.removeDocumentById(removeID);
            map.putString("response", JSONSTORE_SUCCESS);
			promise.resolve(map);
			//successCallback.invoke(JSONSTORE_SUCCESS);
        } catch (Exception e) {
            map.putString("response", sendErrorDetails(JSONSTORE_REMOVE_ERROR,e.getMessage(),collectionName).toString());
			promise.resolve(map);
			//errorCallback.invoke(sendErrorDetails(JSONSTORE_REMOVE_ERROR,e.getMessage(),collectionName).toString());
            }
    }


    @ReactMethod
    public void removeCollection(String collectionName,Promise promise){
		//final Callback errorCallback,final Callback successCallback
		WritableMap map = Arguments.createMap();
        try {
            JSONStoreCollection collection = WLJSONStore.getInstance(getReactApplicationContext()).getCollectionByName(collectionName);
            collection.removeCollection();
           map.putString("response", JSONSTORE_SUCCESS);
			promise.resolve(map);
		   // successCallback.invoke(JSONSTORE_SUCCESS);
        } catch (Exception e) {
			map.putString("response", sendErrorDetails(JSONSTORE_REMOVE_COLLECTION_ERROR,e.getMessage(),collectionName).toString());
			promise.resolve(map);
            //errorCallback.invoke(sendErrorDetails(JSONSTORE_REMOVE_COLLECTION_ERROR,e.getMessage(),collectionName).toString());
            // e.printStackTrace();
        }
    }

    @ReactMethod
    public void destroyAll(Promise promise){
		//final Callback errorCallback,final Callback successCallback
        WritableMap map = Arguments.createMap();
		try {
            WLJSONStore.getInstance(getReactApplicationContext()).destroy();
			 map.putString("response", JSONSTORE_SUCCESS);
			promise.resolve(map);
            //successCallback.invoke(JSONSTORE_SUCCESS);
        } catch (Exception e) {
			map.putString("response", sendErrorDetails(JSONSTORE_DESTROY_ALL_ERROR,e.getMessage(),"").toString());
			promise.resolve(map);
            //errorCallback.invoke(sendErrorDetails(JSONSTORE_DESTROY_ALL_ERROR,e.getMessage(),"").toString());
            // e.printStackTrace();
        }
    }

    @ReactMethod
    public void findAllDirtyDocuments(String collectionName,Promise promise){
        //final Callback errorCallback,final Callback successCallback
        WritableMap map = Arguments.createMap();
        try {
            JSONStoreCollection collection = WLJSONStore.getInstance(getReactApplicationContext()).getCollectionByName(collectionName);
            List<JSONObject> results = collection.findAllDirtyDocuments();
            JSONArray j_array = new JSONArray(results);
            WritableArray warray = RNJSONUtils.convertJsonToArray(j_array);
            map.putArray("response", warray);
            promise.resolve(map);
        } catch (Exception e) {
            map.putString("response", sendErrorDetails(JSONSTORE_FIND_DIRTY_ERROR,e.getMessage(),collectionName).toString());
            promise.resolve(map);
            //errorCallback.invoke(sendErrorDetails(JSONSTORE_REMOVE_COLLECTION_ERROR,e.getMessage(),collectionName).toString());
            // e.printStackTrace();
        }
    }

    @ReactMethod
    public void justName( final Callback errorCallback,final Callback successCallback){
        successCallback.invoke("Hi");
     //  Toast.makeText(getReactApplicationContext(), "Hi", Toast.LENGTH_SHORT).show();
    //    return "Hi JSONSTORE";
    }

}
