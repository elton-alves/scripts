#!/bin/bash

# sk6.sh
# A simple wrapper script to run k6 tests with a wrk-like command-line interface.
# sk6 stands for "simple k6", expressing a simple k6 wrapper inspired by wrk command line interface.
#
# Usage: ./sk6.sh [-D] [-X <METHOD>] [-b <BODY_STRING> | -f <BODY_FILE>] -c <connections> -d <duration> -R <rate> [-H "Header: Value"]... <URL>
#
# Parameters:
#   -D : Enable debug logging from the k6 script itself.
#   -X <METHOD>: HTTP method to use (e.g., GET, POST, PUT, DELETE). Defaults to GET.
#   -b <BODY_STRING>: Request body as a string. For simple, static payloads.
#   -f <BODY_FILE>: Path to a file containing the request body. Overrides -b if both are specified.
#                   Useful for larger or dynamic payloads.
#   -c <connections>: Number of concurrent virtual users/connections.
#   -d <duration>: Duration of the test (e.g., "30s", "1m").
#   -R <rate>: Target requests per second (constant throughput).
#   -H "Header: Value": HTTP header to send with the request. Can be specified multiple times.
#                        WARNING: Header values containing '|' will be parsed incorrectly if defined via -H.
#   <URL>: The target HTTP URL for the request.
#
# Prerequisites:
# - k6 must be installed and available in your PATH.
# - This script expects 'sk6.test.js' to be in the same directory as the ORIGINAL sk6.sh file.

# --- Most Robust Way to Determine the Script's Own Directory ---
SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do
    DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
    SOURCE="$(readlink "$SOURCE")"
    [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE"
done
SCRIPT_DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"

# Path to the k6 test script, now reliably pointing to its true location
TEST_SCRIPT_PATH="${SCRIPT_DIR}/sk6.test.js"

# --- Initialize Variables ---
DURATION=""
RATE=""
CONNECTIONS=""
TARGET_URL=""
HTTP_METHOD="GET" # Default HTTP method
REQUEST_BODY=""   # Default empty request body (can be set by -b or -f)
REQUEST_BODY_FILE="" # Stores the path to the body file if -f is used
DEBUG_FLAG="false" # Default to false (debug disabled)
declare -a HEADERS_ARRAY=() # Array to store multiple header strings

# --- Parse Command Line Arguments ---
while getopts "DX:b:f:c:d:R:H:" opt; do
  case "$opt" in
    D) # Debug flag
      DEBUG_FLAG="true"
      ;;
    X) # HTTP Method
      HTTP_METHOD="$OPTARG"
      ;;
    b) # Request Body String
      REQUEST_BODY="$OPTARG" # This will be potentially overwritten by -f
      ;;
    f) # Request Body from File
      REQUEST_BODY_FILE="$OPTARG"
      ;;
    c) # Connections (maps to k6's preAllocatedVUs and maxVUs)
      CONNECTIONS="$OPTARG"
      ;;
    d) # Duration
      DURATION="$OPTARG"
      ;;
    R) # Rate (requests per second)
      RATE="$OPTARG"
      ;;
    H) # HTTP Header
      HEADERS_ARRAY+=("$OPTARG") # Add each header string to the array
      ;;
    \?) # Invalid option
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
    :) # Missing argument for an option
      echo "Option -$OPTARG requires an argument." >&2
      exit 1
      ;;
  esac
done

# Shift processed arguments so that $1 now points to the URL
shift $((OPTIND - 1))

# The remaining argument should be the URL
TARGET_URL="$1"

# --- Input Validation ---
if [ -z "$CONNECTIONS" ]; then
  echo "Error: -c (connections) is required."
  exit 1
fi

if [ -z "$DURATION" ]; then
  echo "Error: -d (duration) is required."
  exit 1
fi

if [ -z "$RATE" ]; then
  echo "Error: -R (rate) is required."
  exit 1
fi

if [ -z "$TARGET_URL" ]; then
  echo "Error: Target URL is required."
  exit 1
fi

# Check if sk6.test.js exists using its absolute path
if [ ! -f "$TEST_SCRIPT_PATH" ]; then
  echo "Error: sk6.test.js not found at expected path: $TEST_SCRIPT_PATH"
  echo "Please ensure 'sk6.test.js' is in the same directory as the ORIGINAL sk6.sh script file."
  exit 1
fi

# --- Body Content Resolution ---
# If a body file is specified, read its content, overriding any -b string.
BODY_SOURCE_INFO=""
if [ -n "$REQUEST_BODY_FILE" ]; then
  if [ ! -f "$REQUEST_BODY_FILE" ]; then
    echo "Error: Body file not found: $REQUEST_BODY_FILE" >&2
    exit 1
  fi
  if [ ! -r "$REQUEST_BODY_FILE" ]; then
    echo "Error: Body file not readable: $REQUEST_BODY_FILE" >&2
    exit 1
  fi
  REQUEST_BODY="$(cat "$REQUEST_BODY_FILE")"
  BODY_SOURCE_INFO=" (from file: $REQUEST_BODY_FILE)"
fi

# --- Join Headers into a single pipe-separated string ---
IFS='|' K6_HTTP_HEADERS="${HEADERS_ARRAY[*]}"

# --- Execute K6 Test ---
echo "Running k6 test with the following parameters:"
echo "  URL: $TARGET_URL"
echo "  Method: $HTTP_METHOD"
if [ -n "$REQUEST_BODY" ]; then
  echo "  Body: \"$REQUEST_BODY\"$BODY_SOURCE_INFO"
fi
echo "  Duration: $DURATION"
echo "  Rate (RPS): $RATE"
echo "  Connections (VUs): $CONNECTIONS"
if [ "$DEBUG_FLAG" = "true" ]; then
  echo "  Debug Logging: Enabled"
fi
if [ ${#HEADERS_ARRAY[@]} -gt 0 ]; then
  echo "  Headers: ${HEADERS_ARRAY[@]}"
fi
echo ""

# Initialize the k6 command as an array
K6_CMD_ARGS=(
  k6 run
  "--env" "TARGET_URL=$TARGET_URL"
  "--env" "DURATION=$DURATION"
  "--env" "RATE=$RATE"
  "--env" "CONNECTIONS=$CONNECTIONS"
  "--env" "HTTP_HEADERS=$K6_HTTP_HEADERS"
  "--env" "K6_HTTP_METHOD=$HTTP_METHOD"
  "--env" "K6_REQUEST_BODY=$REQUEST_BODY"
)

if [ "$DEBUG_FLAG" = "true" ]; then
  K6_CMD_ARGS+=( "--env" "DEBUG_ENABLED=true" )
fi

K6_CMD_ARGS+=( "$TEST_SCRIPT_PATH" ) # Add the test script path

# Execute the command using the array
"${K6_CMD_ARGS[@]}"
