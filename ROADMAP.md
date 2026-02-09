# Elixir Claude Optimization Plugin - Roadmap

**Last Updated:** 2026-02-09
**Current Version:** 1.0.0
**Status:** Planning for v1.1.0+

This document outlines planned improvements for the Elixir Claude Optimization plugin based on real-world usage analysis and development feedback.

## Semantic Versioning

This project follows [Semantic Versioning 2.0.0](https://semver.org/):

- **MAJOR.x.x** (e.g., 2.0.0): Breaking changes or major new features
- **x.MINOR.x** (e.g., 1.1.0): New features, backward-compatible
- **x.x.PATCH** (e.g., 1.0.1): Bug fixes, backward-compatible

**Version Mapping:**
- v1.1.0 = Quick Wins (minor features)
- v1.2.0 = High-Impact Skills (minor features)
- v2.0.0 = Automation (major new feature set)
- v2.1.0 = Polish (minor features after major)

See [RELEASE.md](RELEASE.md) for the complete release process.

---

## Executive Summary

Based on analysis of three key documents:
1. **Code Duplication Detection Guide** - Systematic refactoring patterns
2. **Usage Feedback Analysis** - Why skills aren't being used
3. **Real Development Experience** - Patterns learned building a Phoenix app

**Key Finding:** Skills provide value but suffer from discoverability issues. Developers need both **automated detection** (proactive) and **better skill adoption** (preventive).

---

## Version 1.1.0 - Quick Wins (Skill Discoverability)

**Priority:** 🔴 **CRITICAL**
**Effort:** Low (8 hours)
**Impact:** High
**Target:** Next release (Week 1)

### 1.1 Update Skill Descriptions with Forcing Language

**Current Problem:** Advisory "Use when..." language feels optional, leading to low adoption.

**Solution:** Adopt mandatory "INVOKE BEFORE" language similar to superpowers skills.

**Changes Required:**

```markdown
# BEFORE
elixir-patterns: Use when writing Elixir code. Covers pattern matching, pipe operators...

# AFTER
elixir-patterns: INVOKE BEFORE writing any Elixir code. REQUIRED for pattern matching,
pipe operators, with statements, guards, list comprehensions, and naming conventions.
```

**Apply to all existing skills:**
- ✅ elixir-patterns → "INVOKE BEFORE writing any Elixir code"
- ✅ ecto-database → "INVOKE BEFORE modifying any Ecto schema, query, or migration"
- ✅ phoenix-liveview → "INVOKE BEFORE implementing any LiveView feature"
- ✅ phoenix-uploads → "INVOKE BEFORE implementing file upload functionality"
- ✅ phoenix-static-files → "INVOKE BEFORE serving uploaded files or static content"
- ✅ error-handling → "INVOKE BEFORE handling errors in Elixir"
- ✅ liveview-lifecycle → "INVOKE BEFORE working with LiveView rendering phases"

### 1.2 Add File Pattern Detection Metadata

**Current Problem:** No automatic trigger when editing relevant files.

**Solution:** Add metadata to skill definitions for file pattern matching.

**Implementation:**

```markdown
---
name: elixir-patterns
file_patterns: ["**/*.ex", "**/*.exs"]
auto_suggest: true
---

---
name: phoenix-liveview
file_patterns: ["**/live/**/*.ex", "**/*.html.heex"]
auto_suggest: true
---

---
name: ecto-database
file_patterns: ["**/schemas/**/*.ex", "**/migrations/**/*.exs", "**/repo.ex"]
auto_suggest: true
---
```

**System Behavior:**
- When user opens/modifies matching file → Display: "💡 Elixir project detected. Relevant skill: elixir-patterns"
- Hook into file read/edit operations to trigger reminders

### 1.3 Create Skill Discovery Meta-Skill

**Current Problem:** No structured way to discover applicable skills for a task.

**Solution:** Create `skill-discovery` skill that agents invoke first.

**File:** `skills/skill-discovery.md`

```markdown
---
name: skill-discovery
description: INVOKE FIRST when starting any task - identifies relevant skills based on context
priority: 1
---

# Skill Discovery Checklist

Run through this checklist to identify which skills apply to the current task.

## File Type Detection

Check what files you'll be modifying:

- [ ] Working with `.ex` or `.exs` files? → **elixir-patterns**
- [ ] Modifying Ecto schemas or queries? → **ecto-database**
- [ ] Implementing LiveView features? → **phoenix-liveview**
- [ ] Adding file upload functionality? → **phoenix-uploads**
- [ ] Serving static files? → **phoenix-static-files**
- [ ] Working with error handling? → **error-handling**
- [ ] Dealing with LiveView lifecycle? → **liveview-lifecycle**

## Task Type Detection

Identify the type of work being requested:

- [ ] New feature implementation? → **superpowers:brainstorming** first
- [ ] Bug fix or unexpected behavior? → **superpowers:systematic-debugging**
- [ ] Writing tests? → **superpowers:test-driven-development**
- [ ] Multi-step implementation? → **superpowers:writing-plans**

## Output

Based on checklist results:
1. List all identified skills
2. Invoke them in priority order (domain-specific first, then process skills)
3. Proceed with implementation using skill guidance

## Example Workflow

```
User: "Add file upload to the post creation form"

Agent runs skill-discovery:
✓ Will modify LiveView files → phoenix-liveview
✓ Adding file upload → phoenix-uploads
✓ Will need static file serving → phoenix-static-files

Agent invokes:
1. phoenix-uploads (most specific)
2. phoenix-liveview (context)
3. phoenix-static-files (supporting)
```
```

**Estimated Effort:** 2-3 hours
**Expected Impact:** 50%+ increase in skill adoption

---

## Version 1.2.0 - High-Impact Skills (Battle-Tested Patterns)

**Priority:** 🟠 **HIGH**
**Effort:** Medium (12 hours)
**Impact:** High
**Target:** Follow-up release (Week 3)

These skills represent patterns learned through 30-90 minutes of painful debugging in real development.

### 2.1 phoenix-liveview-auth

**Purpose:** Guide LiveView authentication implementation
**Pain Point:** LiveViews don't automatically inherit auth assigns from controller plugs

**Should Cover:**
- on_mount callback patterns for authentication
- current_scope vs current_user patterns
- Import conflicts between Phoenix.Controller and Phoenix.LiveView (redirect/2, put_flash/3)
- Session token extraction in LiveViews
- assign_new/3 for conditional assigns
- Testing LiveView redirects in mount/3

**Key Patterns:**
```elixir
# on_mount authentication
def on_mount(:require_authenticated_user, _params, session, socket) do
  socket = mount_current_scope(socket, session)
  if socket.assigns.current_scope && socket.assigns.current_scope.user do
    {:cont, socket}
  else
    {:halt, socket |> LiveView.put_flash(:error, "Login required") |> LiveView.redirect(to: ~p"/login")}
  end
end

# Resolving import conflicts
import Phoenix.Controller, except: [redirect: 2, put_flash: 3]
alias Phoenix.Controller
alias Phoenix.LiveView

# Safe template access
<%= if assigns[:current_scope] && @current_scope.user do %>
```

**Source:** ELIXIR_PLUGIN_IMPROVEMENTS.md W5 session notes

### 2.2 phoenix-file-uploads

**Purpose:** Comprehensive guide for LiveView file upload implementation
**Pain Point:** consume_uploaded_entries pattern not intuitive, static_paths config often missed

**Should Cover:**
- allow_upload/3 configuration in mount/3
- consume_uploaded_entries/3 processing pattern
- Converting LiveView entry to Plug.Upload struct
- Upload error handling and display
- Drag-and-drop UI patterns (phx-drop-target)
- Static file serving configuration (static_paths in web.ex)
- File validation (extension, size)
- Integration with storage modules

**Key Patterns:**
```elixir
# Configuration
socket
|> allow_upload(:photo,
  accept: ~w(.jpg .jpeg .png .heic),
  max_entries: 1,
  max_file_size: 10_485_760
)

# Processing uploads
uploaded_files =
  consume_uploaded_entries(socket, :photo, fn %{path: path}, entry ->
    upload = %Plug.Upload{
      path: path,
      filename: entry.client_name,
      content_type: entry.client_type
    }

    case Photo.store(upload) do
      {:ok, url} -> {:ok, url}
      {:error, reason} -> {:postpone, reason}
    end
  end)

# CRITICAL: Add to static_paths in lib/app_web.ex
def static_paths, do: ~w(assets fonts images uploads)
```

**Source:** ELIXIR_PLUGIN_IMPROVEMENTS.md W3, W4 session notes

### 2.3 ecto-changeset-patterns

**Purpose:** Different changeset types and composition patterns
**Pain Point:** cast_assoc foreign key requirements, conditional validation, changeset organization

**Should Cover:**
- Separate changesets for different operations (registration, update, profile, password)
- Changeset composition with pipe operator
- Conditional validation with opts pattern
- unsafe_validate_unique + unique_constraint combo
- CRITICAL: cast_assoc and required fields (don't require foreign keys!)
- update_change/3 for field transformations
- Validation helpers organization

**Key Patterns:**
```elixir
# Separate changesets
def registration_changeset(user, attrs, opts \\ [])
def email_changeset(user, attrs)
def password_changeset(user, attrs)
def profile_changeset(user, attrs)

# Conditional validation
defp maybe_validate_unique_username(changeset, opts) do
  if Keyword.get(opts, :validate_unique, true) do
    changeset
    |> unsafe_validate_unique(:username, Repo)
    |> unique_constraint(:username)
  else
    changeset
  end
end

# CRITICAL: cast_assoc pattern - DON'T require foreign keys
def changeset(ingredient, attrs) do
  ingredient
  |> cast(attrs, [:name, :quantity, :unit, :order, :post_id])
  |> validate_required([:name])  # NOT :post_id - set automatically!
end
```

**Source:** ELIXIR_PLUGIN_IMPROVEMENTS.md W1, W2 session notes

### 2.4 phoenix-auth-customization

**Purpose:** Extending phx.gen.auth with custom fields
**Pain Point:** Migration patterns, fixture updates, password vs magic link conflicts

**Should Cover:**
- Running phx.gen.auth with correct arguments
- Creating separate migrations for custom fields (never modify generated migrations)
- Updating User.registration_changeset for new fields
- Username validation patterns (length, format, uniqueness)
- Test fixture updates when adding required fields
- Password vs magic link authentication modes
- Confirming users in fixtures for password-based auth
- Handling incompatible generated tests (@tag :skip)

**Key Patterns:**
```elixir
# Migration for custom fields
mix ecto.gen.migration add_profile_fields_to_users

# Username validation
defp validate_username(changeset, opts) do
  changeset
  |> validate_required([:username])
  |> validate_length(:username, min: 3, max: 30)
  |> validate_format(:username, ~r/^[a-zA-Z0-9_]+$/,
    message: "must contain only letters, numbers, and underscores"
  )
  |> maybe_validate_unique_username(opts)
end

# Fixture for password-based auth
def user_fixture(attrs \\ %{}) do
  {:ok, user} =
    attrs
    |> Enum.into(%{
      email: unique_user_email(),
      username: unique_user_username(),
      password: "hello world!"
    })
    |> Accounts.register_user()

  # Confirm user for password-based auth
  {:ok, user} =
    user
    |> Ecto.Changeset.change(%{confirmed_at: DateTime.utc_now(:second)})
    |> Repo.update()

  user
end
```

**Source:** ELIXIR_PLUGIN_IMPROVEMENTS.md W1 session notes

**Estimated Effort:** 8-12 hours (2-3 hours per skill)
**Expected Impact:** Saves 30-90 min debugging per pattern

---

## Version 2.0.0 - Automation (Code Quality Detection)

**Priority:** 🟡 **MEDIUM**
**Effort:** High (60 hours)
**Impact:** Very High
**Target:** Major feature release (Month 2)

**Note:** Major version bump due to significant new automation features.

Based on the refactoring guide analysis showing ~500+ lines of duplicated code eliminated.

### 3.1 Code Duplication Detection System

**Purpose:** Automatically detect duplicated functions across modules

**Detection Rules:**
- **Threshold:** 2+ files share >70% identical function implementations
- **Confidence:** High when 3+ files share the same pattern
- **Action:** Suggest creating shared module with concrete refactoring example

**What to Detect:**
```elixir
# Pattern: Same private helper in 3+ LiveView modules
# In cycle_time.ex, lead_time.ex, wait_time.ex
defp format_time(%Decimal{} = seconds) do
  seconds |> Decimal.to_float() |> format_time()
end

defp format_time(seconds) when is_number(seconds) do
  # ... 20 lines of formatting logic ...
end

# Detection Output:
# ⚠️  Duplication Detected
# Function `format_time/1` found in 3 modules:
#   - lib/app_web/live/cycle_time.ex:45
#   - lib/app_web/live/lead_time.ex:52
#   - lib/app_web/live/wait_time.ex:48
#
# 💡 Suggestion: Extract to shared module
# Create: lib/app_web/live/helpers.ex
# Move: format_time/1, format_datetime/1, parse_time_range/1
# Impact: -370 lines of duplicated code
```

**Implementation Approach:**
1. AST-based similarity analysis using Elixir parser
2. Track function signatures and bodies
3. Generate similarity score (0-100%)
4. Flag when threshold exceeded

### 3.2 Template Duplication Detection

**Purpose:** Detect duplicated HEEx markup across templates

**Detection Rules:**
- **Threshold:** 2+ templates share >50 consecutive identical lines
- **Confidence:** Very high when class names and structure match exactly
- **Action:** Suggest extracting to function component

**What to Detect:**
```heex
<!-- In cycle_time.html.heex and lead_time.html.heex -->
<!-- 86 identical lines of filter UI -->
<div class="mt-8 bg-gradient-to-br from-white via-indigo-50/30...">
  <form phx-change="filter_change">
    <!-- ... -->
  </form>
</div>

# Detection Output:
# ⚠️  Template Duplication Detected
# 86 identical lines in:
#   - lib/app_web/live/cycle_time.html.heex:12-98
#   - lib/app_web/live/lead_time.html.heex:15-101
#
# 💡 Suggestion: Extract to function component
# Create: lib/app_web/live/components.ex
# Component: metric_filters/1
# Impact: -172 lines, improved maintainability
```

### 3.3 ABC Complexity Analyzer

**Purpose:** Flag functions exceeding complexity thresholds

**Detection Rules:**
- **Threshold:** Function ABC complexity > 30 (configurable)
- **Action:** Suggest breaking into smaller helper functions
- **Integration:** Based on Credo complexity analysis

**What to Detect:**
```elixir
def calculate_trend_line(daily_times) do
  # ABC Complexity: 41 (exceeds threshold of 30)
  # ... complex nested logic ...
end

# Detection Output:
# ⚠️  High Complexity Detected
# Function `calculate_trend_line/1` has ABC complexity of 41 (threshold: 30)
# Location: lib/app_web/live/helpers.ex:45
#
# 💡 Suggestion: Break into smaller functions
# Extract: calculate_regression_sums/1
# Extract: calculate_slope/5
# Extract: calculate_intercept/4
# Target: <20 complexity per function
```

### 3.4 Unused Function Detection

**Purpose:** Detect unused private functions after refactoring

**Detection Rules:**
- **Threshold:** Private functions never called
- **Action:** Suggest removal
- **Integration:** Based on compiler warnings

**Invocation Triggers:**
1. **On File Save:** Detect duplication in the file being edited
2. **On Module Creation:** Warn if creating LiveView similar to existing ones
3. **On Template Edit:** Detect markup duplication
4. **On CI/CD:** Run as quality check before merge
5. **On Demand:** Via `mix elixir_optimization.analyze`

**Estimated Effort:** 40-60 hours
**Expected Impact:** Prevents 500+ lines of duplicated code per project

---

## Version 2.1.0 - Additional Skills & Hooks

**Priority:** 🟢 **LOW-MEDIUM**
**Effort:** Medium (24 hours)
**Impact:** Medium
**Target:** Polish release (Month 3)

### 4.1 phoenix-pubsub-patterns

**Purpose:** Guide for real-time updates with PubSub

**Should Cover:**
- connected?/1 guard usage (prevent duplicate subscriptions)
- Topic naming conventions ("resource:action")
- Broadcasting from contexts
- Handling real-time updates in LiveView
- Testing PubSub interactions

**Key Patterns:**
```elixir
# Subscribe only on connected socket
def mount(_params, _session, socket) do
  if connected?(socket) do
    Phoenix.PubSub.subscribe(MyApp.PubSub, "posts:new")
  end
  {:ok, assign(socket, :posts, list_posts())}
end

# Broadcast from context
Phoenix.PubSub.broadcast(
  MyApp.PubSub,
  "posts:new",
  {:new_post, post}
)

# Handle in LiveView
def handle_info({:new_post, post}, socket) do
  posts = [post | socket.assigns.posts]
  {:noreply, assign(socket, :posts, posts)}
end
```

### 4.2 phoenix-authorization-patterns

**Purpose:** Implementing authorization in Phoenix applications

**Should Cover:**
- Owner-only actions pattern
- Authorization in event handlers (always verify server-side)
- Policy modules pattern
- Role-based access control
- data-confirm for destructive actions
- Testing authorization

**Key Patterns:**
```elixir
# UI-level check (not security, just UX)
<%= if assigns[:current_scope] && @current_scope.user && @current_scope.user.id == @post.user_id do %>
  <.button phx-click="delete" data-confirm="Are you sure?">Delete</.button>
<% end %>

# Server-side authorization (CRITICAL)
def handle_event("delete", _params, socket) do
  if socket.assigns.current_scope.user.id == socket.assigns.post.user_id do
    # Allow deletion
  else
    {:noreply, put_flash(socket, :error, "Not authorized")}
  end
end
```

### 4.3 ecto-nested-associations

**Purpose:** Creating schemas with nested associations

**Should Cover:**
- Order of operations for related schemas
- Using cast_assoc and cast_embed
- Handling one-to-many relationships
- Transaction patterns with Ecto.Multi
- Migration patterns for related tables
- Foreign key cascade rules (on_delete: :delete_all vs :nothing)

**Key Patterns:**
```elixir
# Parent reference - don't cascade
add :user_id, references(:users, on_delete: :nothing)

# Child reference - cascade delete
add :post_id, references(:posts, on_delete: :delete_all)

# Ecto.Multi for nested creation
Multi.new()
|> Multi.insert(:parent, changeset)
|> Multi.insert_all(:children, Child, fn %{parent: parent} ->
  build_children(parent, attrs)
end)
|> Repo.transaction()
```

### 4.4 Hooks System

**Pre-Migration Hook**
```bash
#!/bin/bash
# Check for missing indexes on foreign keys
# Validate on_delete strategies
# Warn about missing timestamps
```

**Pre-Commit Hook**
```bash
#!/bin/bash
# Run mix format --check-formatted
# Run mix compile --warnings-as-errors
# Run mix credo --strict
```

**Project Initialization Hook**
```bash
#!/bin/bash
# Check for .tool-versions and warn if missing
# Verify Phoenix version compatibility
# Check database connection
```

**Estimated Effort:** 16-20 hours
**Expected Impact:** Moderate - helps avoid common mistakes

---

## Lower Priority Items

### 5.1 phoenix-project-init

**Purpose:** Guide initial Phoenix project setup
**Why Lower Priority:** Only needed once per project

**Should Cover:**
- phoenix.new with correct flags (--live, --database postgres)
- .tool-versions setup for asdf
- mix.exs initial dependencies
- Database configuration

### 5.2 Pattern Templates Library

**Purpose:** Reusable code snippets for common patterns

**Templates to Include:**
- Soft delete pattern
- Filename generation for uploads
- Tag normalization
- Username validation
- Grid layout for photo galleries
- Placeholder avatars with initials

---

## Implementation Recommendations

### Phase 1: Foundation (v1.1.0)
**Timeline:** 1 week
**Focus:** Make existing skills discoverable
**Type:** Minor release (new features, backward-compatible)

1. Update all skill descriptions → 2 hours
2. Add file pattern metadata → 2 hours
3. Create skill-discovery skill → 3 hours
4. Test and iterate → 1 hour

**Success Metric:** 50%+ increase in skill usage

### Phase 2: Content (v1.2.0)
**Timeline:** 2 weeks
**Focus:** Add battle-tested patterns
**Type:** Minor release (new features, backward-compatible)

1. phoenix-liveview-auth → 3 hours
2. phoenix-file-uploads → 3 hours
3. ecto-changeset-patterns → 3 hours
4. phoenix-auth-customization → 3 hours

**Success Metric:** Users report fewer auth/upload/changeset errors

### Phase 3: Automation (v2.0.0)
**Timeline:** 4-6 weeks
**Focus:** Build detection system
**Type:** Major release (major new features, potential breaking changes)

1. Code duplication detection → 20 hours
2. Template duplication detection → 15 hours
3. ABC complexity analyzer → 10 hours
4. Integration and testing → 15 hours

**Success Metric:** Detect 80%+ of duplication cases automatically

### Phase 4: Polish (v2.1.0)
**Timeline:** 2-3 weeks
**Focus:** Additional skills and hooks
**Type:** Minor release (new features after major bump)

1. Create remaining skills → 12 hours
2. Implement hooks → 8 hours
3. Documentation and examples → 4 hours

**Success Metric:** Comprehensive coverage of Phoenix development patterns

---

## Key Success Factors

### What Makes This Different

The combination of three approaches:

1. **Proactive (Detection)** - Automatically find issues in existing code
2. **Preventive (Skills)** - Teach patterns upfront before mistakes happen
3. **Enforced (Forcing Functions)** - Ensure skills are actually used

### Critical Insights from Analysis

> "Skills weren't used even when directly applicable. The improvements doc shows exactly what patterns developers actually need in the trenches."

**The Problem:** Skills are valuable but suffer from:
- Discoverability issues (no one knows they exist)
- Continuation bias (skipped in ongoing work)
- Advisory language (feels optional)

**The Solution:**
- Auto-suggest based on file patterns
- Force invocation with mandatory language
- Cross-reference in related skills

### What NOT to Do (Antipatterns)

- ❌ **Don't make skills too advisory** - Forcing language works better
- ❌ **Don't create skills in isolation** - Cross-reference them
- ❌ **Don't rely on users to discover** - Build automated triggers
- ❌ **Don't ignore real usage data** - The session notes are gold

---

## Metrics & Success Criteria

### v1.1.0 Success Metrics
- [ ] Skill invocation rate increases by 50%+
- [ ] File pattern detection works for .ex, .exs, .heex files
- [ ] skill-discovery used in 80%+ of new tasks

### v1.2.0 Success Metrics
- [ ] Auth implementation time reduced by 50%
- [ ] File upload issues decrease by 70%
- [ ] cast_assoc errors eliminated
- [ ] Positive user feedback on new skills

### v2.0.0 Success Metrics
- [ ] Detects 80%+ of code duplication cases
- [ ] Identifies 90%+ of high-complexity functions
- [ ] Saves 100+ lines per project on average
- [ ] Zero false positives in duplication detection

### v2.1.0 Success Metrics
- [ ] Comprehensive Phoenix pattern coverage
- [ ] Pre-commit hooks prevent 80%+ of style issues
- [ ] Positive community feedback

---

## Sources

This roadmap is based on analysis of:

1. **elixir-optimization-plugin-refactoring.md** - Code duplication detection guide showing ~500 lines eliminated through systematic refactoring
2. **elixir-optimization-plugin-feedback.md** - Root cause analysis of why skills weren't being used during development
3. **ELIXIR_PLUGIN_IMPROVEMENTS.md** - Real development experience from building Trays Social app with 7 weeks of detailed session notes

---

## Next Steps

1. **Review and approve** this roadmap
2. **Prioritize** which version to start with (recommend v1.1.0 for quick wins)
3. **Create issues** for each major feature
4. **Begin implementation** with skill discoverability improvements
5. **Follow release process** in RELEASE.md when shipping each version

---

**Maintainer Notes:**
- Keep this document updated as features are implemented
- Mark completed items with ✅
- Add new insights from ongoing development
- Review priorities quarterly based on user feedback
