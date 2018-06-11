using ReactNative.Bridge;
using System;
using System.Collections.Generic;
using Windows.ApplicationModel.Core;
using Windows.UI.Core;

namespace Mobilefirst.Jsonstore.RNMobilefirstJsonstore
{
    /// <summary>
    /// A module that allows JS to share data.
    /// </summary>
    class RNMobilefirstJsonstoreModule : NativeModuleBase
    {
        /// <summary>
        /// Instantiates the <see cref="RNMobilefirstJsonstoreModule"/>.
        /// </summary>
        internal RNMobilefirstJsonstoreModule()
        {

        }

        /// <summary>
        /// The name of the native module.
        /// </summary>
        public override string Name
        {
            get
            {
                return "RNMobilefirstJsonstore";
            }
        }
    }
}
