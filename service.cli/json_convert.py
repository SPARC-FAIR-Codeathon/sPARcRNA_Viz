"""Script to convert a json file to a js file"""
import json
import sys
import os

if __name__ == '__main__':
    if len(sys.argv) == 3:
        print('Usage: json_convert.py <json_file> <output_folder>')
        sys.exit(1)
        
    json_file = sys.argv[1]
    output_folder = sys.argv[2]
    
    # Check if the json file exists
    if not os.path.exists(json_file):
        print('The json file does not exist')
        sys.exit(1)
    
    # Get the file name
    file_name = json_file.split('/')[-1].split('.')[0]
    
    # Read the json file
    with open(json_file, 'r') as f:
        data = json.load(f)
        
    # Write the js file
    with open(f'{output_folder}/{file_name}.js', 'w') as f:
        f.write(f'const {file_name} = {json.dumps(data)};')
        
    print(f'File {file_name}.js created in {output_folder}')
    
    sys.exit(0)