---
name: skill-discovery
description: INVOKE FIRST when starting any Elixir/Phoenix task to identify relevant skills. Provides systematic checklist for skill selection based on file types and task requirements. Use this to ensure no applicable skills are missed.
priority: 1
auto_suggest: true
file_patterns:
  - "**/*.ex"
  - "**/*.exs"
  - "**/*.heex"
---

# Skill Discovery Checklist

**Purpose:** Systematically identify which skills apply to your current task to ensure comprehensive guidance.

**When to Use:** INVOKE THIS SKILL FIRST before starting any Elixir or Phoenix development work.

---

## How to Use This Checklist

1. Read through the File Type Detection section
2. Identify which file types you'll be working with
3. Check the Task Type Detection section
4. Note all applicable skills
5. Invoke those skills in the order listed
6. Proceed with implementation using skill guidance

---

## File Type Detection

Check what files you'll be modifying or creating:

### General Elixir Development
- [ ] **Working with `.ex` or `.exs` files?**
  - **→ Invoke: `elixir-patterns`**
  - Covers: Pattern matching, pipes, with statements, guards, naming conventions
  - When: ANY Elixir code changes

### Phoenix LiveView
- [ ] **Modifying LiveView modules (`**/live/**/*.ex` or `**/*_live.ex`)?**
  - **→ Invoke: `phoenix-liveview`**
  - Covers: mount, handle_event, handle_info, navigation, PubSub, streams
  - When: Creating or updating LiveView functionality

- [ ] **Working with LiveView templates (`*.html.heex`)?**
  - **→ Invoke: `phoenix-liveview` + `liveview-lifecycle`**
  - Covers: Component structure, assign access, rendering phases
  - When: Updating LiveView templates or components

### Database & Ecto
- [ ] **Creating or modifying Ecto schemas (`**/schemas/**/*.ex`)?**
  - **→ Invoke: `ecto-database`**
  - Covers: Schema definition, associations, changesets
  - When: Database model changes

- [ ] **Writing Ecto queries or working with contexts?**
  - **→ Invoke: `ecto-database`**
  - Covers: Query composition, preloading, transactions
  - When: Data access layer changes

- [ ] **Creating or modifying migrations (`**/migrations/**/*.exs`)?**
  - **→ Invoke: `ecto-database`**
  - Covers: Migration patterns, indexes, constraints
  - When: Database schema changes

### File Uploads
- [ ] **Implementing file upload functionality?**
  - **→ Invoke: `phoenix-uploads` + `phoenix-static-files`**
  - Covers: allow_upload, consume_uploaded_entries, static_paths
  - When: Adding or fixing file upload features

### Static File Serving
- [ ] **Configuring static file serving or fixing 404s on uploaded files?**
  - **→ Invoke: `phoenix-static-files`**
  - Covers: static_paths configuration, Plug.Static, endpoint setup
  - When: Files upload but aren't accessible via HTTP

### Error Handling
- [ ] **Implementing error handling or working with supervision trees?**
  - **→ Invoke: `error-handling`**
  - Covers: Tagged tuples, with statements, try/rescue, supervisors
  - When: Adding error handling logic

### LiveView Lifecycle Issues
- [ ] **Debugging KeyError crashes or assign issues in LiveView?**
  - **→ Invoke: `liveview-lifecycle`**
  - Covers: Static vs connected rendering, safe assign access
  - When: LiveView crashes with KeyError or assign problems

---

## Task Type Detection

Identify the type of work being requested:

### New Feature Implementation
- [ ] **Building a new feature?**
  - **→ Also invoke: `superpowers:brainstorming`**
  - Explore requirements and design before coding

### Bug Fixes
- [ ] **Debugging unexpected behavior or errors?**
  - **→ Also invoke: `superpowers:systematic-debugging`**
  - Systematic approach to identifying root cause

### Test Writing
- [ ] **Writing or updating tests?**
  - **→ Also invoke: `superpowers:test-driven-development`**
  - TDD patterns and testing best practices

### Multi-Step Implementation
- [ ] **Task requires multiple steps or significant changes?**
  - **→ Also invoke: `superpowers:writing-plans`**
  - Create implementation plan before coding

---

## Skill Invocation Priority

When multiple skills apply, invoke them in this order:

1. **Process Skills First** (superpowers)
   - brainstorming, systematic-debugging, test-driven-development, writing-plans

2. **Domain-Specific Skills Next** (elixir-optimization)
   - Most specific to least specific:
     - `liveview-lifecycle` (if debugging lifecycle issues)
     - `phoenix-uploads` (if implementing uploads)
     - `phoenix-static-files` (if configuring static serving)
     - `ecto-database` (if working with database)
     - `phoenix-liveview` (if working with LiveView)
     - `error-handling` (if implementing error handling)
     - `elixir-patterns` (always for Elixir code)

3. **Implementation** (after gathering guidance)
   - Use the patterns and best practices from invoked skills

---

## Example Workflows

### Example 1: Adding File Upload to LiveView

**User Request:** "Add photo upload to the post creation form"

**Skill Discovery Process:**
```
✓ Working with LiveView files → phoenix-liveview
✓ Implementing file uploads → phoenix-uploads
✓ Will need static file serving → phoenix-static-files
✓ Writing Elixir code → elixir-patterns
```

**Invocation Order:**
1. `phoenix-uploads` (most specific)
2. `phoenix-static-files` (supporting feature)
3. `phoenix-liveview` (context)
4. `elixir-patterns` (general)

### Example 2: Debugging LiveView Crash

**User Request:** "Fix KeyError when accessing @user in LiveView template"

**Skill Discovery Process:**
```
✓ LiveView crash with assigns → liveview-lifecycle
✓ Working with LiveView → phoenix-liveview
✓ Debugging issue → superpowers:systematic-debugging
```

**Invocation Order:**
1. `superpowers:systematic-debugging` (process)
2. `liveview-lifecycle` (specific problem)
3. `phoenix-liveview` (general context)

### Example 3: Creating New Ecto Schema

**User Request:** "Create a User schema with posts association"

**Skill Discovery Process:**
```
✓ Creating schema → ecto-database
✓ Writing Elixir code → elixir-patterns
✓ New feature → superpowers:brainstorming
```

**Invocation Order:**
1. `superpowers:brainstorming` (understand requirements)
2. `ecto-database` (schema patterns)
3. `elixir-patterns` (Elixir conventions)

### Example 4: Fixing Migration

**User Request:** "The migration is missing an index on user_id"

**Skill Discovery Process:**
```
✓ Modifying migration → ecto-database
✓ Writing Elixir code → elixir-patterns
```

**Invocation Order:**
1. `ecto-database` (migration patterns)
2. `elixir-patterns` (Elixir conventions)

---

## Common Patterns

### Pattern 1: LiveView Feature
```
superpowers:brainstorming (if new feature)
→ phoenix-liveview
→ elixir-patterns
```

### Pattern 2: File Upload Feature
```
superpowers:brainstorming (if new feature)
→ phoenix-uploads
→ phoenix-static-files
→ phoenix-liveview
→ elixir-patterns
```

### Pattern 3: Database Changes
```
superpowers:brainstorming (if new feature)
→ ecto-database
→ elixir-patterns
```

### Pattern 4: Debugging
```
superpowers:systematic-debugging
→ [specific skill for the component]
→ elixir-patterns
```

---

## Output Format

After running through this checklist, output:

```markdown
## Skills Identified for This Task

**File Types:**
- `.ex` files (LiveView modules)
- `.html.heex` templates

**Skills to Invoke:**
1. phoenix-liveview (LiveView patterns)
2. elixir-patterns (Elixir conventions)

**Proceeding to invoke skills...**
```

Then invoke the identified skills using the Skill tool before starting implementation.

---

## Important Notes

- **Don't skip this step in continuation work** - Even ongoing tasks benefit from skill guidance
- **When in doubt, include more skills** - Better to have guidance you don't need than miss critical patterns
- **Invoke skills BEFORE writing code** - Prevention is better than correction
- **File patterns are hints, not rules** - If you're working on error handling in a LiveView, invoke both skills

---

## Success Criteria

✅ You've successfully used skill-discovery when:
- All relevant skills for the task have been identified
- Skills are invoked in the correct priority order
- Implementation follows patterns from the invoked skills
- No "I should have checked that skill" moments during code review

---

## Meta Note

**This skill itself should be invoked first**, before identifying other skills. Think of it as the "master index" that helps you find the right specialized guidance for your specific task.
