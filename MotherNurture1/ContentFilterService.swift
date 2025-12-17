//
//  ContentFilterService.swift
//  MotherNurture1
//
//  Content filtering service to prevent inappropriate content from being sent
//

import Foundation

class ContentFilterService {
    static let shared = ContentFilterService()
    
    // Common profanity and inappropriate words/phrases
    // Note: Only blocking clearly inappropriate words, not common words that have legitimate uses
    private let blockedWords: Set<String> = [
        // Profanity (explicit only)
        "dick", "cock", "pussy",
        // Hate speech indicators
        "nazi", "kkk", "retard", "fag", "faggot", "nigger",
        // Explicit threats (removed common words like "kill", "die", "harm" that have legitimate uses)
        "murder", "suicide",
        // Spam indicators (phrases only, not single words)
        "click here", "free money",
        // Sexual content (explicit only)
        "porn", "xxx"
    ]
    
    // Patterns that indicate inappropriate content
    // Note: These are strict patterns that only match actual problematic content
    private let blockedPatterns: [String] = [
        // URLs - only match complete URLs with protocol
        "https?://[\\w\\-._~:/?#\\[\\]@!$&'()*+,;=%]+",
        // www URLs - only match complete www.domain.com patterns
        "www\\.[\\w\\-._~:/?#\\[\\]@!$&'()*+,;=%]+\\.[a-z]{2,}",
        // Email - only match if there's an @ symbol followed by domain
        "[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}",
        // Phone numbers - only match if it looks like a phone number (3-3-4 or 3.3.4 format)
        "\\b\\d{3}[-.\\s]\\d{3}[-.\\s]\\d{4}\\b"
    ]
    
    private init() {}
    
    // MARK: - Main Filtering Method
    
    /// Filters content and returns a result indicating if content is safe
    /// - Parameter content: The text content to filter
    /// - Returns: ContentFilterResult with validation status and reason if blocked
    func filterContent(_ content: String) -> ContentFilterResult {
        let trimmedContent = content.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Check for empty content
        guard !trimmedContent.isEmpty else {
            return ContentFilterResult(isSafe: false, reason: "Message cannot be empty")
        }
        
        // Check for minimum length (too short might be spam or incomplete)
        guard trimmedContent.count >= 2 else {
            return ContentFilterResult(isSafe: false, reason: "Message is too short")
        }
        
        // Check for maximum length (prevent abuse)
        guard trimmedContent.count <= 5000 else {
            return ContentFilterResult(isSafe: false, reason: "Message is too long (maximum 5000 characters)")
        }
        
        let lowercasedContent = trimmedContent.lowercased()
        
        // Check for blocked words
        if containsBlockedWords(lowercasedContent) != nil {
            return ContentFilterResult(
                isSafe: false,
                reason: "Your message contains inappropriate language. Please keep conversations respectful and family-friendly."
            )
        }
        
        // Check for blocked patterns
        if containsBlockedPatterns(trimmedContent) != nil {
            return ContentFilterResult(
                isSafe: false,
                reason: "Your message contains content that isn't allowed (e.g., links, contact information). Please keep conversations within the app."
            )
        }
        
        // Check for excessive special characters (often spam)
        if hasExcessiveSpecialCharacters(trimmedContent) {
            return ContentFilterResult(
                isSafe: false,
                reason: "Your message contains too many special characters. Please use normal text."
            )
        }
        
        // Check for only whitespace/numbers (not meaningful content)
        if isOnlyWhitespaceOrNumbers(trimmedContent) {
            return ContentFilterResult(
                isSafe: false,
                reason: "Please enter meaningful text"
            )
        }
        
        // Content passed all checks
        return ContentFilterResult(isSafe: true, reason: nil)
    }
    
    // MARK: - Helper Methods
    
    /// Checks if content contains any blocked words
    private func containsBlockedWords(_ content: String) -> String? {
        // Split content into words (handles punctuation)
        let words = content.components(separatedBy: CharacterSet.alphanumerics.inverted)
            .filter { !$0.isEmpty }
        
        // Check exact word matches first (more precise)
        for word in words {
            let lowercasedWord = word.lowercased()
            if blockedWords.contains(lowercasedWord) {
                return word
            }
        }
        
        // Check for blocked words as whole words (with word boundaries)
        // This prevents false positives like "class" matching "ass"
        for blockedWord in blockedWords {
            // Use word boundary regex to match whole words only
            let pattern = "\\b\(NSRegularExpression.escapedPattern(for: blockedWord))\\b"
            if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) {
                let range = NSRange(content.startIndex..., in: content)
                if regex.firstMatch(in: content, options: [], range: range) != nil {
                    return blockedWord
                }
            }
        }
        
        return nil
    }
    
    /// Checks if content matches any blocked patterns
    private func containsBlockedPatterns(_ content: String) -> String? {
        // Only check for actual problematic patterns, not partial matches
        let lowercased = content.lowercased()
        
        // Check for URLs (must have http:// or https:// or www.)
        if lowercased.contains("http://") || lowercased.contains("https://") || lowercased.contains("www.") {
            // Verify it's actually a URL pattern
            for pattern in blockedPatterns.filter({ $0.contains("http") || $0.contains("www") }) {
                if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) {
                    let range = NSRange(content.startIndex..., in: content)
                    if regex.firstMatch(in: content, options: [], range: range) != nil {
                        return pattern
                    }
                }
            }
        }
        
        // Check for email (must have @ symbol)
        if content.contains("@") {
            for pattern in blockedPatterns.filter({ $0.contains("@") }) {
                if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) {
                    let range = NSRange(content.startIndex..., in: content)
                    if regex.firstMatch(in: content, options: [], range: range) != nil {
                        return pattern
                    }
                }
            }
        }
        
        // Check for phone numbers (must have digits and separators)
        if content.range(of: #"\d{3}[-.\s]\d{3}[-.\s]\d{4}"#, options: .regularExpression) != nil {
            for pattern in blockedPatterns.filter({ $0.contains("\\d") }) {
                if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) {
                    let range = NSRange(content.startIndex..., in: content)
                    if regex.firstMatch(in: content, options: [], range: range) != nil {
                        return pattern
                    }
                }
            }
        }
        
        return nil
    }
    
    /// Checks for excessive special characters (potential spam)
    private func hasExcessiveSpecialCharacters(_ content: String) -> Bool {
        let specialCharCount = content.filter { !$0.isLetter && !$0.isNumber && !$0.isWhitespace }.count
        let totalCharCount = content.count
        
        // Only flag if more than 60% are special characters and message is reasonably long
        // This allows normal punctuation in messages (periods, commas, etc.)
        guard totalCharCount > 20 else { return false } // Don't check short messages
        let specialCharRatio = Double(specialCharCount) / Double(totalCharCount)
        return specialCharRatio > 0.6
    }
    
    /// Checks if content is only whitespace or numbers
    private func isOnlyWhitespaceOrNumbers(_ content: String) -> Bool {
        let trimmed = content.trimmingCharacters(in: .whitespaces)
        // Only fail if it's empty or contains ONLY numbers/whitespace/punctuation (no letters)
        // This allows normal messages with punctuation
        guard !trimmed.isEmpty else { return true }
        // Check if there are any letters - if yes, it's valid content
        let hasLetters = trimmed.contains { $0.isLetter }
        if hasLetters {
            return false // Has letters, so it's valid
        }
        // No letters - only fail if it's all numbers/punctuation/whitespace
        return trimmed.allSatisfy { $0.isNumber || $0.isWhitespace || $0.isPunctuation }
    }
    
    // MARK: - Sanitization (for display purposes)
    
    /// Sanitizes content by replacing blocked words with asterisks
    /// Note: This is for display only - original content should still be blocked from sending
    func sanitizeContent(_ content: String) -> String {
        var sanitized = content
        let lowercased = content.lowercased()
        
        for blockedWord in blockedWords {
            if lowercased.contains(blockedWord) {
                let replacement = String(repeating: "*", count: blockedWord.count)
                sanitized = sanitized.replacingOccurrences(
                    of: blockedWord,
                    with: replacement,
                    options: .caseInsensitive
                )
            }
        }
        
        return sanitized
    }
}

// MARK: - Content Filter Result

struct ContentFilterResult {
    let isSafe: Bool
    let reason: String?
    
    var errorMessage: String? {
        isSafe ? nil : reason
    }
}

