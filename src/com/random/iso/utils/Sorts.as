package com.random.iso.utils 
{
	import com.random.iso.GameObject;
	/**
	 * ...
	 * @author Allen Halsted
	 * ============================================================================
	 * Data Structures For Game Programmers
	 * This file holds all of the sorting algorithms
	 * ============================================================================
	 */
	public class Sorts
	{
		
		public function Sorts() 
		{
		}			


		// ----------------------------------------------------------------
		//  Name:           Swap
		//  Description:    a simple swap function, swaps two pieces of data
		//  Arguments:      a, b: the data to swap
		//  Return Value:   None
		// ----------------------------------------------------------------
		private function Swap(a:Array, b:Array ):void
		{
			var t:Array;
			t = a;
			a = b;
			b = t;
		}




		// ----------------------------------------------------------------
		//  Name:           FindMedianOfThree
		//  Description:    Finds the median of three values in a segment
		//  Arguments:      p_array: the array to find the median of
		//                  p_first: the first index in the segment
		//                  p_size: the size of the segment
		//                  p_compare: comparison function
		//  Return Value:   index of the median
		// ----------------------------------------------------------------
		
		public function FindMedianOfThree( p_array:Array, 
							   p_first:int, 
							   p_size:int): int
		{
			// calculate the last and middle indexes
			var last:int = p_first + p_size - 1;
			var mid:int = p_first + (p_size / 2);
			
			// if the first index is the lowest,
			if( CompareY( p_array[p_first], p_array[mid] ) < 0 && 
				CompareY( p_array[p_first], p_array[last] ) < 0 )
			{
				// then the smaller of the middle and the last is the median.
				if( CompareY( p_array[mid], p_array[last] ) < 0 )
					return mid;
				else
					return last;
			}

			// if the middle index is the lowest,
			if( CompareY( p_array[mid], p_array[p_first] ) < 0 && 
				CompareY( p_array[mid], p_array[last] ) < 0 )
			{
				// then the smaller of the first and last is the median
				if( CompareY( p_array[p_first], p_array[last] ) < 0 )
					return p_first;
				else
					return last;
			}

			// by this point, we know that the last index is the lowest,
			// so the smaller of the middle and the first is the median.
			if( CompareY( p_array[mid], p_array[p_first] ) < 0 )
				return mid;
			else
				return p_first;
		}


		// ----------------------------------------------------------------
		//  Name:           QuickSort
		//  Description:    quicksorts the array
		//  Arguments:      p_array: the array to sort
		//                  p_first: first index of the segment to sort
		//                  p_size: size of the segment
		//                  p_compare: comparison function
		//  Return Value:   None
		// ----------------------------------------------------------------
		
		public function QuickSort( p_array:Array, p_first:int, p_size:int):void 
		{
			
			var pivot:GameObject;
			var last:int = p_first + p_size - 1;    // index of the last cell
			var lower:int = p_first;                // index of the lower cell
			var higher:int = last;                  // index of the upper cell
			var mid:int;                            // index of the median value
			var tmpArr:Array = [];
			// if the size of the array to sort is greater than 1, then sort it.
			if( p_size > 1 )
			{
				// find the index of the median value, and set that as the pivot.
				mid = FindMedianOfThree( p_array, p_first, p_size);
				pivot = p_array[mid];

				// move the first value in the array into the place where the pivot was
				p_array[mid] = p_array[p_first];

				// while the lower index is lower than the higher index
				while( lower < higher )
				{
					// iterate downwards until a value lower than the pivot is found
					while( CompareY( pivot, p_array[higher] ) < 0 && lower < higher )
						higher -=1;

					// if the previous loop found a value lower than the pivot, 
					// higher will not equal lower.
					if( higher != lower ) 
					{
						// so move the value of the higher index into the lower index 
						// (which is empty), and move the lower index up.
						p_array[lower] = p_array[higher];
						lower += 1;
						
					}

					// now iterate upwards until a value greater than the pivot is found
					while( CompareY( pivot, p_array[lower] ) > 0 && lower < higher )
						lower++;

					// if the previous loop found a value greater than the pivot,
					// higher will not equal lower
					if( higher != lower )
					{
						// move the value at the lower index into the higher index,
						// (which is empty), and move the higher index down.
						p_array[higher] = p_array[lower];
						higher -= 1;
					}
				}

				// at the end of the main loop, the lower index will be empty, so
				// put the pivot in there.
				p_array[lower] = pivot;
				
				// recursively quicksort the left half
				QuickSort( p_array, p_first, lower - p_first);

				// recursively quicksort the right half.
				QuickSort( p_array, lower + 1, last - lower);
				
				
			}
		}

		private function CompareY(l:GameObject, r:GameObject):int
		{
			if (l.yPos == r.yPos )
			{
				if( l.xPos < r.xPos )
					return 1;
				if( l.xPos > r.xPos )
					return -1;
			}
			if( l.yPos < r.yPos )
				return -1;
			if( l.yPos > r.yPos )
				return 1;
			return 0;
		}

		
	}

}