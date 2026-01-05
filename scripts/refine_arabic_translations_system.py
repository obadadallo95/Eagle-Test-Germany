#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Script to refine Arabic translations in questions_system.json
Following strict terminology rules for German Constitutional Law
"""

import json
import re

# Critical terminology mapping
TERMINOLOGY = {
    r'\bBundestag\b': 'البرلمان الاتحادي (بوندستاغ)',
    r'\bBundesrat\b': 'المجلس الاتحادي (بوندسرات)',
    r'\bBundesversammlung\b': 'المجمع الفيدرالي',
    r'\bRechtsstaat\b': 'دولة القانون والمؤسسات',
    r'\bGewaltenteilung\b': 'فصل السلطات',
    r'\bExekutive\b': 'السلطة التنفيذية',
    r'\bLegislative\b': 'السلطة التشريعية',
    r'\bJudikative\b': 'السلطة القضائية',
}

# Additional improvements for common phrases (order matters - more specific first)
IMPROVEMENTS = [
    # Specific fixes
    ('المعرضة البرلمانية', 'المعارضة البرلمانية'),
    ('ملهي مهمة', 'ما هي مهمة'),
    ('يختار اعضاء', 'ينتخب أعضاء'),
    ('يختار المستشار', 'ينتخب المستشار'),
    ('يختار المستشارة', 'ينتخب المستشارة'),
    ('يختار الرئيس', 'ينتخب الرئيس'),
    ('يختار الرئيسة', 'ينتخب الرئيسة'),
    ('يسمى ذلك', 'يُطلق على ذلك'),
    ('ماهو', 'ما هو'),
    ('ماهي', 'ما هي'),
    ('ماذا يوجد', 'ما يوجد'),
    ('ماذا يحصل', 'ما يحصل'),
    ('لكم سنة', 'لمدة كم سنة'),
    ('ابتداء من اي عمر', 'بدءاً من أي عمر'),
    ('من أجل…', 'للإشارة إلى…'),
    ('من أجل', 'للإشارة إلى'),
    # General improvements
    ('يسمى', 'يُطلق عليه'),
]

def apply_terminology(text):
    """Apply critical terminology rules"""
    for pattern, replacement in TERMINOLOGY.items():
        text = re.sub(pattern, replacement, text, flags=re.IGNORECASE)
    return text

def improve_translation(text, context_de=""):
    """Improve Arabic translation for better flow and official tone"""
    original_text = text
    
    # Apply terminology first (case-insensitive)
    for pattern, replacement in TERMINOLOGY.items():
        text = re.sub(pattern, replacement, text, flags=re.IGNORECASE)
    
    # Apply specific improvements (order matters)
    for old, new in IMPROVEMENTS:
        text = text.replace(old, new)
    
    # Context-specific improvements
    context_lower = context_de.lower()
    
    # Election-related: use "ينتخب" instead of "يختار"
    if any(word in context_lower for word in ['wahl', 'wählt', 'wählen', 'gewählt']):
        text = re.sub(r'\bيختار\b', 'ينتخب', text)
        text = re.sub(r'\bاختيار\b', 'انتخاب', text)
    
    # Bundestag: ensure proper terminology
    if 'bundestag' in context_lower:
        # Replace standalone "البرلمان" with full term when context is about Bundestag
        if 'البرلمان' in text and 'بوندستاغ' not in text:
            text = re.sub(r'\bالبرلمان\b(?!\s*الاتحادي)', 'البرلمان الاتحادي (بوندستاغ)', text)
        text = re.sub(r'\bالبوندستاغ\b', 'البرلمان الاتحادي (بوندستاغ)', text)
        text = re.sub(r'\bمجلس النواب الألماني\b', 'البرلمان الاتحادي (بوندستاغ)', text)
    
    # Bundesrat: ensure proper terminology
    if 'bundesrat' in context_lower:
        text = re.sub(r'\bمجلس الشورى\b', 'المجلس الاتحادي (بوندسرات)', text)
        text = re.sub(r'\bمجلس\s*الاتحاد\b', 'المجلس الاتحادي (بوندسرات)', text)
        text = re.sub(r'\bالمجلس\s*الاتحادي\b(?!\s*\(بوندسرات\))', 'المجلس الاتحادي (بوندسرات)', text)
    
    # Bundesversammlung: ensure proper terminology
    if 'bundesversammlung' in context_lower:
        text = re.sub(r'\bالجمعية\s*الاتحادية\b', 'المجمع الفيدرالي', text)
        text = re.sub(r'\bالجمعية\s*العمومية\s*الاتحادية\b', 'المجمع الفيدرالي', text)
    
    # Exekutive/Legislative/Judikative
    if 'exekutive' in context_lower:
        text = re.sub(r'\bتنفيذي\b', 'السلطة التنفيذية', text)
    if 'legislative' in context_lower:
        text = re.sub(r'\bالسلطة\s*التشريعية\b(?!\s*$)', 'السلطة التشريعية', text)
    if 'judikative' in context_lower:
        text = re.sub(r'\bالقضاء\b', 'السلطة القضائية', text)
    
    # Fix grammatical issues
    text = re.sub(r'\s+', ' ', text)  # Multiple spaces
    text = text.strip()
    
    # Ensure proper punctuation
    if text and not text.endswith(('.', '؟', '!', '…')):
        if '؟' in original_text or '?' in context_de:
            if not text.endswith('؟'):
                text = text.rstrip('.') + '؟'
    
    return text

def refine_question(question_obj):
    """Refine a single question object"""
    de_text = question_obj.get('question', {}).get('de', '')
    ar_text = question_obj.get('question', {}).get('ar', '')
    
    if ar_text:
        question_obj['question']['ar'] = improve_translation(ar_text, de_text)
    
    # Refine answers
    for answer in question_obj.get('answers', []):
        de_answer = answer.get('text', {}).get('de', '')
        ar_answer = answer.get('text', {}).get('ar', '')
        
        if ar_answer:
            answer['text']['ar'] = improve_translation(ar_answer, de_answer)
    
    return question_obj

def main():
    input_file = 'assets/data/questions_system.json'
    output_file = 'assets/data/questions_system.json'
    
    print(f'Reading {input_file}...')
    with open(input_file, 'r', encoding='utf-8') as f:
        data = json.load(f)
    
    print(f'Found {len(data)} questions. Refining translations...')
    
    refined_count = 0
    for question in data:
        original_ar = question.get('question', {}).get('ar', '')
        question = refine_question(question)
        new_ar = question.get('question', {}).get('ar', '')
        
        if original_ar != new_ar:
            refined_count += 1
    
    print(f'Refined {refined_count} questions.')
    
    print(f'Writing to {output_file}...')
    with open(output_file, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=2)
    
    print('Done!')

if __name__ == '__main__':
    main()

