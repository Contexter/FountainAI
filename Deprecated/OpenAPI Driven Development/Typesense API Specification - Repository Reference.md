# Typesense API Specification - Repository Reference

## **Repository Overview**

**Repository URL:** [typesense-api-spec](https://github.com/typesense/typesense-api-spec)

**Purpose:**
This repository contains the API specifications for the **Typesense HTTP API**. It provides a formal OpenAPI 3.0.3 definition that outlines all supported endpoints, request parameters, responses, and data models.

---

## **Repository Structure**
```
typesense-api-spec/
├── .gitignore         # Ignore rules for git version control.
├── README.md          # Documentation about repository usage.
└── openapi.yml        # OpenAPI specification file for Typesense's HTTP API.
```

### **Key Files:**
1. **`openapi.yml`**  
   - Contains the OpenAPI 3.0.3 specification for Typesense.  
   - Defines endpoints, methods, request bodies, responses, and schemas.
   - Enables auto-generation of client SDKs and documentation.

2. **`README.md`**  
   - Provides an overview of the repository.  
   - Includes instructions for viewing or editing the API spec.

3. **`.gitignore`**  
   - Manages files and folders excluded from version control.

---

## **Usage Instructions**

To view or edit the API specification, follow these steps:

1. **Clone the Repository:**
```bash
git clone https://github.com/typesense/typesense-api-spec.git
```

2. **Run Swagger Editor using Docker:**
```bash
docker run -p 8080:8080 -v $(pwd):/tmp -e SWAGGER_FILE=/tmp/openapi.yml swaggerapi/swagger-editor
```

3. **Access Swagger Editor:**
- Open your browser and navigate to: [http://localhost:8080](http://localhost:8080)

---

## **Additional Information**

- **OpenAPI Compliance:** The repository adheres to the OpenAPI 3.0.3 standard for defining RESTful APIs.
- **Client Libraries:** The specification supports auto-generation of SDKs for multiple programming languages.
- **Contribution Guide:** Contributions are welcomed, with instructions provided in the README file.

---

## **Links:**
- **Repository URL:** [typesense-api-spec](https://github.com/typesense/typesense-api-spec)
- **OpenAPI File:** [openapi.yml](https://github.com/typesense/typesense-api-spec/blob/master/openapi.yml)
- **Swagger Editor Docs:** [swagger.io](https://swagger.io/tools/swagger-editor/)

---

This document serves as a quick reference for understanding and working with the **Typesense API Specification Repository**. For further assistance, refer to the repository README or the Typesense documentation.

