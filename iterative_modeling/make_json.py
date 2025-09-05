

import json
import sys
import re

# Usage: python make_json.py <ENCSR_ID> <output_path> <template_path>

def main():
    if len(sys.argv) != 4:
        print("Usage: python make_json.py <ENCSR_ID> <output_path> <template_path>")
        sys.exit(1)
    encsr_id = sys.argv[1]
    output_path = sys.argv[2]
    template_path = sys.argv[3]

    with open(template_path, "r") as f:
        data = json.load(f)

    def replace_id(obj):
        if isinstance(obj, dict):
            return {k: replace_id(v) for k, v in obj.items()}
        elif isinstance(obj, list):
            return [replace_id(v) for v in obj]
        elif isinstance(obj, str):
            # Replace only the 11-character ENCID (ENCSR followed by 6 alphanumeric characters)
            return re.sub(r"ENCSR\w{6}", encsr_id, obj)
        else:
            return obj

    new_data = replace_id(data)

    with open(output_path, "w") as f:
        json.dump(new_data, f, indent=2)

if __name__ == "__main__":
    main()
