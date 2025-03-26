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

    event CampaignDeleted(uint indexed _campaignId);

    // STRUCT
    struct CrowdFundStruct {
        address creator;
        uint campaignId;
        string nameCampaign;
        string description;
        uint targetFund;
        uint currentFund;
        uint deadline;
        DonationDetailStruct[] donations;
    }

    struct DonationDetailStruct {
        address donatur;
        uint amount;
        uint payAt;
    }
    struct CampaignSummary {
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
    address[] public creators;

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

    // FUNCTION GET ALL CAMPAIGN by CREATOR
    function getAllCampaignByCreator(
        uint _page,
        uint _perPage
    ) public view onlyRegister returns (CampaignSummary[] memory) {
        CrowdFundStruct[] storage campaigns = crowdFunds[msg.sender];
        uint totalCampaigns = campaigns.length;

        uint start = _page * _perPage;
        if (start >= totalCampaigns) {
            return new CampaignSummary[](0);
        }
        uint end = start + _perPage > totalCampaigns
            ? totalCampaigns
            : start + _perPage;

        CampaignSummary[] memory result = new CampaignSummary[](end - start);

        for (uint256 i = start; i < end; i++) {
            result[i - start] = CampaignSummary({
                creator: campaigns[i].creator,
                campaignId: campaigns[i].campaignId,
                nameCampaign: campaigns[i].nameCampaign,
                description: campaigns[i].description,
                targetFund: campaigns[i].targetFund,
                currentFund: campaigns[i].currentFund,
                deadline: campaigns[i].deadline
            });
        }

        return result;
    }

    // Fungsi untuk mendapatkan total jumlah kampanye by creator (frontend)
    function getTotalCampaignsByCreator()
        public
        view
        onlyRegister
        returns (uint)
    {
        return crowdFunds[msg.sender].length;
    }

    // FUNCTION GET ALL CAMPAIGN for PUBLIC
    function getAllCampaign(
        uint _page,
        uint _perPage
    ) public view returns (CrowdFundStruct[] memory) {
        uint totalCampaigns = 0;
        for (uint256 i = 0; i < creators.length; i++) {
            totalCampaigns += crowdFunds[creators[i]].length;
        }

        uint start = _page * _perPage;
        if (start >= totalCampaigns) {
            return new CrowdFundStruct[](0); 
        }
        uint end = start + _perPage > totalCampaigns
            ? totalCampaigns
            : start + _perPage;

        CrowdFundStruct[] memory result = new CrowdFundStruct[](end - start);

        uint currentIndex = 0;
        uint resultIndex = 0;

        for (
            uint256 i = 0;
            i < creators.length && resultIndex < result.length;
            i++
        ) {
            address creator = creators[i];
            for (
                uint256 j = 0;
                j < crowdFunds[creator].length && resultIndex < result.length;
                j++
            ) {
                if (currentIndex >= start && currentIndex < end) {
                    result[resultIndex] = crowdFunds[creator][j];
                    resultIndex++;
                }
                currentIndex++;
            }
        }

        return result;
    }

    // Fungsi untuk mendapatkan total jumlah kampanye (frontend)
    function getTotalCampaigns() public view returns (uint) {
        uint total = 0;
        for (uint256 i = 0; i < creators.length; i++) {
            total += crowdFunds[creators[i]].length;
        }
        return total;
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

        crowdFunds[msg.sender].push();
        CrowdFundStruct storage newCampaign = crowdFunds[msg.sender][
            crowdFunds[msg.sender].length - 1
        ];

        newCampaign.creator = msg.sender;
        newCampaign.campaignId = campaignId;
        newCampaign.nameCampaign = _nameCampaign;
        newCampaign.description = _description;
        newCampaign.targetFund = _targetFund;
        newCampaign.currentFund = 0;
        newCampaign.deadline = _deadline;

        if (crowdFunds[msg.sender].length == 1) {
            creators.push(msg.sender);
        }

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

    // FUNCTION DELETE CAMPAIGN
    function deleteCampaign(uint _campaignId) public onlyRegister {
        require(_campaignId > 0, "Campaign ID Not Found");

        CrowdFundStruct[] storage campaigns = crowdFunds[msg.sender];
        bool found = false;

        for (uint256 i = 0; i < campaigns.length; i++) {
            if (campaigns[i].campaignId == _campaignId) {
                found = true;

                for (uint256 j = i; j < campaigns.length - 1; j++) {
                    campaigns[j] = campaigns[j + 1];
                }

                campaigns.pop();
                break;
            }
        }

        emit CampaignDeleted(_campaignId);
    }

    //  **Donasi**:
    //  - Pengguna dapat mendonasikan ETH ke kampanye tertentu.
    //  - Donasi hanya diterima jika kampanye belum melewati batas waktu.
    //  - Catat jumlah total donasi dan daftar donatur (opsional: simpan alamat donatur dan jumlah donasi).

    // function donate(
    //     uint _campaignId,
    //     uint _amount
    // ) public payable {
    //     require(_amount > );

    // }
}
