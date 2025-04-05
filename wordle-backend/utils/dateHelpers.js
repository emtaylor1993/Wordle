/******************************************************************************************************
 * File: dateHelper.js
 * 
 * Author: Emmanuel Taylor
 * Created: April 3, 2025
 * Modified: April 4, 2025
 * 
 * Description:
 *   - Utility functions for date normalization to help with the streak tracking
 *     logic in the Wordle backend.
 * 
 * Dependences:
 *   - None
 ******************************************************************************************************/

/**
 * getTodayDate
 * 
 * Returns today's date in ISO format (YYYY-MM-DD). This will ensure
 * consistency when comparing stored game dates.
 * 
 * @returns {string} - Today's date string.
 */
function getTodayDate() {
    return new Date().toISOString().split("T")[0];
}

/**
 * isYesterday
 * 
 * Compares a given date string with yesterday's date. Used to determine if the 
 * player's last played game was yesterday, which is required for streak tracking logic.
 * 
 * @param {string} dateStr - Date string in ISO format to compare.
 * @returns {boolean} - True if the date is exactly one day before today.
 */
function isYesterday(dateStr) {
    const today = new Date(getTodayDate());
    const yesterday = new Date(today);
    yesterday.setDate(yesterday.getDate() - 1);
    const input = new Date(dateStr);
    return input.toDateString() === yesterday.toDateString();
}

module.exports = { getTodayDate, isYesterday };