// SPDX-License-Identifier: MIT

pragma solidity ^0.8.28;

import "@openzeppelin/contracts/access/Ownable.sol";

interface IUser {
    struct UserStruct {
        string name;
        string email;
    }

    function getUser(
        address _address
    ) external view returns (UserStruct memory);
}

contract CrowdFund is Ownable {
    // INTERFACE
    IUser public userContract;

    // EVENT
    event CampaignCreated(
        address indexed creator,
        uint indexed campaignId,
        string _nameCampaign,
        string _description,
        uint _targetFund,
        uint _deadline
    );
    
    event CampaignUpdated(
        uint indexed campaignId,
        string _nameCampaign,
        string _description,
        uint _targetFund,
        uint _deadline
    );

    // STRUCT
    struct CrowdFundStruct {
        address creator;
        uint campaignId;
        string nameCampaign;
        string description;
        uint targetFund;
        uint currentFund;
        uint deadline;
    }

    // MAPPING
    mapping(address => CrowdFundStruct[]) public crowdFunds;

    // CONSTRUCTOR
    constructor(address _userContract) Ownable(msg.sender) {
        // Initialize the contract with the owner
        userContract = IUser(_userContract);
    }

    // MODIFIER
    modifier onlyRegister() {
        IUser.UserStruct memory user = userContract.getUser(msg.sender);
        require(bytes(user.name).length > 0, "User not registered");
        _;
    }

    // FUNCTION MEMBUAT CAMPAIGN BARU
    function createCampaign(
        string memory _nameCampaign,
        string memory _description,
        uint _targetFund,
        uint _deadline
    ) public onlyRegister {
        require(_deadline > block.timestamp, "Deadline must be in the future");

        uint campaignId = crowdFunds[msg.sender].length + 1;

        CrowdFundStruct memory newCampaign = CrowdFundStruct({
            creator: msg.sender,
            campaignId: campaignId,
            nameCampaign: _nameCampaign,
            description: _description,
            targetFund: _targetFund,
            currentFund: 0,
            deadline: _deadline
        });

        crowdFunds[msg.sender].push(newCampaign);

        emit CampaignCreated(
            msg.sender,
            campaignId,
            _nameCampaign,
            _description,
            _targetFund,
            _deadline
        );
    }

    // FUNCTION UPDATE CAMPAIGN
    function updateCampaign(
        uint _campaignId,
        string memory _nameCampaign,
        string memory _description,
        uint _targetFund,
        uint _deadline
    ) public onlyRegister {
        require(_campaignId > 0, "Parameter Campaign ID not found!!");

        CrowdFundStruct[] storage campaigns = crowdFunds[msg.sender];

        bool campaignFound = false;
        for (uint256 index = 0; index < campaigns.length; index++) {
            if (campaigns[index].campaignId == _campaignId) {
                if (bytes(_nameCampaign).length > 0) {
                    campaigns[index].nameCampaign = _nameCampaign;
                }
                if (bytes(_description).length > 0) {
                    campaigns[index].description = _description;
                }
                if (_targetFund > 0) {
                    campaigns[index].targetFund = _targetFund;
                }
                if (_deadline > 0) {
                    campaigns[index].deadline = _deadline;
                }
                campaignFound = true;
                break;
            }
        }

        require(campaignFound, "Campaign with this ID does not exist!");

        emit CampaignUpdated(
            _campaignId,
            _nameCampaign,
            _description,
            _targetFund,
            _deadline
        );
    }
}
