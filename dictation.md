# Dictation Setup and Research

## Overview

This document summarizes research on voice dictation solutions, specifically focusing on nerd-dictation 
with VOSK models for both general dictation and programming use cases.

## Voice Dictation Solutions Comparison

### Nerd-Dictation (Current Choice)
* **Engine**: VOSK-API offline speech recognition
* **Best for**: Dual-purpose (general dictation + programming)
* **Pros**: Works across all applications, hackable Python configuration, offline/private
* **Cons**: Less specialized for programming than dedicated tools

### Talon Voice (Alternative)
* **Engine**: Conformer (wav2letter) or Dragon
* **Best for**: Programming-focused voice coding
* **Pros**: Programming-specific design, phonetic alphabet, extensive community
* **Cons**: Steep learning curve, less natural for general text, paid beta required

### Commercial Alternatives
* **Wispr Flow**: AI-powered, 3x faster than typing, works across IDEs
* **Super Whisper**: Local Whisper implementation optimized for coding

## VOSK Model Selection

### Available English Models

| Model | Size | WER | Accuracy | Features |
|-------|------|-----|----------|----------|
| `vosk-model-small-en-us-0.15` | 40MB | 9.85% | 90.15% | Lightweight, mobile-friendly |
| `vosk-model-en-us-0.22-lgraph` | 128MB | 7.82% | 92.18% | **Dynamic graph, vocabulary modification** |
| `vosk-model-en-us-0.22` | 1.8GB | 5.69% | 94.31% | High accuracy, static graph |
| `vosk-model-en-us-0.42-gigaspeech` | 2.3GB | 5.64% | 94.36% | Highest accuracy, latest training |

### Current Setup

**Primary Model**: `vosk-model-en-us-0.22-lgraph`
* **Rationale**: Best balance of accuracy (92.18%) and functionality
* **Key Advantage**: Dynamic graph supports runtime vocabulary modification
* **Size**: 128MB - reasonable for desktop use

**Fallback Model**: `vosk-model-small-en-us-0.15`
* **Rationale**: Smaller, faster for lower-resource situations
* **Usage**: Commented out in `bin/bin/dictation-toggle.sh`

## Technical Vocabulary Extension Methods

### Method 1: Grammar Files (Restrictive)
```bash
# Restricts recognition to only specified terms
./nerd-dictation begin --vosk-grammar-file programming.json
```

**Pros**: Higher accuracy for technical terms
**Cons**: Cannot dictate general text, limited vocabulary

### Method 2: Runtime Vocabulary Addition (Ideal but Complex)
Uses VOSK's dynamic graph capabilities to add technical terms without restricting vocabulary.

**Current Status**: Requires extending nerd-dictation's VOSK integration
**Implementation**: Would need custom VOSK API calls in nerd-dictation source

### Method 3: Post-Processing (Current Recommendation)
Text replacement in `~/.config/nerd-dictation/nerd-dictation.py`

**Performance**:
* **Frequency**: ~10 times/second during continuous mode
* **Cost**: <1ms per call with optimized regex
* **Complexity**: Single O(n) pass vs multiple O(n*k) string replacements

**Optimized Implementation**:
```python
import re

# Compile once at startup
TECH_PATTERNS = re.compile(r'\b(?:get hub|dock her|cuba net ease)\b', re.IGNORECASE)
REPLACEMENTS = {
    "get hub": "github",
    "dock her": "docker", 
    "cuba net ease": "kubernetes"
}

def nerd_dictation_process(text):
    def replace_match(match):
        return REPLACEMENTS.get(match.group().lower(), match.group())
    return TECH_PATTERNS.sub(replace_match, text)
```

## Model Management (Ansible)

### Current Implementation
```yaml
- name: Download VOSK models
  ansible.builtin.get_url:
    url: "https://alphacephei.com/vosk/models/{{ item.name }}.zip"
    dest: "{{ ansible_env.HOME }}/.config/nerd-dictation/{{ item.name }}.zip"
    mode: '0644'
    checksum: "sha1:{{ item.checksum }}"
  loop:
    - name: vosk-model-small-en-us-0.15
      checksum: "4b5523d1db7688e31e44608cf96cdad92e4603e7"
      description: "Lightweight model (40MB, 9.85% WER)"
      default: false
    - name: vosk-model-en-us-0.22-lgraph
      checksum: "d03bb4c3a7f4ccb19157c8c7bc055c5083095cbb" 
      description: "Dynamic graph model (128MB, 7.82% WER)"
      default: true
```

**Benefits**:
* Prevents unnecessary re-downloads using SHA1 checksums
* Clean list-based management for multiple models
* Easy to add new models or change defaults

## Dictation Script Configuration

### Current Setup (`bin/bin/dictation-toggle.sh`)
```bash
# Primary model (dynamic graph for technical terms)
VOSK_MODEL="$HOME/.config/nerd-dictation/vosk-model-en-us-0.22-lgraph"
# VOSK_MODEL="$HOME/.config/nerd-dictation/vosk-model-small-en-us-0.15"  # Fallback

# Key features
--vosk-model-dir="$VOSK_MODEL"
--simulate-input-tool=WTYPE     # Wayland compatibility
--timeout=30                    # Auto-stop after silence
--continuous                    # Streaming mode
```

## Performance Characteristics

### Accuracy Expectations
* **7.82% WER** = ~7-8 errors per 100 words
* **Real-world**: 1-2 errors per sentence
* **Usability**: Good enough for productive dictation with light editing

### Processing Frequency
* **Audio Processing**: ~10 times/second (--idle-time=0.1)
* **Text Processing**: Called on each audio chunk
* **Parallel Processing**: Recording and speech-to-text run concurrently

## Developer Workflow Integration

### Dual-Mode Usage
1. **General Dictation**: Full vocabulary for emails, documents, notes
2. **Technical Mode**: Enhanced with programming term corrections

### Microphone Management
* **Auto-unmute**: Microphone activated during dictation
* **State Restoration**: Previous mute state restored on exit
* **Audio Feedback**: Desktop notifications for start/stop

## Future Improvements

### Short Term
1. Implement post-processing config for technical terms
2. Create programming-specific grammar files for specialized contexts
3. Add model switching capability to dictation script

### Long Term
1. Investigate runtime vocabulary modification in VOSK
2. Consider Talon Voice for heavy programming use
3. Explore hybrid approach (nerd-dictation + specialized tools)

## Word Error Rate (WER) Interpretation

**WER Formula**: `(Substitutions + Deletions + Insertions) / Total Words × 100`

**Quality Levels**:
* **<5% WER**: Professional transcription quality
* **5-10% WER**: Usable with occasional corrections (our range)
* **10-15% WER**: Requires frequent editing
* **>15% WER**: Frustrating to use

**Test Datasets**:
* **LibriSpeech**: Clean audiobook recordings (ideal conditions)  
* **TEDlium**: TED talk recordings (realistic speech patterns)
* **Callcenter**: Phone audio (challenging conditions)