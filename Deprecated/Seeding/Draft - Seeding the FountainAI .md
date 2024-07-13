To seed the FountainAI datastore with the complete works of William Shakespeare and modernize them using a GPT model, we need to automate the process using GitHub Actions. The workflow involves breaking the text into manageable chunks, sending them to the GPT model for paraphrasing, storing the paraphrased text, and committing the results to GitHub. Each commit should trigger the processing of the next chunk.

## Draft 1
Here’s a step-by-step guide to achieve this:

### 1. Prerequisites

- Ensure the complete works of William Shakespeare are stored as `shakespeare.txt` in the repository.
- Set up a GPT model endpoint for paraphrasing.
- Configure GitHub Actions to handle the workflow.

### 2. Chunking the Text

Create a Python script to split the text into manageable chunks. Save this script as `chunk_text.py`.

```python
import os

def chunk_text(file_path, chunk_size):
    with open(file_path, 'r') as file:
        text = file.read()

    chunks = [text[i:i+chunk_size] for i in range(0, len(text), chunk_size)]
    
    for i, chunk in enumerate(chunks):
        with open(f'chunk_{i+1}.txt', 'w') as chunk_file:
            chunk_file.write(chunk)

if __name__ == "__main__":
    chunk_size = 1000  # Adjust this value based on the GPT model's capability
    chunk_text('shakespeare.txt', chunk_size)
```

### 3. GitHub Actions Workflow

Create a GitHub Actions workflow file to automate the chunking, paraphrasing, and committing process. Save this as `.github/workflows/seed_datastore.yml`.

```yaml
name: Seed FountainAI Datastore

on:
  push:
    branches:
      - main
  workflow_dispatch:

jobs:
  chunk_text:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout repository
        uses: actions/checkout@v2

      - name: Set up Python
        uses: actions/setup-python@v2
        with:
          python-version: '3.x'

      - name: Chunk text
        run: |
          python chunk_text.py
          
      - name: Commit chunks
        run: |
          git config --global user.name 'github-actions[bot]'
          git config --global user.email 'github-actions[bot]@users.noreply.github.com'
          git add chunk_*.txt
          git commit -m "Add text chunks"
          git push
          
  paraphrase_text:
    runs-on: ubuntu-latest
    needs: chunk_text

    steps:
      - name: Checkout repository
        uses: actions/checkout@v2

      - name: Set up Python
        uses: actions/setup-python@v2
        with:
          python-version: '3.x'

      - name: Install requests
        run: |
          pip install requests

      - name: Paraphrase chunks
        run: |
          for file in chunk_*.txt; do
            echo "Processing $file"
            python paraphrase_chunk.py "$file"
          done

      - name: Commit paraphrased text
        run: |
          git config --global user.name 'github-actions[bot]'
          git config --global user.email 'github-actions[bot]@users.noreply.github.com'
          git add paraphrased_*.txt
          git commit -m "Add paraphrased text chunks"
          git push
```

### 4. Paraphrasing Script

Create a Python script to send chunks to the GPT model for paraphrasing. Save this script as `paraphrase_chunk.py`.

```python
import os
import requests
import sys

def paraphrase_chunk(chunk_file):
    with open(chunk_file, 'r') as file:
        text = file.read()

    response = requests.post(
        'https://api.openai.com/v1/engines/davinci-codex/completions',
        headers={'Authorization': f'Bearer {os.getenv("OPENAI_API_KEY")}'},
        json={
            'prompt': f'Paraphrase the following text to modern English:\n\n{text}',
            'max_tokens': 1000  # Adjust this based on the GPT model's capability
        }
    )

    if response.status_code == 200:
        paraphrased_text = response.json()['choices'][0]['text'].strip()
        paraphrased_file = chunk_file.replace('chunk', 'paraphrased_chunk')
        with open(paraphrased_file, 'w') as file:
            file.write(paraphrased_text)
    else:
        print(f'Error paraphrasing {chunk_file}: {response.status_code}')
        print(response.json())

if __name__ == "__main__":
    chunk_file = sys.argv[1]
    paraphrase_chunk(chunk_file)
```

### 5. Set Up GitHub Secrets

Add your OpenAI API key as a secret in your GitHub repository:

1. Go to the repository on GitHub.
2. Click on `Settings` > `Secrets and variables` > `Actions`.
3. Click `New repository secret`.
4. Add `OPENAI_API_KEY` as the name and your OpenAI API key as the value.

### 6. Workflow Execution

When you push changes to the `main` branch or manually trigger the workflow, the following will happen:

1. The text will be split into chunks and committed to the repository.
2. The workflow will process each chunk, paraphrase it using the GPT model, and commit the paraphrased chunks back to the repository.

This setup ensures that each chunk is processed and stored sequentially, allowing for efficient and automated seeding of the FountainAI datastore with modernized text from Shakespeare's works.