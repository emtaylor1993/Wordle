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
 *   - None
 ******************************************************************************************************/

const words = ["apple", "brain", "crane", "delta", "eagle"];

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
    const hash = date.split("-").reduce((acc, part) => acc + parseInt(part), 0);
    const index = hash % words.length;
    return words[index];
}

module.exports = getWordOfTheDay;