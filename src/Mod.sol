// SPDX-License-Identifier: MIT
pragma solidity >=0.8.30;

import "@openzeppelin/contracts/access/Ownable.sol";
import "solady/utils/SSTORE2.sol";

// @todo Probably I'd call this something more self explanatory that Mod.
contract Mod is Ownable {
    constructor() Ownable(msg.sender) {}

    address private exhibitionText;

    function setText(string memory _text) public onlyOwner {
        exhibitionText = SSTORE2.write(bytes(_text));
    }

    function text() public view returns (string memory) {
        if (exhibitionText == address(0)) {
            return "";
        }
        return string(SSTORE2.read(exhibitionText));
    }

    string[] private exhibitionUrls;

    function setExhibitionUrls(string[] memory _urls) public onlyOwner {
        exhibitionUrls = _urls;
    }

    function urls() public view returns (string[] memory) {
        return exhibitionUrls;
    }

    // @todo This should be called explorerBaseUrl
    string public etherscanBase = "https://etherscan.io/address/";

    function setEtherscanBase(string memory _etherscanBase) public onlyOwner {
        etherscanBase = _etherscanBase;
    }

    string public curator = "Jonooo";

    function setCurator(string memory _curator) public onlyOwner {
        curator = _curator;
    }

    string public curatorUrl = "https://x.com/im_jonooo";

    function setCuratorUrl(string memory _curatorUrl) public onlyOwner {
        curatorUrl = _curatorUrl;
    }

    string public superrare = "SuperRare";

    function setSuperrare(string memory _superrare) public onlyOwner {
        superrare = _superrare;
    }

    string public superrareUrl = "https://superrare.com/curation/exhibitions/intimate-systems";

    function setSuperrareUrl(string memory _superrareUrl) public onlyOwner {
        superrareUrl = _superrareUrl;
    }

    string public thanks = "0xfff";

    function setThanks(string memory _thanks) public onlyOwner {
        thanks = _thanks;
    }

    string public thanksUrl = "https://www.0xfff.love/";

    function setThanksUrl(string memory _thanksUrl) public onlyOwner {
        thanksUrl = _thanksUrl;
    }

    string public thanksShow = "World Computer Sculpture Garden";

    function setThanksShow(string memory _thanksShow) public onlyOwner {
        thanksShow = _thanksShow;
    }

    string public thanksShowUrl = "https://worldcomputersculpture.garden/";

    function setThanksShowUrl(string memory _thanksShowUrl) public onlyOwner {
        thanksShowUrl = _thanksShowUrl;
    }

    string public essayAuthor = "Luke Weaver";

    function setEssayAuthor(string memory _essayAuthor) public onlyOwner {
        essayAuthor = _essayAuthor;
    }

    string public essayAuthorUrl = "https://x.com/lukeweaver_eth";

    function setEssayAuthorUrl(string memory _essayAuthorUrl) public onlyOwner {
        essayAuthorUrl = _essayAuthorUrl;
    }

    string public description =
        "A contract show exploring the quiet, interior spaces within networks designed for visibility.";

    function setDescription(string memory _description) public onlyOwner {
        description = _description;
    }

    function operator() external view returns (address) {
        return owner();
    }
}
