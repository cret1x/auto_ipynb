import nbformat
from nbclient import NotebookClient
import sys

def run_notebook(notebook_path, kernel_name):
    with open(notebook_path, 'r', encoding='utf-8') as f:
        notebook = nbformat.read(f, as_version=4)
    client = NotebookClient(notebook, kernel_name=kernel_name)
    client.execute()
    output_path = notebook_path.replace('.ipynb', '_executed.ipynb')
    with open(output_path, 'w', encoding='utf-8') as f:
        nbformat.write(notebook, f)
    print(f"Notebook executed and saved to {output_path}")

run_notebook(sys.argv[1], sys.argv[2])