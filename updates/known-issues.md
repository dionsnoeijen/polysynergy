# Known Issues

This page lists currently known issues and limitations in PolySynergy Studio Alpha.

## ⚠️ Alpha Status

PolySynergy Studio is currently in **alpha**. This means:
- Features may be incomplete or change
- You may encounter bugs
- Documentation is still being completed

We appreciate your patience and feedback as we work toward a stable release!

---

## Current Known Issues

- **DOCUMENTATION** Incomplete, especially for getting started, features and nodes.
- **UI/UX** The undo/redo functionality is unreliable in some scenarios.
- **UI/UX** If you close a panel, you cannot reopen it, when there is no flow active because the buttons are in the editor.
- **UI/UX** The connections can be created on the same input many times. In some cases this is correct, but in most it's not. This needs an update.
- **UI/UX** If you go to a sub-form, and then close it, you won't go back to the original form. (for example: go to secrets, and through secrets to manage stages)
- **UI/UX** The error log node, does not accept a dict on the message input, which sucks.
- **UI/UX** Check the log panel, it sometimes does not show the logs from the log node (possibly local issue).
- **UI/UX** The documentation is in the ui, but it needs to be added to the bottom bar, and then link to the internal documentation.
- **NODES** Not all nodes have been tested extensively, so there may be bugs in nodes.
- **NODES AGNO** Still in development, not all features are implemented.

---

## Reporting Issues

Found a bug or have feedback?

### GitHub Issues
Report bugs and request features: [github.com/dionsnoeijen/polysynergy/issues](https://github.com/dionsnoeijen/polysynergy/issues)

### What to Include
When reporting an issue, please include:
- Clear description of the problem
- Steps to reproduce
- Expected vs actual behavior
- Screenshots if applicable
- Browser/system information

---

## What's Being Fixed

We're actively working on:
1. ✅ Documentation completion - Top priority
2. 🚧 Performance optimizations - In progress
3. 🚧 Error message improvements - In progress
4. 📋 Enhanced OAuth setup UX - Planned

---

*This page is updated regularly as issues are identified and resolved.*

*Last updated: January 2025*
