/******************************************************************************************************
 * File: wordOfTheDay.js
 * 
 * Author: Emmanuel Taylor
 * Created: April 3, 2025
 * Modified: April 4, 2025
 * 
 * Description:
 *   - Provides a word of the day based on the current date for the Wordle puzzle.
 * 
 * Dependences:
 *   - fs: Node.js file system module to work with files
 *   - path: Provides utilities for working with file and directory paths.
 ******************************************************************************************************/

const fs = require("fs");
const path = require("path");

const wordlistPath = path.join(__dirname, "../data/wordlist.json");

let words = []
let cachedWord = null;
let cachedDate = null;

// Safely loads word list on startup. Prevents system crash if wordslist is malformed.
try {
    const fileContent = fs.readFileSync(wordlistPath, "utf-8");
    const parsed = JSON.parse(fileContent);

    if (!Array.isArray(parsed) || parsed.some(word => typeof word !== "string")) {
        throw new Error("Word list must be an array of strings.");
    }

    words = parsed.map(w => w.trim().toLowerCase()).filter(w => w.length === 5);
    if (words.length === 0) throw new Error("Word list contains no valid 5-letter words.");
    
    console.log(`Loaded ${words.length} words from wordlist.json`);
} catch (err) {
    console.error("Failed to load or validate wordlist.json: ", err.message);
    words = ["error"];
}

/**
 * getWordOfTheDay
 * 
 * Generates a daily word selection based on the current date. The same word will
 * be returned for a given day to ensure consistent gameplay.
 * 
 * Algorithm:
 *   - Get today's date in the YYYY-MM-DD format.
 *   - Convert the date into a simple numeric hash by summing its components.
 *   - Use the modulus operator to select a word index within the bounds of the `words` array.
 * @returns {string} - The selected word of the day.
 */
function getWordOfTheDay() {
    const date = new Date().toISOString().split("T")[0];
    
    if (date != cachedDate) {
        const hash = today.split("-").reduce((acc, part) => acc + parseInt(part), 0);
        const index = hash % words.length;
        cachedWord = words[index];
        cachedDate = today;
    }

    return cachedWord;
}

module.exports = {
    getWordOfTheDay,
    words
  };