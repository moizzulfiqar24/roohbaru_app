import os

# File extensions to include
CODE_EXTENSIONS = ['.dart', '.py', '.js', '.java', '.cpp', '.ts', '.html', '.css']

# Files to ignore
IGNORE_FILES = ['firebase_options.dart']

def is_code_file(filename):
    return any(filename.endswith(ext) for ext in CODE_EXTENSIONS)

def write_code_files_to_text(parent_path, output_file='codeFiles.txt'):
    # Find the "roohbaru_app" root in the path
    parts = parent_path.split(os.sep)
    if "roohbaru_app" not in parts:
        raise ValueError("The path must include 'roohbaru_app' as a folder.")
    root_index = parts.index("roohbaru_app")
    project_root = os.path.join(*parts[:root_index + 1])  # roohbaru_app

    with open(output_file, 'w', encoding='utf-8') as out_file:
        for root, _, files in os.walk(parent_path):
            relative_root = os.path.relpath(root, os.path.join(os.sep, *parts[:root_index]))
            code_files = []

            for file in files:
                if file in IGNORE_FILES:
                    print(f'Skipping ignored file: {file}')
                    continue
                if is_code_file(file):
                    code_files.append(file)

            if not code_files:
                print(f'No code files in: {relative_root}')
                out_file.write(f"{relative_root}: no code files are added in this folder yet\n\n")
            else:
                for file in code_files:
                    full_path = os.path.join(root, file)
                    relative_path = os.path.relpath(full_path, os.path.join(os.sep, *parts[:root_index]))
                    print(f'Processing: {relative_path}')
                    try:
                        with open(full_path, 'r', encoding='utf-8') as code_file:
                            code_content = code_file.read()
                        out_file.write(f"{relative_path}: [\n{code_content}\n]\n\n")
                    except Exception as e:
                        print(f"Could not read {relative_path}: {e}")

if __name__ == "__main__":
    # Set your actual folder path here
    parent_folder = '/Users/moiz/Moiz/Coding/Flutter/IBA/Project/roohbaru_app/lib/screens'
    write_code_files_to_text(parent_folder)
    print("\n✅ All folders processed and code files written to codeFiles.txt.")
