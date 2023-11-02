#!/bin/bash

# Goal
## Extract certificate chain from a given domain.
## Note that we are considering 443 port as constant.


# Check if DOMAIN and output folder name are provided as arguments
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <DOMAIN> <OUTPUT>"
    exit 1
fi

domain="$1"
output_folder="$2"
crt_chain_file="$output_folder/crt_chain.txt"
domain_port="$domain:443"
cn_pattern="CN\s*=\s*(.+),?"

# Create the output folder if it doesn't exist
mkdir -p "$output_folder"

# Extract certificates from the given DOMAIN and save the complete output to the output file
openssl s_client -showcerts -connect "$domain_port" </dev/null 2>/dev/null > "$crt_chain_file"

# Variables to track certificate start and end
in_certificate=false
cert_filename=""
cn_value=""

# Read the certificate chain file and save each certificate in separate files
while IFS= read -r line; do
    if [[ -z "$cn_value" && "$line" =~ $cn_pattern ]]; then
        # Extract CN value and replace spaces with underscores
        cn_value="${BASH_REMATCH[1]// /_}"
    elif [[ "$line" == "-----BEGIN CERTIFICATE-----" ]]; then
        # Set in_certificate flag to true and prepare certificate filename
        in_certificate=true
        cert_filename="$cn_value.crt"
        echo -n > "$output_folder/$cert_filename"
        echo "$line" >> "$output_folder/$cert_filename"
    elif [[ "$line" == "-----END CERTIFICATE-----" ]]; then
        # Save the line and set in_certificate flag to false and reset CN value
        echo "$line" >> "$output_folder/$cert_filename"
        in_certificate=false
        cn_value=""
    elif [[ "$in_certificate" == true ]]; then
        # Save certificate content to the corresponding file
        echo "$line" >> "$output_folder/$cert_filename"
    fi
done < "$crt_chain_file"

# Print the list of created file names under the heading "Extracted certificates:"
echo "Extracted certificates:"
find "$output_folder" -type f -name "*.crt";

