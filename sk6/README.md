# sk6:

###### Simple k6 Wrapper for HTTP Load Testing

`sk6` (Simple k6) is a lightweight Bash wrapper script that provides a `wrk`-like command-line interface for running
HTTP load tests using the powerful `k6` load testing tool. Its primary purpose is to simplify common load testing
scenarios, allowing you to quickly define and execute tests with constant throughput, custom headers, and request
bodies, without diving deep into `k6`'s JavaScript syntax for basic needs. It's designed to be a "simple k6 wrapper
inspired by the `wrk` command-line interface."

## 🚀 Features

* **Constant Throughput:** Achieve a consistent rate of requests per second, ideal for sustained load testing.
* **Flexible HTTP Methods:** Supports `GET`, `POST`, `PUT`, `DELETE`, `PATCH`, and other standard HTTP methods.
* **Custom HTTP Headers:** Easily add multiple custom headers to your requests.
* **Request Body Support:** Send request bodies as a direct string or load them from a file, suitable for API testing (
  e.g., JSON, XML payloads).
* **Basic Authentication:** Easily add `Authorization: Basic` headers using a simple `username:password` format.
* **Enhanced Debugging:** Toggle verbose debug logs from the `k6` test script to inspect request/response details,
  especially for failed requests.
* **`wrk`-like Interface:** Familiar command-line arguments for users accustomed to tools like `wrk` or `wrk2`.
* **Directory Independent:** Can be executed from any directory or via a symbolic link, as long as `sk6.test.js` is in
  the same directory as the original `sk6.sh` script.
* **Comprehensive Failure Logging:** When a request returns a non-2XX status, detailed information about the request (
  URL, method, headers, body) and the full response (status, headers, body) is logged for easy debugging.

## 📦 Prerequisites

Before using `sk6`, ensure you have the following installed:

* **`k6`**: The open-source load testing tool.
    * Installation
      instructions: [https://k6.io/docs/getting-started/installation/](https://k6.io/docs/getting-started/installation/)
* **Bash**: The script is written in Bash, typically pre-installed on Linux and macOS.
* **`base64`**: A utility used for encoding basic authentication credentials (usually pre-installed).

## 🛠️ Installation & Setup

1. **Download the scripts:**
   Save the following two files in the **same directory** (e.g., `~/load_tests/`):
    * `sk6.sh` (the Bash wrapper script)
    * `sk6.test.js` (the k6 JavaScript test script)

2. **Make the wrapper executable:**
   ```bash
   chmod +x ~/load_tests/sk6.sh
   ```

3. **(Optional) Create a symbolic link for easy access:**
   To run `sk6` from any directory, you can create a symbolic link in a directory that's part of your system's `PATH` (
   e.g., `~/bin/` or `/usr/local/bin/`).
   ```bash
   mkdir -p ~/bin # Create if it doesn't exist
   ln -s ~/load_tests/sk6.sh ~/bin/sk6
   # Ensure ~/bin is in your PATH. You might need to add it to your .bashrc or .zshrc:
   # export PATH="$HOME/bin:$PATH"
   # Then run: source ~/.bashrc (or .zshrc)
   ```
   **Important:** The `sk6.test.js` file *must* remain in the same directory as the *original* `sk6.sh` file, even if
   you use a symbolic link.

## 🚀 Usage

The `sk6` script uses a command-line interface similar to `wrk`.

```txt
sk6 [-D] [-X <METHOD>] [-u <username>:<password>] [-b <BODY_STRING> | -f <BODY_FILE>] -c <connections> -d <duration> -R <rate> [-H "Header: Value"]... <URL>
Parameters:

-D: (Optional) Enable debug logging from the k6 test script. This will print detailed request/response information, especially useful for debugging failures.

-X <METHOD>: (Optional) Specify the HTTP method (e.g., GET, POST, PUT, DELETE, PATCH). Defaults to GET if not specified.

-u <username>:<password>: (Optional) Provide credentials for HTTP Basic Authentication. The script will automatically format and add the Authorization header.

-b <BODY_STRING>: (Optional) Provide the request body as a direct string. Useful for simple JSON or plain text payloads.

-f <BODY_FILE>: (Optional) Provide the path to a file containing the request body. This is ideal for larger or more complex payloads (e.g., my_payload.json). If both -b and -f are used, -f takes precedence.

-c <connections>: (Required) The number of concurrent virtual users (connections) to maintain.

-d <duration>: (Required) The total duration of the test run (e.g., 30s, 1m, 2h).

-R <rate>: (Required) The target constant requests per second (RPS) that k6 will attempt to maintain.

-H "Header: Value": (Optional) Add a custom HTTP header. Can be specified multiple times for multiple headers.
Note: Header values containing the pipe | character will be parsed incorrectly if they are part of the value you define in the command line (not for the basic auth one, which is internally generated).
```

## Examples

#### Basic GET Request (Expected Failure):

This command will send GET requests to a URL that returns a 404 Not Found status, demonstrating the failure logging.

```bash

sk6 -D -c 1 -d 5s -R 1 http://httpbin.org/status/404
```

#### POST Request with Inline JSON Body:

This example sends a POST request with a simple JSON payload. Note the need for the Content-Type header.

```bash

sk6 -D -X POST -c 1 -d 5s -R 1 \
  -H "Content-Type: application/json" \
  -H "x-other-header: X" \
  -b '{"name": "k6", "value": 1}' \
  http://httpbin.org/post
```  

#### POST Request with Body from File:

First, create a file named my_payload.json in your current directory:

```bash

cat <<EOT > /tmp/my_payload.json
{
  "product": "Laptop",
  "quantity": 1,
  "price": 1200.00
}
EOT

sk6 -X POST -c 1 -d 5s -R 1 \
  -H "Content-Type: application/json" \
  -f /tmp/my_payload.json \
  http://httpbin.org/post
```