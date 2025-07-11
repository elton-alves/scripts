// sk6.test.js
// This k6 script performs HTTP requests with a constant arrival rate,
// configured via environment variables, applying custom HTTP headers,
// and dynamically selecting the HTTP method and request body.

import http from 'k6/http';
import { check } from 'k6';

// --- Configuration from Environment Variables ---
const TARGET_URL = __ENV.TARGET_URL || 'http://localhost:80/';
const TEST_DURATION = __ENV.DURATION || '10s';
const TARGET_RATE = parseInt(__ENV.RATE || '100');
const CONNECTIONS = parseInt(__ENV.CONNECTIONS || '10');
const DEBUG_ENABLED = __ENV.DEBUG_ENABLED === 'true';

// Read HTTP method and request body
const HTTP_METHOD = __ENV.K6_HTTP_METHOD ? __ENV.K6_HTTP_METHOD.toUpperCase() : 'GET';
const REQUEST_BODY = __ENV.K6_REQUEST_BODY || null;

// Read and parse HTTP headers from environment variable
const HTTP_HEADERS_STR = __ENV.HTTP_HEADERS || '';
console.log(`[DEBUG] __ENV.HTTP_HEADERS: "${__ENV.HTTP_HEADERS}"`);
let customHeaders = {};

if (HTTP_HEADERS_STR) {
  const headersArray = HTTP_HEADERS_STR.split("|");

  if (DEBUG_ENABLED) {
    console.log(`[DEBUG] Split Headers Array: ${JSON.stringify(headersArray)}`);
  }

  headersArray.forEach(headerString => {
    const parts = headerString.split(':', 2);
    if (parts.length === 2) {
      const headerName = parts[0].trim();
      const headerValue = parts[1].trim();
      customHeaders[headerName] = headerValue;
      if (DEBUG_ENABLED) {
        console.log(`[DEBUG] Parsed Header: "${headerName}": "${headerValue}"`);
      }
    } else {
      console.warn(`[WARNING] Malformed header string (ignored): "${headerString}"`);
    }
  });

  if (DEBUG_ENABLED) {
    console.log(`[DEBUG] Final Custom Headers Object: ${JSON.stringify(customHeaders)}`);
  }
}

// --- Conditional Debugging Logs ---
if (DEBUG_ENABLED) {
  console.log(`[DEBUG] TARGET_URL: ${TARGET_URL}`);
  console.log(`[DEBUG] HTTP_METHOD: ${HTTP_METHOD}`);
  console.log(`[DEBUG] HTTP_HEADERS_STR: "${HTTP_HEADERS_STR}"`);
  console.log(`[DEBUG] REQUEST_BODY: "${REQUEST_BODY}"`);
  console.log(`[DEBUG] TEST_DURATION: ${TEST_DURATION}`);
  console.log(`[DEBUG] TARGET_RATE (parsed): ${TARGET_RATE}`);
  console.log(`[DEBUG] CONNECTIONS (parsed): ${CONNECTIONS}`);
}
// --- END Conditional Debugging Logs ---

// --- Input Validation ---
if (isNaN(TARGET_RATE) || TARGET_RATE <= 0) {
  console.error('ERROR: Invalid or missing TARGET_RATE. Please provide a positive number for -R.');
  throw new Error('Invalid TARGET_RATE');
}

if (isNaN(CONNECTIONS) || CONNECTIONS <= 0) {
  console.error('ERROR: Invalid or missing CONNECTIONS. Please provide a positive number for -c.');
  throw new Error('Invalid CONNECTIONS');
}

// --- k6 Test Options ---
export const options = {
  scenarios: {
    constant_load: {
      executor: 'constant-arrival-rate',
      rate: TARGET_RATE,
      timeUnit: '1s',
      duration: TEST_DURATION,
      preAllocatedVUs: CONNECTIONS,
      maxVUs: CONNECTIONS,
    },
  },
};

// --- Main Test Function (Virtual User Logic) ---
export default function () {
  const params = {
    headers: customHeaders,
  };

  let res;
  const methodLower = HTTP_METHOD.toLowerCase();

  // Dynamically call the appropriate http method based on HTTP_METHOD
  if (typeof http[methodLower] === 'function') {
    const methodsWithBody = ['post', 'put', 'patch'];

    if (methodsWithBody.includes(methodLower)) {
      res = http[methodLower](TARGET_URL, REQUEST_BODY, params);
    } else {
      res = http[methodLower](TARGET_URL, params);
    }
  } else {
    console.error(`ERROR: Unsupported HTTP method specified: ${HTTP_METHOD}. Defaulting to GET.`);
    res = http.get(TARGET_URL, params);
  }

  const is2XX = res.status >= 200 && res.status < 300;

  // Perform the check for any 2XX status
  check(res, {
    'status is 2XX': is2XX,
  });

  // --- NEW: Enhanced Failure Logging ---
  if (is2XX) {
    console.info(`SUCCESS: ${res.status}`);
  } else {
    // Log detailed failure information
    console.error(`FAILURE: ${res.status} (URL: ${res.url})`); // Using console.error for prominent failure logs

    // Request Details
    console.error(`--- Request Details ---`);
    console.error(`  Method: ${HTTP_METHOD}`);
    console.error(`  URL: ${TARGET_URL}`); // Use TARGET_URL for what was configured
    console.error(`  Headers: ${JSON.stringify(customHeaders, null, 2)}`);

    if (REQUEST_BODY) {
      // Truncate long request bodies for console readability
      const displayBody = REQUEST_BODY.length > 500
          ? REQUEST_BODY.substring(0, 500) + '... (truncated)'
          : REQUEST_BODY;
      console.error(`  Body: ${displayBody}`);
    } else {
      console.error(`  Body: (None)`);
    }

    // Response Details
    console.error(`--- Response Details ---`);
    console.error(`  Status: ${res.status}`);
    console.error(`  Response Headers: ${JSON.stringify(res.headers, null, 2)}`);

    if (res.body) {
      // Truncate long response bodies for console readability
      const displayResponseBody = res.body.length > 500
          ? res.body.substring(0, 500) + '... (truncated)'
          : res.body;
      console.error(`  Response Body: ${displayResponseBody}`);
    } else {
      console.error(`  Response Body: (None)`);
    }
    console.error(`-----------------------`);
  }
  // --- END NEW ---
}
