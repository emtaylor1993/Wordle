/******************************************************************************************************
 * File: dateHelper.js
 * 
 * Author: Emmanuel Taylor
 * Created: April 3, 2025
 * Modified: April 7, 2025
 * 
 * Description:
 *   - Utility functions for date comparisons and formatting. Supports game logic such as
 *     identifying "yesterday" for the ability to track streaks.
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
    try {
        const today = new Date(getTodayDate());
        const yesterday = new Date(today);
        yesterday.setDate(today.getDate() - 1);
        const input = new Date(dateStr);
        const yesterdayString = yesterday.toISOString().split("T")[0];
        const inputString = input.toISOString().split("T")[0];
        const result = input.toDateString() === yesterday.toDateString();

        if (!result) {
            console.log(`[DATEHELPER] Date ${inputString} Isn't Yesterday: Expected: ${yesterdayString}`);
        }

        return result;
    } catch (err) {
        console.warn(`[DATEHELPER] Invalid Date String Passed to isYesterday: `, dateStr);
        return false;
    }
}

module.exports = { getTodayDate, isYesterday };