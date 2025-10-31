# PolySynergy Dynamic Content System - Architecture

## Overview

A Craft CMS-inspired dynamic content management system for PolySynergy that allows users to:
- Define custom field types as plugins (like nodes)
- Create sections (forms) that become real PostgreSQL tables
- Manage data through auto-generated forms and table views
- Handle database migrations semi-automatically

## Core Concepts

### 1. Field Types (Plugin System)
Field types define **what can be configured** - validation methods, UI rendering, database storage.

### 2. Sections
Sections define **actual database tables** in the `custom` schema. Each section:
- Has a configuration (which fields, layout, etc.)
- Creates a real PostgreSQL table: `custom.{table_name}`
- Generates forms for data entry
- Generates table views for data display

### 3. Section Fields
Section fields combine field types with layout configuration:
- **Field Type**: What kind of data (text, number, relation, etc.)
- **Layout**: Where in the form (tab, width, order)
- **Validation**: Required, unique, custom rules

---

## Architecture Decisions

✅ **Field types as Python classes** - `@field_type` decorator + `FieldType` base class (like nodes)
✅ **Semi-automatic migrations** - Generate SQL → User reviews → User applies
✅ **Schema separation** - User tables in `custom.{handle}` schema
✅ **No versioning** - Metadata in Supabase, code in git repos

---

## Module Structure

### New Git Submodule: `section_field`

Located at: `orchestrator/section_field/` (separate git repo as submodule)

```
section_field/
├── pyproject.toml
├── README.md
├── polysynergy_section_field/
│   ├── __init__.py                    # registered_field_types = [...]
│   │
│   ├── field_types/                   # Field type implementations
│   │   ├── text/
│   │   │   ├── text.py
│   │   │   ├── text_area.py
│   │   │   └── __init__.py
│   │   ├── number/
│   │   │   ├── number.py
│   │   │   ├── integer.py
│   │   │   ├── decimal.py
│   │   │   └── __init__.py
│   │   ├── boolean/
│   │   │   └── boolean.py
│   │   ├── date/
│   │   │   ├── date.py
│   │   │   ├── datetime.py
│   │   │   └── time.py
│   │   ├── select/
│   │   │   ├── select.py
│   │   │   └── multi_select.py
│   │   ├── relation/
│   │   │   └── relation.py
│   │   └── advanced/
│   │       ├── json.py
│   │       ├── email.py
│   │       └── url.py
│   │
│   └── section_field_runner/          # Base classes (like node_runner)
│       ├── __init__.py
│       ├── base_field_type.py         # FieldType base class
│       ├── field_type_decorator.py    # @field_type decorator
│       ├── field_type_settings.py     # Settings configuration
│       └── validation/
│           ├── validators.py          # Common validators
│           └── validation_rules.py    # Validation rule system
└── tests/
```

---

## Field Type System

### Base Field Type Class

```python
# section_field_runner/base_field_type.py
from abc import ABC, abstractmethod
from typing import Any, Dict, Optional, Tuple

class FieldType(ABC):
    """Base class for all field types"""

    @property
    @abstractmethod
    def handle(self) -> str:
        """Unique identifier (e.g., 'text', 'number', 'relation')"""
        pass

    @property
    @abstractmethod
    def label(self) -> str:
        """Human-readable label for UI"""
        pass

    @property
    @abstractmethod
    def postgres_type(self) -> str:
        """
        PostgreSQL column type for migrations.
        Examples: 'TEXT', 'INTEGER', 'TIMESTAMP WITH TIME ZONE', 'UUID'
        """
        pass

    @property
    def ui_component(self) -> str:
        """
        Frontend UI component identifier.
        Used by frontend to determine which component to render.
        Examples: 'text-input', 'number-input', 'date-picker', 'relation-select'
        """
        return "text-input"  # default fallback

    @property
    def category(self) -> str:
        """Field type category for UI grouping"""
        return "general"

    @property
    def icon(self) -> Optional[str]:
        """Icon filename for UI"""
        return None

    @property
    def settings_schema(self) -> Optional[Dict]:
        """
        JSON Schema defining field-specific settings.

        Example for text field:
        {
            "type": "object",
            "properties": {
                "maxLength": {"type": "integer", "minimum": 1},
                "minLength": {"type": "integer", "minimum": 0},
                "pattern": {"type": "string"}
            }
        }
        """
        return None

    def validate(self, value: Any, settings: Dict = None) -> Tuple[bool, Optional[str]]:
        """
        Validate a value for this field type.

        Args:
            value: The value to validate
            settings: Field-specific settings from settings_schema

        Returns:
            (is_valid, error_message)
            - (True, None) if valid
            - (False, "Error message") if invalid
        """
        return (True, None)

    def serialize(self, value: Any) -> Any:
        """
        Convert Python value to database-storable format.
        Called before INSERT/UPDATE.

        Example: datetime object → ISO string
        """
        return value

    def deserialize(self, value: Any) -> Any:
        """
        Convert database value to Python format.
        Called after SELECT.

        Example: ISO string → datetime object
        """
        return value

    def get_migration_sql(self, field_name: str, settings: Dict = None, is_required: bool = False) -> str:
        """
        Generate SQL column definition for migrations.

        Args:
            field_name: Column name
            settings: Field-specific settings
            is_required: Whether field is required (NOT NULL)

        Returns:
            SQL column definition (without trailing comma)
            Example: '"company_name" TEXT NOT NULL'
        """
        sql = f'"{field_name}" {self.postgres_type}'

        if is_required:
            sql += ' NOT NULL'

        return sql

    def get_index_sql(self, table_name: str, field_name: str, settings: Dict = None) -> Optional[str]:
        """
        Generate optional index SQL for this field.

        Returns:
            SQL CREATE INDEX statement or None
        """
        return None
```

### Field Type Decorator

```python
# section_field_runner/field_type_decorator.py
def field_type(*, category: str = "general", icon: str = None):
    """
    Decorator for field type classes.

    Usage:
        @field_type(category="basic", icon="text.svg")
        class TextField(FieldType):
            handle = "text"
            label = "Plain Text"
            ...
    """
    def decorator(cls):
        cls._category = category
        cls._icon = icon
        return cls
    return decorator
```

### Example Field Type: Text

```python
# polysynergy_section_field/field_types/text/text.py
from section_field_runner.base_field_type import FieldType
from section_field_runner.field_type_decorator import field_type
from typing import Any, Dict, Optional, Tuple

@field_type(
    category="basic",
    icon="text.svg"
)
class TextField(FieldType):
    handle = "text"
    label = "Plain Text"
    postgres_type = "TEXT"
    ui_component = "text-input"

    @property
    def settings_schema(self):
        return {
            "type": "object",
            "properties": {
                "maxLength": {
                    "type": "integer",
                    "minimum": 1,
                    "title": "Maximum Length",
                    "description": "Maximum number of characters allowed"
                },
                "minLength": {
                    "type": "integer",
                    "minimum": 0,
                    "title": "Minimum Length",
                    "description": "Minimum number of characters required"
                },
                "pattern": {
                    "type": "string",
                    "title": "Regex Pattern",
                    "description": "Regular expression for validation"
                }
            }
        }

    def validate(self, value: Any, settings: Dict = None) -> Tuple[bool, Optional[str]]:
        if value is None:
            return (True, None)  # NULL is valid (unless field is required)

        if not isinstance(value, str):
            return (False, "Value must be a string")

        if settings:
            max_len = settings.get("maxLength")
            min_len = settings.get("minLength")
            pattern = settings.get("pattern")

            if max_len is not None and len(value) > max_len:
                return (False, f"Text too long (maximum {max_len} characters)")

            if min_len is not None and len(value) < min_len:
                return (False, f"Text too short (minimum {min_len} characters)")

            if pattern:
                import re
                if not re.match(pattern, value):
                    return (False, "Text does not match required pattern")

        return (True, None)

    def get_migration_sql(self, field_name: str, settings: Dict = None, is_required: bool = False) -> str:
        max_len = settings.get("maxLength") if settings else None

        if max_len:
            sql = f'"{field_name}" VARCHAR({max_len})'
        else:
            sql = f'"{field_name}" TEXT'

        if is_required:
            sql += ' NOT NULL'

        return sql
```

### Example Field Type: Relation

```python
# polysynergy_section_field/field_types/relation/relation.py
from section_field_runner.base_field_type import FieldType
from section_field_runner.field_type_decorator import field_type
from typing import Any, Dict, Optional, Tuple

@field_type(
    category="relational",
    icon="link.svg"
)
class RelationField(FieldType):
    handle = "relation"
    label = "Relation"
    postgres_type = "UUID"  # Stores foreign key
    ui_component = "relation-select"

    @property
    def settings_schema(self):
        return {
            "type": "object",
            "required": ["targetSection"],
            "properties": {
                "targetSection": {
                    "type": "string",
                    "title": "Target Section",
                    "description": "Handle of the section to relate to"
                },
                "allowMultiple": {
                    "type": "boolean",
                    "title": "Allow Multiple",
                    "default": False,
                    "description": "Allow selecting multiple related entries"
                },
                "maxItems": {
                    "type": "integer",
                    "minimum": 1,
                    "title": "Maximum Items",
                    "description": "Maximum number of related entries (when multiple allowed)"
                }
            }
        }

    def validate(self, value: Any, settings: Dict = None) -> Tuple[bool, Optional[str]]:
        if value is None:
            return (True, None)

        # Validate UUID format
        import uuid
        try:
            if isinstance(value, str):
                uuid.UUID(value)
            elif not isinstance(value, uuid.UUID):
                return (False, "Value must be a valid UUID")
        except ValueError:
            return (False, "Invalid UUID format")

        return (True, None)

    def get_migration_sql(self, field_name: str, settings: Dict = None, is_required: bool = False) -> str:
        sql = f'"{field_name}" UUID'

        if is_required:
            sql += ' NOT NULL'

        # Add foreign key constraint
        if settings and settings.get("targetSection"):
            target_section = settings["targetSection"]
            sql += f' REFERENCES custom.{target_section}(id) ON DELETE SET NULL'

        return sql

    def get_index_sql(self, table_name: str, field_name: str, settings: Dict = None) -> Optional[str]:
        # Create index for foreign key for better query performance
        return f'CREATE INDEX idx_{table_name}_{field_name} ON custom.{table_name}("{field_name}");'
```

---

## Database Schema (Supabase)

### System Tables (in `public` schema)

```sql
-- ========================================
-- Field Type Registry
-- Auto-populated by system on startup
-- ========================================
CREATE TABLE field_type_registry (
    handle TEXT PRIMARY KEY,
    label TEXT NOT NULL,
    postgres_type TEXT NOT NULL,
    ui_component TEXT NOT NULL,
    settings_schema JSONB,
    category TEXT NOT NULL DEFAULT 'general',
    icon TEXT,
    version TEXT,
    registered_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- ========================================
-- Sections
-- Each section = one table in custom schema
-- ========================================
CREATE TABLE sections (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    handle TEXT NOT NULL UNIQUE,
    label TEXT NOT NULL,
    description TEXT,
    icon TEXT,

    -- Table information
    table_name TEXT NOT NULL UNIQUE, -- Name in custom schema (same as handle)
    title_field_handle TEXT, -- Which field to use as title/identifier

    -- Status
    is_active BOOLEAN DEFAULT TRUE,
    migration_status TEXT DEFAULT 'pending', -- pending, migrated, failed
    last_migration_id UUID,

    -- Metadata
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),

    CONSTRAINT valid_handle CHECK (handle ~ '^[a-z][a-z0-9_]*$')
);

-- ========================================
-- Section Fields
-- Field configuration per section
-- ========================================
CREATE TABLE section_fields (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    section_id UUID NOT NULL REFERENCES sections(id) ON DELETE CASCADE,

    -- Field definition
    handle TEXT NOT NULL, -- Column name in table (e.g., 'company_name')
    label TEXT NOT NULL, -- Human-readable label
    field_type_handle TEXT NOT NULL REFERENCES field_type_registry(handle),

    -- Field settings (from field type's settings_schema)
    field_settings JSONB DEFAULT '{}',
    default_value TEXT,
    help_text TEXT,
    placeholder TEXT,

    -- Validation
    is_required BOOLEAN DEFAULT FALSE,
    is_unique BOOLEAN DEFAULT FALSE,
    custom_validation_rules JSONB, -- Additional validation beyond field type

    -- UI/Layout
    ui_width TEXT DEFAULT 'full', -- full, half, third, quarter
    tab_name TEXT DEFAULT 'Content',
    sort_order INTEGER DEFAULT 0,
    is_visible BOOLEAN DEFAULT TRUE,

    -- Relations (for relation field type)
    related_section_id UUID REFERENCES sections(id),

    -- Metadata
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),

    CONSTRAINT valid_field_handle CHECK (handle ~ '^[a-z][a-z0-9_]*$'),
    UNIQUE(section_id, handle)
);

-- ========================================
-- Section Migrations
-- Track generated and applied migrations
-- ========================================
CREATE TABLE section_migrations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    section_id UUID NOT NULL REFERENCES sections(id) ON DELETE CASCADE,

    -- Migration details
    migration_type TEXT NOT NULL, -- create_table, add_field, modify_field, drop_field
    migration_sql TEXT NOT NULL,
    description TEXT,

    -- Status tracking
    status TEXT NOT NULL DEFAULT 'generated', -- generated, applied, failed, rolled_back
    error_message TEXT,

    -- Audit
    generated_by TEXT,
    applied_by TEXT,
    generated_at TIMESTAMP DEFAULT NOW(),
    applied_at TIMESTAMP,

    -- Version tracking
    version INTEGER NOT NULL
);

-- ========================================
-- Indexes
-- ========================================
CREATE INDEX idx_sections_handle ON sections(handle);
CREATE INDEX idx_sections_active ON sections(is_active);
CREATE INDEX idx_section_fields_section ON section_fields(section_id);
CREATE INDEX idx_section_fields_type ON section_fields(field_type_handle);
CREATE INDEX idx_section_migrations_section ON section_migrations(section_id);
CREATE INDEX idx_section_migrations_status ON section_migrations(status);

-- ========================================
-- Create custom schema for user tables
-- ========================================
CREATE SCHEMA IF NOT EXISTS custom;
COMMENT ON SCHEMA custom IS 'User-generated content tables from sections';
```

### User Tables (in `custom` schema)

User tables are **dynamically created** based on section configuration.

**Example: Research Companies Section**

```sql
-- Generated from section configuration
CREATE TABLE custom.research_companies (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    -- User-defined fields (from section_fields)
    company_name TEXT NOT NULL,
    uses_kubernetes BOOLEAN DEFAULT FALSE,
    kubernetes_confidence TEXT,
    industry TEXT,
    company_size TEXT,
    outreach_suggestion TEXT,

    -- System metadata (always included)
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_research_companies_created ON custom.research_companies(created_at);
CREATE INDEX idx_research_companies_updated ON custom.research_companies(updated_at);
CREATE INDEX idx_research_companies_name ON custom.research_companies(company_name);
```

**For sections with relations:**

Separate junction tables for many-to-many relations:

```sql
-- If a section has a multi-relation field
CREATE TABLE custom.research_companies_contacts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    source_id UUID NOT NULL REFERENCES custom.research_companies(id) ON DELETE CASCADE,
    target_id UUID NOT NULL REFERENCES custom.contacts(id) ON DELETE CASCADE,
    sort_order INTEGER DEFAULT 0,

    UNIQUE(source_id, target_id)
);
```

---

## Migration System

### Migration Generator

The migration generator creates SQL based on section configuration changes.

```python
class MigrationGenerator:
    """Generate SQL migrations for section changes"""

    def generate_create_table(self, section_id: UUID) -> str:
        """Generate CREATE TABLE for new section"""
        section = self.get_section(section_id)
        fields = self.get_section_fields(section_id)

        field_definitions = []
        indexes = []

        # System fields (always included)
        field_definitions.append('id UUID PRIMARY KEY DEFAULT gen_random_uuid()')

        # User-defined fields
        for field in sorted(fields, key=lambda f: f.sort_order):
            field_type = self.get_field_type(field.field_type_handle)

            field_sql = field_type.get_migration_sql(
                field_name=field.handle,
                settings=field.field_settings,
                is_required=field.is_required
            )

            if field.is_unique:
                field_sql += ' UNIQUE'

            if field.default_value:
                field_sql += f" DEFAULT {field.default_value}"

            field_definitions.append(field_sql)

            # Generate indexes if field type provides them
            index_sql = field_type.get_index_sql(
                table_name=section.table_name,
                field_name=field.handle,
                settings=field.field_settings
            )
            if index_sql:
                indexes.append(index_sql)

        # System metadata fields
        field_definitions.extend([
            'created_at TIMESTAMP DEFAULT NOW()',
            'updated_at TIMESTAMP DEFAULT NOW()'
        ])

        # Build CREATE TABLE statement
        sql_parts = [
            f"-- Create table for section: {section.label}",
            f"CREATE TABLE custom.{section.table_name} (",
            ",\n    ".join(f"    {fd}" for fd in field_definitions),
            ");",
            "",
            "-- System indexes",
            f"CREATE INDEX idx_{section.table_name}_created ON custom.{section.table_name}(created_at);",
            f"CREATE INDEX idx_{section.table_name}_updated ON custom.{section.table_name}(updated_at);"
        ]

        # Add field-specific indexes
        if indexes:
            sql_parts.append("")
            sql_parts.append("-- Field indexes")
            sql_parts.extend(indexes)

        return "\n".join(sql_parts)

    def generate_add_field(self, section_id: UUID, field_id: UUID) -> str:
        """Generate ALTER TABLE ADD COLUMN for new field"""
        section = self.get_section(section_id)
        field = self.get_section_field(field_id)
        field_type = self.get_field_type(field.field_type_handle)

        field_sql = field_type.get_migration_sql(
            field_name=field.handle,
            settings=field.field_settings,
            is_required=False  # Can't add NOT NULL to existing table without default
        )

        sql_parts = [
            f"-- Add field '{field.label}' to {section.label}",
            f"ALTER TABLE custom.{section.table_name}",
            f"ADD COLUMN {field_sql};"
        ]

        # Add index if needed
        index_sql = field_type.get_index_sql(
            table_name=section.table_name,
            field_name=field.handle,
            settings=field.field_settings
        )
        if index_sql:
            sql_parts.append("")
            sql_parts.append(index_sql)

        return "\n".join(sql_parts)

    def generate_drop_field(self, section_id: UUID, field_handle: str) -> str:
        """Generate ALTER TABLE DROP COLUMN"""
        section = self.get_section(section_id)

        return f"""-- Remove field '{field_handle}' from {section.label}
ALTER TABLE custom.{section.table_name}
DROP COLUMN "{field_handle}";"""

    def generate_modify_field(self, section_id: UUID, field_id: UUID, changes: Dict) -> str:
        """Generate ALTER TABLE ALTER COLUMN for field modifications"""
        section = self.get_section(section_id)
        field = self.get_section_field(field_id)

        sql_parts = [f"-- Modify field '{field.label}' in {section.label}"]

        if 'type_change' in changes:
            # Type change requires USING clause
            new_type = changes['type_change']
            sql_parts.append(
                f"ALTER TABLE custom.{section.table_name}\n"
                f"ALTER COLUMN \"{field.handle}\" TYPE {new_type} USING \"{field.handle}\"::{new_type};"
            )

        if 'required_change' in changes:
            if changes['required_change']:
                sql_parts.append(
                    f"ALTER TABLE custom.{section.table_name}\n"
                    f"ALTER COLUMN \"{field.handle}\" SET NOT NULL;"
                )
            else:
                sql_parts.append(
                    f"ALTER TABLE custom.{section.table_name}\n"
                    f"ALTER COLUMN \"{field.handle}\" DROP NOT NULL;"
                )

        if 'default_change' in changes:
            new_default = changes['default_change']
            if new_default is not None:
                sql_parts.append(
                    f"ALTER TABLE custom.{section.table_name}\n"
                    f"ALTER COLUMN \"{field.handle}\" SET DEFAULT {new_default};"
                )
            else:
                sql_parts.append(
                    f"ALTER TABLE custom.{section.table_name}\n"
                    f"ALTER COLUMN \"{field.handle}\" DROP DEFAULT;"
                )

        return "\n".join(sql_parts)
```

### Migration Flow

1. **User modifies section** in UI (add/remove/modify fields)
2. **System detects changes** and calls MigrationGenerator
3. **SQL is generated** and saved to `section_migrations` table with status='generated'
4. **User reviews SQL** in UI
5. **User clicks "Apply Migration"**
6. **System executes SQL** via PostgreSQL connection
7. **Migration status updated** to 'applied' or 'failed'
8. **Section migration_status updated** to 'migrated'

---

## PolySynergy Nodes

New nodes for managing the content system:

### Section Management Nodes

**1. Section Create**
```
Inputs:
  - handle (text)
  - label (text)
  - description (text, optional)
  - icon (text, optional)

Outputs:
  - section_id (uuid)
  - table_name (text)

Creates new section and generates initial CREATE TABLE migration.
```

**2. Section Field Add**
```
Inputs:
  - section_id (uuid)
  - field_handle (text)
  - field_label (text)
  - field_type_handle (text)
  - field_settings (json)
  - is_required (boolean)
  - is_unique (boolean)
  - ui_width (select)
  - tab_name (text)

Outputs:
  - field_id (uuid)
  - migration_id (uuid)

Adds field to section and generates ALTER TABLE migration.
```

**3. Section Field Remove**
```
Inputs:
  - section_id (uuid)
  - field_handle (text)

Outputs:
  - migration_id (uuid)

Removes field from section and generates DROP COLUMN migration.
```

**4. Section Field Update**
```
Inputs:
  - field_id (uuid)
  - updates (json) - what to change

Outputs:
  - migration_id (uuid)

Modifies field settings and generates ALTER COLUMN migration.
```

### Migration Management Nodes

**5. Migration Generate**
```
Inputs:
  - section_id (uuid)

Outputs:
  - migration_sql (text)
  - migration_id (uuid)

Generates migration SQL for current section state.
```

**6. Migration Apply**
```
Inputs:
  - migration_id (uuid)
  - confirm (boolean) - safety flag

Outputs:
  - success (boolean)
  - error_message (text, optional)

Executes migration SQL and updates status.
```

**7. Migration Rollback**
```
Inputs:
  - migration_id (uuid)

Outputs:
  - success (boolean)

Attempts to rollback a migration (dangerous).
```

### Data Entry Nodes

**8. Entry Create**
```
Inputs:
  - section_handle (text)
  - field_data (json) - key-value pairs

Outputs:
  - entry_id (uuid)
  - created_data (json)

Inserts new entry into custom table with validation.
```

**9. Entry Update**
```
Inputs:
  - section_handle (text)
  - entry_id (uuid)
  - field_data (json) - fields to update

Outputs:
  - success (boolean)
  - updated_data (json)

Updates existing entry with validation.
```

**10. Entry Query**
```
Inputs:
  - section_handle (text)
  - filters (json, optional) - WHERE conditions
  - order_by (text, optional)
  - limit (integer, optional)
  - offset (integer, optional)

Outputs:
  - entries (list[json])
  - total_count (integer)

Queries entries from custom table.
```

**11. Entry Delete**
```
Inputs:
  - section_handle (text)
  - entry_id (uuid)

Outputs:
  - success (boolean)

Deletes entry from custom table.
```

---

## Implementation Phases

### Phase 1: Foundation (Week 1-2)
- ✅ Create `section_field` git repository
- ✅ Setup as submodule in orchestrator
- ✅ Create base classes: `FieldType`, decorator, validators
- ✅ Implement basic field types: text, number, boolean, date
- ✅ Create field type registration system (like nodes)
- ✅ Write tests for field types

### Phase 2: Database Schema (Week 2-3)
- ✅ Create Supabase system tables
- ✅ Create `custom` schema
- ✅ Implement field type registry sync
- ✅ Write database migration for system tables
- ✅ Create seed data for testing

### Phase 3: Migration System (Week 3-4)
- ✅ Implement MigrationGenerator class
- ✅ Create migration templates
- ✅ Implement migration executor
- ✅ Add migration history tracking
- ✅ Build migration rollback logic (limited)
- ✅ Write tests for migration generation

### Phase 4: Management Nodes (Week 4-5)
- ✅ Implement section management nodes (create, update, delete)
- ✅ Implement field management nodes (add, remove, update)
- ✅ Implement migration nodes (generate, apply, rollback)
- ✅ Add validation and error handling
- ✅ Write node tests

### Phase 5: Data Entry Nodes (Week 5-6)
- ✅ Implement entry CRUD nodes
- ✅ Implement entry query node with filtering
- ✅ Add field validation during entry operations
- ✅ Handle relation fields properly
- ✅ Write tests for data operations

### Phase 6: Advanced Field Types (Week 6-7)
- ✅ Implement relation field type
- ✅ Implement select/multi-select field types
- ✅ Implement email, URL field types
- ✅ Implement JSON field type
- ✅ Test complex scenarios

### Phase 7: UI Integration (Week 7-8)
- ✅ Create section builder UI
- ✅ Create field configurator UI
- ✅ Create migration review/apply UI
- ✅ Create dynamic form generator
- ✅ Create table view with filtering/sorting
- ✅ Test end-to-end workflows

---

## Usage Example: Research Companies

### 1. Create Section

```python
# Using Section Create node
section_id = create_section(
    handle="research_companies",
    label="Research Companies",
    description="Companies researched for Kubernetes usage"
)
```

### 2. Add Fields

```python
# Add company name field
add_field(
    section_id=section_id,
    field_handle="company_name",
    field_label="Company Name",
    field_type_handle="text",
    field_settings={"maxLength": 200},
    is_required=True,
    is_unique=True
)

# Add kubernetes usage field
add_field(
    section_id=section_id,
    field_handle="uses_kubernetes",
    field_label="Uses Kubernetes",
    field_type_handle="boolean",
    is_required=False
)

# Add confidence level field
add_field(
    section_id=section_id,
    field_handle="kubernetes_confidence",
    field_label="Confidence Level",
    field_type_handle="select",
    field_settings={
        "options": ["hoog", "middel", "laag"]
    }
)

# Add industry field
add_field(
    section_id=section_id,
    field_handle="industry",
    field_label="Industry",
    field_type_handle="text"
)

# Add outreach field
add_field(
    section_id=section_id,
    field_handle="outreach_suggestion",
    field_label="Outreach Message",
    field_type_handle="textarea",
    field_settings={"rows": 5}
)
```

### 3. Generate & Review Migration

```python
# Generate migration SQL
migration = generate_migration(section_id=section_id)

# Review the SQL (shown in UI)
print(migration.sql)
"""
-- Create table for section: Research Companies
CREATE TABLE custom.research_companies (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    company_name VARCHAR(200) NOT NULL UNIQUE,
    uses_kubernetes BOOLEAN,
    kubernetes_confidence TEXT,
    industry TEXT,
    outreach_suggestion TEXT,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_research_companies_created ON custom.research_companies(created_at);
CREATE INDEX idx_research_companies_updated ON custom.research_companies(updated_at);
CREATE INDEX idx_research_companies_name ON custom.research_companies(company_name);
"""
```

### 4. Apply Migration

```python
# User clicks "Apply" in UI
result = apply_migration(
    migration_id=migration.id,
    confirm=True
)

# Table is now created in Supabase: custom.research_companies
```

### 5. Create Entry

```python
# Insert research data
entry_id = create_entry(
    section_handle="research_companies",
    field_data={
        "company_name": "SWIS",
        "uses_kubernetes": True,
        "kubernetes_confidence": "hoog",
        "industry": "Digital Agency",
        "outreach_suggestion": "Hi Björn, ik zag jullie Kubernetes artikelen..."
    }
)
```

### 6. Query Entries

```python
# List all companies using Kubernetes
companies = query_entries(
    section_handle="research_companies",
    filters={"uses_kubernetes": True},
    order_by="created_at DESC",
    limit=50
)

# Returns:
[
    {
        "id": "...",
        "company_name": "SWIS",
        "uses_kubernetes": True,
        "kubernetes_confidence": "hoog",
        "industry": "Digital Agency",
        "outreach_suggestion": "Hi Björn...",
        "created_at": "2025-10-31T10:30:00Z",
        "updated_at": "2025-10-31T10:30:00Z"
    },
    ...
]
```

---

## Technical Considerations

### Security

1. **SQL Injection Prevention**
   - All user input validated
   - Use parameterized queries for data operations
   - Field handles validated with regex: `^[a-z][a-z0-9_]*$`

2. **Schema Isolation**
   - User tables in separate `custom` schema
   - System tables in `public` schema
   - PostgreSQL permissions properly configured

3. **Migration Safety**
   - User review required before applying
   - Dangerous operations (DROP COLUMN) flagged
   - Rollback limited to recent changes only

### Performance

1. **Automatic Indexes**
   - created_at, updated_at always indexed
   - Unique fields automatically indexed
   - Relation fields get foreign key indexes

2. **Query Optimization**
   - Use proper WHERE clauses
   - JSONB for complex nested data (if needed)
   - Consider materialized views for complex queries

3. **Scaling**
   - Each section = separate table = better performance
   - No JSONB scanning for basic queries
   - Proper database normalization

### Limitations

1. **No Schema Versioning**
   - Can't rollback arbitrary migrations
   - Destructive changes are permanent
   - Export data before major changes

2. **Limited Type Changes**
   - Changing field type may lose data
   - Manual USING clause may be needed
   - Test in staging first

3. **No Computed Fields**
   - Fields are static, not computed
   - Use database views if needed
   - Or add computed field type in future

---

## Future Enhancements

### Phase 2 Features (Later)
- Matrix field type (repeatable blocks)
- File upload field type
- Asset manager integration
- Multi-site support
- Field groups/reusable field sets
- Entry templates
- Workflow/approval system
- Entry versioning
- Audit logging
- GraphQL API generation
- REST API generation
- Webhooks on entry changes
- Search/indexing optimization
- Import/export tools
- Field localization (i18n)

---

## Questions & Decisions Log

**Q: Why separate `custom` schema instead of prefixed tables?**
A: Clean separation, better permissions control, avoids naming conflicts, easier to backup/restore user data separately.

**Q: Why semi-automatic migrations instead of fully automatic?**
A: Safety - destructive changes (DROP COLUMN, type changes) need human review. User can test SQL first.

**Q: Why not use JSONB for all data?**
A: Performance - real columns are faster for queries, better indexes, proper data types, clearer schema.

**Q: Can we support existing tables?**
A: Future feature - "import existing table" could introspect and create section config from it.

**Q: How to handle many-to-many relations?**
A: Automatically create junction tables for multi-relation fields: `{section_a}_{field_handle}` table with source_id and target_id.

---

## Conclusion

This architecture provides a robust, scalable foundation for dynamic content management in PolySynergy. It balances flexibility (plugin field types), safety (reviewed migrations), and performance (real database tables).

Key strengths:
✅ Plugin architecture like nodes
✅ Type-safe with real PostgreSQL columns
✅ Safe migration workflow
✅ Clean schema separation
✅ Extensible field type system

Next step: Begin Phase 1 implementation!
