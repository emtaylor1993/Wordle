const words = ["apple", "brain", "crane", "delta", "eagle"];

function getWordOfTheDay() {
    const date = new Date().toISOString().split("T")[0];
    const hash = date.split("-").reduce((acc, part) => acc + parseInt(part), 0);
    const index = hash % words.length;
    return words[index];
}

module.exports = getWordOfTheDay;