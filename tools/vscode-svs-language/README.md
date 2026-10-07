# SVS Command Script (VS Code language extension)

Syntax highlighting for `.svs` files - the command scripts documented in
[`command/README.md`](../../command/README.md) and used under
[`command/test/`](../../command/test/) (`RUN.SCRIPT`, test fixtures, etc.).

Unlike borrowing another language's grammar (CoffeeScript, Ruby, YAML, ...),
this one is written for the actual syntax: `#` comments, `=`-prefixed
section-divider lines (skipped the same way by `sanitizeScriptLine` in
`runScript.pde`), command names (including the punctuation-heavy ones -
`REC.png`, `Shade.Materials`, `+MapZoom`, `N.E.`, `3d-model`, `1D>GROUP`),
and `key:value`/`key=value` argument pairs (both forms highlighted the same
way, since `tokenizeScriptLine` treats them identically).

## Install

Pick whichever you're more comfortable with - both just register the
language, there's nothing to build.

**Option A - from within VS Code (no terminal needed):**

1. Command Palette (`Ctrl+Shift+P` / `Cmd+Shift+P`) -> **Developer: Install
   Extension from Location...**
2. Select this folder (`tools/vscode-svs-language`).
3. Reload the window if prompted.

**Option B - copy into your user extensions folder:**

```sh
# macOS/Linux
cp -r tools/vscode-svs-language ~/.vscode/extensions/svs-language-0.0.1

# Windows (PowerShell)
Copy-Item -Recurse tools\vscode-svs-language "$env:USERPROFILE\.vscode\extensions\svs-language-0.0.1"
```

Then reload the window (`Developer: Reload Window`).

## After installing

`.svs` files now default to the `svs` language on their own (via this
extension's own `extensions` contribution in `package.json`), so the
`files.associations` override in the repo's `.vscode/settings.json` is no
longer needed for that mapping - see the updated settings file.

## Editing the grammar

[`svs.tmLanguage.json`](svs.tmLanguage.json) is a regular
TextMate grammar (same format VS Code's built-in languages use), matched in
this order per line: comments, section dividers, the leading command token,
`key:value`/`key=value` pairs (numeric value, then a fallback for anything
else), quoted strings, bare numbers (for trailing arguments and
comma-separated coordinate lists), then a catch-all for any remaining bare
word (a multi-word command caption's trailing words, e.g. `last` in
`Select last`).

After changing it, reload the window to pick up the change - no
reinstall needed when using Option A or a copied/linked folder.
