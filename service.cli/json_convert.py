"""Script to convert json files to js files"""
import json
import sys
import os

if __name__ == '__main__':
    if len(sys.argv) == 3:
        print('Usage: json_convert.py <input_folder> <output_folder>')
        sys.exit(1)
        
    input_folder = sys.argv[1]
    output_folder = sys.argv[2]
    
    # Check if the input folder exists
    if not os.path.exists(input_folder):
        print('The input folder does not exist')
        sys.exit(1)

    # Check if the output folder exists
    if not os.path.exists(output_folder):
        os.makedirs(output_folder)
        
    # Get the json files
    json_files = [f'{input_folder}/{f}' for f in os.listdir(input_folder) if f.endswith('.json')]
    
    # Check if there are json files
    if not json_files:
        print('There are no json files in the input folder')
        sys.exit(1)
        
    # Convert the json files to js files
    for json_file in json_files:
        file_name = json_file.split('/')[-1].split('.')[0]
        
        with open(json_file, 'r') as f:
            data = json.load(f)
            
        with open(f'{output_folder}/{file_name}.js', 'w') as f:
            f.write(f'const {file_name} = {json.dumps(data)};')
            
        print(f'File {file_name}.js created in {output_folder}')
        
    sys.exit(0)