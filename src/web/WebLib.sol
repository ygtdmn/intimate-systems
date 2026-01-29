// SPDX-License-Identifier: MIT
pragma solidity >=0.8.30;

import { Sculpture } from "../Sculpture.sol";
import { LibString } from "solady/utils/LibString.sol";

library WebLib {
    using LibString for string;

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
        if (o > 0 && out[o - 1] == "-") {
            o--;
        }
        assembly {
            mstore(out, o)
        }
        return string(out);
    }

    function firstMimeUrl(Sculpture sculpture) internal view returns (string memory) {
        string[] memory urls = sculpture.urls();

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

    function linksHtmlFor(Sculpture sculpture, string memory artworkUrl) internal view returns (string memory _html) {
        string[] memory urls = sculpture.urls();

        for (uint256 i = 0; i < urls.length; i++) {
            if (bytes(artworkUrl).length > 0 && keccak256(bytes(urls[i])) == keccak256(bytes(artworkUrl))) {
                continue;
            }
            if (urls[i].startsWith("data:image/")) {
                _html = string.concat(_html, '<img src="', urls[i], '" alt="">');
            } else {
                _html = string.concat(
                    _html,
                    '<a href="',
                    urls[i],
                    '" target="_blank" rel="noopener">',
                    urls[i],
                    "</a>"
                );
            }
        }

        if (bytes(_html).length == 0) {
            return "";
        }

        return string.concat("<div>", _html, "</div>");
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

    function escapeHtml(string memory s) internal pure returns (string memory) {
        bytes memory b = bytes(s);
        bytes memory out = new bytes(b.length * 6);
        uint256 o;
        for (uint256 i = 0; i < b.length; i++) {
            if (b[i] == "<") {
                out[o++] = "&";
                out[o++] = "l";
                out[o++] = "t";
                out[o++] = ";";
            } else if (b[i] == ">") {
                out[o++] = "&";
                out[o++] = "g";
                out[o++] = "t";
                out[o++] = ";";
            } else if (b[i] == "&") {
                out[o++] = "&";
                out[o++] = "a";
                out[o++] = "m";
                out[o++] = "p";
                out[o++] = ";";
            } else {
                out[o++] = b[i];
            }
        }
        assembly {
            mstore(out, o)
        }
        return string(out);
    }
}
