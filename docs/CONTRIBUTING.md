# Contributing Guide

Thank you for considering contributing to this project! This document provides guidelines and best practices for contributing.

## Getting Started

1. Fork the repository
2. Clone your fork:
```bash
git clone https://github.com/your-username/project-name.git
```
3. Add upstream remote:
```bash
git remote add upstream https://github.com/original-owner/project-name.git
```
4. Create a feature branch:
```bash
git checkout -b feature/your-feature-name
```

## Development Workflow

1. Make sure you're on the latest version:
```bash
git pull upstream main
```

2. Create your feature branch:
```bash
git checkout -b feature/your-feature-name
```

3. Make your changes following our coding standards

4. Run tests:
```bash
dart tools/scripts/test.dart
```

5. Commit your changes:
```bash
git commit -m "feat: add your feature description"
```

## Commit Message Guidelines

We follow the Conventional Commits specification:

- `feat:` - A new feature
- `fix:` - A bug fix
- `docs:` - Documentation changes
- `style:` - Code style changes (formatting, etc)
- `refactor:` - Code changes that neither fix bugs nor add features
- `test:` - Adding or modifying tests
- `chore:` - Changes to build process or auxiliary tools

## Code Style

1. Follow the official Dart style guide
2. Use meaningful variable and function names
3. Write descriptive comments for complex logic
4. Keep functions small and focused
5. Use proper indentation

## Testing

- Write tests for all new features
- Maintain or improve code coverage
- Test edge cases
- Use meaningful test descriptions

## Pull Request Process

1. Update documentation if needed
2. Add tests for new features
3. Ensure all tests pass
4. Update the changelog
5. Request review from maintainers

## Creating Issues

When creating issues, please:

1. Use a clear and descriptive title
2. Provide steps to reproduce (for bugs)
3. Include expected vs actual behavior
4. Add screenshots if relevant
5. List environment details

## Code Review Process

All submissions require review. We use GitHub pull requests for this purpose.

1. Create a pull request
2. Address review comments
3. Update your branch with latest main
4. Squash commits if needed

## Community

- Be respectful and inclusive
- Help others when you can
- Share knowledge
- Follow our code of conduct
