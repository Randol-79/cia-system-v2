/**
 * CIA System - Mobile Optimization Middleware
 * Optimizes API responses for mobile devices
 */

const compression = require('compression');

/**
 * Detect if request is from mobile device
 */
function isMobileDevice(req) {
  const userAgent = req.headers['user-agent'] || '';
  const mobileRegex = /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i;
  return mobileRegex.test(userAgent);
}

/**
 * Detect connection speed/type
 */
function getConnectionType(req) {
  // Check for Network Information API headers
  const saveData = req.headers['save-data'];
  const effectiveType = req.headers['ect']; // effective connection type
  
  if (saveData === 'on') {
    return 'slow';
  }
  
  if (effectiveType) {
    if (effectiveType === 'slow-2g' || effectiveType === '2g') {
      return 'slow';
    }
    if (effectiveType === '3g') {
      return 'medium';
    }
  }
  
  return 'fast';
}

/**
 * Mobile-optimized response formatter
 */
function mobileResponseFormatter(req, res, next) {
  const originalJson = res.json.bind(res);
  
  res.json = function(data) {
    const isMobile = isMobileDevice(req);
    const connectionType = getConnectionType(req);
    
    if (isMobile) {
      // Add mobile-specific metadata
      const mobileData = {
        ...data,
        _mobile: {
          optimized: true,
          connectionType,
          timestamp: new Date().toISOString()
        }
      };
      
      // Reduce payload for slow connections
      if (connectionType === 'slow') {
        // Limit array sizes
        Object.keys(mobileData).forEach(key => {
          if (Array.isArray(mobileData[key]) && mobileData[key].length > 10) {
            mobileData[key] = mobileData[key].slice(0, 10);
            mobileData._mobile.truncated = true;
          }
        });
      }
      
      return originalJson(mobileData);
    }
    
    return originalJson(data);
  };
  
  next();
}

/**
 * Compression middleware with mobile optimization
 */
function mobileCompression() {
  return compression({
    filter: (req, res) => {
      // Always compress for mobile
      if (isMobileDevice(req)) {
        return true;
      }
      
      // Use default compression filter for desktop
      return compression.filter(req, res);
    },
    level: (req) => {
      // Higher compression for mobile
      return isMobileDevice(req) ? 9 : 6;
    }
  });
}

/**
 * Cache headers for mobile
 */
function mobileCacheHeaders(req, res, next) {
  const isMobile = isMobileDevice(req);
  
  if (isMobile) {
    // Aggressive caching for mobile
    res.set({
      'Cache-Control': 'public, max-age=300, stale-while-revalidate=600',
      'X-Mobile-Optimized': 'true'
    });
  }
  
  next();
}

/**
 * Pagination for mobile
 */
function mobilePagination(req, res, next) {
  const isMobile = isMobileDevice(req);
  
  if (isMobile && !req.query.limit) {
    // Default smaller page size for mobile
    req.query.limit = '20';
  }
  
  next();
}

/**
 * Image optimization headers
 */
function mobileImageOptimization(req, res, next) {
  const isMobile = isMobileDevice(req);
  const connectionType = getConnectionType(req);
  
  if (isMobile) {
    // Suggest image quality based on connection
    const quality = connectionType === 'slow' ? 'low' : 
                    connectionType === 'medium' ? 'medium' : 'high';
    
    req.suggestedImageQuality = quality;
  }
  
  next();
}

/**
 * Request timeout for mobile
 */
function mobileTimeout(req, res, next) {
  const isMobile = isMobileDevice(req);
  const connectionType = getConnectionType(req);
  
  if (isMobile && connectionType === 'slow') {
    // Longer timeout for slow connections
    req.setTimeout(60000); // 60 seconds
  }
  
  next();
}

/**
 * Error handler for mobile
 */
function mobileErrorHandler(err, req, res, next) {
  const isMobile = isMobileDevice(req);
  
  if (isMobile) {
    // Simplified error response for mobile
    res.status(err.status || 500).json({
      error: {
        message: err.message || 'An error occurred',
        code: err.code || 'INTERNAL_ERROR',
        mobile: true
      }
    });
  } else {
    next(err);
  }
}

/**
 * WebSocket optimization for mobile
 */
function optimizeWebSocketForMobile(ws, req) {
  const isMobile = isMobileDevice(req);
  
  if (isMobile) {
    // Reduce ping frequency for mobile
    ws._pingInterval = 30000; // 30 seconds instead of default 10
    
    // Enable compression
    ws._compress = true;
    
    // Add mobile flag
    ws._isMobile = true;
  }
}

/**
 * Batch API requests for mobile
 */
function mobileBatchHandler(req, res, next) {
  // Allow batching multiple API calls in one request
  if (req.body && req.body._batch && Array.isArray(req.body._batch)) {
    const batchResults = [];
    let completed = 0;
    
    req.body._batch.forEach((batchReq, index) => {
      // Process each batched request
      // This is a simplified version - implement full batching logic
      batchResults[index] = {
        status: 'pending',
        data: null
      };
    });
    
    res.json({
      batch: true,
      results: batchResults
    });
  } else {
    next();
  }
}

/**
 * Service Worker support
 */
function serviceWorkerSupport(req, res, next) {
  // Add headers to support service worker caching
  if (req.path.includes('/api/')) {
    res.set({
      'Service-Worker-Allowed': '/',
      'X-SW-Cacheable': 'true'
    });
  }
  
  next();
}

module.exports = {
  isMobileDevice,
  getConnectionType,
  mobileResponseFormatter,
  mobileCompression,
  mobileCacheHeaders,
  mobilePagination,
  mobileImageOptimization,
  mobileTimeout,
  mobileErrorHandler,
  optimizeWebSocketForMobile,
  mobileBatchHandler,
  serviceWorkerSupport
};
