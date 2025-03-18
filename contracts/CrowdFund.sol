// SPDX-License-Identifier: MIT

pragma solidity ^0.8.28;

import "@openzeppelin/contracts/access/Ownable.sol";

interface IUser {
    struct UserStruct {
        string name;
        string email;
    }

    function getUser(address _address) external view returns (UserStruct memory);
}

contract CrowdFund is Ownable {

    IUser public userContract;

    constructor(address _userContract) Ownable(msg.sender) {
        // Initialize the contract with the owner
        userContract = IUser(_userContract);
    }

}