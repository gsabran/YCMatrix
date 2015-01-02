//
// YCMatrix.m
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

#import "YCMatrix.h"
#import "Constants.h"

@implementation YCMatrix

#pragma mark Factory Methods

+ (instancetype)matrixOfRows:(int)m Columns:(int)n
{
    return [self matrixOfRows:m Columns:n ValuesInDiagonal:nil Value:0];
}

+ (instancetype)matrixLike:(YCMatrix *)other
{
    return [self matrixOfRows:other->rows Columns:other->columns];
}

+ (instancetype)onesLike:(YCMatrix *)other
{
    return [self matrixOfRows:other->rows Columns:other->columns Value:1.0];
}

+ (instancetype)dirtyMatrixOfRows:(int)m Columns:(int)n
{
    double *new_m = malloc(m*n * sizeof(double));
	YCMatrix *mt = [self matrixFromArray:new_m Rows:m Columns:n Mode:YCMWeak];
    mt->freeData = YES;
    return mt;
}

+ (instancetype)matrixOfRows:(int)m Columns:(int)n Value:(double)val
{
	return [self matrixOfRows:m Columns:n ValuesInDiagonal:nil Value:val];
}

+ (instancetype)matrixOfRows:(int)m
                     Columns:(int)n
            ValuesInDiagonal:(double *)diagonal
                       Value:(double)val
{
	double *new_m = malloc(m*n*sizeof(double));
	YCMatrix *mt = [self matrixFromArray:new_m Rows:m Columns:n Mode:YCMWeak];
    mt->freeData = YES;
	int len = m*n;
	for (int i=0; i<len; i++)
	{
		mt->matrix[i] = val;
	}
    if (diagonal)
    {
        int mind = MIN(m, n);
        for (int i=0; i<mind; i++)
        {
            mt->matrix[i*(n+1)] = diagonal[i];
        }
    }
	return mt;
}

+ (instancetype)matrixFromArray:(double *)arr Rows:(int)m Columns:(int)n
{
	return [self matrixFromArray:arr Rows:m Columns:n Mode:YCMCopy];
}

+ (instancetype)matrixFromArray:(double *)arr Rows:(int)m Columns:(int)n Mode:(refMode)mode
{
	YCMatrix *mt = [[YCMatrix alloc] init];
	if (mode == YCMCopy)
	{
		double *new_m = malloc(m*n*sizeof(double));
		memcpy(new_m, arr, m*n*sizeof(double));
		mt->matrix = new_m;
        mt->freeData = YES;
	}
	else
	{
		mt->matrix = arr;
        mt->freeData = NO;
	}
    if (mode != YCMWeak) mt->freeData = YES;
	mt->rows = m;
	mt->columns = n;
	return mt;
}

+ (instancetype)matrixFromNSArray:(NSArray *)arr Rows:(int)m Columns:(int)n
{
	if([arr count] != m*n)
		@throw [NSException exceptionWithName:@"MatrixSizeException"
		        reason:@"Matrix size does not match that of the input array."
		        userInfo:nil];
	YCMatrix *newMatrix = [YCMatrix matrixOfRows:m Columns:n];
	double *cArray = newMatrix->matrix;
	NSUInteger j=[arr count];
	for (int i=0; i<j; i++)
	{
		cArray[i] = [[arr objectAtIndex:i] doubleValue];
	}
	return newMatrix;
}

+ (instancetype)matrixFromMatrix:(YCMatrix *)other
{
	YCMatrix *mt = [YCMatrix matrixFromArray:other->matrix Rows:other->rows Columns:other->columns];
	return mt;
}

+ (instancetype)identityOfRows:(int)m Columns:(int)n
{
	double *new_m = calloc(m*n, sizeof(double));
	int minsize = m;
	if (n < m) minsize = n;
	for(int i=0; i<minsize; i++) {
		new_m[(n + 1)*i] = 1.0;
	}
	return [YCMatrix matrixFromArray:new_m Rows:m Columns:n];
}

#pragma mark Instance Methods

- (double)valueAtRow:(int)row Column:(int)column
{
	[self checkBoundsForRow:row Column:column];
	return matrix[row*columns + column];
}

- (double)i:(int)i j:(int)j
{
	[self checkBoundsForRow:i Column:j];
	return matrix[i*columns + j];
}

- (void)setValue:(double)vl Row:(int)row Column:(int)column
{
	[self checkBoundsForRow:row Column:column];
	matrix[row*columns + column] = vl;
}

- (void)i:(int)i j:(int)j set:(double)vl
{
	[self checkBoundsForRow:i Column:j];
	matrix[i*columns + j] = vl;
}

- (void)checkBoundsForRow:(int)row Column:(int)column
{
	if(column >= columns)
		@throw [NSException exceptionWithName:@"IndexOutOfBoundsException"
		        reason:@"Column index input is out of bounds."
		        userInfo:nil];
	if(row >= rows)
		@throw [NSException exceptionWithName:@"IndexOutOfBoundsException"
		        reason:@"Rows index input is out of bounds."
		        userInfo:nil];
}

- (void)checkSquare
{
    if(columns != rows)
		@throw [NSException exceptionWithName:@"MatrixSizeException"
                                       reason:@"Matrix is not square."
                                     userInfo:nil];
}

- (YCMatrix *)matrixByAdding:(YCMatrix *)addend
{
	return [self matrixByMultiplyingWithScalar:1 AndAdding:addend];
}

- (YCMatrix *)matrixBySubtracting:(YCMatrix *)subtrahend
{
	return [subtrahend matrixByMultiplyingWithScalar:-1 AndAdding:self];
}

- (YCMatrix *)matrixByMultiplyingWithRight:(YCMatrix *)mt
{
	return [self matrixByTransposing:NO
	        TransposingRight:NO
	        MultiplyWithRight:mt
	        Factor:1
	        Adding:nil];
}

- (YCMatrix *)matrixByMultiplyingWithRight:(YCMatrix *)mt AndTransposing:(bool)trans
{
	YCMatrix *M1 = trans ? mt : self;
	YCMatrix *M2 = trans ? self : mt;
	return [M1 matrixByTransposing:trans
	        TransposingRight:trans
	        MultiplyWithRight:M2
	        Factor:1
	        Adding:nil];
}

- (YCMatrix *)matrixByMultiplyingWithRight:(YCMatrix *)mt AndAdding:(YCMatrix *)ma
{
	return [self matrixByTransposing:NO
	        TransposingRight:NO
	        MultiplyWithRight:mt
	        Factor:1
	        Adding:ma];
}

- (YCMatrix *)matrixByMultiplyingWithRight:(YCMatrix *)mt AndFactor:(double)sf
{
	return [self matrixByTransposing:NO
	        TransposingRight:NO
	        MultiplyWithRight:mt
	        Factor:sf
	        Adding:nil];
}

- (YCMatrix *)matrixByTransposingAndMultiplyingWithRight:(YCMatrix *)mt
{
	return [self matrixByTransposing:YES
	        TransposingRight:NO
	        MultiplyWithRight:mt
	        Factor:1
	        Adding:nil];
}

- (YCMatrix *)matrixByTransposingAndMultiplyingWithLeft:(YCMatrix *)mt
{
	return [mt matrixByTransposing:NO
	        TransposingRight:YES
	        MultiplyWithRight:self
	        Factor:1
	        Adding:nil];
}

//
// Actual calls to BLAS

- (YCMatrix *)matrixByTransposing:(BOOL)transposeLeft
        TransposingRight:(BOOL)transposeRight
        MultiplyWithRight:(YCMatrix *)mt
        Factor:(double)factor
        Adding:(YCMatrix *)addend
{
	int M = transposeLeft ? columns : rows;
	int N = transposeRight ? mt->rows : mt->columns;
	int K = transposeLeft ? rows : columns;
	int lda = columns;
	int ldb = mt->columns;
	int ldc = N;

	if ((transposeLeft ? rows : columns) != (transposeRight ? mt->columns : mt->rows))
	{
		@throw [NSException exceptionWithName:@"MatrixSizeException"
		        reason:@"Matrix size unsuitable for multiplication."
		        userInfo:nil];
	}
	if (addend && (addend->rows != M && addend->columns != N)) // FIX!!!
	{
		@throw [NSException exceptionWithName:@"MatrixSizeException"
		        reason:@"Matrix size unsuitable for addition."
		        userInfo:nil];
	}
	enum CBLAS_TRANSPOSE lT = transposeLeft ? CblasTrans : CblasNoTrans;
	enum CBLAS_TRANSPOSE rT = transposeRight ? CblasTrans : CblasNoTrans;

	YCMatrix *result = addend ?[YCMatrix matrixFromMatrix:addend] :[YCMatrix matrixOfRows:M
	                                                                Columns:N];
	cblas_dgemm(CblasRowMajor, lT,          rT,         M,
	            N,              K,          factor,     matrix,
	            lda,            mt->matrix, ldb,        1,
	            result->matrix, ldc);
	return result;
}

- (YCMatrix *)matrixByMultiplyingWithScalar:(double)ms
{
	YCMatrix *product = [YCMatrix matrixFromMatrix:self];
	cblas_dscal(rows*columns, ms, product->matrix, 1);
	return product;
}

- (YCMatrix *)matrixByMultiplyingWithScalar:(double)ms AndAdding:(YCMatrix *)addend
{
	if(columns != addend->columns || rows != addend->rows || sizeof(matrix) != sizeof(addend->matrix))
		@throw [NSException exceptionWithName:@"MatrixSizeException"
		        reason:@"Matrix size mismatch."
		        userInfo:nil];
	YCMatrix *sum = [YCMatrix matrixFromMatrix:addend];
	cblas_daxpy(rows*columns, ms, self->matrix, 1, sum->matrix, 1);
	return sum;
}

// End of actual calls to BLAS
//

- (YCMatrix *)matrixByNegating
{
	return [self matrixByMultiplyingWithScalar:-1];
}

- (YCMatrix *)matrixByTransposing
{
	YCMatrix *trans = [YCMatrix dirtyMatrixOfRows:columns Columns:rows];
	vDSP_mtransD(self->matrix, 1, trans->matrix, 1, trans->rows, trans->columns);
	return trans;
}

- (YCMatrix *)matrixByElementWiseMultiplyWith:(YCMatrix *)mt
{
	YCMatrix *result = [self copy];
	[result elementWiseMultiply:mt];
	return result;
}

- (YCMatrix *)matrixByElementWisDivideBy:(YCMatrix *)mt
{
    YCMatrix *result = [self copy];
    [result elementWiseDivide:mt];
    return result;
}

- (void)add:(YCMatrix *)addend
{
	if(columns != addend->columns || rows != addend->rows || sizeof(matrix) != sizeof(addend->matrix))
		@throw [NSException exceptionWithName:@"MatrixSizeException"
		        reason:@"Matrix size mismatch."
		        userInfo:nil];
	cblas_daxpy(rows*columns, 1, addend->matrix, 1, self->matrix, 1);
}

- (void)subtract:(YCMatrix *)subtrahend
{
	if(columns != subtrahend->columns || rows != subtrahend->rows || sizeof(matrix) != sizeof(subtrahend->matrix))
		@throw [NSException exceptionWithName:@"MatrixSizeException"
		        reason:@"Matrix size mismatch."
		        userInfo:nil];
	cblas_daxpy(rows*columns, -1, subtrahend->matrix, 1, self->matrix, 1);
}

- (void)multiplyWithScalar:(double)ms
{
	cblas_dscal(rows*columns, ms, matrix, 1);
}

- (void)negate
{
	[self multiplyWithScalar:-1];
}

- (void)elementWiseMultiply:(YCMatrix *)mt
{
	if(columns != mt->columns || rows != mt->rows || sizeof(matrix) != sizeof(mt->matrix))
		@throw [NSException exceptionWithName:@"MatrixSizeException"
		        reason:@"Matrix size mismatch."
		        userInfo:nil];
	for (int i=0, j=self->rows * self->columns; i<j; i++)
	{
		self->matrix[i] *= mt->matrix[i];
	}
}

- (void)elementWiseDivide:(YCMatrix *)mt
{
    if(columns != mt->columns || rows != mt->rows || sizeof(matrix) != sizeof(mt->matrix))
        @throw [NSException exceptionWithName:@"MatrixSizeException"
                                       reason:@"Matrix size mismatch."
                                     userInfo:nil];
    for (int i=0, j=self->rows * self->columns; i<j; i++)
    {
        self->matrix[i] /= mt->matrix[i];
    }
}

- (double)trace
{
	[self checkSquare];
	double trace = 0;
	for (int i=0; i<rows; i++)
	{
		trace += matrix[i*(columns + 1)];
	}
	return trace;
}

- (double)dotWith:(YCMatrix *)other
{
	// A few more checks need to be made here.
	if(sizeof(matrix) != sizeof(other->matrix))
		@throw [NSException exceptionWithName:@"MatrixSizeException"
		        reason:@"Matrix size mismatch."
		        userInfo:nil];
	if(columns != 1 && rows != 1)
		@throw [NSException exceptionWithName:@"MatrixSizeException"
		        reason:@"Dot can only be performed on vectors."
		        userInfo:nil];
	return cblas_ddot(self->rows * self->columns, self->matrix, 1, other->matrix, 1);
}

- (YCMatrix *)matrixByUnitizing
{
	if(columns != 1 && rows != 1)
		@throw [NSException exceptionWithName:@"MatrixSizeException"
		        reason:@"Unit can only be performed on vectors."
		        userInfo:nil];
	int len = rows * columns;
	double sqsum = 0;
	for (int i=0; i<len; i++)
	{
		double v = matrix[i];
		sqsum += v*v;
	}
	double invmag = 1/sqrt(sqsum);
	YCMatrix *norm = [YCMatrix matrixOfRows:rows Columns:columns];
	double *normMatrix = norm->matrix;
	for (int i=0; i<len; i++)
	{
		normMatrix[i] = matrix[i] * invmag;
	}
	return norm;
}

- (double *)array
{
	return matrix;
}

- (double *)arrayCopy
{
	double *resArr = calloc(self->rows*self->columns, sizeof(double));
	memcpy(resArr, matrix, self->rows*self->columns*sizeof(double));
	return resArr;
}

- (NSArray *)numberArray
{
	int length = self->rows * self->columns;
	NSMutableArray *result = [NSMutableArray arrayWithCapacity:length];
	for (int i=0; i<length; i++)
	{
		[result addObject:@(self->matrix[i])];
	}
	return result;
}

- (YCMatrix *)diagonal
{
    int minDim = MIN(rows, columns);
    YCMatrix *result = [YCMatrix matrixOfRows:minDim Columns:1];
    for (int i=0; i<minDim; i++)
    {
        [result setValue:[self valueAtRow:i Column:i] Row:i Column:0];
    }
    return result;
}

- (int)rows
{
	return self->rows;
}

- (int)columns
{
	return self->columns;
}

- (NSUInteger)count
{
	return self->rows * self->columns;
}

- (double)sum
{
	double sum = 0;
    NSUInteger j= [self count];
	for (int i=0; i<j; i++)
	{
		sum += self->matrix[i];
	}
	return sum;
}

- (double)product
{
    double product = 1;
    NSUInteger j= [self count];
    for (int i=0; i<j; i++)
    {
        product *= self->matrix[i];
    }
    return product;
}

- (BOOL)isSquare
{
	return self->rows == self->columns;
}

- (BOOL)isEqual:(id)anObject {
	if (![anObject isKindOfClass:[self class]]) return NO;
	YCMatrix *other = (YCMatrix *)anObject;
	if (rows != other->rows || columns != other->columns) return NO;
	int arr_length = self->rows * self->columns;
	for (int i=0; i<arr_length; i++) {
		if (matrix[i] != other->matrix[i]) return NO;
	}
	return YES;
}

- (BOOL)isEqualToMatrix:(YCMatrix *)aMatrix Precision:(int)decimals
{
    if (self->rows != aMatrix->rows || self->columns != aMatrix->columns) return NO;
    double mult = pow(10, decimals);
    int arr_length = self->rows * self->columns;
    for (int i=0; i<arr_length; i++)
    {
		if ( (int)((matrix[i] - aMatrix->matrix[i]) * mult) / mult ) return NO;
	}
    return YES;
}

- (NSString *)description {
	NSString *s = @"\n";
	for ( int i=0; i<rows*columns; ++i ) {
		s = [NSString stringWithFormat:@"%@\t%f", s, matrix[i]];
		if (i % columns == columns - 1) s = [NSString stringWithFormat:@"%@\n", s];
	}
	return s;
}

#pragma mark Object Destruction

- (void)dealloc {
	if (self->freeData) free(self->matrix);
}

#pragma mark NSCoding Implementation

- (void)encodeWithCoder:(NSCoder *)encoder
{
	int len = self->rows * self->columns;
	NSMutableArray *matrixContent = [NSMutableArray arrayWithCapacity:len];
	for (int i=0; i<len; i++)
	{
		matrixContent[i] = @(self->matrix[i]);
	}
	[encoder encodeObject:matrixContent forKey:@"matrixContent"];
	[encoder encodeObject:@(self->rows) forKey:@"rows"];
	[encoder encodeObject:@(self->columns) forKey:@"columns"];
}

- (id)initWithCoder:(NSCoder *)decoder
{
	if (self = [super init])
	{
		self->rows = [[decoder decodeObjectForKey:@"rows"] intValue];
		self->columns = [[decoder decodeObjectForKey:@"columns"] intValue];
		NSArray *matrixContent = [decoder decodeObjectForKey:@"matrixContent"];
		int len = self->rows*self->columns;
		self->matrix = malloc(len*sizeof(double));
		for (int i=0; i<len; i++)
		{
			self->matrix[i] = [matrixContent[i] doubleValue];
		}
	}
	return self;
}

- (instancetype)copyWithZone:(NSZone *)zone
{
	YCMatrix *newMatrix = [YCMatrix matrixFromArray:self->matrix
	                       Rows:self->rows
	                       Columns:self->columns];
	return newMatrix;
}

@end
