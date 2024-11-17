# Development Tools

This directory contains various tools and scripts to help with development. All scripts are designed to work across different shells (CMD, PowerShell, Git Bash, Zsh, etc.).

## Directory Structure

```
tools/
├── scripts/           # Cross-platform scripts for common tasks
├── templates/         # Templates for code generation
└── README.md         # This file
```

## Available Scripts

### Feature Generation
Creates a new feature following Clean Architecture principles.

```bash
# Windows CMD
tools\scripts\create_feature.bat user_profile

# Git Bash / Zsh / Bash
./tools/scripts/create_feature.sh user_profile
```

### Project Renaming
Renames the project, updates bundle IDs, and package names.

```bash
# Windows CMD
tools\scripts\rename_project.bat -n my_app -d "My Awesome App" -o com.mycompany

# Git Bash / Zsh / Bash
./tools/scripts/rename_project.sh -n my_app -d "My Awesome App" -o com.mycompany
```

### Running Tests
Runs all tests with coverage report.

```bash
# Windows CMD
tools\scripts\test.bat

# Git Bash / Zsh / Bash
./tools/scripts/test.sh
```

### Building Release
Builds release versions for all platforms.

```bash
# Windows CMD
tools\scripts\build.bat

# Git Bash / Zsh / Bash
./tools/scripts/build.sh
```

## Script Arguments

### create_feature
- Argument: `<feature_name>` (required)
- Format: snake_case (e.g., user_profile, authentication)
- Example: `create_feature.sh user_profile`

### rename_project
- `-n, --name`: New project name in snake_case (required)
- `-d, --description`: Project description (required)
- `-o, --organization`: Organization name in reverse domain notation (required)
- Example: `rename_project.sh -n my_app -d "My Awesome App" -o com.mycompany`

### test
- `-c, --coverage`: Generate coverage report (optional)
- `-u, --update`: Update golden files (optional)
- Example: `test.sh -c`

### build
- `-p, --platform`: Target platform (android|ios|web|windows|macos|linux)
- `-r, --release`: Build in release mode
- Example: `build.sh -p android -r`

## Templates

The `templates` directory contains base templates for:
- Data Layer (Repository pattern, Data sources)
- Domain Layer (Entities, Use cases)
- Presentation Layer (BLoC pattern, Pages, Widgets)

## Best Practices

1. Always run scripts from the project root directory
2. Use the appropriate script extension for your shell:
   - `.bat` for Windows CMD
   - `.sh` for Git Bash, Zsh, and other Unix shells
3. Make sure scripts are executable:
   ```bash
   chmod +x tools/scripts/*.sh
   ```

## Troubleshooting

### Common Issues

1. Script not found
   ```bash
   # Add tools/scripts to your PATH or use relative path
   export PATH="$PATH:./tools/scripts"
   ```

2. Permission denied
   ```bash
   # Make scripts executable
   chmod +x tools/scripts/*.sh
   ```

3. Line endings issues
   ```bash
   # Fix line endings
   git config --global core.autocrlf input
   ```

### Getting Help

Each script supports the `-h` or `--help` flag for detailed usage information:
```bash
./tools/scripts/create_feature.sh --help
./tools/scripts/rename_project.sh --help
./tools/scripts/test.sh --help
./tools/scripts/build.sh --help
```
