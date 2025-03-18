// SPDX-License-Identifier: MIT

pragma solidity ^0.8.28;

contract User {
    
    struct UserStruct {
        string name;
        string email;
    }

    mapping(address => UserStruct) internal users;

    function setUser(string memory _name, string memory _email) public {
        users[msg.sender] = UserStruct({
            name: _name,
            email: _email
        });
    }

    function getUser(address _address) public view returns (UserStruct memory) {
        return users[_address];
    }

}