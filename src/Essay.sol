// SPDX-License-Identifier: MIT
pragma solidity >=0.8.30;

import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { SSTORE2 } from "solady/utils/SSTORE2.sol";
import { Sculpture } from "./Sculpture.sol";

contract Essay is Sculpture, Ownable {
    address private pointer1;
    address private pointer2;
    string private t;
    string private a = "Luke Weaver";
    string[] private u;

    constructor() Ownable(msg.sender) {}

    function title() external view returns (string memory) {
        return t;
    }

    function authors() public view returns (string[] memory authors_) {
        authors_ = new string[](1);
        authors_[0] = a;
        return authors_;
    }

    function addresses() external view returns (address[] memory) {
        address[] memory _addresses = new address[](1);
        _addresses[0] = address(this);
        return _addresses;
    }

    function urls() external view returns (string[] memory) {
        return u;
    }

    function text() external view returns (string memory) {
        if (pointer1 == address(0)) {
            return "";
        }
        return
            string.concat(string(SSTORE2.read(pointer1)), pointer2 == address(0) ? "" : string(SSTORE2.read(pointer2)));
    }

    function setTitle(string memory _title) external onlyOwner {
        t = _title;
    }

    function setAuthor(string memory _author) external onlyOwner {
        a = _author;
    }

    function setUrls(string[] memory _urls) external onlyOwner {
        u = _urls;
    }

    function setTextPt1(string memory _text) external onlyOwner {
        pointer1 = SSTORE2.write(bytes(_text));
    }

    function setTextPt2(string memory _text) external onlyOwner {
        pointer2 = SSTORE2.write(bytes(_text));
    }

    /// @notice Returns the full HTML representation of the essay
    function html() external view returns (string memory _html) {
        string memory essayContent = pointer1 == address(0)
            ? ""
            : string.concat(
                string(SSTORE2.read(pointer1)),
                pointer2 == address(0) ? "" : string(SSTORE2.read(pointer2))
            );

        _html = string.concat(
            "<header>",
            "<h1>",
            t,
            "</h1>",
            "<address><i>Written by ",
            authors()[0],
            "</i></address>",
            "</header>",
            "<section>",
            essayContent,
            "</section>"
        );
    }
}
