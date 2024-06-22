
## Project Presentation: Continuous Training and Integration of GPT-2 Model with FountainAI APIs

#### Introduction

In this project, we aim to build a FastAPI application that continuously trains a GPT-2 model using data from the FountainAI APIs. By integrating Weights & Biases (W&B) for experiment tracking, we ensure robust, reproducible, and scalable machine learning workflows. The resulting model will complement the current use of the OpenAI API within the FountainAI system to enhance script management and editing workflows.

### Project Structure

1. **Data Ingestion**
2. **Model Training Pipeline**
3. **FastAPI Application**
4. **Adaptive Training Scheduling**
5. **OpenAPI Documentation**

### Step 1: Data Ingestion

We fetch data from the FountainAI APIs and preprocess it for training.

#### Example Script (`fetch_data.py`):

```python
import requests

# Define API endpoints
SCRIPT_API_URL = "https://script.fountain.coach/scripts"
SECTION_HEADINGS_API_URL = "https://sectionheading.fountain.coach/sectionHeadings"
SPOKEN_WORDS_API_URL = "https://spokenwords.fountain.coach/spokenWords"
TRANSITIONS_API_URL = "https://transition.fountain.coach/transitions"
ACTIONS_API_URL = "https://action.fountain.coach/actions"
CHARACTERS_API_URL = "https://character.fountain.coach/characters"
NOTES_API_URL = "https://note.fountain.coach/notes"
MUSIC_API_URL = "https://musicsound.fountain.coach/generate"

# Function to fetch data from an API
def fetch_data(api_url):
    response = requests.get(api_url)
    response.raise_for_status()
    return response.json()

# Fetch data from the APIs
def get_training_data():
    scripts = fetch_data(SCRIPT_API_URL)
    section_headings = fetch_data(SECTION_HEADINGS_API_URL)
    spoken_words = fetch_data(SPOKEN_WORDS_API_URL)
    transitions = fetch_data(TRANSITIONS_API_URL)
    actions = fetch_data(ACTIONS_API_URL)
    characters = fetch_data(CHARACTERS_API_URL)
    notes = fetch_data(NOTES_API_URL)
    music = fetch_data(MUSIC_API_URL)

    # Combine and preprocess data as needed
    training_data = {
        "scripts": scripts,
        "section_headings": section_headings,
        "spoken_words": spoken_words,
        "transitions": transitions,
        "actions": actions,
        "characters": characters,
        "notes": notes,
        "music": music
    }

    return training_data
```

### Step 2: Model Training Pipeline

The training script preprocesses the data, trains the GPT-2 model, and logs the results to Weights & Biases.

#### Example Training Script (`train_gpt2_wandb.py`):

```python
import os
import torch
import wandb
from transformers import GPT2Tokenizer, GPT2LMHeadModel, Trainer, TrainingArguments
from datasets import Dataset
from fetch_data import get_training_data

# Initialize Weights & Biases
wandb.init(project="fountainai-gpt2-training")

# Load tokenizer and model
model_name = "gpt2"
tokenizer = GPT2Tokenizer.from_pretrained(model_name)
model = GPT2LMHeadModel.from_pretrained(model_name)

# Fetch and preprocess training data
training_data = get_training_data()

# Example: Combine all texts into a single string
texts = []
for key in training_data:
    for item in training_data[key]:
        if 'text' in item:
            texts.append(item['text'])

combined_text = "\n".join(texts)

# Tokenize the dataset
def tokenize_function(examples):
    return tokenizer(examples, return_tensors='pt', max_length=512, truncation=True)

tokens = tokenize_function(combined_text)

# Define training arguments
training_args = TrainingArguments(
    output_dir="./results",
    evaluation_strategy="epoch",
    learning_rate=5e-5,
    per_device_train_batch_size=8,
    per_device_eval_batch_size=8,
    num_train_epochs=1,
    weight_decay=0.01,
    logging_dir='./logs',
    logging_steps=10,
    report_to="wandb"  # Report to Weights & Biases
)

# Trainer
trainer = Trainer(
    model=model,
    args=training_args,
    train_dataset=Dataset.from_dict(tokens),
    eval_dataset=Dataset.from_dict(tokens),
)

# Train the model
trainer.train()

# Save the model
trainer.save_model("./results")

# Log model
wandb.save("./results")

# Finish W&B run
wandb.finish()
```

### Step 3: FastAPI Application

We create a FastAPI application to handle training requests asynchronously.

#### Example FastAPI Application (`main.py`):

```python
from fastapi import FastAPI, BackgroundTasks, HTTPException
from fetch_data import get_training_data
from train_gpt2_wandb import train_model

app = FastAPI()

@app.post("/train")
async def train(background_tasks: BackgroundTasks):
    try:
        background_tasks.add_task(train_model)
        return {"message": "Training started"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
```

### Step 4: Adaptive Training Scheduling

Instead of using `cron` for scheduling, we use the OpenAI API to determine the optimal time for retraining based on model performance and new data availability.

#### Example Adaptive Scheduling Function (`schedule_training.py`):

```python
import openai
import requests
import time

# Define OpenAI API credentials
OPENAI_API_KEY = "your_openai_api_key"

# Define API endpoints
TRAIN_API_URL = "http://localhost:8000/train"
MODEL_PERFORMANCE_API_URL = "https://performance.fountain.coach/model"

# Function to check model performance
def check_model_performance():
    response = requests.get(MODEL_PERFORMANCE_API_URL)
    response.raise_for_status()
    return response.json()

# Function to decide whether to retrain the model
def should_retrain_model():
    openai.api_key = OPENAI_API_KEY
    
    # Fetch model performance data
    performance_data = check_model_performance()
    
    # Prompt OpenAI to decide whether to retrain
    prompt = (
        "Given the following model performance data, should we retrain the model? "
        "Performance data: "
        f"{performance_data}"
    )
    
    response = openai.Completion.create(
        engine="davinci-codex",
        prompt=prompt,
        max_tokens=10
    )
    
    decision = response.choices[0].text.strip().lower()
    return decision in ["yes", "true"]

# Function to schedule training
def schedule_training():
    while True:
        if should_retrain_model():
            response = requests.post(TRAIN_API_URL)
            if response.status_code == 200:
                print("Training started successfully.")
            else:
                print(f"Failed to start training: {response.text}")
        else:
            print("No need to retrain the model at this time.")
        
        # Check every 6 hours
        time.sleep(21600)

if __name__ == "__main__":
    schedule_training()
```

### Step 5: OpenAPI Documentation

FastAPI automatically generates OpenAPI documentation, making it easy to understand and interact with the API.

#### FastAPI Created OpenAPI Documentation

FastAPI automatically provides OpenAPI documentation, accessible at `/docs` (Swagger UI) and `/redoc` (ReDoc).

##### Example of Generated OpenAPI Schema:

```json
{
  "openapi": "3.0.2",
  "info": {
    "title": "FastAPI",
    "version": "0.1.0"
  },
  "paths": {
    "/train": {
      "post": {
        "summary": "Train",
        "operationId": "train_train_post",
        "responses": {
          "200": {
            "description": "Successful Response",
            "content": {
              "application/json": {
                "schema": {
                  "$ref": "#/components/schemas/Message"
                }
              }
            }
          },
          "500": {
            "description": "Internal Server Error",
            "content": {
              "application/json": {
                "schema": {
                  "$ref": "#/components/schemas/HTTPValidationError"
                }
              }
            }
          }
        }
      }
    }
  },
  "components": {
    "schemas": {
      "Message": {
        "title": "Message",
        "type": "object",
        "properties": {
          "message": {
            "title": "Message",
            "type": "string"
          }
        }
      },
      "HTTPValidationError": {
        "title": "HTTPValidationError",
        "type": "object",
        "properties": {
          "detail": {
            "title": "Detail",
            "type": "array",
            "items": {
              "$ref": "#/components/schemas/ValidationError"
            }
          }
        }
      },
      "ValidationError": {
        "title": "ValidationError",
        "type": "object",
        "properties": {
          "loc": {
            "title": "Location",
            "type": "array",
            "items": {
             

 "type": "string"
            }
          },
          "msg": {
            "title": "Message",
            "type": "string"
          },
          "type": {
            "title": "Error Type",
            "type": "string"
          }
        }
      }
    }
  }
}
```

### Conclusion

By integrating FastAPI, Weights & Biases, and the Hugging Face Transformers library, we have developed a robust solution for continuously training a GPT-2 model using data from the FountainAI APIs. This system ensures that the model remains updated with the latest script data, enhancing its performance and relevance.

### Foreshadowing: Usage within the FountainAI System

The integration of the continuously trained GPT-2 model with the current system using the OpenAI API will significantly enhance the FountainAI Matrix Bot's capabilities. By leveraging both models, the bot can intelligently manage and edit scripts, providing a seamless and intelligent script management experience. This dual-model approach will enable the bot to handle a wide range of tasks more effectively, ensuring high-quality interactions and efficient workflows within the Matrix chat environment. The continuously updated GPT-2 model will complement the OpenAI API, providing more contextually relevant and fine-tuned responses based on the latest data from FountainAI. Additionally, using the OpenAI API to decide when to retrain the GPT-2 model ensures that retraining occurs at optimal times, based on real-time performance data and usage patterns.