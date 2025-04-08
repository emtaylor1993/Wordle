/******************************************************************************************************
 * File: wordOfTheDay.js
 * 
 * Author: Emmanuel Taylor
 * Created: April 3, 2025
 * Modified: April 7, 2025
 * 
 * Description:
 *   - Provides a deterministic daily word based on the current date. It loads a
 *     validated list of 5-letter words from a local JSON file. Ensures the same word
 *     is returned for each user on a given date.
 * 
 * Dependences:
 *   - fs:   For reading the word list from the filesystem.
 *   - path: Resolves the correct path to wordlist.json.
 ******************************************************************************************************/

const fs = require("fs");
const path = require("path");

const wordlistPath = path.join(__dirname, "../data/wordlist.json");

// Global variables for loaded data and word cache.
let words = [];
let cachedWord = null;
let cachedDate = null;

/**
 * Loads the word list from disk and performs word validation.
 * - Must be a JSON array of strings.
 * - Filters for only lowercase 5-letter words.
 * - Logs the number of valid words loaded.
 */
try {
    const fileContent = fs.readFileSync(wordlistPath, "utf-8");
    const parsed = JSON.parse(fileContent);

    // Validate shape and content of the JSON file.
    if (!Array.isArray(parsed) || parsed.some(word => typeof word !== "string")) {
        throw new Error("Invalid Format: JSON File must be an Array of Strings.");
    }

    words = parsed.map(w => w.trim().toLowerCase()).filter(w => w.length === 5);

    if (words.length === 0) {
        throw new Error("Invalid Format: JSON File Has No Valid 5-Letter Words.");
    }

    console.log(`[WORDGEN] Loaded ${words.length} Words From wordlist.json`);
} catch (err) {
    console.error("[WORDGEN] Failed to load or validate wordlist.json: ", err.message);
}

/**
 * getWordOfTheDay
 * 
 * Determines the daily Wordle word based on a hash of the current date. The result
 * is cached to avoid recomputing during the same request cycle.
 * 
 * @returns {string} - The selected word of the day.
 */
function getWordOfTheDay() {
    const date = new Date().toISOString().split("T")[0];
    
    // Return cached word if we're still on the same day.
    if (date === cachedDate && cachedWord) {
        return cachedWord;
    }

    // Creates a hash by summing the year, month and day numbers.
    const hash = date.split("-").reduce((acc, part) => acc + parseInt(part), 0);
    const index = hash % words.length;
    cachedWord = words[index];
    cachedDate = date;

    console.log(`[WORDGEN] Word for ${date} is "${cachedWord}"`);
    return cachedWord;
}

module.exports = { getWordOfTheDay, words };