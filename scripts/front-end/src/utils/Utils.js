// helper function to sort array of objects by field
export const dynamicSort = (property) => {
    var sortOrder = 1;
    if (property[0] === "-") {
        sortOrder = -1;
        property = property.substr(1);
    }
    return function (a, b) {
        var result = (a[property] < b[property]) ? -1 : (a[property] > b[property]) ? 1 : 0;
        return result * sortOrder;
    }
}

// beautify date data from the server
export const beautifyDate = (dateString) => {
    const year = dateString.substr(0, 4);
    const month = dateString.substr(4, 2);
    const day = dateString.substr(6, 2);
    const hour = dateString.substr(8, 2);
    const minute = dateString.substr(10, 2);
    const second = dateString.substr(12, 2);

    const humanReadableDate =
        year + '-' + month + '-' + day + '  ' + hour + ':' + minute + ':' + second;

    return humanReadableDate;
}