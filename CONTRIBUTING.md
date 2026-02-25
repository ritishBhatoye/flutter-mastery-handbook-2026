# 🤝 Contributing to Flutter Mastery Handbook

Thank you for your interest in contributing! This guide will help you get started.

---

## 📋 How to Contribute

### 1. Report Issues
- Found an error? Open a [GitHub Issue](../../issues)
- Include: chapter, section, and what's wrong
- Suggest corrections if possible

### 2. Fix Typos & Errors
- Fork the repo
- Fix the issue
- Submit a PR with a clear description

### 3. Add Content
- New examples, interview questions, or real-world scenarios
- Follow the existing Markdown format
- Include code that compiles and runs

### 4. Improve Code Examples
- Ensure all code is Dart 3.7+ / Flutter 3.29+ compatible
- Add comments explaining non-obvious parts
- Follow [Effective Dart](https://dart.dev/effective-dart) style guide

---

## 📐 Style Guide

### Markdown
- Use `#` for chapter title, `##` for sections, `###` for subsections
- Use fenced code blocks with language hints: ` ```dart `
- Use tables for comparisons
- Use `> ` for callouts and tips
- Use `---` for section separators

### Code
- Follow [Effective Dart](https://dart.dev/effective-dart)
- Use `const` where possible
- Include proper null safety
- Add inline comments for complex logic
- Test that code compiles

### File Naming
- Chapter files: `XX_chapter_name.md`
- Code files: `snake_case.dart`
- Folders: `snake_case/`

---

## 🔄 Pull Request Process

1. Fork the repository
2. Create a feature branch: `git checkout -b feat/add-riverpod-example`
3. Make your changes
4. Test code examples: `dart analyze && dart test`
5. Commit with clear messages: `feat(ch04): add Riverpod 3.x counter example`
6. Push and create a Pull Request
7. Wait for review

### Commit Convention

```
type(scope): description

Types: feat, fix, docs, style, refactor, test, chore
Scope: ch01, ch02, ..., ch15, glossary, cheatsheet
```

---

## 📄 License

By contributing, you agree that your contributions will be licensed under the MIT License.

---

[← Back to README](README.md)
