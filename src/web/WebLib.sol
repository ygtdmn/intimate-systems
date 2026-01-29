// SPDX-License-Identifier: MIT
pragma solidity >=0.8.30;

import { Sculpture } from "../Sculpture.sol";
import { SculptureERC721 } from "../SculptureERC721.sol";
import { ContractShow } from "../ContractShow.sol";
import { Mod } from "../Mod.sol";
import { IERC721Metadata } from "../lib/IERC721Metadata.sol";
import { LibString } from "solady/utils/LibString.sol";

library WebLib {
    using LibString for string;

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

    function rawTokenUriFor(Sculpture sculpture, address show) internal view returns (string memory) {
        SculptureERC721 memory sculptureERC721 = ContractShow(show).getSculptureERC721(sculpture);
        if (sculptureERC721.contractAddress != address(0)) {
            try IERC721Metadata(sculptureERC721.contractAddress).tokenURI(sculptureERC721.tokenId) returns (string memory uri) {
                if (bytes(uri).length > 0) return uri;
            } catch {}
        }

        address sculptureAddress = address(sculpture);
        try IERC721Metadata(sculptureAddress).tokenURI(0) returns (string memory uri) {
            if (bytes(uri).length > 0) return uri;
        } catch {}

        try IERC721Metadata(sculptureAddress).tokenURI(1) returns (string memory uri) {
            return uri;
        } catch {}

        return "";
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
                '" class="token-media token-iframe" sandbox="allow-scripts allow-same-origin" loading="eager" scrolling="no"></iframe>'
            );
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
