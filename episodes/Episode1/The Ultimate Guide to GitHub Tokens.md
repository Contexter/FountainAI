# The Ultimate Guide to GitHub Tokens

GitHub tokens are essential for managing authentication and access control for various GitHub operations, such as interacting with the GitHub API, GitHub Actions workflows, and third-party integrations. This guide will cover both classic and fine-grained personal access tokens, providing comprehensive details on their creation, usage, and best practices.

For more detailed information, refer to the official GitHub documentation on [managing your personal access tokens](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens).

## Table of Contents

1. [Introduction to GitHub Tokens](#introduction-to-github-tokens)
2. [Classic Personal Access Tokens (PATs)](#classic-personal-access-tokens-pats)
    - [Creating a Classic PAT](#creating-a-classic-pat)
    - [Using Classic PATs](#using-classic-pats)
    - [Managing Classic PATs](#managing-classic-pats)
3. [Fine-Grained Personal Access Tokens](#fine-grained-personal-access-tokens)
    - [Creating a Fine-Grained PAT](#creating-a-fine-grained-pat)
    - [Using Fine-Grained PATs](#using-fine-grained-pats)
    - [Managing Fine-Grained PATs](#managing-fine-grained-pats)
4. [Using GitHub Tokens in GitHub Actions](#using-github-tokens-in-github-actions)
5. [Best Practices for Managing GitHub Tokens](#best-practices-for-managing-github-tokens)
6. [Revoking and Regenerating Tokens](#revoking-and-regenerating-tokens)
7. [Conclusion](#conclusion)

## Introduction to GitHub Tokens

GitHub tokens are authentication tokens used to access the GitHub API and perform various actions, such as cloning repositories, triggering workflows, and interacting with GitHub services. There are two primary types of tokens: classic Personal Access Tokens (PATs) and fine-grained Personal Access Tokens.

## Classic Personal Access Tokens (PATs)

Classic Personal Access Tokens (PATs) are long-standing tokens that provide broad access to your GitHub account and repositories based on the scopes you grant.

### Creating a Classic PAT

1. **Navigate to GitHub Settings**:
   - Go to [GitHub](https://github.com).
   - Click on your profile picture in the top-right corner and select `Settings`.

2. **Access Developer Settings**:
   - In the left sidebar, click on `Developer settings`.

3. **Generate a New Token**:
   - Click on `Personal access tokens`.
   - Click `Generate new token`.

4. **Configure the Token**:
   - Provide a descriptive name for the token.
   - Select the scopes or permissions you want to grant this token.
   - Click `Generate token`.

5. **Copy the Token**:
   - Make sure to copy the token now as you will not be able to see it again.

### Using Classic PATs

Classic PATs can be used for:

- **Authenticating API Requests**:
  ```sh
  curl -H "Authorization: token YOUR_PERSONAL_ACCESS_TOKEN" https://api.github.com/user
  ```

- **Git Operations**:
  ```sh
  git clone https://YOUR_PERSONAL_ACCESS_TOKEN@github.com/username/repository.git
  ```

### Managing Classic PATs

You can view and manage your classic PATs in the Developer settings under Personal access tokens. Here you can:

- **Regenerate**: Renew the token without changing its scopes.
- **Revoke**: Delete the token to revoke its access immediately.
- **Edit**: Modify the scopes of an existing token.

## Fine-Grained Personal Access Tokens

Fine-grained Personal Access Tokens provide more granular control over the permissions and access levels granted to the token, enhancing security and flexibility.

### Creating a Fine-Grained PAT

1. **Navigate to GitHub Settings**:
   - Go to [GitHub](https://github.com).
   - Click on your profile picture in the top-right corner and select `Settings`.

2. **Access Developer Settings**:
   - In the left sidebar, click on `Developer settings`.

3. **Generate a New Token**:
   - Click on `Personal access tokens (fine-grained)`.
   - Click `Generate new token`.

4. **Configure the Token**:
   - Provide a descriptive name for the token.
   - Select the repository access, permissions, and expiration date.
   - Click `Generate token`.

5. **Copy the Token**:
   - Make sure to copy the token now as you will not be able to see it again.

### Using Fine-Grained PATs

Fine-grained PATs can be used similarly to classic PATs but provide more specific access control.

- **Authenticating API Requests**:
  ```sh
  curl -H "Authorization: token YOUR_FINE_GRAINED_PERSONAL_ACCESS_TOKEN" https://api.github.com/user
  ```

- **Git Operations**:
  ```sh
  git clone https://YOUR_FINE_GRAINED_PERSONAL_ACCESS_TOKEN@github.com/username/repository.git
  ```

### Managing Fine-Grained PATs

You can view and manage your fine-grained PATs in the Developer settings under Personal access tokens (fine-grained). Here you can:

- **Regenerate**: Renew the token without changing its permissions.
- **Revoke**: Delete the token to revoke its access immediately.
- **Edit**: Modify the permissions and repository access of an existing token.

## Using GitHub Tokens in GitHub Actions

GitHub tokens are essential for performing actions in GitHub Actions workflows.

### Using Secrets

Store your tokens as secrets in your GitHub repository to keep them secure.

1. **Navigate to Repository Settings**:
   - Go to your repository on GitHub.
   - Click on `Settings`.

2. **Add a Secret**:
   - Click on `Secrets and variables` in the left sidebar.
   - Click `Actions`.
   - Click `New repository secret`.
   - Add your token as a secret.

### Using Tokens in Workflows

```yaml
name: Example Workflow

on: [push]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v2

      - name: Use Personal Access Token
        run: |
          curl -H "Authorization: token ${{ secrets.PERSONAL_ACCESS_TOKEN }}" https://api.github.com/user

      - name: Use Fine-Grained Personal Access Token
        env:
          GITHUB_TOKEN: ${{ secrets.FINE_GRAINED_PERSONAL_ACCESS_TOKEN }}
        run: |
          curl -H "Authorization: token $GITHUB_TOKEN" https://api.github.com/user
```

## Best Practices for Managing GitHub Tokens

1. **Use Least Privilege**: Grant the minimal required scopes or permissions for your tokens.
2. **Rotate Tokens Regularly**: Periodically regenerate and replace tokens to minimize the risk of exposure.
3. **Store Tokens Securely**: Use GitHub secrets to store tokens securely and avoid hardcoding them in your codebase.
4. **Monitor Token Usage**: Regularly review the access logs and audit trails for your tokens to detect any unauthorized use.

## Revoking and Regenerating Tokens

### Revoking Tokens

To revoke a token, navigate to your Developer settings and delete the token. This will immediately invalidate the token and revoke its access.

### Regenerating Tokens

If you need to renew a token, you can regenerate it from the Developer settings. This will issue a new token with the same permissions.

## Conclusion

GitHub tokens are crucial for securing access to your GitHub resources. By understanding the differences between classic Personal Access Tokens and the new fine-grained Personal Access Tokens, you can choose the best approach for your needs. Always follow best practices for managing and securing your tokens to protect your GitHub environment.

For more detailed information, refer to the official GitHub documentation on [managing your personal access tokens](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens).