# FountainAI AV-Management API Feature Set

## Overview

The FountainAI AV-Management API is a comprehensive solution designed for handling and managing audiovisual assets, metadata, and scripts. It is optimized for seamless integration with Hugo static site generators and Markdown (.md) content, supporting enhanced media management, including audio generation using CSound. The system runs dockerized locally, integrating Hugo and Jekyll for content management and publishing directly to GitHub Pages as its delivery front. All assets are properly delivered through the GitHub infrastructure, ensuring scalability and reliability.

This system is an integral component of FountainAI and is designed to integrate seamlessly into AI-driven workflows, providing advanced automation and management features for audiovisual content creation.

## Official Documentation Links

- [Hugo Official Documentation](https://gohugo.io/documentation/)
- [GitHub Pages Documentation](https://pages.github.com/)
- [CSound Python Bindings Documentation](https://csound.com/csound-python.html)
- [WebP Image Format Overview](https://developers.google.com/speed/webp)
- [SQLite Documentation](https://sqlite.org/docs.html)
- [Hugo Book Theme](https://github.com/alex-shpak/hugo-book)

## Key Features

1. **Asset Management:**

   - Handles image, audio, and video files with metadata tagging.
   - Supports WebP image format with embedded captions.
   - Automated compression and resizing using WebP.
   - API-driven access for uploading, updating, and retrieving assets.

2. **Audio Processing with CSound:**

   - Generates and processes audio files directly through the API.
   - Supports dynamic composition and synthesis.
   - Automates embedding audio references in Markdown content.

3. **Markdown (.md) Optimization for Hugo:**

   - Generates preformatted Markdown code snippets for embedding AV assets.
   - Automates linking and captioning for image and audio resources.
   - Ensures compatibility with Hugo themes.

4. **Metadata Management:**

   - Allows customizable metadata fields for AV assets.
   - REST endpoints for querying, updating, and managing metadata.

5. **REST API Design:**

   - RESTful endpoints for seamless integration.
   - Designed to be future-proof with OpenAPI 3.0.1 standards.

6. **Database and Storage:**

   - SQLite-powered local storage with Docker container support.
   - CLI tools for database management and maintenance.
   - RESTful endpoints for asset queries and bulk imports.

7. **Batch Processing and Workflow Support:**

   - Batch processing and automation via CLI tools.
   - Script-based workflows for AV and Markdown generation.

8. **Versioning and Context Management:**

   - Supports multiple versions of assets and metadata.
   - Context-aware tagging and categorization for Hugo content.

9. **Future Enhancements:**

   - Full OpenAPI 3.0.1 schema adoption.
   - Extended support for video processing and rendering.

## REST API Example

### Endpoint: `/assets`

- **GET**: Retrieve a list of assets.
- **POST**: Upload a new asset with metadata.
- **PUT**: Update asset metadata.
- **DELETE**: Remove an asset.

### Endpoint: `/audio`

- **POST**: Generate an audio file using CSound with specified parameters.
- **GET**: Retrieve processed audio metadata.

### Endpoint: `/markdown/generate`

- **POST**: Generate Hugo-compatible Markdown snippets for embedding AV assets.

### Endpoint: `/metadata`

- **GET**: Query metadata associated with AV files.
- **POST**: Add metadata to existing assets.

### Endpoint: `/batch/process`

- **POST**: Batch process assets for resizing, compression, and embedding into Markdown.

## Markdown & Hugo Integration

1. **Image Embedding Example:**

   ```markdown
   ![Caption Text](/images/example.webp "Image Title")
   ```

2. **Audio Embedding Example:**

   ```markdown
   <audio controls>
      <source src="/audio/example.mp3" type="audio/mpeg">
   </audio>
   ```

3. **Code Generation API Usage:**

   - Call the `/markdown/generate` endpoint with asset details.
   - Receive preformatted code snippets ready for Hugo integration.

4. **Metadata and Captions:**

   - Metadata is stored in SQLite and linked to the asset.
   - Captions can be embedded directly in WebP images or referenced dynamically.

### Caption Handling in WebP

- WebP images support EXIF, XMP, and ICC profiles for metadata storage.
- Captions can be embedded using tools like `exiftool`.

**Example Commands:**

- Embed Caption:
  ```bash
  exiftool -XMP:Description="Sample Caption Text" example.webp
  ```
- Retrieve Caption:
  ```bash
  exiftool -XMP:Description example.webp
  ```
- Automated scripts can handle batch captioning and metadata updates.

## Installation and Setup

### Local Dependencies

- **Docker**: Required to run the system in containers.
- **Hugo**: For site generation and static content rendering.
- **Jekyll**: Optional for Markdown processing.
- **GitHub CLI**: For managing publishing workflows to GitHub Pages.
- **CSound**: Required for audio generation and processing.
- **SQLite**: Embedded database for metadata and context storage.

### Setup Process

1. Install dependencies using Homebrew:
   ```bash
   brew install hugo
   brew install csound
   brew install sqlite
   brew install docker
   brew install gh
   ```
2. Clone the repository and navigate to the project directory.
3. Start Docker and build the containers:
   ```bash
   docker-compose up --build
   ```
4. Access the REST API locally at `http://localhost:8080`.
5. Integrate with Hugo or Jekyll by linking assets and running builds.
6. Deploy to GitHub Pages using `gh` commands:
   ```bash
   gh repo create
   git add .
   git commit -m "Initial commit"
   git push origin main
   ```

## Conclusion

The FountainAI AV-Management API combines advanced AV handling with Markdown and Hugo optimizations, offering a scalable and flexible solution for content creators and developers. With its RESTful design and future OpenAPI compliance, it ensures adaptability for modern workflows. All assets are served via GitHub infrastructure, providing scalability and reliability for content delivery.

As part of FountainAI, this system integrates seamlessly into AI-driven workflows, making it an advanced and adaptable solution for audiovisual management.

## Appendix: Quick Setup for Hugo and GitHub Pages

1. Create a Hugo site:
   ```bash
   hugo new site my-hugo-site
   cd my-hugo-site
   ```

2. Add the template:
   ```bash
   git submodule add https://github.com/alex-shpak/hugo-book themes/hugo-book
   ```

3. Configure the theme in `config.toml`:
   ```toml
   theme = "hugo-book"
   ```

4. Add content in Markdown format.

5. Test locally:
   ```bash
   hugo server
   ```

6. Deploy to GitHub Pages:
   ```bash
   git init
   git add .
   git commit -m "Initial commit"
   git remote add origin <repository-url>
   git push -u origin main
   ```

7. Set up GitHub Pages under repository settings to deploy the site.

