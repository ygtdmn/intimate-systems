// SPDX-License-Identifier: MIT
pragma solidity >=0.8.30;

import { Layout } from "../Layout.sol";
import { WebLib } from "../WebLib.sol";
import { Sculpture } from "../../Sculpture.sol";
import { ContractShow } from "../../ContractShow.sol";
import { Mod } from "../../Mod.sol";
import { LibString } from "solady/utils/LibString.sol";

library IndexPage {
    using LibString for address;
    using LibString for uint256;

    function html(address showAddress, address data) public view returns (string memory) {
        string memory showAddressStr = showAddress.toHexStringChecksummed();
        ContractShow show = ContractShow(showAddress);
        Sculpture[] memory sculptures = show.getSculptures();
        Mod mod = Mod(data);

        string memory heading = string.concat(
            "<h1>",
            show.title(),
            "</h1>"
            "<p>"
            "A contract show curated by "
            '<a href="',
            mod.curatorUrl(),
            '" target="_blank" rel="noopener">',
            mod.curator(),
            "</a>"
            " with "
            '<a href="',
            mod.superrareUrl(),
            '" target="_blank" rel="noopener">',
            mod.superrare(),
            "</a>"
            "</p>"
        );

        (string memory navigation, string memory allWorks) = artworks(sculptures, mod.explorerBase());

        string memory thanks = string.concat(
            "<footer>"
            "<p>"
            "Special thanks to "
            '<a href="',
            mod.thanksUrl(),
            '" target="_blank" rel="noopener">',
            mod.thanks(),
            "</a> "
            "et al. for lighting the path with "
            '<a href="',
            mod.thanksShowUrl(),
            '" target="_blank" rel="noopener">',
            mod.thanksShow(),
            "</a>"
            "</p>"
            "<p>"
            "December 1, 2025 "
            '<a href="',
            mod.explorerBase(),
            showAddressStr,
            '" target="_blank" rel="noopener">',
            showAddressStr,
            "</a>"
            "</p>"
            "</footer>"
        );

        string memory intro = string.concat(
            '<header id="intro">',
            heading,
            "<nav>",
            navigation,
            "</nav>"
            "<p>"
            '<a href="essay">Essay by ',
            mod.essayAuthor(),
            unicode" →</a>",
            "</p>",
            thanks,
            "</header>"
        );

        string memory about = string.concat('<article id="about">', mod.text(), "</article>");

        string memory works = string.concat('<section id="works">', allWorks, "</section>");

        string memory body = string.concat(intro, "<main>", about, works, "</main>");

        string memory pageCss = "body{max-width:780px;margin:0 auto 14em;padding:0.75em}"
        "article footer{display:inline-flex;flex-direction:column;gap:1em}"
        "#intro,#about{min-height:100vh;display:flex;flex-direction:column;justify-content:center}"
        "#intro nav{margin:2.5em 0}"
        "#intro footer{margin-top:1em}"
        "#intro footer > :last-child{font-size:0.8em;margin-top:1em;opacity:0.7}"
        '#intro footer > :last-child a:before{content:"";display:block}'
        "#works>article{padding-top:2em;}"
        "#works>article+article{margin-top:14em;}"
        "#works footer{margin-top:4em;font-size:0.8em}"
        '#works footer a:before{content:"";display:block}'
        "iframe{margin:4em auto}";

        return Layout.html(body, show.title(), mod.description(), pageCss);
    }

    function artworks(
        Sculpture[] memory sculptures,
        string memory explorerBaseUrl
    ) public view returns (string memory navigation, string memory works) {
        for (uint256 i; i < sculptures.length; i++) {
            Sculpture sculpture = sculptures[i];
            string memory artist;
            string memory slug;

            try sculpture.authors() returns (string[] memory authors) {
                if (authors.length > 0 && bytes(authors[0]).length > 0) {
                    artist = authors[0];
                    slug = WebLib.slugify(artist);
                    navigation = string.concat(
                        navigation,
                        (i > 0 ? ", " : ""),
                        '<a href="#',
                        slug,
                        '">',
                        artist,
                        "</a>"
                    );
                }
            } catch {}

            works = string.concat(
                works,
                '<article id="',
                slug,
                '">'
                "<header>",
                artist,
                "<h2>",
                sculpture.title(),
                "</h2>"
                "</header>",
                _renderMedia(i),
                WebLib.formatText(sculpture.text()),
                "<footer>",
                _renderLinks(sculpture),
                "<div>",
                _renderAddresses(sculpture, explorerBaseUrl),
                "</div>",
                "</footer>"
                "</article>"
            );
        }
    }

    function _renderMedia(uint256 index) internal pure returns (string memory) {
        return
            string.concat(
                '<iframe src="/sculpture-media/',
                LibString.toString(index),
                '" sandbox="allow-scripts allow-same-origin" loading="eager" scrolling="no"',
                index == 4 ? ' style="aspect-ratio: 1248/832;"' : "", // custom aspect ratio for Nahiko's Pond
                ">"
                "</iframe>"
            );
    }

    function _renderLinks(Sculpture sculpture) internal view returns (string memory) {
        return WebLib.linksHtmlFor(sculpture, WebLib.firstMimeUrl(sculpture));
    }

    function _renderAddresses(
        Sculpture sculpture,
        string memory explorerBaseUrl
    ) internal view returns (string memory) {
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
            if (all[i] == address(0)) continue;
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
            string memory addr = unique[i].toHexStringChecksummed();
            _html = string.concat(
                _html,
                '<a href="',
                explorerBaseUrl,
                addr,
                '" target="_blank" rel="noopener">',
                addr,
                "</a>"
            );
        }
        return _html;
    }
}
