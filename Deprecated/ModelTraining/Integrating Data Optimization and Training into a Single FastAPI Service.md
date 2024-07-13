### Comprehensive Project Presentation: Integrating Data Optimization and Training into a Single FastAPI Service

#### Introduction

In this project, we build a FastAPI application that continuously trains a GPT-2 model using data from the FountainAI APIs. We leverage the OpenAI API to preprocess the data, ensuring it is optimized for training. The preprocessing service and the training application are integrated into a single comprehensive FastAPI service, which can be called at any given moment, fitting seamlessly into the Matrix FountainAI Bot use case.

### Project Structure

1. **Data Ingestion**
2. **Data Optimization and Training API**
3. **Adaptive Training Scheduling**
4. **OpenAPI Documentation**

### Step 1: Data Ingestion

We fetch data from all FountainAI APIs. This data includes scripts, section headings, spoken words, transitions, actions, characters, notes, and music.

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

### Step 2: Data Optimization and Training API

We create a FastAPI service that handles both data optimization using the OpenAI API and model training. This service preprocesses the data and trains the GPT-2 model.

#### Example FastAPI Application (`main.py`):

```python
from fastapi import FastAPI, BackgroundTasks, HTTPException, Request
import openai
import json
import wandb
import torch
from transformers import GPT2Tokenizer, GPT2LMHeadModel, Trainer, TrainingArguments
from datasets import Dataset
from fetch_data import get_training_data

app = FastAPI()

# Set your OpenAI API key
openai.api_key = "your_openai_api_key"

# Initialize W&B
wandb.init(project="fountainai-gpt2-training")

# Load tokenizer and model
model_name = "gpt2"
tokenizer = GPT2Tokenizer.from_pretrained(model_name)
model = GPT2LMHeadModel.from_pretrained(model_name)

@app.post("/optimize_data")
async def optimize_data(request: Request):
    try:
        data_sample = await request.json()
        prompt = (
            "Given the following dataset sample, preprocess the data for training a GPT-2 model. "
            "The preprocessing steps should include removing special characters, lowercasing, and tokenizing the text.\n\n"
            f"Dataset Sample:\n{json.dumps(data_sample, indent=2)}\n\n"
            "Preprocessed Data:"
        )
        
        response = openai.Completion.create(
            engine="text-davinci-002",
            prompt=prompt,
            max_tokens=2048  # Adjust as needed to handle the full response
        )
        
        preprocessed_data = response.choices[0].text.strip()
        return json.loads(preprocessed_data)
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

def preprocess_received_data(received_data):
    tokens = [tokenizer.encode(item['text'], truncation=True, max_length=512) for item in received_data]
    return {"input_ids": tokens}

def train_model(received_data):
    processed_data = preprocess_received_data(received_data)

    # Convert to dataset
    dataset = Dataset.from_dict(processed_data)

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
        train_dataset=dataset,
        eval_dataset=dataset,
    )

    # Train the model
    trainer.train()

    # Save the model
    trainer.save_model("./results")

    # Log model
    wandb.save("./results")

@app.post("/train")
async def train(background_tasks: BackgroundTasks, request: Request):
    try:
        request_data = await request.json()
        preprocessed_data = request_data.get("data", [])
        if not preprocessed_data:
            raise HTTPException(status_code=400, detail="No data provided")

        background_tasks.add_task(train_model, preprocessed_data)
        return {"message": "Training started"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
```

### Step 3: Adaptive Training Scheduling

Use OpenAI API to determine the optimal time for retraining.

#### Example Adaptive Scheduling Script (`schedule_training.py`):

```python
import openai
import requests
import time

# Set your OpenAI API key
openai.api_key = "your_openai_api_key"

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
    openai.api_key = "your_openai_api_key"
    
    # Fetch model performance data
    performance_data = check_model_performance()
    
    # Prompt OpenAI to decide whether to retrain
    prompt = (
        "Given the following model performance data, should we retrain the model? "
        "Performance data: "
        f"{performance_data}"
    )
    
    response = openai.Completion.create(
        engine="text-davinci-002",
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

### Step 4: OpenAPI Documentation

FastAPI automatically generates OpenAPI documentation, making it easy to understand and interact with the API.

#### OpenAPI Schema for the Integrated Application:

FastAPI automatically provides OpenAPI documentation, accessible at `/docs` (Swagger UI) and `/redoc` (ReDoc).

##### Example of Generated OpenAPI Schema:

```json
{
  "openapi": "3.0.2",
  "info": {
    "title": "Integrated Data Optimization and Training API",
    "version": "0.1.0"
  },
  "paths": {
    "/optimize_data": {
      "post": {
        "summary": "Optimize Data",
        "operationId": "optimize_data_optimize_data_post",
        "requestBody": {
          "content": {
            "application/json": {
              "schema": {
                "type": "object",
                "properties": {
                  "data": {
                    "type": "array",
                    "items": {
                      "type": "object",
                      "properties": {
                        "text": {
                          "type": "string"
                        }
                      }
                    }
                  }
                }
              }
            }
          },
          "required": true
        },
        "responses": {
          "200": {
            "description": "Successful Response",
            "content": {
              "application/json": {
                "schema": {
                  "type": "object",
                  "properties": {
                    "preprocessed_data": {
                      "type": "array",
                      "items": {
                        "type": "object",
                        "properties": {
                          "text": {
                            "type": "string"
                          }
                        }
                      }
                    }
                  }
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
    },
    "/train": {
      "post": {
        "summary": "Train",
        "operationId": "train_train_post",
        "requestBody": {
          "content": {
            "application/json": {
              "schema": {
                "type": "object",
                "properties": {
                  "data": {
                    "type": "array",
                    "items": {
                      "type": "object",
                      "properties": {
                        "text": {
                          "type": "string"
                        }
                      }
                    }
                  }
                }
              }
            }
          },
          "required": true
        },
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
          "400": {
            "description": "Bad Request",
            "content": {
              "application/json": {
                "schema": {
                  "$ref": "#/components/schemas/HTTPValidationError"
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

This implementation integrates the data optimization and training functionalities into a single FastAPI service. The service preprocesses data using the OpenAI API and trains the GPT-2 model using this optimized data. Adaptive scheduling ensures the model is retrained at optimal times based on real-time performance data. This approach ensures that the model remains up-to-date and performs well with the latest data from FountainAI. The OpenAPI documentation provided by FastAPI makes it easy to understand and interact with the APIs.

### Commit Message

```
feat: Integrate data optimization and training into a single FastAPI service

- Combined data optimization and training functionalities into one FastAPI application (`main.py`):
  - Added `/optimize_data` endpoint for data preprocessing using the OpenAI API.
  - Added `/train` endpoint for training the GPT-2 model with optimized data.
  - Included data ingestion script (`fetch_data.py`) to fetch data from FountainAI APIs.
  - Implemented model training pipeline with Weights & Biases (W&B) logging.

- Updated adaptive training scheduling script (`schedule_training.py`):
  - Utilizes the OpenAI API to determine optimal retraining times based on model performance data.
  - Automates training checks and initiates training when necessary.

- Generated comprehensive OpenAPI documentation for the integrated application:
  - Included schemas for request and response bodies.
  - Provided endpoints documentation accessible via `/docs` and `/redoc`.

This refactor enhances the modularity and scalability of the system, allowing for continuous improvement and integration of the GPT-2 model with the latest data from FountainAI.
```