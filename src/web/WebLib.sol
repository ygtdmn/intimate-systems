// SPDX-License-Identifier: MIT
pragma solidity >=0.8.30;

import { Sculpture } from "../Sculpture.sol";
import { SculptureERC721 } from "../SculptureERC721.sol";
import { ContractShow } from "../ContractShow.sol";
import { Mod } from "../Mod.sol";
import { IERC721Metadata } from "../lib/IERC721Metadata.sol";
import { LibString } from "solady/utils/LibString.sol";
import { Base64 } from "solady/utils/Base64.sol";
import { JSONParserLib } from "solady/utils/JSONParserLib.sol";

library WebLib {
    using LibString for string;
    using JSONParserLib for JSONParserLib.Item;
    using JSONParserLib for string;

    function sortSculpturesByAuthor(Sculpture[] memory sculptures) internal view returns (Sculpture[] memory) {
        Sculpture[] memory sorted = new Sculpture[](sculptures.length);
        for (uint256 i = 0; i < sculptures.length; i++) {
            sorted[i] = sculptures[i];
        }
        for (uint256 i = 0; i < sorted.length; i++) {
            for (uint256 j = i + 1; j < sorted.length; j++) {
                string memory a = primaryAuthor(sorted[i]);
                string memory b = primaryAuthor(sorted[j]);
                if (compareStrings(a.lower(), b.lower()) > 0) {
                    Sculpture tmp = sorted[i];
                    sorted[i] = sorted[j];
                    sorted[j] = tmp;
                }
            }
        }
        return sorted;
    }

    function primaryAuthor(Sculpture sculpture) internal view returns (string memory) {
        string memory author = "Unknown";
        try sculpture.authors() returns (string[] memory list) {
            if (list.length > 0 && bytes(list[0]).length > 0) {
                author = list[0];
            }
        } catch {}
        return author;
    }

    function compareStrings(string memory a, string memory b) internal pure returns (int256) {
        bytes memory ba = bytes(a);
        bytes memory bb = bytes(b);
        uint256 minLen = ba.length < bb.length ? ba.length : bb.length;
        for (uint256 i = 0; i < minLen; i++) {
            if (ba[i] < bb[i]) {
                return -1;
            }
            if (ba[i] > bb[i]) {
                return 1;
            }
        }
        if (ba.length < bb.length) {
            return -1;
        }
        if (ba.length > bb.length) {
            return 1;
        }
        return 0;
    }

    function slugify(string memory input) internal pure returns (string memory) {
        bytes memory b = bytes(input.lower());
        bytes memory out = new bytes(b.length);
        uint256 o;
        for (uint256 i = 0; i < b.length; i++) {
            bytes1 c = b[i];
            if ((c >= "a" && c <= "z") || (c >= "0" && c <= "9")) {
                out[o++] = c;
            } else if (c == " " || c == "-" || c == "_") {
                if (o > 0 && out[o - 1] != "-") {
                    out[o++] = "-";
                }
            }
        }
        // trim trailing dash
        if (o > 0 && out[o - 1] == "-") {
            o--;
        }
        assembly {
            mstore(out, o)
        }
        return string(out);
    }

    function parseJson(string memory json) internal pure returns (string memory image, string memory animation) {
        image = jsonValue(json, "image");
        if (bytes(image).length == 0) {
            image = jsonValue(json, "image_url");
        }
        animation = jsonValue(json, "animation_url");
    }

    function jsonValue(string memory json, string memory key) internal pure returns (string memory) {
        JSONParserLib.Item memory root = json.parse();
        string memory quotedKey = string.concat('"', key, '"');
        JSONParserLib.Item memory item = root.at(quotedKey);
        if (item.isUndefined()) {
            return "";
        }
        if (item.isString()) {
            return item.value().decodeString();
        }
        return item.value();
    }

    function renderMediaFromUrl(
        string memory url,
        string memory title
    ) internal pure returns (string memory _html, string memory artworkUrl) {
        if (url.startsWith("data:video/") || url.endsWith(".mp4") || url.endsWith(".webm") || url.endsWith(".mov")) {
            _html = string.concat(
                '<video src="',
                url,
                '" controls loop muted playsinline class="token-media"></video>'
            );
            return (_html, url);
        }
        if (url.startsWith("data:text/html") || url.endsWith(".html") || url.endsWith(".htm")) {
            string memory iframeSrc = injectStyleReset(url);
            _html = string.concat(
                '<iframe src="',
                iframeSrc,
                '" class="token-media token-iframe" sandbox="allow-scripts"></iframe>'
            );
            return (_html, url);
        }
        return renderImage(url, title);
    }

    function renderImage(
        string memory url,
        string memory title
    ) internal pure returns (string memory _html, string memory artworkUrl) {
        _html = string.concat('<img src="', url, '" alt="', title, '" class="token-media">');
        return (_html, url);
    }

    function firstMimeUrl(string[] memory urls) internal pure returns (string memory) {
        for (uint256 i = 0; i < urls.length; i++) {
            if (
                urls[i].startsWith("data:image/") ||
                urls[i].startsWith("data:video/") ||
                urls[i].startsWith("data:text/html")
            ) {
                return urls[i];
            }
        }
        return "";
    }

    function injectStyleReset(string memory url) internal pure returns (string memory) {
        if (!url.startsWith("data:text/html;base64,")) {
            return url;
        }
        string memory base64 = url.slice(22);
        string memory _html = string(Base64.decode(base64));
        string
            memory styleReset = "<style>*{margin:0!important;padding:0!important;box-sizing:border-box!important}html,body{width:100%!important;height:100%!important;background:transparent!important;overflow:hidden!important;justify-content:flex-start!important;align-items:flex-start!important}</style>";

        if (_html.contains("<head>")) {
            _html = replaceFirst(_html, "<head>", string.concat("<head>", styleReset));
        } else if (_html.contains("<html>")) {
            _html = replaceFirst(_html, "<html>", string.concat("<html><head>", styleReset, "</head>"));
        } else {
            _html = string.concat(styleReset, _html);
        }

        return string.concat("data:text/html;base64,", Base64.encode(bytes(_html)));
    }

    function replaceFirst(
        string memory str,
        string memory needle,
        string memory replacement
    ) internal pure returns (string memory) {
        uint256 idx = str.indexOf(needle);
        if (idx == LibString.NOT_FOUND) {
            return str;
        }
        return string.concat(str.slice(0, idx), replacement, str.slice(idx + bytes(needle).length));
    }

    function urlDecode(string memory str) internal pure returns (string memory) {
        bytes memory b = bytes(str);
        bytes memory out = new bytes(b.length);
        uint256 o;
        for (uint256 i = 0; i < b.length; i++) {
            bytes1 c = b[i];
            if (c == "%") {
                if (i + 2 < b.length) {
                    uint8 hi = _fromHexChar(uint8(b[i + 1]));
                    uint8 lo = _fromHexChar(uint8(b[i + 2]));
                    out[o++] = bytes1((hi << 4) | lo);
                    i += 2;
                }
            } else if (c == "+") {
                out[o++] = " ";
            } else {
                out[o++] = c;
            }
        }
        assembly {
            mstore(out, o)
        }
        return string(out);
    }

    function _fromHexChar(uint8 c) private pure returns (uint8) {
        if (c >= 48 && c <= 57) {
            return c - 48;
        }
        if (c >= 65 && c <= 70) {
            return c - 55;
        }
        if (c >= 97 && c <= 102) {
            return c - 87;
        }
        return 0;
    }

    function sculptureUrls(Sculpture sculpture) internal view returns (string[] memory) {
        string[] memory urls;
        try sculpture.urls() returns (string[] memory result) {
            urls = result;
        } catch {
            urls = new string[](0);
        }
        return urls;
    }

    function titleFor(Sculpture sculpture) internal view returns (string memory) {
        string memory title = "Untitled";
        try sculpture.title() returns (string memory t) {
            if (bytes(t).length > 0) {
                title = t;
            }
        } catch {}
        return title;
    }

    function tokenMediaFor(
        Sculpture sculpture,
        address show
    ) internal view returns (string memory image, string memory animation) {
        SculptureERC721 memory sculptureERC721 = ContractShow(show).getSculptureERC721(sculpture);
        if (sculptureERC721.contractAddress != address(0)) {
            (image, animation) = tokenMediaFrom(sculptureERC721.contractAddress, sculptureERC721.tokenId);
            if (bytes(image).length > 0 || bytes(animation).length > 0) {
                return (image, animation);
            }
        }

        address sculptureAddress = address(sculpture);
        (image, animation) = tokenMediaFrom(sculptureAddress, 0);
        if (bytes(image).length > 0 || bytes(animation).length > 0) {
            return (image, animation);
        }

        return tokenMediaFrom(sculptureAddress, 1);
    }

    function tokenMediaFrom(
        address contractAddress,
        uint256 tokenId
    ) internal view returns (string memory image, string memory animation) {
        try IERC721Metadata(contractAddress).tokenURI(tokenId) returns (string memory uri) {
            return parseTokenUri(uri);
        } catch {
            return ("", "");
        }
    }

    function parseTokenUri(string memory uri) internal pure returns (string memory image, string memory animation) {
        if (uri.startsWith("data:application/json;base64,")) {
            string memory base64 = uri.slice(29);
            string memory json = string(Base64.decode(base64));
            return parseJson(json);
        }
        if (uri.startsWith("data:application/json,")) {
            string memory encoded = uri.slice(22);
            string memory json = urlDecode(encoded);
            return parseJson(json);
        }
        return ("", "");
    }

    function authorsTextFor(Sculpture sculpture) internal view returns (string memory) {
        string memory authorsText = "";
        try sculpture.authors() returns (string[] memory authors) {
            for (uint256 i = 0; i < authors.length; i++) {
                if (bytes(authors[i]).length == 0) {
                    continue;
                }
                if (bytes(authorsText).length > 0) {
                    authorsText = string.concat(authorsText, ", ");
                }
                authorsText = string.concat(authorsText, authors[i]);
            }
        } catch {}
        if (bytes(authorsText).length == 0) {
            authorsText = "Unknown";
        }
        return authorsText;
    }

    function textFor(Sculpture sculpture) internal view returns (string memory) {
        string memory body = "";
        try sculpture.text() returns (string memory t) {
            if (bytes(t).length > 0) {
                body = t;
            }
        } catch {}
        return body;
    }

    function linksHtmlFor(string[] memory urls, string memory artworkUrl) internal pure returns (string memory _html) {
        for (uint256 i = 0; i < urls.length; i++) {
            if (bytes(artworkUrl).length > 0 && keccak256(bytes(urls[i])) == keccak256(bytes(artworkUrl))) {
                continue;
            }
            if (urls[i].startsWith("data:image/")) {
                _html = string.concat(_html, '<img src="', urls[i], '" alt="" class="url-thumbnail">');
            } else {
                _html = string.concat(
                    _html,
                    '<a href="',
                    urls[i],
                    '" class="external-link" target="_blank" rel="noopener">',
                    urls[i],
                    "</a>"
                );
            }
        }
        if (bytes(_html).length == 0) {
            return "";
        }
        return string.concat('<div class="sculpture-urls">', _html, "</div>");
    }

    function mediaIframe(uint256 index) internal pure returns (string memory) {
        return
            string.concat(
                '<iframe src="/sculpture-media/',
                LibString.toString(index),
                '" class="token-media token-iframe" sandbox="allow-scripts" loading="eager" scrolling="no"></iframe>'
            );
    }

    function addressesForNew(Sculpture sculpture, string memory exporerBaseUrl) internal view returns (string memory) {
        address[] memory addresses;
        try sculpture.addresses() returns (address[] memory returned) {
            addresses = returned;
        } catch {
            addresses = new address[](0);
        }

        address[] memory all = new address[](addresses.length + 1);
        all[0] = address(sculpture);
        for (uint256 i = 0; i < addresses.length; i++) {
            all[i + 1] = addresses[i];
        }

        address[] memory unique = new address[](all.length);
        uint256 count;
        for (uint256 i = 0; i < all.length; i++) {
            if (all[i] == address(0)) {
                continue;
            }
            bool exists;
            for (uint256 j = 0; j < count; j++) {
                if (unique[j] == all[i]) {
                    exists = true;
                    break;
                }
            }
            if (!exists) {
                unique[count] = all[i];
                count++;
            }
        }

        string memory _html;
        for (uint256 i = 0; i < count; i++) {
            string memory addr = LibString.toHexStringChecksummed(unique[i]);
            _html = string.concat(
                _html,
                '<a href="',
                exporerBaseUrl,
                addr,
                '" target="_blank" rel="noopener" class="sculpture-address">',
                addr,
                "</a>"
            );
        }

        return _html;
    }

    function addressesFor(Sculpture sculpture, address data) internal view returns (string memory) {
        address[] memory addresses;
        try sculpture.addresses() returns (address[] memory returned) {
            addresses = returned;
        } catch {
            addresses = new address[](0);
        }

        address[] memory all = new address[](addresses.length + 1);
        all[0] = address(sculpture);
        for (uint256 i = 0; i < addresses.length; i++) {
            all[i + 1] = addresses[i];
        }

        address[] memory unique = new address[](all.length);
        uint256 count;
        for (uint256 i = 0; i < all.length; i++) {
            if (all[i] == address(0)) {
                continue;
            }
            bool exists;
            for (uint256 j = 0; j < count; j++) {
                if (unique[j] == all[i]) {
                    exists = true;
                    break;
                }
            }
            if (!exists) {
                unique[count] = all[i];
                count++;
            }
        }

        string memory _html;
        for (uint256 i = 0; i < count; i++) {
            string memory addr = LibString.toHexStringChecksummed(unique[i]);
            _html = string.concat(
                _html,
                '<a href="',
                Mod(data).etherscanBase(),
                addr,
                '" target="_blank" rel="noopener" class="sculpture-address">',
                addr,
                "</a>"
            );
        }

        return _html;
    }

    function artistsList(Sculpture[] memory sculptures) internal view returns (string memory) {
    }

    function _artistsList(Sculpture[] memory sculptures) internal view returns (string memory) {
        string[] memory authors = new string[](sculptures.length);
        uint256[] memory indices = new uint256[](sculptures.length);
        uint256 count;
        for (uint256 i = 0; i < sculptures.length; i++) {
            string memory author = primaryAuthor(sculptures[i]);
            bool exists;
            for (uint256 j = 0; j < count; j++) {
                if (keccak256(bytes(authors[j])) == keccak256(bytes(author))) {
                    exists = true;
                    break;
                }
            }
            if (!exists) {
                authors[count] = author;
                indices[count] = i + 1;
                count++;
            }
        }

        for (uint256 i = 0; i < count; i++) {
            for (uint256 j = i + 1; j < count; j++) {
                if (compareStrings(authors[i].lower(), authors[j].lower()) > 0) {
                    (authors[i], authors[j]) = (authors[j], authors[i]);
                    (indices[i], indices[j]) = (indices[j], indices[i]);
                }
            }
        }

        string memory _html;
        for (uint256 i = 0; i < count; i++) {
            if (i > 0) {
                _html = string.concat(_html, ", ");
            }
            _html = string.concat(_html, '<a href="#', slugify(authors[i]), '">', authors[i], "</a>");
        }
        return _html;
    }

    function formatText(string memory text) internal pure returns (string memory) {
        if (bytes(text).length == 0) {
            return "";
        }
        if (text.contains("<p") || text.contains("<div") || text.contains("<br") || text.contains("<h")) {
            return text;
        }

        bytes memory b = bytes(text);
        uint256 maxLen = b.length * 7 + 7;
        bytes memory out = new bytes(maxLen);
        uint256 o;
        out[o++] = "<";
        out[o++] = "p";
        out[o++] = ">";

        for (uint256 i = 0; i < b.length; i++) {
            if (b[i] == "\r") {
                continue;
            }
            if (b[i] == "\\") {
                if (i + 1 < b.length && b[i + 1] == "n") {
                    bool isDoubleEscaped = i + 3 < b.length && b[i + 2] == "\\" && b[i + 3] == "n";
                    if (isDoubleEscaped) {
                        i += 3;
                        o = _appendLiteral(out, o, "</p><p>");
                        continue;
                    }
                    i += 1;
                    o = _appendLiteral(out, o, "<br>");
                    continue;
                }
                if (i + 1 < b.length && b[i + 1] == "r") {
                    i += 1;
                    continue;
                }
            }
            if (b[i] == "\n") {
                bool isDouble = i + 1 < b.length && b[i + 1] == "\n";
                if (isDouble) {
                    i++;
                    o = _appendLiteral(out, o, "</p><p>");
                    continue;
                }
                o = _appendLiteral(out, o, "<br>");
                continue;
            }
            out[o++] = b[i];
        }

        o = _appendLiteral(out, o, "</p>");
        assembly {
            mstore(out, o)
        }
        return string(out);
    }

    function _appendLiteral(bytes memory out, uint256 index, string memory literal) private pure returns (uint256) {
        bytes memory b = bytes(literal);
        for (uint256 i = 0; i < b.length; i++) {
            out[index++] = b[i];
        }
        return index;
    }
}
