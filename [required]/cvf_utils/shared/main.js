/**
----------------------- [ CoreV ] -----------------------
-- GitLab: https://git.arens.io/ThymonA/corev-framework/
-- GitHub: https://github.com/ThymonA/CoreV-Framework/
-- License: GNU General Public License v3.0
--          https://choosealicense.com/licenses/gpl-3.0/
-- Author: Thymon Arens <contact@arens.io>
-- Name: CoreV
-- Version: 1.0.0
-- Description: Custom FiveM Framework
----------------------- [ CoreV ] -----------------------
*/

/**
 * Transform @type string to hash
 * @param {string} key Transform to hash
 * @returns {number} Generated hash
 */
function hashString(key) {
    const strLen = key.length;
    let hash = 0;

    for (var i = 0; i < strLen; i++) {
        hash += key.charCodeAt(i);
        hash += (hash << 10);
        hash ^= (hash >> 6);
    }

    hash += (hash << 3);
    hash ^= (hash >> 11);
    hash += (hash << 15);

    return hash;
}

/**
 * Export `hashString` function
 */
exports('__h', (arg) => {
    arg = String(arg)

    return hashString(arg)
});