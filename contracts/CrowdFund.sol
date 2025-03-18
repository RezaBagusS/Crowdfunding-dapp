// SPDX-License-Identifier: MIT

pragma solidity ^0.8.28;

import "@openzeppelin/contracts/access/Ownable.sol";

contract CrowdFund is Ownable {

    constructor() Ownable(msg.sender) {
        // Initialize the contract with the owner
    }

}