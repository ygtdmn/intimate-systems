// SPDX-License-Identifier: MIT
pragma solidity >=0.8.30;

import { Layout } from "../Layout.sol";
import { WebLib } from "../WebLib.sol";
import { Sculpture } from "../../Sculpture.sol";
import { ContractShow, ShowSculptures } from "../../ContractShow.sol";
import { Mod } from "../../Mod.sol";
import { IERC721Metadata } from "../../lib/IERC721Metadata.sol";
import { LibString } from "solady/utils/LibString.sol";
import { Base64 } from "solady/utils/Base64.sol";
import { JSONParserLib } from "solady/utils/JSONParserLib.sol";

library IndexPage {
    using LibString for string;
    using LibString for address;
    using LibString for uint256;
    using JSONParserLib for JSONParserLib.Item;
    using JSONParserLib for string;

    function html(address show, address data) public view returns (string memory) {
        string memory showAddress = show.toHexStringChecksummed();

        Sculpture intimateSystems = Sculpture(show);

        ShowSculptures showSculptures = ShowSculptures(show);
        Sculpture[] memory sculptures = showSculptures.getSculptures();

        Mod mod = Mod(data);

        string memory title = string.concat(
            '<h1>',intimateSystems.title(),'</h1>'
            '<p>'
                'A contract show curated by '
                    '<a href="', mod.curatorUrl(),'" target="_blank" rel="noopener">',
                        mod.curator(),
                    '</a>'
                ' with '
                '<a href="', mod.superrareUrl(), '" target="_blank" rel="noopener">',
                    mod.superrare(),
                '</a>'
            '</p>'
        );

        (string memory navigation,,,string memory allWorks) = artworks(sculptures, mod.etherscanBase());

        string memory thanks = string.concat(
            '<footer>'
                '<p>'
                    'Special thanks to '
                        '<a href="',mod.thanksUrl(),'" target="_blank" rel="noopener">',
                            mod.thanks(),
                        '</a> '
                    'et al. for lighting the path with '
                        '<a href="', mod.thanksShowUrl(),'" target="_blank" rel="noopener">',
                            mod.thanksShow(),
                        '</a>'
                '</p>'
                '<p>'
                    'December 1, 2025 '
                    '<a href="',mod.etherscanBase(),showAddress,'" target="_blank" rel="noopener">',
                        showAddress,
                    '</a>'
                '</p>'
            '</footer>'
        );

        string memory intro = string.concat(
            '<header id="intro">',
                title,
                '<nav>',
                    navigation,
                '</nav>'
                '<p>'
                    '<a href="essay">Essay by ',mod.essayAuthor(),unicode' →</a>',
                '</p>',
                thanks,
            '</header>'
        );

        string memory about = string.concat(
            '<article id="about">',
                mod.text(),
            '</article>'
        );

        string memory works = string.concat(
            '<section id="works">',
                allWorks,
            '</section>'
        );

        string memory body = string.concat(
            intro,
            '<main>',
                about,
                works,
            '</main>'
        );

        // @todo In reality the entire css should be passed by the router
        // if we want to allow CSS customization.
        string memory pageCss =
            'body{max-width:780px;margin:0 auto 14em;padding:0.75em}'
            'article footer{display:inline-flex;flex-direction:column;gap:1em}'
            '#intro,#about{min-height:100vh;display:flex;flex-direction:column;justify-content:center}'
            '#intro nav{margin: 2.5em 0}'
            '#intro footer{margin-top:1em}'
            '#intro footer > :last-child{font-size:0.8em;margin-top:1em;opacity:0.7}'
            '#intro footer > :last-child a:before{content:"";display:block}'
            '#works>article+article{margin-top:8em;padding-top:8em;border-top:1px solid var(--border-color)}'
            '#works footer{margin-top:4em;font-size:0.8em}'
            '#works footer a:before{content:"";display:block}'
            'iframe{margin:4em auto}'
        ;

        return Layout.htmlNew(body, intimateSystems.title(), mod.description(), pageCss);
    }


    function artworks(Sculpture[] memory sculptures, string memory explorerBaseUrl) public view returns (
        string memory navigation,
        string[] memory artists,
        string[] memory slugs,
        string memory works
    ) {
        artists = new string[](sculptures.length);
        slugs = new string[](sculptures.length);

        for (uint256 i; i < sculptures.length; i++) {
            string memory artist;
            string memory slug;
            Sculpture sculpture = sculptures[i];

            try sculpture.authors() returns (string[] memory authors) {
                if (authors.length == 0 || bytes(authors[0]).length == 0) {
                    artists[i] = "";
                    slugs[i] = "";
                } else {
                    artist = authors[0];

                    artists[i] = artist;
                    slug = WebLib.slugify(artist);
                    slugs[i] = slug;

                    navigation = string.concat(
                        navigation,
                        (i > 0 ? ', ' : ''),
                        string.concat('<a href="#', slug, '">', artist, "</a>")
                    );
                }
            } catch {}

            string memory addressesLinks = WebLib.addressesForNew(sculpture, explorerBaseUrl);

            works = string.concat(
                works,
                '<article id="',slug,'">'
                    '<header>',
                        artist,
                        '<h2 class="sculpture-title">',
                            sculpture.title(),
                        '</h2>'
                    '</header>',
                    _renderMedia(i),
                    WebLib.formatText(sculpture.text()),
                    '<footer>',
                        _renderLinks(sculpture),
                        '<div>',addressesLinks,'</div>',
                    '</footer>'
                '</article>'
            );
        }

        return (navigation, artists, slugs, works);
    }

    function _renderMedia(uint256 index) internal pure returns (string memory media) {
        media = string.concat(
            '<iframe src="/sculpture-media/',
                LibString.toString(index),
                '" class="token-media token-iframe" sandbox="allow-scripts" loading="lazy" scrolling="no">'
            '</iframe>'
        );
        return media;
    }

    function _renderLinks(Sculpture sculpture) internal view returns (string memory links) {
        string[] memory urls = sculpture.urls();
        string memory url = WebLib.firstMimeUrl(urls);
        string memory links = WebLib.linksHtmlFor(urls, url);
        return WebLib.linksHtmlFor(urls, url);
    }

    // function html_(address show, address data) public view returns (string memory) {
    //     string memory body = string.concat(
    //         _introHtml(show, data),
    //         _aboutHtml(data),
    //         _worksHtml(show, data),
    //         _footerHtml(show, data)
    //     );
    //     string memory description = Mod(data).description();
    //     return Layout.html(body, Sculpture(show).title(), description);
    // }

    // function _introHtml(address show, address data) internal view returns (string memory _html) {
    //     Sculpture[] memory sculptures = WebLib.sortSculpturesByAuthor(ContractShow(show).getSculptures());
    //     string memory artistList = WebLib.artistsList(sculptures);
    //     string memory showAddr = show.toHexStringChecksummed();

    //     _html = string.concat(
    //         '<main class="gallery-flow">',
    //         '<section id="intro" class="intro-section">',
    //         '<h1 class="intro-title">',
    //         Sculpture(show).title(),
    //         "</h1>"
    //     );

    //     _html = string.concat(
    //         _html,
    //         '<p class="intro-subtitle">',
    //         "A contract show curated by ",
    //         '<a href="',
    //         Mod(data).curatorUrl(),
    //         '" target="_blank" rel="noopener">',
    //         Mod(data).curator(),
    //         "</a>",
    //         " with ",
    //         '<a href="',
    //         Mod(data).superrareUrl(),
    //         '" target="_blank" rel="noopener">',
    //         Mod(data).superrare(),
    //         "</a>.",
    //         "</p>"
    //     );

    //     _html = string.concat(
    //         _html,
    //         '<p class="intro-artists">',
    //         artistList,
    //         "</p>",
    //         '<p class="intro-essay"><a href="/essay">Essay by ',
    //         Mod(data).essayAuthor(),
    //         unicode" →</a></p>",
    //         '<p class="intro-thanks">',
    //         "<span>Special thanks to</span> ",
    //         '<a href="',
    //         Mod(data).thanksUrl(),
    //         '" target="_blank" rel="noopener">',
    //         Mod(data).thanks(),
    //         "</a>",
    //         "<span> et al. for lighting the path with</span> ",
    //         '<a href="',
    //         Mod(data).thanksShowUrl(),
    //         '" target="_blank" rel="noopener">',
    //         Mod(data).thanksShow(),
    //         "</a>",
    //         "</p>"
    //     );

    //     _html = string.concat(
    //         _html,
    //         '<p class="intro-meta">',
    //         "<span>December 1, 2025</span>",
    //         '<a href="',
    //         Mod(data).etherscanBase(),
    //         showAddr,
    //         '" target="_blank" rel="noopener">',
    //         showAddr,
    //         "</a>",
    //         "</p>",
    //         "</section>"
    //     );
    // }

    // function _aboutHtml(address data) internal view returns (string memory _html) {
    //     _html = string.concat(
    //         '<section id="about" class="about-section">',
    //         '<div class="about-content">',
    //         Mod(data).text(),
    //         "</div>",
    //         "</section>"
    //     );
    // }

    // function _worksHtml(address show, address data) internal view returns (string memory _html) {
    //     Sculpture[] memory sculptures = WebLib.sortSculpturesByAuthor(ContractShow(show).getSculptures());
    //     _html = string.concat(
    //         '<section id="works" class="works-section">',
    //         '<div id="sculptures" class="sculptures-container">'
    //     );

    //     for (uint256 i = 0; i < sculptures.length; i++) {
    //         _html = _html.concat(_sculptureHtml(sculptures[i], i, data));
    //     }

    //     _html = string.concat(_html, "</div>", "</section>");
    // }

    // function _sculptureHtml(
    //     Sculpture sculpture,
    //     uint256 index,
    //     address data
    // ) internal view returns (string memory _html) {
    //     string memory authorsText = WebLib.authorsTextFor(sculpture);
    //     string memory title = WebLib.titleFor(sculpture);
    //     string memory text = WebLib.formatText(WebLib.textFor(sculpture));
    //     string[] memory urls = WebLib.sculptureUrls(sculpture);
    //     string memory mediaHtml = WebLib.mediaIframe(index);
    //     string memory artworkUrl = WebLib.firstMimeUrl(urls);
    //     string memory linksHtml = WebLib.linksHtmlFor(urls, artworkUrl);
    //     string memory addressesHtml = WebLib.addressesFor(sculpture, data);

    //     _html = string.concat(
    //         '<article class="sculpture" id="',
    //         WebLib.slugify(WebLib.primaryAuthor(sculpture)),
    //         '">',
    //         '<div class="sculpture-header">',
    //         '<div class="sculpture-authors">',
    //         authorsText,
    //         "</div>",
    //         '<h2 class="sculpture-title">',
    //         title,
    //         "</h2>",
    //         "</div>",
    //         '<div class="sculpture-media">',
    //         mediaHtml,
    //         "</div>",
    //         '<div class="sculpture-text">'
    //     );

    //     _html = string.concat(
    //         _html,
    //         text,
    //         linksHtml,
    //         '<div class="sculpture-footer">',
    //         addressesHtml,
    //         "</div>",
    //         "</div>",
    //         "</article>"
    //     );
    // }

    // function _footerHtml(address show, address data) internal view returns (string memory _html) {
    //     string memory showAddr = show.toHexStringChecksummed();
    //     _html = string.concat(
    //         '<footer class="footer-section">',
    //         '<div class="footer-content">',
    //         '<div class="project-info">',
    //         "<p>Generated in block ",
    //         block.number.toString(),
    //         " from ",
    //         '<a href="',
    //         Mod(data).etherscanBase(),
    //         showAddr,
    //         '" target="_blank" rel="noopener">',
    //         showAddr,
    //         "</a>",
    //         "</p>",
    //         "</div>",
    //         "</div>",
    //         "</footer>",
    //         "</main>"
    //     );
    // }
}
