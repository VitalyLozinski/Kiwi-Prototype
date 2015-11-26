/*!
    @header DebugDefines.h
    @creation_date 19.03.2012
    @abstract This file provides debug defines for prefix file.
 */

#ifndef __DebugDefines_h__
#define __DebugDefines_h__

/*!
    @defined LKTrace
    @abstract Printing to console.
    @discussion This macro will use NSLog for printing to console only in DEBUG version of product. Do not use it everywhere. Most suitable is informing about errors or it should be wrapped by user personal define:
 */

#define LOREM_IPSUM @"Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nulla sed facilisis lorem. Curabitur tincidunt enim ac ultricies bibendum. Nunc pharetra tellus sit amet elementum rutrum. Morbi et lorem adipiscing, tristique augue vitae, aliquam leo. Cras odio metus, porttitor eu porttitor non, eleifend id velit. Ut malesuada magna orci, vitae mattis nisl consequat non. Vivamus congue placerat arcu, id mattis erat commodo id. Cras nec turpis eu neque malesuada mollis. Proin pretium augue ante. Suspendisse at elit eget enim scelerisque accumsan vitae et tortor. Vivamus luctus dictum mauris sit amet venenatis. Nam tempus lobortis purus, ut tincidunt nisl dictum eget. Curabitur pretium felis nec libero porttitor congue. Ut lacus nulla, ullamcorper eget suscipit quis, sollicitudin vel metus. Nam leo magna, fringilla sed ultricies vitae, tincidunt vitae ipsum. Maecenas volutpat arcu vitae ultricies tincidunt."

#ifdef __OBJC__

	#ifdef DEBUG
		#define Trace(...) NSLog(__VA_ARGS__)
		#define ConditionalTrace(condition, ...) if (!(condition)) NSLog(__VA_ARGS__)
	#else
		#define Trace(...)
		#define ConditionalTrace(...)
	#endif // DEBUG

#endif // __OBJC__

#ifndef ASSERT

	#if DEBUG
		#define ASSERT(test) assert(test)
	#else
		#define ASSERT(test)
	#endif // DEBUG

#endif // ASSERT

#ifndef VERIFY

	#if DEBUG
		#define VERIFY(test) assert(test)
	#else
		#define VERIFY(test) test
	#endif // DEBUG

#endif // VERIFY

#ifdef __OBJC__

	#ifndef NSTRACE
		#ifdef DEBUG
			#define NSTRACE(x) \
	do { \
		NSLog x; \
	} while (0)
		#else
			#define NSTRACE(x)
		#endif // DEBUG
	#endif // NSTRACE

	#ifndef TRACE
		#ifdef DEBUG
			#define TRACE(x) \
	do { \
		printf x; \
	} while (0)
		#else
			#define TRACE(x)
		#endif // DEBUG
	#endif // TRACE

	#ifdef DEBUG
		#define TRACE_SEL() NSTRACE((@"[%s(%p) %s]", object_getClassName(self), self, sel_getName(_cmd)))
	#else
		#define TRACE_SEL()
	#endif // DEBUG

	#ifndef REPORT_EXCEPTION
	#ifdef DEBUG
		#define REPORT_EXCEPTION() \
	do { \
		NSLog(@"An exception reported from [<%s: %p> %s]: %@ raised, reason: %@", object_getClassName(self), self, sel_getName(_cmd), [localException name], [localException reason]); \
	} while (0)
	#else
		#define REPORT_EXCEPTION()
	#endif // DEBUG
	#endif // REPORT_EXCEPTION

	#ifndef CREPORT_EXCEPTION
	#ifdef DEBUG
		#define CREPORT_EXCEPTION() \
	do { \
		NSLog(@"An exception reported from %s in %s:%i: %@ raised, reason: %@", __PRETTY_FUNCTION__, __FILE__, __LINE__, [localException name], [localException reason]); \
	} while (0)
	#else
		#define CREPORT_EXCEPTION()
	#endif // DEBUG
	#endif // REPORT_EXCEPTION

	#ifndef RAISE_CALL
		#define RAISE_CALL(proc) \
	do { \
		NSInteger __ex_err = proc; \
		if (__ex_err) \
			[NSException extraRaiseError:__ex_err name:@"OSStatusError" format:@"error %d in [%s(%p) %s]", __ex_err, object_getClassName(self), self, sel_getName(_cmd)]; \
	} while (0)
		#define CRAISE_CALL(proc) \
	do { \
		NSInteger __ex_err = proc; \
		if (__ex_err) \
			[NSException extraRaiseError:__ex_err name:@"OSStatusError" format:@"error %d in function %s", __ex_err, __PRETTY_FUNCTION__];    \
	} while (0)
	#endif // RAISE_CALL

	#ifndef SAFE_CALL
		#ifdef DEBUG
			#define SAFE_CALL(proc) RAISE_CALL(proc)
			#define CSAFE_CALL(proc) RAISE_CALL(proc)
		#else
			#define SAFE_CALL(proc) do { proc; } while (0)
			#define CSAFE_CALL(proc) do { proc; } while (0)
		#endif // DEBUG
	#endif // SAFE_CALL

	#ifndef STATUS_TRY
		#define STATUS_TRY \
	{ \
		OSStatus _local_err = noErr; \
		NS_DURING
	#endif // STATUS_TRY

	#ifndef STATUS_CATCH
		#define STATUS_CATCH \
	NS_HANDLER \
	REPORT_EXCEPTION(); \
	NS_ENDHANDLER \
	}
	#endif // STATUS_CATCH

	#ifndef STATUS_CATCH_RETURN
		#define STATUS_CATCH_RETURN \
	NS_HANDLER \
	REPORT_EXCEPTION(); \
	_local_err = [localException extraStatusError]; \
	NS_ENDHANDLER \
	return _local_err; \
	}
	#endif // STATUS_CATCH_RETURN

	#ifndef CSTATUS_TRY
		#define CSTATUS_TRY \
	{ \
		OSStatus _local_err = noErr; \
		NS_DURING
	#endif // CSTATUS_TRY

	#ifndef CSTATUS_CATCH
		#define CSTATUS_CATCH \
	NS_HANDLER \
	CREPORT_EXCEPTION(); \
	NS_ENDHANDLER \
	}
	#endif // CSTATUS_CATCH

	#ifndef CSTATUS_CATCH_RETURN
		#define CSTATUS_CATCH_RETURN \
	NS_HANDLER \
	CREPORT_EXCEPTION(); \
	_local_err = [localException extraStatusError]; \
	NS_ENDHANDLER \
	return _local_err; \
	}
	#endif // CSTATUS_CATCH_RETURN

#endif // __OBJC__

#endif // __LK_DebugDefines_h__
