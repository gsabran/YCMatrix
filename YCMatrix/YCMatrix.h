//
// YCMatrix.h
//
// YCMatrix
//
// Copyright (c) 2013, 2014 Ioannis (Yannis) Chatzikonstantinou. All rights reserved.
// http://yconst.com
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.


#define Matrix YCMatrix

typedef enum refMode { YCMWeak, YCMStrong, YCMCopy } refMode;

#import <Foundation/Foundation.h>
#import <Accelerate/Accelerate.h>

@interface YCMatrix : NSObject <NSCoding, NSCopying>
{
	@public double *matrix;
	@public int rows;
	@public int columns;
    @private BOOL freeData;
}


/// @name Initialization

/**
 Initializes and returns a new YCMatrix of |m| rows and |n| columns.

 @param m Number of rows.
 @param n Number of columns.

 @return A new YCMatrix of |m| rows and |n| columns.
 */
+ (instancetype)matrixOfRows:(int)m Columns:(int)n;

/**
 Initializes and returns a new YCMatrix of |m| rows and |n| columns, each containing value |val|.

 @param m   The number of rows.
 @param n   The number of columns.
 @param val Cell value.

 @return A new YCMatrix of |m| rows and |n| columns.
 */
+ (instancetype)matrixOfRows:(int)m Columns:(int)n Value:(double)val;

/**
 Initializes and returns a new YCMatrix of |m| rows and |n| columns, with values in array |diagonal|
 representing values in the matrix diagonal, and each other cell containing value |val|.
 
 @param m        The number of rows.
 @param n        The number of columns.
 @param diagonal The values to insert to the diagonal.
 @param val      The value to insert to the rest of the matrix.
 
 @return A new YCMatrix of |m| rows and |n| columns.
 */
+ (instancetype)matrixOfRows:(int)m
                     Columns:(int)n
            ValuesInDiagonal:(double *)diagonal
                       Value:(double)val;

/**
 Initializes and returns a new YCMatrix of |m| rows and |n| columns,
 by copying array |arr|.

 @param arr The array of values.
 @param m   The number of rows.
 @param n   The number of columns.

 @return A new YCMatrix of |m| rows and |n| columns.
 */
+ (instancetype)matrixFromArray:(double *)arr Rows:(int)m Columns:(int)n;

/**
 Initializes and returns a new YCMatrix of |m| rows and |n| columns,
 by either weakly or strongly referencing, or copying array |arr|.

 @param arr  The array of values.
 @param m    The number of rows.
 @param n    The number of columns.
 @param mode The reference mode.

 @return A new YCMatrix of |m| rows and |n| columns.
 */
+ (instancetype)matrixFromArray:(double *)arr Rows:(int)m Columns:(int)n Mode:(refMode)mode;

/**
 Initializes and returns a new YCMatrix of |m| rows and |n| columns,
 by copying values in NSArray |arr|

 @param arr The NSArray containing values to be copied.
 @param m   The number of rows.
 @param n   The number of columns.

 @return A new YCMatrix of |m| rows and |n| columns.
 */
+ (instancetype)matrixFromNSArray:(NSArray *)arr Rows:(int)m Columns:(int)n;

/**
 Initializes and returns a new YCMatrix by copying matrix |other|.

 @param other The matrix to copy.

 @return A new matrix of equal dimensions to |other|.
 */
+ (instancetype)matrixFromMatrix:(YCMatrix *)other;

/**
 Initializes and returns a new Identity Matrix of |m| rows and |n| columns
 
 @param m The number of rows.
 @param n The number of columns.
 
 @return A new YCMatrix of |m| rows and |n| columns.
 */
+ (instancetype)identityOfRows:(int)m Columns:(int)n;


/// @name Accessing and setting data

/**
 Returns the value at position |row|, |column| of the receiver.
 
 @param row    The row.
 @param column The column.
 
 @return A double corresponding to the value at position |row|, |column|.
 */
- (double)valueAtRow:(int)row Column:(int)column;

/**
 Returns the value at position |m|, |n| of the receiver.
 
 @param m    The row.
 @param n The column.
 
 @return A double corresponding to the value at position |m|, |n|.
 */
- (double)m:(int)m n:(int)n;

/**
 Sets value |vl| at |row|, |column| of the receiver.
 
 @param vl     The value to set.
 @param row    The row.
 @param column The column.
 */
- (void)setValue:(double)vl Row:(int)row Column:(int)column;

/**
 Sets value |vl| at |m|, |n| of the receiver.
 
 @param m    The row.
 @param n    The column.
 @param vl   The value to set.
 */
- (void)m:(int)m n:(int)n is:(double)vl;


/// @name Matrix Operations

/**
 Returns the result of adding the matrix to |addend|.
 
 @param addend The YCMatrix to add to.
 
 @return The result of the addition.
 */
- (YCMatrix *)matrixByAdding:(YCMatrix *)addend;

/**
 Returns the result of subtracting |subtrahend| from the receiver.
 
 @param subtrahend The YCMatrix to subtract from this.
 
 @return The result of the subtraction.
 */
- (YCMatrix *)matrixBySubtracting:(YCMatrix *)subtrahend;

/**
 Returns the result of multiplying the receiver with right matrix |mt|.
 
 @param mt The YCMatrix to multiply with.
 
 @return The result of the multiplication.
 */
- (YCMatrix *)matrixByMultiplyingWithRight:(YCMatrix *)mt;

/**
 Returns the result of multiplying the receiver with right matrix |mt| and optionally transposing
 the result.
 
 @param mt    The YCMatrix to multiply with.
 @param trans Whether to transpose the result.
 
 @return The result of the operation.
 */
- (YCMatrix *)matrixByMultiplyingWithRight:(YCMatrix *)mt AndTransposing:(bool)trans;

/**
 Returns the result of multiplying the receiver with right matrix |mt| and adding
 YCMatrix |ma| to the result.
 
 @param mt The YCMatrix to multiply with.
 @param ma The YCMatrix to add to the multiplication result.
 
 @return The result of the operation.
 */
- (YCMatrix *)matrixByMultiplyingWithRight:(YCMatrix *)mt AndAdding:(YCMatrix *)ma;

/**
 Returns the result of multiplying the receiver with right matrix |mt| and then with scalar |factor|.
 
 @param mt The YCMatrix to multiply with.
 @param sf The scalar factor to multiply with.
 
 @return The result of the multiplication.
 */
- (YCMatrix *)matrixByMultiplyingWithRight:(YCMatrix *)mt AndFactor:(double)sf;

/**
 Returns the result of transposing the receiver and multiplying with right matrix |mt|.
 
 @param mt The YCMatrix to multiply with.
 
 @return The result of the operation.
 */
- (YCMatrix *)matrixByTransposingAndMultiplyingWithRight:(YCMatrix *)mt;

/**
 Returns the result of transposing the receiver and multiplying with left matrix |mt|.
 
 @param mt The YCMatrix to multiply with.
 
 @return The result of the operation.
 */
- (YCMatrix *)matrixByTransposingAndMultiplyingWithLeft:(YCMatrix *)mt;

/**
 Returns the result of multiplying the receiver with scalar |ms|.
 
 @param ms The scalar to multiply with.
 
 @return The result of the multiplication.
 */
- (YCMatrix *)matrixByMultiplyingWithScalar:(double)ms;

/**
 Returns the result of multiplying the receiver with scalar |ms| and adding matrix |addend|.
 
 @param ms     The scalar to multiply with
 @param addend The YCMatrix to add.
 
 @return The result of the operation.
 */
- (YCMatrix *)matrixByMultiplyingWithScalar:(double)ms AndAdding:(YCMatrix *)addend;

/**
 Negates the receiver.
 
 @return The result of the negation.
 */
- (YCMatrix *)matrixByNegating;

/**
 Transposes the receiver.
 
 @return The result of the transposition.
 */
- (YCMatrix *)matrixByTransposing;

/**
 Returns the result of elementwise multiplication of the receiver with matrix |mt|.
 
 @param mt The YCMatrix to elementwise multiply with.
 
 @return The result of the elementwise multiplication.
 */
- (YCMatrix *)matrixByElementWiseMultiplyingWith:(YCMatrix *)mt;


/// @name In-place Matrix Operations

/**
 Performs an in-place addition of |addend|.
 
 @param addend The matrix to add.
 */
- (void)add:(YCMatrix *)addend;

/**
 Performs an in-place subtraction of |subtrahend|.
 
 @param subtrahend The matrix to subtract.
 */
- (void)subtract:(YCMatrix *)subtrahend;

/**
 Performs an in-place scalar multiplication of the receiver.
 
 @param ms The scalar to multiply with.
 */
- (void)multiplyWithScalar:(double)ms;

/**
 Performs an in-place negation of this matrix.
 */
- (void)negate;

/**
 Returns the result of an elementwise multiplication with YCMatrix |mt|.
 
 @param mt The result of the elementwise multiplication.
 */
- (void)elementWiseMultiply:(YCMatrix *)mt;

/**
 Returns the trace of this matrix.
 
 @return A double corresponding to the calculated trace of the receiver.
 */
- (double)trace;

/**
 Returns a double resulting from the summation of an elementwise multiplication of the receiver with |other|

 @param other The YCMatrix to perform the elementwise multiplication with.

 @return A double corresponding to the result of the operation.
 */
- (double)dotWith:(YCMatrix *)other;

/**
 Returns a copy that is normalized to the range [0,1].

 @return The YCMatrix copy.
 @warning This method is applicable only to vectors.
 */
- (YCMatrix *)matrixByUnitizing;

/**
 Returns YES if the receiver is a square matrix.

 @return Boolean denoting if the matrix is square.
 */
- (BOOL)isSquare;

/**
 Compares the receiver with a YCMatrix, using the specified precision
 
 @param aMatrix The other matrix
 @param decimals the decimal places to use for comparisons
 
 @return Boolean showing whether the YCMatrix objects are equal or not.
 */
- (BOOL)isEqualToMatrix:(YCMatrix *)aMatrix Precision:(int)decimals;


/// @name Checks

/**
 Checks if supplied indices are within bounds. Throws a YCMatrixException if not.
 
 @param row    The row index to check.
 @param column The column index to check.
 */
- (void)checkBoundsForRow:(int)row Column:(int)column;

/**
 Checks if the receiver is square. Throws YCMatrixException if not.
 */
- (void)checkSquare;


/**
 Returns the data array of the receiver.
 */
@property (readonly) double *array;

/**
 Returns a copy of the data array of thereceiver.
 */
@property (readonly) double *arrayCopy;

/**
 Returns an NSArray with the content of the data array of the receiver.
 */
@property (readonly) NSArray *numberArray;

/**
 Returns a column matrix (vector) containing the elements of the diagonal of the receiver.
 
 @warning   Calling this method repeatedly will incur a performance penalty,
            since the elements need to be extracted every time. Better store
            the result and reuse.
 */
@property (readonly) YCMatrix *diagonal;

/**
 Returns the number of rows of the receiver.
 */
@property (readonly) int rows;

/**
 Returns the number of columns of the receiver.
 */
@property (readonly) int columns;

/**
 Returns the length of the data array of the receiver.
 */
@property (readonly) NSUInteger count;

/**
 Returns the sum of all the elements of the receiver.
 */
@property (readonly) double sum;

/**
 Returns the product of all the elements of the receiver.
 */
@property (readonly) double product;

@end
