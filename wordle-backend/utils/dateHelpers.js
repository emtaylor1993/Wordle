function getTodayDate() {
    return new Date().toISOString().split("T")[0];
}

function isYesterday(dateStr) {
    const today = new Date(getTodayDate());
    const yesterday = new Date(today);
    yesterday.setDate(yesterday.getDate() - 1);
    const input = new Date(dateStr);
    return input.toDateString() === yesterday.toDateString();
}

module.exports = { getTodayDate, isYesterday };