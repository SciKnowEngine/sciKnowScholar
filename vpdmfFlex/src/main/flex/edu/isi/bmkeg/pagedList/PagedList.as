/*
Copyright (C) 2012 James Ward

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/
package edu.isi.bmkeg.pagedList
{

	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	import mx.collections.IList;
	import mx.collections.errors.ItemPendingError;
	import mx.events.CollectionEvent;
	import mx.events.CollectionEventKind;
	import mx.events.PropertyChangeEvent;
	import mx.events.PropertyChangeEventKind;
	import mx.resources.IResourceManager;
	import mx.resources.ResourceManager;
	import mx.rpc.IResponder;
	
	[Event(name="collectionChange", type="mx.events.CollectionEvent")]
	
	/**
	 *  An IList whose items are fetched asynchronously by a user provided function.   The 
	 *  loadItemsFunction initiates an asynchronous request for a pageSize block items, typically
	 *  from a web service.  When the request sucessfully completes, the storeItemsAt() method
	 *  must be called. If the request fails, then failItemsAt().
	 * 
	 *  <p>PagedList divides its <code>length</code> items into <code>pageSize</code> blocks or 
	 *  "pages".  It tracks which items exist locally, typically because they've been stored with
	 *  storeItemsAt().  When an item that does not exist locally is requested with getItemAt(),
	 *  the loadItemsFunction is called and then an IPE is thrown.  When the loadItemsFunction
	 *  either completes or fails, it must call storeItemsAt() or failItemsAt() which causes
	 *  the IPE's responders to run and a "replace" CollectionEvent to be dispatched for the 
	 *  updated page.  The failItemsAt() method resets the corresponding items to undefined, 
	 *  which means that subsequent calls to getItemAt() will cause an IPE to be thrown.</p>
	 * 
	 *  <p>Unlike some other IList implementations, the only method here that can thrown an
	 *  IPE is getItemAt().   Methods like getItemIndex() and toArray() just report items
	 *  that aren't local as null.</p>
	 * 
	 *  <p>This class is intended to be used as the "list" source for an ASyncListView.</p>
	 */
	public class PagedList extends EventDispatcher implements IList
	{
							
		/**
		 *  @private
		 */
		private static function get resourceManager():IResourceManager
		{
			return ResourceManager.getInstance();
		}
		
		/**
		 *  @private
		 */    
		private static function checkItemIndex(index:int, listLength:int):void
		{
			if (index < 0 || (index >= listLength)) 
			{
				const message:String = resourceManager.getString("collections", "outOfBounds", [ index ]);
				throw new RangeError(message);
			}
		}
		
		/**
		 *  @private
		 *  The IList's items.
		 */
		private const _list:Array = new Array();
		//	Changed type of _list from Vector.<*>  to Array [MT];

		/**
		 *  Construct a PagedList with the specified length and pageSize.
		 */    
		public function PagedList(length:int=1000, pageSize:int=10)
		{
			this._list.length = length;
			this.pageSize = pageSize;
			
			for (var i:int = 0; i < _list.length; i++)
				_list[i] = undefined;
		}
		
		//----------------------------------
		//  loadItemsFunction
		//---------------------------------- 
		
		private var _loadItemsFunction:Function = null;
		
		/**
		 *  The value of this property must be a function that loads a contiguous 
		 *  block of items and then calls <code>storeItemsAt()</code> or 
		 *  <code>failItemsAt()</code>.  A loadItemsFunction must be defined as follows:
		 *  <pre>
		 *  myLoadItems(list:PagedList, index:int, count:int):void 
		 *  </pre>
		 *  
		 *  <p>Typically the loadItemsFunction will make one or more network requests
		 *  to retrieve the items.   It must do all of its work asynchronously to avoid
		 *  blocking the application's GUI.
		 *  
		 */
		public function get loadItemsFunction():Function
		{
			return _loadItemsFunction;
		}
		
		/**
		 *  @private
		 */
		public function set loadItemsFunction(value:Function):void
		{
			_loadItemsFunction = value;
		}
		
		//----------------------------------
		//  length
		//---------------------------------- 
		
		[Bindable("collectionChange")]    
		
		/**
		 *  The number of items in the list.
		 *  
		 *  <p>The length of the list can be changed directly however the "-1" indeterminate 
		 *  length value is not supported.</p>
		 */
		public function get length():int
		{
			return _list.length;
		}
		
		/**
		 *  @private
		 */
		public function set length(value:int):void
		{
			const oldLength:int = _list.length;
			const newLength:int = value;
			
			if (oldLength == newLength)
				return;
			
			var ce:CollectionEvent = null;
			if (hasEventListener(CollectionEvent.COLLECTION_CHANGE))
				ce = new CollectionEvent(CollectionEvent.COLLECTION_CHANGE);
			
			if (oldLength < newLength)
			{
				if (ce)
				{
					ce.location = Math.max(oldLength - 1, 0);
					ce.kind = CollectionEventKind.ADD;
					const itemsLength:int = newLength - oldLength;
					for (var i:int = 0; i < itemsLength; i++)
						ce.items.push(undefined);
				}
				
				_list.length = newLength;
				for (var newIndex:int = Math.max(oldLength - 1, 0); newIndex < newLength; newIndex++)
					_list[newIndex] = undefined;
			}
			else // oldLength > newLength
			{
				if (ce)
				{
					ce.location = Math.max(newLength - 1, 0);
					ce.kind = CollectionEventKind.REMOVE;
					for (var oldIndex:int = Math.max(newLength - 1, 0); oldIndex < oldLength; oldIndex++)
						ce.items.push(_list[oldIndex]);
				}
				
				_list.length = newLength; 
			}
			
			if (ce)
				dispatchEvent(ce);
		}
		
		//----------------------------------
		//  pageSize
		//---------------------------------- 
		
		private var _pageSize:int = 10;
		
		/** 
		 *  Items are loaded in contiguous pageSize blocks.  The value of this property should be greater than  
		 *  zero, smaller than the PageList's length, and a reasonable working size for the loadItemsFunction.   
		 */
		public function get pageSize():int
		{
			return _pageSize;
		}
		
		/**
		 *  @private
		 */
		public function set pageSize(value:int):void
		{
			_pageSize = value;    
		}
		
		/**
		 *  Resets the entire list to its initial state.  All local and pending items are 
		 *  cleared.
		 */
		public function clearItems():void
		{
			var index:int = 0;
			for each (var item:Object in _list)
			_list[index++] = undefined;
			
			if (hasEventListener(CollectionEvent.COLLECTION_CHANGE))
			{
				var ce:CollectionEvent = new CollectionEvent(CollectionEvent.COLLECTION_CHANGE);
				ce.kind = CollectionEventKind.RESET;
				dispatchEvent(ce);
			}            
		}
		
		/**
		 *  @private
		 */
		private static function createUpdatePCE(itemIndex:Object, oldValue:Object, newValue:Object):PropertyChangeEvent
		{
			const pce:PropertyChangeEvent = new PropertyChangeEvent(PropertyChangeEvent.PROPERTY_CHANGE);
			pce.kind = PropertyChangeEventKind.UPDATE;
			pce.property = itemIndex;
			pce.oldValue = oldValue;
			pce.newValue = newValue;
			return pce;
		}
		
		/**
		 *  @private
		 */    
		private static function createCE(kind:String, location:int, item:Object):CollectionEvent
		{
			const ce:CollectionEvent = new CollectionEvent(CollectionEvent.COLLECTION_CHANGE);
			ce.kind = kind;
			ce.location = location;
			
			if (item is Array)
				ce.items = item as Array;
			else
				ce.items.push(item);
			
			return ce;
		}
		
		/**
		 *  This method must be called by the loadItemsFunction after a block of requested
		 *  items have been successfully retrieved.  It stores the specified items in the 
		 *  internal data vector and clears the "pending" state associated with the original
		 *  request.
		 */
		public function storeItemsAt(items:Array, index:int):void
		{
			// Changed type of 'items' from Vector.<Object> to Array [MT]
			if (index < 0 || (index + items.length) > length) 
			{
				const message:String = resourceManager.getString("collections", "outOfBounds", [ index ]);
				throw new RangeError(message);
			}
			
			var item:Object;
			var itemIndex:int;
			var pce:PropertyChangeEvent;
			
			// copy the new items into the internal items vector and run the IPE responders
			
			itemIndex = index;
			for each (item in items)
			{
				var ipe:ItemPendingError = _list[itemIndex] as ItemPendingError;
				
				// Inverted the order between responders invokation and assigning
				// items to _list so the responders will find the list updated 
				// with the incoming items [MT]
				
				_list[itemIndex++] = item;

				if (ipe && ipe.responders)
				{
					for each (var responder:IResponder in ipe.responders)
					{
						// Changed the argument of the result method from null to 'item' [MT]
						responder.result(item);						
					}
				}
				
			}
			
			// dispatch collection and property change events
			
			const hasCollectionListener:Boolean = hasEventListener(CollectionEvent.COLLECTION_CHANGE);
			const hasPropertyListener:Boolean = hasEventListener(PropertyChangeEvent.PROPERTY_CHANGE);
			var propertyChangeEvents:Array = new Array();  // Array of PropertyChangeEvents; 
			
			if (hasCollectionListener || hasPropertyListener)
			{   
				itemIndex = index;
				for each (item in items)
				propertyChangeEvents.push(createUpdatePCE(itemIndex++, null, item));
			}
			
			if (hasCollectionListener)
				dispatchEvent(createCE(CollectionEventKind.REPLACE, index, propertyChangeEvents));
			
			if (hasPropertyListener)
			{
				for each (pce in propertyChangeEvents)
				dispatchEvent(pce);
			}
		}
		
		public function failItemsAt(index:int, count:int):void
		{
			if (index < 0 || (index + count) > length) 
			{
				const message:String = resourceManager.getString("collections", "outOfBounds", [ index ]);
				throw new RangeError(message);
			}
			
			for (var i:int = 0; i < count; i++)
			{
				var itemIndex:int = i + index;
				var ipe:ItemPendingError = _list[itemIndex] as ItemPendingError;
				if (ipe && ipe.responders)
				{
					for each (var responder:IResponder in ipe.responders)
					responder.fault(null);
				}
				_list[itemIndex] = undefined;
			}        
			
			
			
		}
		
		//--------------------------------------------------------------------------
		//
		//  IList Implementation (length appears above)
		//
		//--------------------------------------------------------------------------
		
		/**
		 *  @inheritDoc
		 */    
		public function addItem(item:Object):void
		{
			addItemAt(item, length);        
		}
		
		/**
		 *  @inheritDoc
		 */   
		public function addItemAt(item:Object, index:int):void
		{
			checkItemIndex(index, length + 1);
			_list.splice(index, index, item);
			
			if (hasEventListener(CollectionEvent.COLLECTION_CHANGE))
				dispatchEvent(createCE(CollectionEventKind.ADD, index, item));
		}
		
		/**
		 *  @inheritDoc
		 */   
		public function getItemAt(index:int, prefetch:int=0):Object
		{
			checkItemIndex(index, length);
			
			var item:* = _list[index];
			if (item is ItemPendingError)
			{
				throw item as ItemPendingError;
			}
			else if (item === undefined)
			{
				const pageStartIndex:int = Math.floor(index / pageSize) * pageSize;
				const count:int = Math.min(pageSize, _list.length - pageStartIndex);
				
				for (var i:int = 0; i < count; i++)
				{
					// Changed to create IPEs inside loop to have one IPE per item
					var ipe:ItemPendingError = new ItemPendingError(String(pageStartIndex + i));
					_list[pageStartIndex + i] = ipe;
				}
				
				if (loadItemsFunction !== null)
					loadItemsFunction(this, pageStartIndex, count);
				
				// Allow for the possibility that loadItemsFunction has synchronously
				// loaded the requested data item.
				
				if (_list[index] is ItemPendingError)
					throw ipe;
				else
					item = _list[index];
			}
			
			return item;
		}
		
		/**
		 *  Return the index of of the specified item, if it currently exists in the list.
		 *  This method does not cause additional items to be loaded.
		 */   
		public function getItemIndex(item:Object):int
		{
			return _list.indexOf(item);
		}
		
		/**
		 *  @inheritDoc
		 */   
		public function itemUpdated(item:Object, property:Object=null, oldValue:Object=null, newValue:Object=null):void
		{
			const hasCollectionListener:Boolean = hasEventListener(CollectionEvent.COLLECTION_CHANGE);
			const hasPropertyListener:Boolean = hasEventListener(PropertyChangeEvent.PROPERTY_CHANGE);
			var pce:PropertyChangeEvent = null;
			
			if (hasCollectionListener || hasPropertyListener)
				pce = createUpdatePCE(property, oldValue, newValue);
			
			if (hasCollectionListener)
				dispatchEvent(createCE(CollectionEventKind.UPDATE, -1, pce));
			
			if (hasPropertyListener)
				dispatchEvent(pce);
		}
		
		/**
		 *  @inheritDoc
		 */   
		public function removeAll():void
		{
			length = 0;
			
			if (hasEventListener(CollectionEvent.COLLECTION_CHANGE))
			{
				const ce:CollectionEvent = new CollectionEvent(CollectionEvent.COLLECTION_CHANGE);
				ce.kind = CollectionEventKind.RESET;
				dispatchEvent(ce);
			}
		}
		
		/**
		 *  @inheritDoc
		 */   
		public function removeItemAt(index:int):Object
		{
			checkItemIndex(index, length);
			
			const item:Object = _list[index];
			
			_list.splice(index, 1);
			if (hasEventListener(CollectionEvent.COLLECTION_CHANGE))
				dispatchEvent(createCE(CollectionEventKind.REMOVE, index, item));    
			
			return item;
		}
		
		/**
		 *  @inheritDoc
		 */   
		public function setItemAt(item:Object, index:int):Object
		{
			checkItemIndex(index, length);
			
			const oldItem:Object = _list[index];
			
			if (item !== oldItem)
			{
				const hasCollectionListener:Boolean = hasEventListener(CollectionEvent.COLLECTION_CHANGE);
				const hasPropertyListener:Boolean = hasEventListener(PropertyChangeEvent.PROPERTY_CHANGE);
				var pce:PropertyChangeEvent = null;
				
				if (hasCollectionListener || hasPropertyListener)
					pce = createUpdatePCE(index, oldItem, item);
				
				if (hasCollectionListener)
					dispatchEvent(createCE(CollectionEventKind.REPLACE, index, pce));
				
				if (hasPropertyListener)
					dispatchEvent(pce);
				
				_list[index] = item;
			}
			
			return oldItem;
		}
		
		/**
		 *  Returns an array with the same length as this list, that contains all of
		 *  the items successfully loaded so far.  
		 * 
		 *  <p>Calling this method does not force additional items to be loaded.</p>
		 */   
		public function toArray():Array
		{
			const rv:Array = new Array(_list.length);
			
			var index:int = 0;
			for each (var item:* in _list)
			rv[index++] = (item is ItemPendingError) ? undefined : item;
			
			return rv;
		}
	}
}