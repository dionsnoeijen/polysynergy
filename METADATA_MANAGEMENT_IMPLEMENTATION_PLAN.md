# Metadata Management & Knowledge Extraction Implementation Plan

## Overview
Enhance the File Manager with intuitive metadata management and create a bridge to the Agno knowledge extraction system for rich source attribution in AI agent responses.

## Problem Statement
- Current File Manager lacks metadata management capabilities
- No connection between File Manager files and Knowledge extraction
- Knowledge references show generic chunk names instead of meaningful document sources
- Need intuitive metadata management for various source types (File Manager, external sources, webhooks)

## Solution Architecture

### Current System Analysis
- **File Manager**: S3-based storage with React frontend, basic file operations
- **Knowledge System**: Agno framework with PDFUrlKnowledge, auto page extraction
- **Reference System**: Built-in source attribution needs better document metadata
- **Missing**: Bridge between File Manager files and Knowledge extraction

---

## Implementation Phases

### Phase 1: Backend Foundation

#### Step 1.1: Extend FileInfo Schema
```python
# api-local/schemas/file_manager.py
class FileInfo(BaseModel):
    name: str
    path: str
    size: int
    content_type: str
    last_modified: datetime
    url: str | None
    is_directory: bool
    # NEW: Custom metadata storage
    custom_metadata: dict[str, any] | None = Field(default_factory=dict)
```

#### Step 1.2: S3 Metadata Storage
- Implement custom metadata storage using S3 user-defined metadata (`x-amz-meta-*` headers)
- Extend `FileManagerService.get_file_metadata()` to include custom metadata
- Add metadata persistence in upload/update operations
- Maintain backwards compatibility with existing files

#### Step 1.3: Metadata Management API
```python
# api-local/api/v1/project/file_manager.py
@router.put("/metadata/{file_path:path}")
async def update_file_metadata(file_path: str, metadata: dict[str, str])

@router.get("/metadata/{file_path:path}") 
async def get_file_metadata(file_path: str)
```

#### Step 1.4: Simple Key-Value Metadata
```python
# No complex templates needed - just store metadata as dict[str, str]
# File metadata will be a simple key-value store with default fields

# Default metadata fields (auto-populated):
default_metadata = {
    "filename": file.name,  # Auto-filled with actual filename
    "filepath": file.path,  # Auto-filled with full path
    # User can add unlimited custom key-value pairs
}
```

**Metadata Storage:**
- Simple key-value pairs stored in S3 object metadata
- No complex template system needed
- Users can add/remove keys freely
- Default keys (filename, filepath) are pre-populated

---

### Phase 2: File Manager UI Enhancement

#### Step 2.1: Metadata Editor Component
```typescript
// portal/src/components/editor/file-manager/MetadataEditor.tsx
interface MetadataEditorProps {
    file: FileInfo;
    onSave: (metadata: Record<string, string>) => void;
    onClose: () => void;
}

interface MetadataKeyValue {
    key: string;
    value: string;
}
```

**Features:**
- Simple key-value pair editor
- Pre-filled with filename and filepath
- Add new key-value button
- Remove key button for each row
- Clean, intuitive interface

#### Step 2.2: Enhanced File Display
```typescript
// Extend FileGrid.tsx and FileList.tsx
- Show metadata badges/tags on file cards
- Metadata preview in hover tooltips
- Quick metadata indicators (colored dots, icons)
- Template-based file grouping/organization
```

#### Step 2.3: Metadata Search & Filtering
```typescript
// portal/src/components/editor/file-manager/MetadataFilters.tsx
- Simple key-value search (document_name=Thai Recipes)
- Filter by any metadata key
- Search across all metadata values
- Basic text matching
```

#### Step 2.4: Bulk Metadata Operations
```typescript
// portal/src/components/editor/file-manager/BulkMetadataEditor.tsx
- Select multiple files
- Add same key-value pairs to multiple files
- Batch metadata updates
- Copy metadata between files
```

---

### Phase 3: Enhanced File Selection Node

#### Step 3.1: Enhance Existing FileSelection Node
```python
# nodes/polysynergy_nodes/file/file_selection.py (existing file)
@node(
    name="File Selection",
    category="file",
    icon="file.svg",
)
class FileSelection(Node):
    selected_files: list = NodeVariableSettings(
        label="Selected Files", 
        has_in=True, 
        has_out=True,
        dock=True,
        info="List of file locations selected from the file manager"
    )
    
    file_count: int = NodeVariableSettings(
        label="File Count", 
        has_out=True,
        info="Number of selected files"
    )

    # NEW: URLs only (for regular file operations - backwards compatible)
    file_urls: list = NodeVariableSettings(
        label="File URLs",
        has_out=True,
        info="Simple list of file URLs/paths"
    )

    # NEW: Files with metadata (for knowledge extraction - Agno compatible)
    files_with_metadata: list = NodeVariableSettings(
        label="Files with Metadata",
        has_out=True,
        info="Files with metadata for knowledge base ingestion"
    )

    true_path: bool | list = PathSettings(label="Files with Metadata", info="Files with full metadata (default output)")
    false_path: bool | dict = PathSettings(label="Error", info="Triggered if no files were selected")
```

#### Step 3.2: File Manager to Agno Format Conversion
```python
def _extract_clean_filename(self, filepath: str) -> str:
    """Extract clean filename without signature/query parameters."""
    import os
    import re
    from urllib.parse import urlparse, unquote
    
    try:
        # If it's a URL, parse it
        if filepath.startswith(('http://', 'https://')):
            parsed_url = urlparse(filepath)
            path = unquote(parsed_url.path)
        else:
            path = filepath
        
        # Get basename and remove query parameters/signatures
        filename = os.path.basename(path)
        clean_name = re.split(r'[?&]', filename)[0]
        
        # If empty, use fallback
        if not clean_name or clean_name.startswith('.'):
            clean_name = "document.pdf"
            
        return clean_name
    except Exception:
        return "document.pdf"

def _get_file_manager_metadata(self, file_path: str) -> dict:
    """Get custom metadata from File Manager API."""
    # TODO: Make HTTP request to File Manager API:
    # GET /api/v1/project/file-manager/metadata/{file_path:path}
    
    # Returns the custom_metadata dict from FileInfo schema
    return {}

def execute(self):
    """Process File Manager files and provide dual outputs"""
    if not self.selected_files or len(self.selected_files) == 0:
        self.false_path = {"error": "No files selected from file manager"}
        self.file_count = 0
        self.file_urls = []
        self.files_with_metadata = []
        return
        
    # Simple URLs list (backwards compatible)
    simple_urls = []
    # Files with metadata (Agno compatible)
    files_with_metadata = []
    
    for file_path in self.selected_files:
        # Add to simple URLs list
        simple_urls.append(file_path)
        
        # Get custom metadata from File Manager API
        custom_metadata = self._get_file_manager_metadata(file_path)
        
        # Create clean filename without signatures
        clean_filename = self._extract_clean_filename(file_path)
        
        # Create Agno PDFUrlKnowledgeBase compatible format
        agno_entry = {
            "url": file_path,
            "metadata": {
                # Always include clean filename and filepath (pre-filled defaults)
                "filename": clean_filename,
                "filepath": file_path,
                # Add all custom key-value metadata from File Manager
                **custom_metadata
            }
        }
        
        files_with_metadata.append(agno_entry)
    
    # Set all outputs
    self.file_count = len(self.selected_files)
    self.file_urls = simple_urls  # Backwards compatible
    self.files_with_metadata = files_with_metadata  # For knowledge extraction
    self.true_path = files_with_metadata  # Default output with metadata
```

#### Step 3.3: Portal Integration
```typescript
// No special panel needed - existing file assignment panel works
// FileSelection node now has dual outputs:
// - file_urls: Simple URLs (backwards compatible)
// - files_with_metadata: Rich metadata for knowledge extraction
// - Clean filename display (without signatures) in file previews
```

---

### Phase 4: UI Integration & Testing

#### Step 4.1: File Manager Integration
- Add "Edit Metadata" button to file context menus
- Integrate metadata editor into file manager workflow
- Test bulk operations and search functionality

#### Step 4.2: Node Editor Integration  
- Update existing FileSelection node (no new node needed)
- Test dual output functionality: file_urls vs files_with_metadata
- Test connection to existing PDFUrlKnowledge nodes
- Verify metadata preservation through pipeline (especially filename and filepath)

#### Step 4.3: End-to-End Testing
```
Test Flow:
1. Upload PDF to File Manager
2. Edit metadata - add key-value pairs (e.g., "document_title": "AI Safety Research", "author": "Dr. Smith")
3. Verify filename and filepath are pre-filled (clean names without signatures)
4. Create FileSelection node in workflow
5. Select files - FileSelection automatically fetches metadata
6. Connect files_with_metadata output → PDFUrlKnowledge → AgentSettingsKnowledge
7. Ensure add_references=true on agent
8. Query agent about document content
9. Verify response shows: clean filename, custom metadata, and page numbers from PDF reader
```

#### Step 4.4: Backwards Compatibility
- Test existing FileSelection nodes still work
- Verify files without metadata work correctly
- Ensure existing knowledge bases continue functioning
- Test migration path for existing files

---

### Phase 5: Advanced Features (Future)

#### Step 5.1: Metadata Auto-Extraction
```python
# Auto-extract metadata using LLM
def extract_metadata_from_content(file_content: str, template: str) -> dict[str, any]:
    """Use LLM to extract structured metadata from document content"""
    # Implement LLM-based extraction for titles, authors, topics, etc.
    pass
```

#### Step 5.2: External Integration
- Webhook metadata processing for external sources
- CSV/Excel-based bulk metadata import
- API integration with external document management systems
- Metadata synchronization with cloud storage providers

#### Step 5.3: Analytics & Insights
- Metadata usage analytics dashboard  
- Tag clouds and relationship visualization
- Document similarity based on metadata
- Knowledge base health metrics

---

## Expected Outcomes

### User Experience Flow
```
1. User uploads "AI_Safety_Research.pdf" to File Manager
2. User clicks "Edit Metadata" button
3. Metadata editor opens with pre-filled fields:
   - filename: "AI_Safety_Research.pdf" (auto-filled clean name, can be edited)
   - filepath: "/documents/research/AI_Safety_Research.pdf" (auto-filled)
4. User adds custom key-value pairs:
   - document_title: "AI Safety in Large Language Models"
   - author: "Dr. Smith, Dr. Johnson"
   - topic: "AI Safety, LLM"
   - year: "2024"
5. User can remove any key or add more as needed
6. User creates FileSelection node in workflow (same node as before)
7. User selects file - FileSelection automatically fetches metadata
8. User connects files_with_metadata → PDFUrlKnowledge → AgentSettingsKnowledge
9. Agent query: "What does the research say about AI safety?"
10. Agent response: "According to 'AI Safety in Large Language Models' by Dr. Smith and Dr. Johnson (page 15), the research indicates..."
```

### Benefits
- **Simple key-value metadata** - no complex templates to manage
- **Clean filenames** - automatically removes signatures and query parameters
- **Dual outputs** - file_urls for regular use, files_with_metadata for knowledge extraction
- **No new nodes needed** - enhances existing FileSelection node
- **Rich source attribution** in AI agent responses with custom metadata
- **Seamless integration** - works with existing PDFUrlKnowledge nodes
- **Fully backwards compatible** - existing workflows continue unchanged
- **Zero learning curve** - same FileSelection interface

### Success Metrics  
- Users can easily add/remove metadata key-value pairs
- Filename and filepath are always present in metadata
- Agent responses show meaningful document attribution
- Knowledge extraction preserves all custom metadata
- System maintains performance with metadata overhead
- Existing workflows continue to function without changes

## Implementation Priority

**High Priority (Phase 1-2):**
- Backend metadata storage and API
- Simple key-value metadata editor UI
- Default fields (filename, filepath) auto-population

**Medium Priority (Phase 3):** 
- KnowledgeFileSelection node
- File Manager integration
- End-to-end testing

**Low Priority (Phase 4-5):**
- Advanced UI features
- Auto-extraction capabilities
- Analytics and insights

---

## Technical Considerations

### Performance
- S3 metadata stored as object headers (no additional storage cost)
- Metadata caching in Redis for frequently accessed files
- Lazy loading of metadata in UI to maintain responsiveness
- Batch operations for bulk metadata updates

### Security
- Metadata validation to prevent XSS/injection
- Access control for metadata templates
- Audit logging for metadata changes
- Encryption of sensitive metadata fields

### Scalability
- Template system designed for thousands of custom templates
- Metadata indexing for fast search across large file collections
- Pagination support for metadata-heavy interfaces
- Background processing for metadata extraction tasks

## Dependencies

### External Libraries
- `agno` framework (existing)
- `boto3` for S3 operations (existing) 
- Additional PDF processing libraries may be needed
- LLM integration for auto-extraction (future)

### Internal Systems
- File Manager Service (extend existing)
- Node Runner Framework (existing)
- Portal UI Framework (existing)
- S3 Storage Infrastructure (existing)

## Risk Mitigation

### Backwards Compatibility
- All metadata features are opt-in
- Existing files work without metadata
- Graceful degradation when metadata is missing
- Migration utilities for existing file collections

### Data Loss Prevention
- Metadata backup in database alongside S3 storage
- Validation before metadata updates
- Rollback capabilities for bulk operations
- Regular backup verification

### User Adoption
- Progressive disclosure of advanced features
- Helpful templates and examples
- Clear migration path from existing workflows
- Comprehensive documentation and tutorials